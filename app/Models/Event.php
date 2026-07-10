<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Event extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'theme', 'venue', 'starts_at', 'ends_at', 'description', 'status', 'created_by'];

    protected function casts(): array
    {
        return ['starts_at' => 'datetime', 'ends_at' => 'datetime'];
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'event_users')->withPivot('role')->withTimestamps();
    }

    public function attendees(): HasMany
    {
        return $this->hasMany(Attendee::class);
    }

    public function mealCategories(): HasMany
    {
        return $this->hasMany(MealCategory::class);
    }

    public function mealVouchers(): HasMany
    {
        return $this->hasMany(MealVoucher::class);
    }

    public function sessions(): HasMany
    {
        return $this->hasMany(ConferenceSession::class);
    }
}
