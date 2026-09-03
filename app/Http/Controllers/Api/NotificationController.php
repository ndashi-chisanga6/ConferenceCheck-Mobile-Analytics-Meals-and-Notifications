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
use Illuminate\Support\Facades\DB;

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
        if ($deviceToken->user_id !== $request->user()->id && $request->user()->role !== 'organiser') {
            return $this->fail('You cannot delete this device token.', null, 403);
        }

        $deviceToken->delete();

        return $this->ok('Device token deleted.');
    }

    public function index(Event $event): JsonResponse
    {
        return $this->ok('Notifications retrieved.', EventNotification::query()->where('event_id', $event->id)->withCount('recipients')->latest()->get());
    }

    public function send(NotificationSendRequest $request, Event $event, FirebaseNotificationService $firebase, NotificationDispatchService $dispatch): JsonResponse
    {
        return DB::transaction(function () use ($request, $event, $firebase, $dispatch) {
            $notification = EventNotification::query()->create($request->validated() + [
                'event_id' => $event->id,
                'sent_by' => $request->user()->id,
                'status' => 'draft',
            ]);

            $recipients = $dispatch->resolveRecipients($event, $request->string('target_type')->toString(), $request->integer('target_session_id') ?: null);
            $result = $dispatch->deliver($notification, $recipients, $firebase);

            return $this->ok('Notification sent.', ['notification' => $notification->fresh('recipients'), 'firebase' => $result]);
        });
    }

    public function show(Event $event, EventNotification $notification): JsonResponse
    {
        return $notification->event_id === $event->id ? $this->ok('Notification retrieved.', $notification->load('recipients')) : $this->fail('Notification not found for this event.', null, 404);
    }
}
