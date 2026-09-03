<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Api\AttendeeRequest;
use App\Models\Attendee;
use App\Models\CheckIn;
use App\Models\Event;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AttendeeController extends ApiController
{
    public function index(Event $event): JsonResponse
    {
        return $this->ok('Attendees retrieved.', $event->attendees()->latest()->get());
    }

    public function me(Request $request, Event $event): JsonResponse
    {
        $attendee = $event->attendees()->where('user_id', $request->user()->id)->first();

        if (! $attendee) {
            return $this->fail('No attendee record is linked to your account for this event.', null, 404);
        }

        return $this->ok('Attendee profile retrieved.', $attendee->load('mealVouchers.category'));
    }

    public function store(AttendeeRequest $request, Event $event): JsonResponse
    {
        $attendee = $event->attendees()->create($request->validated() + [
            'ticket_code' => $request->input('ticket_code', 'TICKET-'.Str::upper(Str::random(10))),
            'qr_token' => $request->input('qr_token', 'ATT-'.Str::uuid()),
        ]);

        if ($attendee->user_id) {
            $event->users()->syncWithoutDetaching([$attendee->user_id => ['role' => 'attendee']]);
        }

        return $this->ok('Attendee created.', $attendee, 201);
    }

    public function show(Event $event, Attendee $attendee): JsonResponse
    {
        if ($attendee->event_id !== $event->id) {
            return $this->fail('Attendee does not belong to this event.', null, 404);
        }

        return $this->ok('Attendee retrieved.', $attendee->load('mealVouchers.category'));
    }

    public function update(AttendeeRequest $request, Event $event, Attendee $attendee): JsonResponse
    {
        if ($attendee->event_id !== $event->id) {
            return $this->fail('Attendee does not belong to this event.', null, 404);
        }

        $attendee->update($request->validated());

        return $this->ok('Attendee updated.', $attendee->fresh());
    }

    public function destroy(Event $event, Attendee $attendee): JsonResponse
    {
        if ($attendee->event_id !== $event->id) {
            return $this->fail('Attendee does not belong to this event.', null, 404);
        }

        $attendee->delete();

        return $this->ok('Attendee deleted.');
    }

    public function checkIn(Request $request, Event $event, Attendee $attendee): JsonResponse
    {
        if ($attendee->event_id !== $event->id) {
            return $this->fail('Attendee does not belong to this event.', null, 404);
        }

        return DB::transaction(function () use ($request, $event, $attendee) {
            if ($attendee->checked_in_at) {
                return $this->ok('Attendee was already checked in.', ['duplicate' => true, 'attendee' => $attendee]);
            }

            $now = now();
            $attendee->update(['checked_in_at' => $now]);
            CheckIn::query()->create([
                'event_id' => $event->id,
                'attendee_id' => $attendee->id,
                'checked_in_by' => $request->user()->id,
                'method' => 'manual',
                'checked_in_at' => $now,
            ]);

            return $this->ok('Attendee checked in successfully.', ['duplicate' => false, 'attendee' => $attendee->fresh()]);
        });
    }

    public function scan(Request $request, Event $event): JsonResponse
    {
        $data = $request->validate(['qr_token' => ['required', 'string']]);
        $attendee = $event->attendees()->where('qr_token', $data['qr_token'])->first();

        if (! $attendee) {
            return $this->fail('Invalid attendee QR token.', ['qr_token' => ['No attendee found for this event.']], 404);
        }

        return DB::transaction(function () use ($request, $event, $attendee) {
            if ($attendee->checked_in_at) {
                return $this->ok('Attendee was already checked in.', ['duplicate' => true, 'attendee' => $attendee]);
            }

            $now = now();
            $attendee->update(['checked_in_at' => $now]);
            CheckIn::query()->create([
                'event_id' => $event->id,
                'attendee_id' => $attendee->id,
                'checked_in_by' => $request->user()->id,
                'method' => 'qr',
                'checked_in_at' => $now,
            ]);

            return $this->ok('Attendee checked in successfully.', ['duplicate' => false, 'attendee' => $attendee->fresh()]);
        });
    }
}
