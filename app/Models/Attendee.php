<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Attendee extends Model
{
    protected $fillable = ['event_id', 'user_id', 'full_name', 'email', 'phone', 'ticket_code', 'qr_token', 'checked_in_at'];

    protected function casts(): array
    {
        return ['checked_in_at' => 'datetime'];
    }

    /** @return BelongsTo<Event, $this> */
    public function event(): BelongsTo
    {
        return $this->belongsTo(Event::class);
    }

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** @return HasMany<MealVoucher, $this> */
    public function mealVouchers(): HasMany
    {
        return $this->hasMany(MealVoucher::class);
    }
}
