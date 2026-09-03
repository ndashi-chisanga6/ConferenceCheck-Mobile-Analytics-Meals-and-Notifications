<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Api\MealCategoryRequest;
use App\Http\Requests\Api\MealVoucherGenerateRequest;
use App\Http\Requests\Api\MealVoucherScanRequest;
use App\Models\Event;
use App\Models\MealCategory;
use App\Models\MealRedemption;
use App\Models\MealVoucher;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MealController extends ApiController
{
    public function categories(Event $event): JsonResponse
    {
        return $this->ok('Meal categories retrieved.', $event->mealCategories()->get());
    }

    public function storeCategory(MealCategoryRequest $request, Event $event): JsonResponse
    {
        return $this->ok('Meal category created.', $event->mealCategories()->create($request->validated()), 201);
    }

    public function showCategory(Event $event, MealCategory $mealCategory): JsonResponse
    {
        return $mealCategory->event_id === $event->id ? $this->ok('Meal category retrieved.', $mealCategory) : $this->fail('Meal category not found for this event.', null, 404);
    }

    public function updateCategory(MealCategoryRequest $request, Event $event, MealCategory $mealCategory): JsonResponse
    {
        if ($mealCategory->event_id !== $event->id) {
            return $this->fail('Meal category not found for this event.', null, 404);
        }

        $mealCategory->update($request->validated());

        return $this->ok('Meal category updated.', $mealCategory->fresh());
    }

    public function destroyCategory(Event $event, MealCategory $mealCategory): JsonResponse
    {
        if ($mealCategory->event_id !== $event->id) {
            return $this->fail('Meal category not found for this event.', null, 404);
        }

        $mealCategory->delete();

        return $this->ok('Meal category deleted.');
    }

    public function generateVouchers(MealVoucherGenerateRequest $request, Event $event): JsonResponse
    {
        $category = $event->mealCategories()->whereKey($request->integer('meal_category_id'))->first();

        if (! $category) {
            return $this->fail('Meal category does not belong to this event.', null, 422);
        }

        $attendees = $event->attendees()
            ->when($request->filled('attendee_ids'), fn ($query) => $query->whereIn('id', $request->input('attendee_ids')))
            ->get();

        $created = 0;
        foreach ($attendees as $attendee) {
            $voucher = MealVoucher::query()->firstOrCreate(
                ['attendee_id' => $attendee->id, 'meal_category_id' => $category->id],
                ['event_id' => $event->id, 'qr_token' => 'MEAL-'.Str::uuid(), 'status' => 'unused']
            );
            $created += $voucher->wasRecentlyCreated ? 1 : 0;
        }

        return $this->ok('Meal vouchers generated.', ['created' => $created, 'total_attendees' => $attendees->count()]);
    }

    public function vouchers(Event $event): JsonResponse
    {
        return $this->ok('Meal vouchers retrieved.', $event->mealVouchers()->with(['attendee', 'category'])->latest()->get());
    }

    public function showVoucher(Event $event, MealVoucher $mealVoucher): JsonResponse
    {
        return $mealVoucher->event_id === $event->id ? $this->ok('Meal voucher retrieved.', $mealVoucher->load(['attendee', 'category'])) : $this->fail('Meal voucher not found for this event.', null, 404);
    }

    public function scanVoucher(MealVoucherScanRequest $request, Event $event): JsonResponse
    {
        return DB::transaction(function () use ($request, $event) {
            $voucher = MealVoucher::query()->where('qr_token', $request->string('qr_token'))->lockForUpdate()->first();

            if (! $voucher || $voucher->event_id !== $event->id) {
                return $this->fail('Invalid meal voucher QR token.', ['qr_token' => ['Voucher not found for this event.']], 404);
            }

            $category = MealCategory::query()->find($voucher->meal_category_id);
            $now = now();

            if ($voucher->status !== 'unused') {
                return $this->fail('Meal voucher has already been redeemed or is not usable.', ['status' => $voucher->status], 409);
            }
            if (! $category || $category->status !== 'active') {
                return $this->fail('Meal category is not active.', null, 422);
            }
            if (($category->starts_at && $now->lt($category->starts_at)) || ($category->ends_at && $now->gt($category->ends_at))) {
                return $this->fail('Meal voucher is outside the redemption window.', null, 422);
            }

            $voucher->update(['status' => 'redeemed', 'redeemed_at' => $now, 'redeemed_by' => $request->user()->id]);
            $redemption = MealRedemption::query()->create([
                'event_id' => $event->id,
                'meal_voucher_id' => $voucher->id,
                'attendee_id' => $voucher->attendee_id,
                'meal_category_id' => $voucher->meal_category_id,
                'redeemed_by' => $request->user()->id,
                'redeemed_at' => $now,
                'device_id' => $request->input('device_id'),
            ]);

            return $this->ok('Meal voucher redeemed successfully.', ['voucher' => $voucher->fresh(['attendee', 'category']), 'redemption' => $redemption]);
        });
    }

    public function redemptions(Event $event): JsonResponse
    {
        return $this->ok('Meal redemptions retrieved.', MealRedemption::query()->where('event_id', $event->id)->latest()->get());
    }
}
