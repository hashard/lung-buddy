import 'models.dart';

class MascotMoodLogic {
  static MascotMood fromToday({
    required int smokeCount,
    required int budget,
    required int nowHour,
    bool yesterdayWon = false,
  }) {
    if (smokeCount > budget) return MascotMood.worried;
    if (yesterdayWon && smokeCount <= budget * 0.3) {
      return MascotMood.celebrate;
    }
    if (smokeCount == 0) return MascotMood.happy;
    if (smokeCount >= budget) return MascotMood.worried;
    if (smokeCount >= (budget * 0.7).floor()) return MascotMood.worried;
    return MascotMood.chill;
  }
}
