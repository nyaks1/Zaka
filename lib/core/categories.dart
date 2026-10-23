import 'package:flutter/material.dart';

/// The four SA cash presets (taxi, vendor, airtime, electricity) plus a
/// couple of general-purpose buckets.
enum SpendCategory {
  taxi(
    label: 'Taxi',
    description: 'Taxi fare',
    icon: Icons.local_taxi_rounded,
    color: Color(0xFFE8A33D),
    preset: true,
  ),
  vendor(
    label: 'Vendor',
    description: 'Street vendor',
    icon: Icons.storefront_rounded,
    color: Color(0xFF8B5CF6),
    preset: true,
  ),
  airtime(
    label: 'Airtime',
    description: 'Airtime & data',
    icon: Icons.smartphone_rounded,
    color: Color(0xFF3B82F6),
    preset: true,
  ),
  electricity(
    label: 'Electricity',
    description: 'Prepaid electricity',
    icon: Icons.bolt_rounded,
    color: Color(0xFFF97316),
    preset: true,
  ),
  food(
    label: 'Food',
    description: 'Food & drink',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFEC4899),
    preset: false,
  ),
  other(
    label: 'Other',
    description: 'Other cash spend',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF64748B),
    preset: false,
  );

  const SpendCategory({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.preset,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool preset;

  static List<SpendCategory> get presets =>
      values.where((category) => category.preset).toList(growable: false);

  static SpendCategory fromName(String name) => values.firstWhere(
    (category) => category.name == name,
    orElse: () => SpendCategory.other,
  );
}
