<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Api\SessionRequest;
use App\Http\Requests\Api\SessionScanRequest;
use App\Models\ConferenceSession;
use App\Models\Event;
use App\Models\EventNotification;
use App\Services\FirebaseNotificationService;
use App\Services\NotificationDispatchService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class SessionController extends ApiController
{
    public function index(Event $event): JsonResponse
    {
        return $this->ok('Sessions retrieved.', $event->sessions()->withCount('attendance')->get());
    }

    public function store(SessionRequest $request, Event $event): JsonResponse
    {
        return $this->ok('Session created.', $event->sessions()->create($request->validated()), 201);
    }

    public function show(Event $event, ConferenceSession $session): JsonResponse
    {
        return $session->event_id === $event->id ? $this->ok('Session retrieved.', $session->loadCount('attendance')) : $this->fail('Session not found for this event.', null, 404);
    }

    public function update(SessionRequest $request, Event $event, ConferenceSession $session): JsonResponse
    {
        if ($session->event_id !== $event->id) {
            return $this->fail('Session not found for this event.', null, 404);
        }

        $session->update($request->validated());

        return $this->ok('Session updated.', $session->fresh());
    }

    public function destroy(Event $event, ConferenceSession $session): JsonResponse
    {
        if ($session->event_id !== $event->id) {
            return $this->fail('Session not found for this event.', null, 404);
        }

        $session->delete();

        return $this->ok('Session deleted.');
    }

    public function scan(SessionScanRequest $request, Event $event, ConferenceSession $session, FirebaseNotificationService $firebase, NotificationDispatchService $dispatch): JsonResponse
    {
        if ($session->event_id !== $event->id) {
            return $this->fail('Session not found for this event.', null, 404);
        }

        $result = DB::transaction(function () use ($request, $event, $session) {
            $attendee = $request->filled('attendee_id')
                ? $event->attendees()->whereKey($request->integer('attendee_id'))->first()
                : $event->attendees()->where('qr_token', $request->string('attendee_qr_token'))->first();

            if (! $attendee) {
                return ['response' => $this->fail('Attendee not found for this event.', null, 404)];
            }

            $existing = $session->attendance()->where('attendee_id', $attendee->id)->first();
            if ($existing) {
                return ['response' => $this->fail('Attendee has already checked into this session.', ['duplicate' => true], 409)];
            }

            $attendance = $session->attendance()->create([
                'event_id' => $event->id,
                'attendee_id' => $attendee->id,
                'checked_in_by' => $request->user()->id,
                'device_id' => $request->input('device_id'),
                'checked_in_at' => now(),
            ]);

            return ['attendance' => $attendance, 'count' => $session->attendance()->count()];
        });

        if (isset($result['response'])) {
            return $result['response'];
        }

        $count = $result['count'];
        // The alert is dispatched after the transaction commits so a push
        // is never sent for attendance that ends up rolled back.
        $this->alertOrganisersOnCapacityTransition($event, $session, $count, $request->user()->id, $firebase, $dispatch);

        return $this->ok('Session attendance recorded.', [
            'attendance' => $result['attendance'],
            'capacity_status' => $this->capacityStatus($count, $session->capacity),
            'warning' => $count > $session->capacity ? 'Session capacity exceeded.' : null,
        ]);
    }

    public function attendance(Event $event, ConferenceSession $session): JsonResponse
    {
        if ($session->event_id !== $event->id) {
            return $this->fail('Session not found for this event.', null, 404);
        }

        return $this->ok('Session attendance retrieved.', $session->attendance()->with('attendee')->get());
    }

    private function capacityStatus(int $count, int $capacity): string
    {
        return $count > $capacity ? 'over_capacity' : ($count === $capacity ? 'full' : 'available');
    }

    /**
     * Push an alert to the event's organisers when a session crosses its
     * warning threshold (default 90% of capacity) or exceeds capacity.
     * Each alert fires exactly once because attendance only grows.
     */
    private function alertOrganisersOnCapacityTransition(Event $event, ConferenceSession $session, int $count, int $sentBy, FirebaseNotificationService $firebase, NotificationDispatchService $dispatch): void
    {
        $capacity = $session->capacity;
        if ($capacity <= 0) {
            return;
        }

        $warningAt = max(1, (int) ceil($capacity * (float) config('conference.capacity_warning_threshold', 0.9)));
        $previous = $count - 1;

        if ($previous < $warningAt && $count >= $warningAt && $count <= $capacity) {
            $title = 'Session filling up';
            $message = "{$session->title} has reached {$count} of {$capacity} seats.";
        } elseif ($previous <= $capacity && $count > $capacity) {
            $title = 'Session over capacity';
            $message = "{$session->title} has exceeded capacity ({$count}/{$capacity}).";
        } else {
            return;
        }

        $notification = EventNotification::query()->create([
            'event_id' => $event->id,
            'title' => $title,
            'message' => $message,
            'target_type' => 'organisers',
            'target_session_id' => $session->id,
            'sent_by' => $sentBy,
            'status' => 'draft',
        ]);

        $dispatch->deliver($notification, $dispatch->resolveRecipients($event, 'organisers', null), $firebase);
    }
}
