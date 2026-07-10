<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Throwable;

class FirebaseNotificationService
{
    /**
     * @param  array<int, string>  $tokens
     * @return array{success: bool, demo: bool, sent_count: int, failed_count: int}
     */
    public function send(array $tokens, string $title, string $message): array
    {
        $tokens = array_values(array_filter(array_unique($tokens)));
        $demoMode = filter_var(config('services.firebase.demo_mode', true), FILTER_VALIDATE_BOOL);
        $credentials = config('services.firebase.credentials_path');
        $projectId = config('services.firebase.project_id');

        if ($demoMode || ! is_string($credentials) || $credentials === '' || ! is_string($projectId) || $projectId === '' || ! file_exists($credentials)) {
            Log::info('Firebase demo notification sent', compact('tokens', 'title', 'message'));

            return ['success' => true, 'demo' => true, 'sent_count' => count($tokens), 'failed_count' => 0];
        }

        try {
            $accessToken = $this->accessToken($credentials);
        } catch (Throwable $exception) {
            Log::error('Firebase authentication failed: '.$exception->getMessage());

            return ['success' => false, 'demo' => false, 'sent_count' => 0, 'failed_count' => count($tokens)];
        }

        $sent = 0;
        $failed = 0;

        foreach ($tokens as $token) {
            $response = Http::withToken($accessToken)->post(
                "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send",
                ['message' => ['token' => $token, 'notification' => ['title' => $title, 'body' => $message]]]
            );

            if ($response->successful()) {
                $sent++;
            } else {
                $failed++;
                Log::warning('FCM v1 send failed', ['status' => $response->status(), 'response' => $response->json()]);
            }
        }

        return ['success' => $tokens === [] || $sent > 0, 'demo' => false, 'sent_count' => $sent, 'failed_count' => $failed];
    }

    /**
     * Exchange the service-account key for a short-lived OAuth2 access token
     * scoped to Firebase Cloud Messaging.
     */
    private function accessToken(string $credentialsPath): string
    {
        $contents = file_get_contents($credentialsPath);
        if ($contents === false) {
            throw new RuntimeException('Unable to read the Firebase credentials file.');
        }

        $account = json_decode($contents, true);
        if (! is_array($account) || ! is_string($account['client_email'] ?? null) || ! is_string($account['private_key'] ?? null)) {
            throw new RuntimeException('Firebase credentials file is missing client_email or private_key.');
        }

        $now = time();
        $signingInput = $this->base64Url((string) json_encode(['alg' => 'RS256', 'typ' => 'JWT']))
            .'.'
            .$this->base64Url((string) json_encode([
                'iss' => $account['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'iat' => $now,
                'exp' => $now + 3600,
            ]));

        if (! openssl_sign($signingInput, $signature, $account['private_key'], OPENSSL_ALGO_SHA256)) {
            throw new RuntimeException('Unable to sign the Firebase token request.');
        }

        $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $signingInput.'.'.$this->base64Url($signature),
        ]);

        $accessToken = $response->json('access_token');
        if (! is_string($accessToken) || $accessToken === '') {
            throw new RuntimeException('Google OAuth token exchange failed (HTTP '.$response->status().').');
        }

        return $accessToken;
    }

    private function base64Url(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
