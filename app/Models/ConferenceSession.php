<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property-read int $attendance_count
 */
class ConferenceSession extends Model
{
    protected $table = 'event_sessions';

    protected $fillable = ['event_id', 'title', 'description', 'venue', 'starts_at', 'ends_at', 'capacity', 'status'];

    protected function casts(): array
    {
        return ['starts_at' => 'datetime', 'ends_at' => 'datetime'];
    }

    /** @return HasMany<SessionAttendance, $this> */
    public function attendance(): HasMany
    {
        return $this->hasMany(SessionAttendance::class, 'session_id');
    }
}
