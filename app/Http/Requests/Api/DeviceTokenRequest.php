<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class DeviceTokenRequest extends FormRequest
{
    public function rules(): array
    {
        return ['token' => ['required', 'string', 'max:500'], 'platform' => ['required', Rule::in(['android', 'ios', 'web', 'unknown'])]];
    }
}
