<?php

namespace App\Http\Requests\Api;

use App\Models\Attendee;
use Illuminate\Foundation\Http\FormRequest;

class AttendeeRequest extends FormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        $attendee = $this->route('attendee');
        $attendeeId = $attendee instanceof Attendee ? $attendee->id : null;

        return [
            'user_id' => ['nullable', 'exists:users,id'],
            'full_name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:30'],
            'ticket_code' => ['nullable', 'string', 'max:100', 'unique:attendees,ticket_code,'.$attendeeId],
            'qr_token' => ['nullable', 'string', 'max:160', 'unique:attendees,qr_token,'.$attendeeId],
        ];
    }
}
