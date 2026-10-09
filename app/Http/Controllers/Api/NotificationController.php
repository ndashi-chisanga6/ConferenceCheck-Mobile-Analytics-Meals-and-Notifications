<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Api\DeviceTokenRequest;
use App\Http\Requests\Api\NotificationSendRequest;
use App\Models\DeviceToken;
use App\Models\Event;
use App\Models\EventNotification;
use App\Services\FirebaseNotificationService;
use App\Services\NotificationDispatchService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends ApiController
{
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
        if ($deviceToken->user_id !== $request->user()->id) {
            return $this->fail('You cannot delete this device token.', null, 403);
        }

        $deviceToken->delete();

        return $this->ok('Device token deleted.');
    }

    public function index(Request $request, Event $event): JsonResponse
    {
        $notifications = EventNotification::query()
            ->where('event_id', $event->id)
            ->when($event->roleFor($request->user()) !== 'organiser', fn ($query) => $query->whereHas('recipients', fn ($recipients) => $recipients->where('user_id', $request->user()->id)))
            ->withCount('recipients')
            ->latest()
            ->get();

        return $this->ok('Notifications retrieved.', $notifications);
    }

    public function send(NotificationSendRequest $request, Event $event, FirebaseNotificationService $firebase, NotificationDispatchService $dispatch): JsonResponse
    {
        $notification = EventNotification::query()->create($request->validated() + [
            'event_id' => $event->id,
            'sent_by' => $request->user()->id,
            'status' => 'draft',
        ]);

        $recipients = $dispatch->resolveRecipients($event, $request->string('target_type')->toString(), $request->integer('target_session_id') ?: null);
        $result = $dispatch->deliver($notification, $recipients, $firebase);

        return $this->ok('Notification sent.', ['notification' => $notification->fresh('recipients'), 'firebase' => $result]);
    }

    public function show(Request $request, Event $event, EventNotification $notification): JsonResponse
    {
        if ($notification->event_id !== $event->id) {
            return $this->fail('Notification not found for this event.', null, 404);
        }

        if ($event->roleFor($request->user()) === 'organiser') {
            return $this->ok('Notification retrieved.', $notification->load('recipients'));
        }

        if (! $notification->recipients()->where('user_id', $request->user()->id)->exists()) {
            return $this->fail('This notification was not sent to you.', null, 403);
        }

        return $this->ok('Notification retrieved.', $notification);
    }
}
