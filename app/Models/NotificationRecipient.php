<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NotificationRecipient extends Model
{
    protected $fillable = ['notification_id', 'user_id', 'attendee_id', 'status', 'delivered_at', 'failure_reason'];

    protected function casts(): array
    {
        return ['delivered_at' => 'datetime'];
    }
}
