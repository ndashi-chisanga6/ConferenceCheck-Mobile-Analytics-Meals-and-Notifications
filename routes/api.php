<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ConferenceController;
use App\Http\Controllers\Api\EventController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function (): void {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::middleware('auth:sanctum')->group(function (): void {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
    });
});

Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('events', [EventController::class, 'index']);
    Route::post('events', [EventController::class, 'store']);
    Route::get('events/{event}', [EventController::class, 'show'])->middleware('event.role:organiser,scanner,attendee');
    Route::match(['put', 'patch'], 'events/{event}', [EventController::class, 'update'])->middleware('event.role:organiser');
    Route::delete('events/{event}', [EventController::class, 'destroy'])->middleware('event.role:organiser');

    Route::post('device-tokens', [ConferenceController::class, 'storeDeviceToken']);
    Route::delete('device-tokens/{deviceToken}', [ConferenceController::class, 'deleteDeviceToken']);

    Route::prefix('events/{event}')->middleware('event.role:organiser,scanner,attendee')->group(function (): void {
        Route::get('attendees', [ConferenceController::class, 'attendees']);
        Route::get('attendees/{attendee}', [ConferenceController::class, 'showAttendee']);
        Route::post('attendees/{attendee}/check-in', [ConferenceController::class, 'checkInAttendee'])->middleware('event.role:organiser,scanner');
        Route::post('attendees/check-in/scan', [ConferenceController::class, 'scanAttendee'])->middleware('event.role:organiser,scanner');

        Route::get('meal-categories', [ConferenceController::class, 'mealCategories']);
        Route::get('meal-categories/{mealCategory}', [ConferenceController::class, 'showMealCategory']);
        Route::get('meal-vouchers', [ConferenceController::class, 'mealVouchers']);
        Route::get('meal-vouchers/{mealVoucher}', [ConferenceController::class, 'showMealVoucher']);
        Route::post('meal-vouchers/scan', [ConferenceController::class, 'scanMealVoucher'])->middleware('event.role:organiser,scanner');
        Route::get('meal-redemptions', [ConferenceController::class, 'mealRedemptions']);

        Route::get('sessions', [ConferenceController::class, 'sessions']);
        Route::get('sessions/{session}', [ConferenceController::class, 'showSession']);
        Route::post('sessions/{session}/scan', [ConferenceController::class, 'scanSession'])->middleware('event.role:organiser,scanner');
        Route::get('sessions/{session}/attendance', [ConferenceController::class, 'sessionAttendance']);

        Route::get('notifications', [ConferenceController::class, 'notifications']);
        Route::get('notifications/{notification}', [ConferenceController::class, 'showNotification']);
    });

    Route::prefix('events/{event}')->middleware('event.role:organiser')->group(function (): void {
        Route::post('attendees', [ConferenceController::class, 'storeAttendee']);
        Route::match(['put', 'patch'], 'attendees/{attendee}', [ConferenceController::class, 'updateAttendee']);
        Route::delete('attendees/{attendee}', [ConferenceController::class, 'deleteAttendee']);

        Route::post('meal-categories', [ConferenceController::class, 'storeMealCategory']);
        Route::match(['put', 'patch'], 'meal-categories/{mealCategory}', [ConferenceController::class, 'updateMealCategory']);
        Route::delete('meal-categories/{mealCategory}', [ConferenceController::class, 'deleteMealCategory']);

        Route::post('meal-vouchers/generate', [ConferenceController::class, 'generateMealVouchers']);

        Route::post('sessions', [ConferenceController::class, 'storeSession']);
        Route::match(['put', 'patch'], 'sessions/{session}', [ConferenceController::class, 'updateSession']);
        Route::delete('sessions/{session}', [ConferenceController::class, 'deleteSession']);

        Route::post('notifications/send', [ConferenceController::class, 'sendNotification']);
    });
});
