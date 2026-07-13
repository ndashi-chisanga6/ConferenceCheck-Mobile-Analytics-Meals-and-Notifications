<?php

// Seeds the simulated-event dataset used by tools/run-evaluation.py:
// one event, 500 attendees, one meal category with a voucher per
// attendee, and 10 sessions. Run with:
//   php artisan tinker tools/seed-evaluation-event.php

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

$category = MealCategory::query()->create([
    'event_id' => $event->id,
    'name' => 'Evaluation Lunch',
    'status' => 'active',
    'starts_at' => now()->subHour(),
    'ends_at' => now()->addHours(6),
]);

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

echo "Seeded event {$event->id}: 500 attendees, 500 vouchers, 10 sessions.\n";
