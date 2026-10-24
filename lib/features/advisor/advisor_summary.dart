import '../../core/categories.dart';
import '../../core/dates.dart';
import '../../core/forecast.dart';
import '../../data/database.dart';

/// The only data that may leave the phone for Ask Zaka.
///
/// The field list is deliberately closed: notes, account names, institutions,
/// import keys, transaction descriptions and exact timestamps never enter this
/// object, so they cannot be sent by accident.
class AdvisorSummary {
  const AdvisorSummary({
    required this.runwayDays,
    required this.dailyBurnRand,
    required this.categoryPercent,
    required this.periodDays,
  });

  /// Days until cash runs out, or null when it lasts beyond the forecast.
  final int? runwayDays;

  /// Average variable spend per day, in rand.
  final double dailyBurnRand;

  /// Percentage of spending in each category over [periodDays].
  final Map<String, int> categoryPercent;

  /// Lookback window used for [categoryPercent].
  final int periodDays;

  factory AdvisorSummary.build(
    ForecastResult forecast,
    List<Spend> spends,
    DateTime asOf, {
    int days = 14,
  }) {
    assert(days > 0, 'days must be positive');

    final today = dateOnly(asOf);
    final start = today.subtract(Duration(days: days - 1));
    final totals = <String, int>{};

    for (final spend in spends) {
      final day = dateOnly(spend.spentAt);
      if (day.isBefore(start) || day.isAfter(today)) continue;
      if (spend.amountCents <= 0) continue;
      final label = SpendCategory.fromName(spend.category).label;
      totals[label] = (totals[label] ?? 0) + spend.amountCents;
    }

    final total = totals.values.fold<int>(0, (sum, value) => sum + value);
    final percentages = <String, int>{};
    if (total > 0) {
      for (final entry in totals.entries) {
        final percent = (entry.value * 100 / total).round();
        if (percent > 0) percentages[entry.key] = percent;
      }
    }

    final sorted = percentages.entries.toList(growable: false)
      ..sort((a, b) {
        final byValue = b.value.compareTo(a.value);
        return byValue != 0 ? byValue : a.key.compareTo(b.key);
      });

    return AdvisorSummary(
      runwayDays: forecast.daysRemaining,
      dailyBurnRand: forecast.dailyBurnCents / 100,
      categoryPercent: {for (final entry in sorted) entry.key: entry.value},
      periodDays: days,
    );
  }

  /// Exact wire format. Do not add fields here without updating the proxy
  /// allowlist and the privacy screen.
  Map<String, Object?> toJson() => {
    'runwayDays': runwayDays,
    'dailyBurnRand': dailyBurnRand,
    'categoryPercent': categoryPercent,
    'periodDays': periodDays,
  };
}
