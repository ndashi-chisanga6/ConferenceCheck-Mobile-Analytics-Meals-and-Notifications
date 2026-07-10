<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property-read int $redemption_count
 */
class MealCategory extends Model
{
    protected $fillable = ['event_id', 'name', 'starts_at', 'ends_at', 'daily_limit', 'status'];

    protected function casts(): array
    {
        return ['starts_at' => 'datetime', 'ends_at' => 'datetime'];
    }

    /** @return BelongsTo<Event, $this> */
    public function event(): BelongsTo
    {
        return $this->belongsTo(Event::class);
    }

    /** @return HasMany<MealVoucher, $this> */
    public function vouchers(): HasMany
    {
        return $this->hasMany(MealVoucher::class);
    }
}
