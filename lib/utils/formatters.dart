import 'package:flutter/material.dart';

const Map<String, IconData> kDaftarIkon = {
  'wallet': Icons.account_balance_wallet_rounded,
  'bank': Icons.account_balance_rounded,
  'ewallet': Icons.phone_android_rounded,
  'card': Icons.credit_card_rounded,
  'food': Icons.restaurant_rounded,
  'car': Icons.directions_car_rounded,
  'bag': Icons.shopping_bag_rounded,
  'bill': Icons.receipt_long_rounded,
  'salary': Icons.payments_rounded,
  'gift': Icons.card_giftcard_rounded,
  'store': Icons.storefront_rounded,
  'health': Icons.favorite_rounded,
  'game': Icons.sports_esports_rounded,
  'edu': Icons.school_rounded,
  'home': Icons.home_rounded,
  'other': Icons.category_rounded,
};

const List<int> kPilihanWarna = [
  0xFF10B981,
  0xFFD4AF37,
  0xFF38BDF8,
  0xFFA855F7,
  0xFFF43F5E,
  0xFF14B8A6,
  0xFFEC4899,
  0xFF6366F1,
];

IconData ikonDariKey(String key) =>
    kDaftarIkon[key] ?? Icons.category_rounded;

String formatRupiah(int angka, {bool sensor = false}) {
  if (sensor) return 'Rp ••••••';
  final str = angka.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
  }
  return '${angka < 0 ? '-' : ''}Rp ${buffer.toString()}';
}

const List<String> kNamaBulan = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String formatTanggal(DateTime dt) =>
    '${dt.day} ${kNamaBulan[dt.month - 1]} ${dt.year}';
