<?php

// Seeds the simulated-event dataset used by tools/run-evaluation.py:
// one event, 500 attendees, three meal categories with a voucher per
// attendee per category, and 10 sessions. Run with:
//   php artisan tinker tools/seed-evaluation-event.php
//
// Three categories rather than one, because the second project objective is
// redemption across multiple meal categories and the unique (attendee,
// category) pair only means something when an attendee holds more than one
// voucher: with a single category, nothing distinguishes that guarantee from
// a per-attendee one.

use App\Models\Attendee;
use App\Models\ConferenceSession;
use App\Models\Event;
use App\Models\MealCategory;
use App\Models\MealVoucher;
use App\Models\User;
use Illuminate\Support\Str;

$organiser = User::query()->where('email', 'organiser@example.com')->firstOrFail();

$existing = Event::query()->where('name', 'Evaluation Simulated Event')->first();
if ($existing) {
    $existing->delete();
    echo "Removed previous evaluation event.\n";
}

$event = Event::query()->create([
    'name' => 'Evaluation Simulated Event',
    'venue' => 'Evaluation Hall',
    'status' => 'active',
    'starts_at' => now(),
    'ends_at' => now()->addDay(),
    'created_by' => $organiser->id,
]);
$event->users()->syncWithoutDetaching([$organiser->id => ['role' => 'organiser']]);
$scanner = User::query()->where('email', 'scanner@example.com')->firstOrFail();
$event->users()->syncWithoutDetaching([$scanner->id => ['role' => 'scanner']]);

$categories = collect(['Evaluation Breakfast', 'Evaluation Lunch', 'Evaluation Supper'])
    ->map(fn (string $name) => MealCategory::query()->create([
        'event_id' => $event->id,
        'name' => $name,
        'status' => 'active',
        // The windows overlap so that every category is open for the whole
        // run; the evaluation measures redemption, not window enforcement,
        // which the backend test suite covers separately.
        'starts_at' => now()->subHour(),
        'ends_at' => now()->addHours(6),
    ]));

$now = now();
foreach (array_chunk(range(1, 500), 100) as $chunk) {
    $rows = [];
    foreach ($chunk as $i) {
        $rows[] = [
            'event_id' => $event->id,
            'full_name' => "Eval Attendee {$i}",
            'ticket_code' => "EVAL-TICKET-{$i}",
            'qr_token' => 'EVAL-ATT-'.Str::uuid(),
            'created_at' => $now,
            'updated_at' => $now,
        ];
    }
    Attendee::query()->insert($rows);
}

$attendeeIds = Attendee::query()->where('event_id', $event->id)->pluck('id');
foreach ($attendeeIds->chunk(100) as $chunk) {
    $rows = [];
    foreach ($chunk as $attendeeId) {
        foreach ($categories as $category) {
            $rows[] = [
                'event_id' => $event->id,
                'attendee_id' => $attendeeId,
                'meal_category_id' => $category->id,
                'qr_token' => 'EVAL-MEAL-'.Str::uuid(),
                'status' => 'unused',
                'created_at' => $now,
                'updated_at' => $now,
            ];
        }
    }
    MealVoucher::query()->insert($rows);
}

for ($i = 1; $i <= 10; $i++) {
    ConferenceSession::query()->create([
        'event_id' => $event->id,
        'title' => "Evaluation Session {$i}",
        'venue' => "Room {$i}",
        'capacity' => 50,
        'status' => 'scheduled',
        'starts_at' => now()->addHours($i),
        'ends_at' => now()->addHours($i + 1),
    ]);
}

$voucherCount = MealVoucher::query()->where('event_id', $event->id)->count();
echo "Seeded event {$event->id}: 500 attendees, {$categories->count()} meal categories, {$voucherCount} vouchers, 10 sessions.\n";
