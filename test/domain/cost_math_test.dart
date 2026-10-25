import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/cost_math.dart';

void main() {
  test('per cigarette from pack', () {
    expect(
      CostMath.perCigarette(packCost: 40, cigsPerPack: 20),
      2.0,
    );
  });

  test('spend scales with count', () {
    expect(
      CostMath.spend(cigaretteCount: 5, packCost: 40, cigsPerPack: 20),
      10.0,
    );
  });

  test('week start is Monday', () {
    // 2026-10-23 is a Friday
    final start = CostMath.weekStart(DateTime(2026, 10, 23));
    expect(start, DateTime(2026, 10, 19));
    expect(start.weekday, DateTime.monday);
  });
}
