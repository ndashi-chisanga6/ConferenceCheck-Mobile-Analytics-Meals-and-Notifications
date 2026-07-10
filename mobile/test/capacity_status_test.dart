import 'package:conference_check_mobile/core/utils/capacity_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('capacity status helper follows required thresholds', () {
    expect(
      capacityStatusFor(attendance: 69, capacity: 100),
      CapacityStatus.normal,
    );
    expect(
      capacityStatusFor(attendance: 70, capacity: 100),
      CapacityStatus.almostFull,
    );
    expect(
      capacityStatusFor(attendance: 90, capacity: 100),
      CapacityStatus.nearlyFull,
    );
    expect(
      capacityStatusFor(attendance: 100, capacity: 100),
      CapacityStatus.full,
    );
    expect(
      capacityStatusFor(attendance: 101, capacity: 100),
      CapacityStatus.overcrowded,
    );
  });
}
