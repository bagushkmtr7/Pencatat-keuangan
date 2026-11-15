import 'package:flutter/material.dart';

class AppTemplate {
  final String id;
  final String nama;
  final String subjudul;
  final bool isDark;
  final Color bgColor;
  final Color cardColor;
  final Color inputColor;
  final Color borderColor;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> cardGradient;
  final double cardRadius;
  final bool useShadow;

  const AppTemplate({
    required this.id,
    required this.nama,
    required this.subjudul,
    required this.isDark,
    required this.bgColor,
    required this.cardColor,
    required this.inputColor,
    required this.borderColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.cardGradient,
    required this.cardRadius,
    required this.useShadow,
  });
}

const List<AppTemplate> kDaftarTemplate = [
  AppTemplate(
    id: 'emerald_obsidian',
    nama: 'Emerald Obsidian',
    subjudul: 'Fintech gelap modern & elegan',
    isDark: true,
    bgColor: Color(0xFF0B0F19),
    cardColor: Color(0xFF151C2C),
    inputColor: Color(0xFF0B0F19),
    borderColor: Color(0xFF232D42),
    primaryColor: Color(0xFF10B981),
    secondaryColor: Color(0xFF0D9488),
    cardGradient: [
      Color(0xFF065F46),
      Color(0xFF047857),
      Color(0xFF0F766E),
    ],
    cardRadius: 20,
    useShadow: false,
  ),
  AppTemplate(
    id: 'royal_gold',
    nama: 'Royal Gold Noir',
    subjudul: 'Private banking hitam & emas mewah',
    isDark: true,
    bgColor: Color(0xFF09090B),
    cardColor: Color(0xFF141417),
    inputColor: Color(0xFF09090B),
    borderColor: Color(0xFF2E281A),
    primaryColor: Color(0xFFD4AF37),
    secondaryColor: Color(0xFFB45309),
    cardGradient: [
      Color(0xFF292112),
      Color(0xFF423315),
      Color(0xFF785A1E),
    ],
    cardRadius: 14,
    useShadow: false,
  ),
  AppTemplate(
    id: 'midnight_sapphire',
    nama: 'Midnight Sapphire',
    subjudul: 'Eksekutif biru malam & indigo',
    isDark: true,
    bgColor: Color(0xFF070D19),
    cardColor: Color(0xFF0F192E),
    inputColor: Color(0xFF070D19),
    borderColor: Color(0xFF1E2F4D),
    primaryColor: Color(0xFF38BDF8),
    secondaryColor: Color(0xFF6366F1),
    cardGradient: [
      Color(0xFF1E3A8A),
      Color(0xFF1D4ED8),
      Color(0xFF4338CA),
    ],
    cardRadius: 24,
    useShadow: false,
  ),
  AppTemplate(
    id: 'pearl_alabaster',
    nama: 'Pearl Alabaster',
    subjudul: 'Minimalis bersih ala bank Swiss',
    isDark: false,
    bgColor: Color(0xFFF4F6F9),
    cardColor: Color(0xFFFFFFFF),
    inputColor: Color(0xFFF1F5F9),
    borderColor: Color(0xFFE2E8F0),
    primaryColor: Color(0xFF0F766E),
    secondaryColor: Color(0xFF1E293B),
    cardGradient: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF0F766E),
    ],
    cardRadius: 18,
    useShadow: true,
  ),
  AppTemplate(
    id: 'velvet_amethyst',
    nama: 'Velvet Amethyst',
    subjudul: 'Ungu mewah dengan aksen magenta',
    isDark: true,
    bgColor: Color(0xFF0E0918),
    cardColor: Color(0xFF1A1229),
    inputColor: Color(0xFF0E0918),
    borderColor: Color(0xFF31224D),
    primaryColor: Color(0xFFC084FC),
    secondaryColor: Color(0xFFEC4899),
    cardGradient: [
      Color(0xFF4C1D95),
      Color(0xFF6D28D9),
      Color(0xFF9D174D),
    ],
    cardRadius: 26,
    useShadow: false,
  ),
];

AppTemplate cariTemplateById(String? id) {
  return kDaftarTemplate.firstWhere(
    (t) => t.id == id,
    orElse: () => kDaftarTemplate.first,
  );
}

BoxDecoration dekorasiKartu(
  AppTemplate t, {
  Color? overrideColor,
  Color? overrideBorder,
}) {
  return BoxDecoration(
    color: overrideColor ?? t.cardColor,
    borderRadius: BorderRadius.circular(t.cardRadius),
    border: Border.all(color: overrideBorder ?? t.borderColor),
    boxShadow: t.useShadow
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
        : null,
  );
}
