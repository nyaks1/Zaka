import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

/// The four SA cash presets (taxi, vendor, airtime, electricity) plus a
/// couple of general-purpose buckets.
/// Clean architectural monochrome palette and Boxicons icon set.
enum SpendCategory {
  taxi(
    label: 'Taxi',
    description: 'Taxi fare',
    icon: Boxicons.bx_taxi,
    preset: true,
  ),
  vendor(
    label: 'Vendor',
    description: 'Street vendor',
    icon: Boxicons.bx_store,
    preset: true,
  ),
  airtime(
    label: 'Airtime',
    description: 'Airtime & data',
    icon: Boxicons.bx_mobile,
    preset: true,
  ),
  electricity(
    label: 'Electricity',
    description: 'Prepaid electricity',
    icon: Boxicons.bx_bolt_circle,
    preset: true,
  ),
  food(
    label: 'Food',
    description: 'Food & drink',
    icon: Boxicons.bx_restaurant,
    preset: false,
  ),
  other(
    label: 'Other',
    description: 'Other cash spend',
    icon: Boxicons.bx_dots_horizontal_rounded,
    preset: false,
  );

  const SpendCategory({
    required this.label,
    required this.description,
    required this.icon,
    required this.preset,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool preset;

  Color get color => switch (this) {
    SpendCategory.taxi => const Color(0xFF18181B),
    SpendCategory.vendor => const Color(0xFF27272A),
    SpendCategory.airtime => const Color(0xFF3F3F46),
    SpendCategory.electricity => const Color(0xFF52525B),
    SpendCategory.food => const Color(0xFF71717A),
    SpendCategory.other => const Color(0xFFA1A1AA),
  };

  static List<SpendCategory> get presets =>
      values.where((category) => category.preset).toList(growable: false);

  static SpendCategory fromName(String name) => values.firstWhere(
    (category) => category.name == name,
    orElse: () => SpendCategory.other,
  );
}
