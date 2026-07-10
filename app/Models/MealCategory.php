<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MealCategory extends Model
{
    protected $fillable = ['event_id', 'name', 'starts_at', 'ends_at', 'daily_limit', 'status'];

    protected function casts(): array
    {
        return ['starts_at' => 'datetime', 'ends_at' => 'datetime'];
    }

    public function event(): BelongsTo
    {
        return $this->belongsTo(Event::class);
    }

    public function vouchers(): HasMany
    {
        return $this->hasMany(MealVoucher::class);
    }
}
