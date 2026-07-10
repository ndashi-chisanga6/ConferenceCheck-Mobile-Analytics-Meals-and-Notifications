enum CapacityStatus { normal, almostFull, nearlyFull, full, overcrowded }

CapacityStatus capacityStatusFor({
  required int attendance,
  required int capacity,
}) {
  if (capacity <= 0) return CapacityStatus.normal;
  final percentage = (attendance / capacity) * 100;
  if (percentage > 100) return CapacityStatus.overcrowded;
  if (percentage >= 100) return CapacityStatus.full;
  if (percentage >= 90) return CapacityStatus.nearlyFull;
  if (percentage >= 70) return CapacityStatus.almostFull;
  return CapacityStatus.normal;
}

String capacityStatusLabel(CapacityStatus status) {
  return switch (status) {
    CapacityStatus.normal => 'Normal',
    CapacityStatus.almostFull => 'Almost full',
    CapacityStatus.nearlyFull => 'Nearly full',
    CapacityStatus.full => 'Full',
    CapacityStatus.overcrowded => 'Overcrowded',
  };
}
