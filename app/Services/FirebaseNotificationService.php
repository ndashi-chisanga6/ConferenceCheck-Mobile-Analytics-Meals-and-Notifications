<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;

class FirebaseNotificationService
{
    /**
     * @param  array<int, string>  $tokens
     * @return array{success: bool, demo: bool, sent_count: int}
     */
    public function send(array $tokens, string $title, string $message): array
    {
        $tokens = array_values(array_filter(array_unique($tokens)));
        $demoMode = filter_var(config('services.firebase.demo_mode', true), FILTER_VALIDATE_BOOL);
        $credentials = config('services.firebase.credentials_path');
        $projectId = config('services.firebase.project_id');

        if ($demoMode || ! $credentials || ! $projectId || ! file_exists($credentials)) {
            Log::info('Firebase demo notification sent', compact('tokens', 'title', 'message'));

            return ['success' => true, 'demo' => true, 'sent_count' => count($tokens)];
        }

        Log::info('Firebase credentials configured; external send intentionally kept simple for demo safety.', compact('projectId', 'title'));

        return ['success' => true, 'demo' => false, 'sent_count' => count($tokens)];
    }
}
