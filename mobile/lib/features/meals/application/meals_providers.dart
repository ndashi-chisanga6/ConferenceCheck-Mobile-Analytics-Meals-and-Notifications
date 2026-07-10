import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/meals/data/meal_models.dart';
import 'package:conference_check_mobile/features/meals/data/meals_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mealsApiProvider = Provider<MealsApi>(
  (ref) => MealsApi(ref.watch(apiClientProvider)),
);

final mealCategoriesProvider = FutureProvider<List<MealCategory>>((ref) async {
  final event = ref.watch(selectedEventProvider);
  if (event == null) return [];
  return ref.watch(mealsApiProvider).categories(event.id);
});

final mealVouchersProvider = FutureProvider<List<MealVoucher>>((ref) async {
  final event = ref.watch(selectedEventProvider);
  if (event == null) return [];
  return ref.watch(mealsApiProvider).vouchers(event.id);
});

final mealRedemptionsProvider = FutureProvider<List<MealRedemption>>((
  ref,
) async {
  final event = ref.watch(selectedEventProvider);
  if (event == null) return [];
  return ref.watch(mealsApiProvider).redemptions(event.id);
});
