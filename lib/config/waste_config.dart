import 'package:flutter/material.dart';

const int kMinWithdrawal = 2000; // points (1 point = UGX 1)
const int kHighValueWithdrawal = 50000; // asks for an OTP above this
const String kUssdCode = '*123#'; // TODO: replace with your real USSD code
const List<String> kDistricts = ['Arua', 'Gulu', 'Nebbi', 'West Nile (other)'];
const List<String> kMobileMoney = ['MTN Mobile Money', 'Airtel Money'];

/// 12500 -> "UGX 12,500"
String formatUGX(num amount) {
  final s = amount.round().toString();
  final withCommas = s.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  return 'UGX $withCommas';
}

String formatDate(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

class WasteCategory {
  final String key;
  final String label;
  final String short;
  final int pointsPerKg;
  final Color color;
  final Color bg;
  final IconData icon;
  final String image;

  const WasteCategory({
    required this.key,
    required this.label,
    required this.short,
    required this.pointsPerKg,
    required this.color,
    required this.bg,
    required this.icon,
    required this.image,
  });
}

/// TODO: edit rates and replace image URLs with your own real photos
/// (put them in assets/ and switch AppImage to Image.asset if you prefer).
const List<WasteCategory> wasteCategories = [
  WasteCategory(
    key: 'polythene',
    label: 'Plastic bags (polythene)',
    short: 'Polythene',
    pointsPerKg: 300,
    color: Color(0xFF1F7A45),
    bg: Color(0xFFE3F5E9),
    icon: Icons.shopping_bag_outlined,
    image: 'https://picsum.photos/seed/gasiya-polythene/600/400',
  ),
  WasteCategory(
    key: 'plastic',
    label: 'Plastic bottles & containers',
    short: 'Plastic',
    pointsPerKg: 500,
    color: Color(0xFF0E7C8A),
    bg: Color(0xFFD9F5F9),
    icon: Icons.local_drink_outlined,
    image: 'https://picsum.photos/seed/gasiya-plastic/600/400',
  ),
  WasteCategory(
    key: 'glass',
    label: 'Glass bottles & containers',
    short: 'Glass',
    pointsPerKg: 200,
    color: Color(0xFF8A6500),
    bg: Color(0xFFFFF3CC),
    icon: Icons.wine_bar_outlined,
    image: 'https://picsum.photos/seed/gasiya-glass/600/400',
  ),
  WasteCategory(
    key: 'metal',
    label: 'Scrap metal',
    short: 'Metal',
    pointsPerKg: 800,
    color: Color(0xFF2F3A44),
    bg: Color(0xFFE6E9ED),
    icon: Icons.hardware_outlined,
    image: 'https://picsum.photos/seed/gasiya-metal/600/400',
  ),
  WasteCategory(
    key: 'rubber',
    label: 'Rubber',
    short: 'Rubber',
    pointsPerKg: 400,
    color: Color(0xFF9A4B00),
    bg: Color(0xFFFFE8D1),
    icon: Icons.tire_repair,
    image: 'https://picsum.photos/seed/gasiya-rubber/600/400',
  ),
];

WasteCategory categoryOf(String key) =>
    wasteCategories.firstWhere((c) => c.key == key, orElse: () => wasteCategories.first);
