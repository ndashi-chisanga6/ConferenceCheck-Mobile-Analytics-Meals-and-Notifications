<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class MealVoucherScanRequest extends FormRequest
{
    public function rules(): array
    {
        return ['qr_token' => ['required', 'string'], 'device_id' => ['nullable', 'string', 'max:255']];
    }
}
