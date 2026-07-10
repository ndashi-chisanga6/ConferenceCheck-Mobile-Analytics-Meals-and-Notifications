<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class SessionScanRequest extends FormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'attendee_qr_token' => ['nullable', 'required_without:attendee_id', 'string'],
            'attendee_id' => ['nullable', 'required_without:attendee_qr_token', 'integer', 'exists:attendees,id'],
        ];
    }
}
