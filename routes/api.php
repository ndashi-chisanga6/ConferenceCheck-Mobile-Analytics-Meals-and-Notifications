<?php

use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\AttendeeController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\MealController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SessionController;
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

    Route::post('device-tokens', [NotificationController::class, 'storeDeviceToken']);
    Route::delete('device-tokens/{deviceToken}', [NotificationController::class, 'deleteDeviceToken']);

    Route::prefix('events/{event}')->middleware('event.role:organiser,scanner,attendee')->group(function (): void {
        Route::get('attendees', [AttendeeController::class, 'index']);
        Route::get('attendees/me', [AttendeeController::class, 'me']);
        Route::get('attendees/{attendee}', [AttendeeController::class, 'show']);
        Route::post('attendees/{attendee}/check-in', [AttendeeController::class, 'checkIn'])->middleware('event.role:organiser,scanner');
        Route::post('attendees/check-in/scan', [AttendeeController::class, 'scan'])->middleware('event.role:organiser,scanner');

        Route::get('analytics/summary', [AnalyticsController::class, 'summary']);
        Route::get('analytics/check-ins', [AnalyticsController::class, 'checkIns']);
        Route::get('analytics/meals', [AnalyticsController::class, 'meals']);
        Route::get('analytics/sessions', [AnalyticsController::class, 'sessions']);

        Route::get('meal-categories', [MealController::class, 'categories']);
        Route::get('meal-categories/{mealCategory}', [MealController::class, 'showCategory']);
        Route::get('meal-vouchers', [MealController::class, 'vouchers']);
        Route::get('meal-vouchers/{mealVoucher}', [MealController::class, 'showVoucher']);
        Route::post('meal-vouchers/scan', [MealController::class, 'scanVoucher'])->middleware('event.role:organiser,scanner');
        Route::get('meal-redemptions', [MealController::class, 'redemptions']);

        Route::get('sessions', [SessionController::class, 'index']);
        Route::get('sessions/{session}', [SessionController::class, 'show']);
        Route::post('sessions/{session}/scan', [SessionController::class, 'scan'])->middleware('event.role:organiser,scanner');
        Route::get('sessions/{session}/attendance', [SessionController::class, 'attendance']);

        Route::get('notifications', [NotificationController::class, 'index']);
        Route::get('notifications/{notification}', [NotificationController::class, 'show']);

        Route::get('reports/attendance.csv', [ReportController::class, 'attendance']);
        Route::get('reports/meals.csv', [ReportController::class, 'meals']);
        Route::get('reports/sessions.csv', [ReportController::class, 'sessions']);
        Route::get('reports/notifications.csv', [ReportController::class, 'notifications']);
    });

    Route::prefix('events/{event}')->middleware('event.role:organiser')->group(function (): void {
        Route::post('attendees', [AttendeeController::class, 'store']);
        Route::match(['put', 'patch'], 'attendees/{attendee}', [AttendeeController::class, 'update']);
        Route::delete('attendees/{attendee}', [AttendeeController::class, 'destroy']);

        Route::post('meal-categories', [MealController::class, 'storeCategory']);
        Route::match(['put', 'patch'], 'meal-categories/{mealCategory}', [MealController::class, 'updateCategory']);
        Route::delete('meal-categories/{mealCategory}', [MealController::class, 'destroyCategory']);

        Route::post('meal-vouchers/generate', [MealController::class, 'generateVouchers']);

        Route::post('sessions', [SessionController::class, 'store']);
        Route::match(['put', 'patch'], 'sessions/{session}', [SessionController::class, 'update']);
        Route::delete('sessions/{session}', [SessionController::class, 'destroy']);

        Route::post('notifications/send', [NotificationController::class, 'send']);
    });
});
