<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use LogicException;

class MealRedemption extends Model
{
    protected $fillable = ['event_id', 'meal_voucher_id', 'attendee_id', 'meal_category_id', 'redeemed_by', 'redeemed_at', 'device_id', 'notes'];

    protected static function booted(): void
    {
        static::updating(fn () => throw new LogicException('Meal redemptions cannot be changed once recorded.'));
        static::deleting(fn () => throw new LogicException('Meal redemptions cannot be deleted.'));
    }

    protected function casts(): array
    {
        return ['redeemed_at' => 'datetime'];
    }
}
