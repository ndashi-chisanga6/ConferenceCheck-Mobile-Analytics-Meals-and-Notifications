<?php

namespace App\Services;

use App\Models\Attendee;
use App\Models\DeviceToken;
use App\Models\Event;
use App\Models\EventNotification;
use App\Models\NotificationRecipient;
use Illuminate\Support\Facades\DB;

class NotificationDispatchService
{
    /**
     * Create per-recipient delivery records, send via Firebase, and record
     * the outcome on the notification and every recipient row.
     *
     * @param  array<int, array{user_id: int|null, attendee_id: int|null}>  $recipients
     * @return array{success: bool, demo: bool, sent_count: int, failed_count: int}
     */
    public function deliver(EventNotification $notification, array $recipients, FirebaseNotificationService $firebase): array
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
    public function resolveRecipients(Event $event, string $targetType, ?int $sessionId): array
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
