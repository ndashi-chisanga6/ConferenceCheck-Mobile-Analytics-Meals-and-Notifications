<?php

namespace App\Http\Controllers\Api;

use App\Models\Event;
use App\Models\EventNotification;
use App\Models\MealRedemption;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends ApiController
{
    public function attendance(Event $event): StreamedResponse
    {
        return $this->csv('attendance.csv', ['Attendee', 'Email', 'Ticket Code', 'Checked In At'], $event->attendees()->get()->map(fn ($attendee) => [
            $attendee->full_name,
            $attendee->email,
            $attendee->ticket_code,
            optional($attendee->checked_in_at)->toDateTimeString(),
        ])->all());
    }

    public function meals(Event $event): StreamedResponse
    {
        $rows = MealRedemption::query()
            ->where('meal_redemptions.event_id', $event->id)
            ->join('attendees', 'attendees.id', '=', 'meal_redemptions.attendee_id')
            ->join('meal_categories', 'meal_categories.id', '=', 'meal_redemptions.meal_category_id')
            ->select('attendees.full_name', 'meal_categories.name', 'meal_redemptions.redeemed_at', 'meal_redemptions.device_id')
            ->get()
            ->map(fn ($row) => [$row->getAttribute('full_name'), $row->getAttribute('name'), $row->redeemed_at, $row->device_id])
            ->all();

        return $this->csv('meals.csv', ['Attendee', 'Meal Category', 'Redeemed At', 'Device ID'], $rows);
    }

    public function sessions(Event $event): StreamedResponse
    {
        $rows = $event->sessions()->withCount('attendance')->get()->map(fn ($session) => [
            $session->title,
            $session->venue,
            $session->capacity,
            $session->attendance_count,
            $session->attendance_count > $session->capacity ? 'over_capacity' : ($session->attendance_count === $session->capacity ? 'full' : 'available'),
        ])->all();

        return $this->csv('sessions.csv', ['Title', 'Venue', 'Capacity', 'Attendance', 'Capacity Status'], $rows);
    }

    public function notifications(Event $event): StreamedResponse
    {
        $rows = EventNotification::query()
            ->where('event_id', $event->id)
            ->withCount('recipients')
            ->get()
            ->map(fn ($notification) => [$notification->title, $notification->target_type, $notification->status, $notification->recipients_count, optional($notification->sent_at)->toDateTimeString()])
            ->all();

        return $this->csv('notifications.csv', ['Title', 'Target Type', 'Status', 'Recipients', 'Sent At'], $rows);
    }

    /**
     * @param  array<int, string>  $headers
     * @param  array<int, array<int, mixed>>  $rows
     */
    private function csv(string $filename, array $headers, array $rows): StreamedResponse
    {
        return response()->streamDownload(function () use ($headers, $rows): void {
            $handle = fopen('php://output', 'w');
            if ($handle === false) {
                return;
            }
            fputcsv($handle, $headers);
            foreach ($rows as $row) {
                fputcsv($handle, $row);
            }
            fclose($handle);
        }, $filename, ['Content-Type' => 'text/csv']);
    }
}
