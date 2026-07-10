<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class MealVoucherGenerateRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'meal_category_id' => ['required', 'exists:meal_categories,id'],
            'attendee_ids' => ['nullable', 'array'],
            'attendee_ids.*' => ['integer', 'exists:attendees,id'],
        ];
    }
}
