<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class NotificationSendRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'message' => ['required', 'string'],
            'target_type' => ['required', Rule::in(['all_attendees', 'session_attendees', 'organisers', 'scanners', 'custom'])],
            'target_session_id' => ['nullable', 'required_if:target_type,session_attendees', 'exists:event_sessions,id'],
        ];
    }
}
