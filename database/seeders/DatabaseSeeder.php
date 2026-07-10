<?php

namespace Database\Seeders;

use App\Models\Attendee;
use App\Models\CheckIn;
use App\Models\ConferenceSession;
use App\Models\DeviceToken;
use App\Models\Event;
use App\Models\EventNotification;
use App\Models\MealCategory;
use App\Models\MealRedemption;
use App\Models\MealVoucher;
use App\Models\NotificationRecipient;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $organiser = User::query()->updateOrCreate(
            ['email' => 'organiser@example.com'],
            ['name' => 'Demo Organiser', 'phone' => '+27000000001', 'role' => 'organiser', 'password' => Hash::make('password')]
        );
        $scanner = User::query()->updateOrCreate(
            ['email' => 'scanner@example.com'],
            ['name' => 'Demo Scanner', 'phone' => '+27000000002', 'role' => 'scanner', 'password' => Hash::make('password')]
        );
        $attendeeUser = User::query()->updateOrCreate(
            ['email' => 'attendee@example.com'],
            ['name' => 'Demo Attendee', 'phone' => '+27000000003', 'role' => 'attendee', 'password' => Hash::make('password')]
        );

        $event = Event::query()->updateOrCreate(['name' => 'ConferenceCheck Demo Conference 2026'], [
            'theme' => 'Analytics, Meals and Notifications',
            'venue' => 'Cape Town Convention Centre',
            'starts_at' => now()->subDay(),
            'ends_at' => now()->addDays(2),
            'description' => 'Demo event for the ConferenceCheck Mobile backend.',
            'status' => 'active',
            'created_by' => $organiser->id,
        ]);

        $event->users()->syncWithoutDetaching([
            $organiser->id => ['role' => 'organiser'],
            $scanner->id => ['role' => 'scanner'],
            $attendeeUser->id => ['role' => 'attendee'],
        ]);

        $attendees = collect();
        for ($i = 1; $i <= 30; $i++) {
            $attendee = Attendee::query()->updateOrCreate(['ticket_code' => sprintf('CONF-2026-%03d', $i)], [
                'event_id' => $event->id,
                'user_id' => $i === 1 ? $attendeeUser->id : null,
                'full_name' => $i === 1 ? 'Demo Attendee' : fake()->name(),
                'email' => $i === 1 ? 'attendee@example.com' : fake()->unique()->safeEmail(),
                'phone' => fake()->optional()->phoneNumber(),
                'qr_token' => sprintf('ATTENDEE-DEMO-%03d', $i),
            ]);
            $attendees->push($attendee);
        }

        $categories = collect(['Breakfast', 'Lunch', 'Supper'])->map(fn (string $name) => MealCategory::query()->updateOrCreate([
            'event_id' => $event->id,
            'name' => $name,
        ], [
            'starts_at' => now()->subHours(2),
            'ends_at' => now()->addDays(2),
            'daily_limit' => 1,
            'status' => 'active',
        ]));

        foreach ($attendees as $attendee) {
            foreach ($categories as $category) {
                MealVoucher::query()->firstOrCreate([
                    'attendee_id' => $attendee->id,
                    'meal_category_id' => $category->id,
                ], [
                    'event_id' => $event->id,
                    'qr_token' => 'MEAL-DEMO-'.$attendee->id.'-'.$category->id,
                    'status' => 'unused',
                ]);
            }
        }

        foreach ($attendees->take(18) as $attendee) {
            $checkedAt = now()->subHours(rand(1, 8));
            $attendee->update(['checked_in_at' => $checkedAt]);
            CheckIn::query()->firstOrCreate(['event_id' => $event->id, 'attendee_id' => $attendee->id], [
                'checked_in_by' => $scanner->id,
                'method' => 'seed',
                'checked_in_at' => $checkedAt,
            ]);
        }

        $sessions = collect([
            ['Opening Keynote', 'Main Hall', 40],
            ['Mobile App Workshop', 'Lab 1', 20],
            ['AI in Event Analytics', 'Room B', 12],
            ['Closing Panel', 'Main Hall', 30],
        ])->values()->map(fn (array $row, int $index) => ConferenceSession::query()->updateOrCreate([
            'event_id' => $event->id,
            'title' => $row[0],
        ], [
            'description' => 'Demo session for '.$row[0],
            'venue' => $row[1],
            'starts_at' => now()->addHours($index + 1),
            'ends_at' => now()->addHours($index + 2),
            'capacity' => $row[2],
            'status' => 'scheduled',
        ]));

        foreach ($categories->take(2) as $category) {
            foreach ($attendees->take(10) as $attendee) {
                $voucher = MealVoucher::query()->where('attendee_id', $attendee->id)->where('meal_category_id', $category->id)->first();
                if ($voucher && $voucher->status !== 'redeemed') {
                    $redeemedAt = now()->subMinutes(rand(5, 90));
                    $voucher->update(['status' => 'redeemed', 'redeemed_at' => $redeemedAt, 'redeemed_by' => $scanner->id]);
                    MealRedemption::query()->firstOrCreate(['meal_voucher_id' => $voucher->id], [
                        'event_id' => $event->id,
                        'attendee_id' => $attendee->id,
                        'meal_category_id' => $category->id,
                        'redeemed_by' => $scanner->id,
                        'redeemed_at' => $redeemedAt,
                        'device_id' => 'seed-scanner',
                    ]);
                }
            }
        }

        foreach ($sessions as $index => $session) {
            foreach ($attendees->take(8 + ($index * 4)) as $attendee) {
                $session->attendance()->firstOrCreate(['attendee_id' => $attendee->id], [
                    'event_id' => $event->id,
                    'checked_in_by' => $scanner->id,
                    'checked_in_at' => now()->subMinutes(rand(1, 120)),
                ]);
            }
        }

        DeviceToken::query()->updateOrCreate(['token' => 'demo-fcm-token-attendee'], ['user_id' => $attendeeUser->id, 'platform' => 'android', 'last_used_at' => now()]);
        $notification = EventNotification::query()->firstOrCreate([
            'event_id' => $event->id,
            'title' => 'Welcome to ConferenceCheck Demo',
        ], [
            'message' => 'Your demo conference is ready.',
            'target_type' => 'all_attendees',
            'sent_by' => $organiser->id,
            'status' => 'sent',
            'sent_at' => now(),
        ]);
        foreach ($attendees->take(5) as $attendee) {
            NotificationRecipient::query()->firstOrCreate(['notification_id' => $notification->id, 'attendee_id' => $attendee->id], [
                'user_id' => $attendee->user_id,
                'status' => 'sent',
                'delivered_at' => now(),
            ]);
        }
    }
}
