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
     * Create per-recipient delivery records, send via Firebase, and record the
     * outcome against each recipient individually.
     *
     * A recipient is marked `sent` only when one of that recipient's own device
     * tokens was accepted, and `failed` when every one of their tokens was
     * refused. A recipient with no registered device is left `pending`: nothing
     * was pushed to them, and the in-app inbox is how they receive the message.
     * Recording one aggregate outcome against every row instead would make the
     * delivery record unable to answer the question it exists to answer, which
     * is whether a given person was reached.
     *
     * @param  array<int, array{user_id: int|null, attendee_id: int|null}>  $recipients
     * @return array{success: bool, demo: bool, sent_count: int, failed_count: int, token_results: array<string, bool>}
     */
    public function deliver(EventNotification $notification, array $recipients, FirebaseNotificationService $firebase): array
    {
        $tokensByUser = [];
        $rows = [];

        foreach ($recipients as $recipient) {
            $row = NotificationRecipient::query()->create([
                'notification_id' => $notification->id,
                'user_id' => $recipient['user_id'],
                'attendee_id' => $recipient['attendee_id'],
                'status' => 'pending',
            ]);

            if ($recipient['user_id'] && ! array_key_exists($recipient['user_id'], $tokensByUser)) {
                $tokensByUser[$recipient['user_id']] = DeviceToken::query()
                    ->where('user_id', $recipient['user_id'])
                    ->pluck('token')
                    ->all();
            }

            $rows[] = ['id' => $row->id, 'user_id' => $recipient['user_id']];
        }

        $tokens = array_values(array_unique(array_merge(...array_values($tokensByUser) ?: [[]])));
        $result = $firebase->send($tokens, $notification->title, $notification->message);

        $delivered = [];
        $refused = [];
        foreach ($rows as $row) {
            $theirs = $tokensByUser[$row['user_id']] ?? [];
            if ($theirs === []) {
                continue;
            }
            $reached = false;
            foreach ($theirs as $token) {
                if ($result['token_results'][$token] ?? false) {
                    $reached = true;
                    break;
                }
            }
            $reached ? $delivered[] = $row['id'] : $refused[] = $row['id'];
        }

        if ($delivered !== []) {
            NotificationRecipient::query()->whereIn('id', $delivered)
                ->update(['status' => 'sent', 'delivered_at' => now(), 'failure_reason' => null]);
        }
        if ($refused !== []) {
            NotificationRecipient::query()->whereIn('id', $refused)
                ->update(['status' => 'failed', 'delivered_at' => null, 'failure_reason' => 'Firebase refused every device token for this recipient.']);
        }

        $notification->update([
            'status' => $result['success'] ? 'sent' : 'failed',
            'sent_at' => $result['success'] ? now() : null,
            'failure_reason' => $result['success'] ? null : 'Firebase send failed.',
        ]);

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
