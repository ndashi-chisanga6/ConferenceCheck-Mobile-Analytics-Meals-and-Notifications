<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MealRedemption extends Model
{
    protected $fillable = ['event_id', 'meal_voucher_id', 'attendee_id', 'meal_category_id', 'redeemed_by', 'redeemed_at', 'device_id', 'notes'];

    protected function casts(): array
    {
        return ['redeemed_at' => 'datetime'];
    }
}
