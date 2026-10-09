<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /** @var array<string, string> */
    private array $references = [
        'event_id' => 'events',
        'meal_voucher_id' => 'meal_vouchers',
        'attendee_id' => 'attendees',
        'meal_category_id' => 'meal_categories',
        'redeemed_by' => 'users',
    ];

    public function up(): void
    {
        $this->rebuild(restrict: true);
    }

    public function down(): void
    {
        $this->rebuild(restrict: false);
    }

    private function rebuild(bool $restrict): void
    {
        Schema::table('meal_redemptions', function (Blueprint $table) use ($restrict): void {
            foreach ($this->references as $column => $on) {
                $table->dropForeign([$column]);
                $foreign = $table->foreign($column)->references('id')->on($on);
                $restrict ? $foreign->restrictOnDelete() : $foreign->cascadeOnDelete();
            }
        });
    }
};
