<?php

namespace Tests\Feature;

use App\Models\Attendee;
use App\Models\ConferenceSession;
use App\Models\Event;
use App\Models\MealVoucher;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ConferenceApiTest extends TestCase
{
    use RefreshDatabase;

    protected User $organiser;

    protected User $scanner;

    protected Event $event;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(DatabaseSeeder::class);
        $this->organiser = User::query()->where('email', 'organiser@example.com')->firstOrFail();
        $this->scanner = User::query()->where('email', 'scanner@example.com')->firstOrFail();
        $this->event = Event::query()->where('name', 'ConferenceCheck Demo Conference 2026')->firstOrFail();
    }

    public function test_login_returns_token(): void
    {
        $this->postJson('/api/auth/login', ['email' => 'organiser@example.com', 'password' => 'password'])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['token', 'user' => ['id', 'email', 'role']]]);
    }

    public function test_analytics_summary_endpoint(): void
    {
        Sanctum::actingAs($this->organiser);

        $this->getJson("/api/events/{$this->event->id}/analytics/summary")
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['total_attendees', 'checked_in_attendees', 'check_in_percentage', 'total_meal_vouchers']]);
    }

    public function test_valid_meal_voucher_scan(): void
    {
        Sanctum::actingAs($this->scanner);
        $voucher = MealVoucher::query()->where('event_id', $this->event->id)->where('status', 'unused')->firstOrFail();

        $this->postJson("/api/events/{$this->event->id}/meal-vouchers/scan", ['qr_token' => $voucher->qr_token, 'device_id' => 'phpunit'])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.voucher.status', 'redeemed');
    }

    public function test_duplicate_meal_voucher_scan_rejected(): void
    {
        Sanctum::actingAs($this->scanner);
        $voucher = MealVoucher::query()->where('event_id', $this->event->id)->where('status', 'unused')->firstOrFail();

        $this->postJson("/api/events/{$this->event->id}/meal-vouchers/scan", ['qr_token' => $voucher->qr_token])->assertOk();
        $this->postJson("/api/events/{$this->event->id}/meal-vouchers/scan", ['qr_token' => $voucher->qr_token])
            ->assertStatus(409)
            ->assertJsonPath('success', false);
    }

    public function test_invalid_meal_voucher_scan_rejected(): void
    {
        Sanctum::actingAs($this->scanner);

        $this->postJson("/api/events/{$this->event->id}/meal-vouchers/scan", ['qr_token' => 'missing-token'])
            ->assertStatus(404)
            ->assertJsonPath('success', false);
    }

    public function test_valid_session_attendance_scan(): void
    {
        Sanctum::actingAs($this->scanner);
        $session = ConferenceSession::query()->where('event_id', $this->event->id)->firstOrFail();
        $attendee = Attendee::query()->where('event_id', $this->event->id)->whereDoesntHave('mealVouchers', fn ($query) => $query->where('status', 'none'))->latest()->firstOrFail();
        $session->attendance()->where('attendee_id', $attendee->id)->delete();

        $this->postJson("/api/events/{$this->event->id}/sessions/{$session->id}/scan", ['attendee_id' => $attendee->id])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['attendance', 'capacity_status']]);
    }

    public function test_duplicate_session_attendance_scan_rejected(): void
    {
        Sanctum::actingAs($this->scanner);
        $session = ConferenceSession::query()->where('event_id', $this->event->id)->firstOrFail();
        $attendee = Attendee::query()->where('event_id', $this->event->id)->firstOrFail();
        $session->attendance()->where('attendee_id', $attendee->id)->delete();

        $this->postJson("/api/events/{$this->event->id}/sessions/{$session->id}/scan", ['attendee_id' => $attendee->id])->assertOk();
        $this->postJson("/api/events/{$this->event->id}/sessions/{$session->id}/scan", ['attendee_id' => $attendee->id])
            ->assertStatus(409)
            ->assertJsonPath('success', false);
    }

    public function test_notification_send_in_demo_mode(): void
    {
        config(['services.firebase.demo_mode' => true]);
        Sanctum::actingAs($this->organiser);

        $this->postJson("/api/events/{$this->event->id}/notifications/send", [
            'title' => 'Schedule update',
            'message' => 'Lunch starts in 10 minutes.',
            'target_type' => 'all_attendees',
        ])->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.notification.status', 'sent')
            ->assertJsonPath('data.firebase.demo', true);
    }

    public function test_csv_report_endpoint_returns_downloadable_csv(): void
    {
        Sanctum::actingAs($this->organiser);

        $this->get("/api/events/{$this->event->id}/reports/attendance.csv")
            ->assertOk()
            ->assertHeader('content-type', 'text/csv; charset=UTF-8');
    }
}
