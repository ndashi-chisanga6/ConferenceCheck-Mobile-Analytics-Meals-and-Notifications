<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MealVoucher extends Model
{
    protected $fillable = ['event_id', 'attendee_id', 'meal_category_id', 'qr_token', 'status', 'redeemed_at', 'redeemed_by'];

    protected function casts(): array
    {
        return ['redeemed_at' => 'datetime'];
    }

    public function attendee(): BelongsTo
    {
        return $this->belongsTo(Attendee::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(MealCategory::class, 'meal_category_id');
    }
}
