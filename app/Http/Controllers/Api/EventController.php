<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Api\EventRequest;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends ApiController
{
    public function index(Request $request)
    {
        $user = $request->user();
        $events = $user->role === 'organiser'
            ? Event::query()->where('created_by', $user->id)->latest()->get()
            : Event::query()->whereHas('users', fn ($query) => $query->whereKey($user->id))->latest()->get();

        return $this->ok('Events retrieved.', $events);
    }

    public function store(EventRequest $request)
    {
        if ($request->user()->role !== 'organiser') {
            return $this->fail('Only organisers can create events.', null, 403);
        }

        $event = Event::query()->create($request->validated() + ['created_by' => $request->user()->id]);
        $event->users()->syncWithoutDetaching([$request->user()->id => ['role' => 'organiser']]);

        return $this->ok('Event created.', $event, 201);
    }

    public function show(Event $event)
    {
        return $this->ok('Event retrieved.', $event->loadCount(['attendees', 'mealVouchers', 'sessions']));
    }

    public function update(EventRequest $request, Event $event)
    {
        $event->update($request->validated());

        return $this->ok('Event updated.', $event->fresh());
    }

    public function destroy(Event $event)
    {
        $event->delete();

        return $this->ok('Event deleted.');
    }
}
