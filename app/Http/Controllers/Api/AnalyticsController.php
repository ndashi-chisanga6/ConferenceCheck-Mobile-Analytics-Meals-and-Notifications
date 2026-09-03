<?php

namespace App\Http\Controllers\Api;

use App\Models\CheckIn;
use App\Models\Event;
use App\Models\EventNotification;
use App\Models\MealCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

class AnalyticsController extends ApiController
{
    public function summary(Event $event): JsonResponse
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

    public function checkIns(Event $event): JsonResponse
    {
        $rows = CheckIn::query()->where('event_id', $event->id)->get()
            ->groupBy(fn (CheckIn $checkIn): string => Carbon::parse($checkIn->checked_in_at)->format('Y-m-d H:00'))
            ->map(fn ($items, string $period) => ['period' => $period, 'count' => $items->count()])
            ->values();

        return $this->ok('Check-in analytics retrieved.', $rows);
    }

    public function meals(Event $event): JsonResponse
    {
        $rows = MealCategory::query()->where('event_id', $event->id)->withCount(['vouchers as redemption_count' => fn ($query) => $query->where('status', 'redeemed')])->get();

        return $this->ok('Meal analytics retrieved.', $rows->map(fn ($category) => [
            'meal_category_id' => $category->id,
            'name' => $category->name,
            'redeemed_count' => $category->redemption_count,
        ]));
    }

    public function sessions(Event $event): JsonResponse
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
}
