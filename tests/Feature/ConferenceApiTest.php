<?php

namespace Tests\Feature;

use App\Models\Attendee;
use App\Models\ConferenceSession;
use App\Models\Event;
use App\Models\MealVoucher;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
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

    public function test_notification_send_uses_fcm_v1_when_configured(): void
    {
        $opensslConfig = [];
        $bundledConfig = dirname(PHP_BINARY).DIRECTORY_SEPARATOR.'extras'.DIRECTORY_SEPARATOR.'ssl'.DIRECTORY_SEPARATOR.'openssl.cnf';
        if (PHP_OS_FAMILY === 'Windows' && file_exists($bundledConfig)) {
            $opensslConfig = ['config' => $bundledConfig];
        }

        $key = openssl_pkey_new(['private_key_bits' => 2048, 'private_key_type' => OPENSSL_KEYTYPE_RSA] + $opensslConfig);
        $this->assertNotFalse($key);
        openssl_pkey_export($key, $privateKey, null, $opensslConfig);
        $credentialsPath = (string) tempnam(sys_get_temp_dir(), 'fcm');
        file_put_contents($credentialsPath, json_encode([
            'client_email' => 'service-account@test-project.iam.gserviceaccount.com',
            'private_key' => $privateKey,
        ]));

        config([
            'services.firebase.demo_mode' => false,
            'services.firebase.credentials_path' => $credentialsPath,
            'services.firebase.project_id' => 'test-project',
        ]);

        Http::fake([
            'oauth2.googleapis.com/token' => Http::response(['access_token' => 'fake-access-token']),
            'fcm.googleapis.com/*' => Http::response(['name' => 'projects/test-project/messages/1']),
        ]);

        Sanctum::actingAs($this->organiser);

        $this->postJson("/api/events/{$this->event->id}/notifications/send", [
            'title' => 'Venue change',
            'message' => 'Keynote moved to Hall B.',
            'target_type' => 'all_attendees',
        ])->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.firebase.demo', false)
            ->assertJsonPath('data.notification.status', 'sent');

        @unlink($credentialsPath);
    }

    public function test_attendee_can_fetch_own_qr_token(): void
    {
        $attendee = Attendee::query()->where('event_id', $this->event->id)->whereNotNull('user_id')->firstOrFail();
        Sanctum::actingAs(User::query()->findOrFail($attendee->user_id));

        $this->getJson("/api/events/{$this->event->id}/attendees/me")
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.qr_token', $attendee->qr_token)
            ->assertJsonPath('data.ticket_code', $attendee->ticket_code);
    }

    public function test_my_attendee_returns_404_when_no_record_is_linked(): void
    {
        Sanctum::actingAs($this->scanner);

        $this->getJson("/api/events/{$this->event->id}/attendees/me")
            ->assertStatus(404)
            ->assertJsonPath('success', false);
    }
}
