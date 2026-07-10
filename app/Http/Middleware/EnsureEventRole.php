<?php

namespace App\Http\Middleware;

use App\Models\Event;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureEventRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();
        $event = $request->route('event');

        if (! $user || ! $event instanceof Event) {
            return response()->json(['success' => false, 'message' => 'Unauthenticated or invalid event.', 'errors' => null], 401);
        }

        if ($user->role === 'organiser' && $event->created_by === $user->id) {
            return $next($request);
        }

        $assignedRole = $event->users()->whereKey($user->id)->first()?->pivot?->role;

        if ($assignedRole && in_array($assignedRole, $roles, true)) {
            return $next($request);
        }

        return response()->json(['success' => false, 'message' => 'You do not have access to this event action.', 'errors' => null], 403);
    }
}
