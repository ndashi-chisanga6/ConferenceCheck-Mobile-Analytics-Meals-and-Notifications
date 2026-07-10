<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class EventNotification extends Model
{
    protected $table = 'notifications';

    protected $fillable = ['event_id', 'title', 'message', 'target_type', 'target_session_id', 'sent_by', 'status', 'sent_at', 'failure_reason'];

    protected function casts(): array
    {
        return ['sent_at' => 'datetime'];
    }

    public function recipients(): HasMany
    {
        return $this->hasMany(NotificationRecipient::class, 'notification_id');
    }
}
