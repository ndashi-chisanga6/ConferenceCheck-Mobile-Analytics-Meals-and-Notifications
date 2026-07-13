<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Api\AttendeeRequest;
use App\Http\Requests\Api\DeviceTokenRequest;
use App\Http\Requests\Api\MealCategoryRequest;
use App\Http\Requests\Api\MealVoucherGenerateRequest;
use App\Http\Requests\Api\MealVoucherScanRequest;
use App\Http\Requests\Api\NotificationSendRequest;
use App\Http\Requests\Api\SessionRequest;
use App\Http\Requests\Api\SessionScanRequest;
use App\Models\Attendee;
use App\Models\CheckIn;
use App\Models\ConferenceSession;
use App\Models\DeviceToken;
use App\Models\Event;
use App\Models\EventNotification;
use App\Models\MealCategory;
use App\Models\MealRedemption;
use App\Models\MealVoucher;
use App\Models\NotificationRecipient;
use App\Services\FirebaseNotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ConferenceController extends ApiController
{
    public function attendees(Event $event): JsonResponse
    {
        return $this->ok('Attendees retrieved.', $event->attendees()->latest()->get());
    }

    public function myAttendee(Request $request, Event $event): JsonResponse
    {
        $attendee = $event->attendees()->where('user_id', $request->user()->id)->first();

        if (! $attendee) {
            return $this->fail('No attendee record is linked to your account for this event.', null, 404);
        }

        return $this->ok('Attendee profile retrieved.', $attendee->load('mealVouchers.category'));
    }

    public function storeAttendee(AttendeeRequest $request, Event $event): JsonResponse
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

    public function showAttendee(Event $event, Attendee $attendee): JsonResponse
    {
        if ($attendee->event_id !== $event->id) {
            return $this->fail('Attendee does not belong to this event.', null, 404);
        }

        return $this->ok('Attendee retrieved.', $attendee->load('mealVouchers.category'));
    }

    public function updateAttendee(AttendeeRequest $request, Event $event, Attendee $attendee): JsonResponse
    {
        if ($attendee->event_id !== $event->id) {
            return $this->fail('Attendee does not belong to this event.', null, 404);
        }

        $attendee->update($request->validated());

        return $this->ok('Attendee updated.', $attendee->fresh());
    }

    public function deleteAttendee(Event $event, Attendee $attendee): JsonResponse
    {
        if ($attendee->event_id !== $event->id) {
            return $this->fail('Attendee does not belong to this event.', null, 404);
        }

        $attendee->delete();

        return $this->ok('Attendee deleted.');
    }

    public function checkInAttendee(Request $request, Event $event, Attendee $attendee): JsonResponse
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

    public function scanAttendee(Request $request, Event $event): JsonResponse
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

    public function analyticsSummary(Event $event): JsonResponse
    {
        $totalAttendees = $event->attendees()->count();
        $checkedIn = $event->attendees()->whereNotNull('checked_in_at')->count();
        $totalVouchers = $event->mealVouchers()->count();
        $redeemedVouchers = $event->mealVouchers()->where('status', 'redeemed')->count();
        $sessions = $event->sessions()->withCount('attendance')->get();

        return $this->ok('Analytics summary retrieved.', [
            'total_attendees' => $totalAttendees,
            'checked_in_attendees' => $checkedIn,
            'check_in_percentage' => $totalAttendees ? round(($checkedIn / $totalAttendees) * 100, 2) : 0,
            'total_meal_vouchers' => $totalVouchers,
            'redeemed_meal_vouchers' => $redeemedVouchers,
            'meal_redemption_percentage' => $totalVouchers ? round(($redeemedVouchers / $totalVouchers) * 100, 2) : 0,
            'total_sessions' => $sessions->count(),
            'total_session_attendance' => $sessions->sum('attendance_count'),
            'overcrowded_sessions_count' => $sessions->filter(fn ($session) => $session->attendance_count > $session->capacity)->count(),
            'notifications_sent' => EventNotification::query()->where('event_id', $event->id)->where('status', 'sent')->count(),
        ]);
    }

    public function analyticsCheckIns(Event $event): JsonResponse
    {
        $rows = CheckIn::query()->where('event_id', $event->id)->get()
            ->groupBy(fn (CheckIn $checkIn): string => Carbon::parse($checkIn->checked_in_at)->format('Y-m-d H:00'))
            ->map(fn ($items, string $period) => ['period' => $period, 'count' => $items->count()])
            ->values();

        return $this->ok('Check-in analytics retrieved.', $rows);
    }

    public function analyticsMeals(Event $event): JsonResponse
    {
        $rows = MealCategory::query()->where('event_id', $event->id)->withCount(['vouchers as redemption_count' => fn ($query) => $query->where('status', 'redeemed')])->get();

        return $this->ok('Meal analytics retrieved.', $rows->map(fn ($category) => [
            'meal_category_id' => $category->id,
            'name' => $category->name,
            'redeemed_count' => $category->redemption_count,
        ]));
    }

    public function analyticsSessions(Event $event): JsonResponse
    {
        $rows = $event->sessions()->withCount('attendance')->get()->map(fn ($session) => [
            'session_id' => $session->id,
            'title' => $session->title,
            'capacity' => $session->capacity,
            'attendance_total' => $session->attendance_count,
            'percentage_full' => $session->capacity ? round(($session->attendance_count / $session->capacity) * 100, 2) : 0,
            'capacity_status' => $session->attendance_count > $session->capacity ? 'over_capacity' : ($session->attendance_count === $session->capacity ? 'full' : 'available'),
        ]);

        return $this->ok('Session analytics retrieved.', $rows);
    }

    public function mealCategories(Event $event): JsonResponse
    {
        return $this->ok('Meal categories retrieved.', $event->mealCategories()->get());
    }

    public function storeMealCategory(MealCategoryRequest $request, Event $event): JsonResponse
    {
        return $this->ok('Meal category created.', $event->mealCategories()->create($request->validated()), 201);
    }

    public function showMealCategory(Event $event, MealCategory $mealCategory): JsonResponse
    {
        return $mealCategory->event_id === $event->id ? $this->ok('Meal category retrieved.', $mealCategory) : $this->fail('Meal category not found for this event.', null, 404);
    }

    public function updateMealCategory(MealCategoryRequest $request, Event $event, MealCategory $mealCategory): JsonResponse
    {
        if ($mealCategory->event_id !== $event->id) {
            return $this->fail('Meal category not found for this event.', null, 404);
        }

        $mealCategory->update($request->validated());

        return $this->ok('Meal category updated.', $mealCategory->fresh());
    }

    public function deleteMealCategory(Event $event, MealCategory $mealCategory): JsonResponse
    {
        if ($mealCategory->event_id !== $event->id) {
            return $this->fail('Meal category not found for this event.', null, 404);
        }

        $mealCategory->delete();

        return $this->ok('Meal category deleted.');
    }

    public function generateMealVouchers(MealVoucherGenerateRequest $request, Event $event): JsonResponse
    {
        $category = $event->mealCategories()->whereKey($request->integer('meal_category_id'))->first();

        if (! $category) {
            return $this->fail('Meal category does not belong to this event.', null, 422);
        }

        $attendees = $event->attendees()
            ->when($request->filled('attendee_ids'), fn ($query) => $query->whereIn('id', $request->input('attendee_ids')))
            ->get();

        $created = 0;
        foreach ($attendees as $attendee) {
            $voucher = MealVoucher::query()->firstOrCreate(
                ['attendee_id' => $attendee->id, 'meal_category_id' => $category->id],
                ['event_id' => $event->id, 'qr_token' => 'MEAL-'.Str::uuid(), 'status' => 'unused']
            );
            $created += $voucher->wasRecentlyCreated ? 1 : 0;
        }

        return $this->ok('Meal vouchers generated.', ['created' => $created, 'total_attendees' => $attendees->count()]);
    }

    public function mealVouchers(Event $event): JsonResponse
    {
        return $this->ok('Meal vouchers retrieved.', $event->mealVouchers()->with(['attendee', 'category'])->latest()->get());
    }

    public function showMealVoucher(Event $event, MealVoucher $mealVoucher): JsonResponse
    {
        return $mealVoucher->event_id === $event->id ? $this->ok('Meal voucher retrieved.', $mealVoucher->load(['attendee', 'category'])) : $this->fail('Meal voucher not found for this event.', null, 404);
    }

    public function scanMealVoucher(MealVoucherScanRequest $request, Event $event): JsonResponse
    {
        return DB::transaction(function () use ($request, $event) {
            $voucher = MealVoucher::query()->where('qr_token', $request->string('qr_token'))->lockForUpdate()->first();

            if (! $voucher || $voucher->event_id !== $event->id) {
                return $this->fail('Invalid meal voucher QR token.', ['qr_token' => ['Voucher not found for this event.']], 404);
            }

            $category = MealCategory::query()->find($voucher->meal_category_id);
            $now = now();

            if ($voucher->status !== 'unused') {
                return $this->fail('Meal voucher has already been redeemed or is not usable.', ['status' => $voucher->status], 409);
            }
            if (! $category || $category->status !== 'active') {
                return $this->fail('Meal category is not active.', null, 422);
            }
            if (($category->starts_at && $now->lt($category->starts_at)) || ($category->ends_at && $now->gt($category->ends_at))) {
                return $this->fail('Meal voucher is outside the redemption window.', null, 422);
            }

            $voucher->update(['status' => 'redeemed', 'redeemed_at' => $now, 'redeemed_by' => $request->user()->id]);
            $redemption = MealRedemption::query()->create([
                'event_id' => $event->id,
                'meal_voucher_id' => $voucher->id,
                'attendee_id' => $voucher->attendee_id,
                'meal_category_id' => $voucher->meal_category_id,
                'redeemed_by' => $request->user()->id,
                'redeemed_at' => $now,
                'device_id' => $request->input('device_id'),
            ]);

            return $this->ok('Meal voucher redeemed successfully.', ['voucher' => $voucher->fresh(['attendee', 'category']), 'redemption' => $redemption]);
        });
    }

    public function mealRedemptions(Event $event): JsonResponse
    {
        return $this->ok('Meal redemptions retrieved.', MealRedemption::query()->where('event_id', $event->id)->latest()->get());
    }

    public function sessions(Event $event): JsonResponse
    {
        return $this->ok('Sessions retrieved.', $event->sessions()->withCount('attendance')->get());
    }

    public function storeSession(SessionRequest $request, Event $event): JsonResponse
    {
        return $this->ok('Session created.', $event->sessions()->create($request->validated()), 201);
    }

    public function showSession(Event $event, ConferenceSession $session): JsonResponse
    {
        return $session->event_id === $event->id ? $this->ok('Session retrieved.', $session->loadCount('attendance')) : $this->fail('Session not found for this event.', null, 404);
    }

    public function updateSession(SessionRequest $request, Event $event, ConferenceSession $session): JsonResponse
    {
        if ($session->event_id !== $event->id) {
            return $this->fail('Session not found for this event.', null, 404);
        }

        $session->update($request->validated());

        return $this->ok('Session updated.', $session->fresh());
    }

    public function deleteSession(Event $event, ConferenceSession $session): JsonResponse
    {
        if ($session->event_id !== $event->id) {
            return $this->fail('Session not found for this event.', null, 404);
        }

        $session->delete();

        return $this->ok('Session deleted.');
    }

    public function scanSession(SessionScanRequest $request, Event $event, ConferenceSession $session, FirebaseNotificationService $firebase): JsonResponse
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
        $this->alertOrganisersOnCapacityTransition($event, $session, $count, $request->user()->id, $firebase);

        return $this->ok('Session attendance recorded.', [
            'attendance' => $result['attendance'],
            'capacity_status' => $this->capacityStatus($count, $session->capacity),
            'warning' => $count > $session->capacity ? 'Session capacity exceeded.' : null,
        ]);
    }

    public function sessionAttendance(Event $event, ConferenceSession $session): JsonResponse
    {
        if ($session->event_id !== $event->id) {
            return $this->fail('Session not found for this event.', null, 404);
        }

        return $this->ok('Session attendance retrieved.', $session->attendance()->with('attendee')->get());
    }

    public function storeDeviceToken(DeviceTokenRequest $request): JsonResponse
    {
        $token = DeviceToken::query()->updateOrCreate(
            ['token' => $request->string('token')->toString()],
            ['user_id' => $request->user()->id, 'platform' => $request->string('platform')->toString(), 'last_used_at' => now()]
        );

        return $this->ok('Device token saved.', $token);
    }

    public function deleteDeviceToken(Request $request, DeviceToken $deviceToken): JsonResponse
    {
        if ($deviceToken->user_id !== $request->user()->id && $request->user()->role !== 'organiser') {
            return $this->fail('You cannot delete this device token.', null, 403);
        }

        $deviceToken->delete();

        return $this->ok('Device token deleted.');
    }

    public function notifications(Event $event): JsonResponse
    {
        return $this->ok('Notifications retrieved.', EventNotification::query()->where('event_id', $event->id)->withCount('recipients')->latest()->get());
    }

    public function sendNotification(NotificationSendRequest $request, Event $event, FirebaseNotificationService $firebase): JsonResponse
    {
        return DB::transaction(function () use ($request, $event, $firebase) {
            $notification = EventNotification::query()->create($request->validated() + [
                'event_id' => $event->id,
                'sent_by' => $request->user()->id,
                'status' => 'draft',
            ]);

            $recipients = $this->resolveNotificationRecipients($event, $request->string('target_type')->toString(), $request->integer('target_session_id') ?: null);
            $result = $this->deliverNotification($notification, $recipients, $firebase);

            return $this->ok('Notification sent.', ['notification' => $notification->fresh('recipients'), 'firebase' => $result]);
        });
    }

    public function showNotification(Event $event, EventNotification $notification): JsonResponse
    {
        return $notification->event_id === $event->id ? $this->ok('Notification retrieved.', $notification->load('recipients')) : $this->fail('Notification not found for this event.', null, 404);
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
    private function alertOrganisersOnCapacityTransition(Event $event, ConferenceSession $session, int $count, int $sentBy, FirebaseNotificationService $firebase): void
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

        $this->deliverNotification($notification, $this->resolveNotificationRecipients($event, 'organisers', null), $firebase);
    }

    /**
     * Create per-recipient delivery records, send via Firebase, and record
     * the outcome on the notification and every recipient row.
     *
     * @param  array<int, array{user_id: int|null, attendee_id: int|null}>  $recipients
     * @return array{success: bool, demo: bool, sent_count: int, failed_count: int}
     */
    private function deliverNotification(EventNotification $notification, array $recipients, FirebaseNotificationService $firebase): array
    {
        $tokens = [];

        foreach ($recipients as $recipient) {
            NotificationRecipient::query()->create([
                'notification_id' => $notification->id,
                'user_id' => $recipient['user_id'],
                'attendee_id' => $recipient['attendee_id'],
                'status' => 'pending',
            ]);
            if ($recipient['user_id']) {
                $tokens = array_merge($tokens, DeviceToken::query()->where('user_id', $recipient['user_id'])->pluck('token')->all());
            }
        }

        $result = $firebase->send($tokens, $notification->title, $notification->message);
        $status = $result['success'] ? 'sent' : 'failed';
        $notification->update(['status' => $status, 'sent_at' => $result['success'] ? now() : null, 'failure_reason' => $result['success'] ? null : 'Firebase send failed.']);
        $notification->recipients()->update(['status' => $status, 'delivered_at' => $result['success'] ? now() : null, 'failure_reason' => $result['success'] ? null : 'Firebase send failed.']);

        return $result;
    }

    /**
     * @return array<int, array{user_id: int|null, attendee_id: int|null}>
     */
    private function resolveNotificationRecipients(Event $event, string $targetType, ?int $sessionId): array
    {
        return match ($targetType) {
            'session_attendees' => Attendee::query()
                ->where('event_id', $event->id)
                ->whereIn('id', DB::table('session_attendance')->where('session_id', $sessionId)->pluck('attendee_id'))
                ->get()
                ->map(fn ($attendee) => ['user_id' => $attendee->user_id, 'attendee_id' => $attendee->id])
                ->all(),
            'organisers', 'scanners' => $event->users()->wherePivot('role', rtrim($targetType, 's'))->get()
                ->map(fn ($user) => ['user_id' => $user->id, 'attendee_id' => null])
                ->all(),
            default => $event->attendees()->get()
                ->map(fn ($attendee) => ['user_id' => $attendee->user_id, 'attendee_id' => $attendee->id])
                ->all(),
        };
    }
}
