import 'package:flutter/material.dart';
import '../theme/app_template.dart';
import 'smooth_widgets.dart';

void tampilkanPemilihTemplate(
  BuildContext context, {
  required AppTemplate aktif,
  required Future<void> Function(AppTemplate) onPilih,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: aktif.cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(aktif.cardRadius + 6),
      ),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Text(
            'Pilih Template Tampilan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sesuaikan gaya visual aplikasi dengan selera kamu.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...kDaftarTemplate.asMap().entries.map((entry) {
            final idx = entry.key;
            final tpl = entry.value;
            final isSelected = tpl.id == aktif.id;
            return AnimatedAppear(
              index: idx,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SmoothTap(
                  onTap: () async {
                    await onPilih(tpl);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tpl.bgColor,
                      borderRadius: BorderRadius.circular(tpl.cardRadius),
                      border: Border.all(
                        color: isSelected ? tpl.primaryColor : tpl.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 46,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: tpl.cardGradient,
                            ),
                            borderRadius:
                                BorderRadius.circular(tpl.cardRadius * 0.6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 24,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: tpl.primaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    tpl.nama,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: tpl.isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          tpl.primaryColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tpl.isDark ? 'Dark' : 'Light',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: tpl.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tpl.subjudul,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  key: const ValueKey('checked'),
                                  color: tpl.primaryColor,
                                  size: 24,
                                )
                              : Icon(
                                  Icons.radio_button_unchecked_rounded,
                                  key: const ValueKey('unchecked'),
                                  color: Colors.grey.withValues(alpha: 0.5),
                                  size: 22,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );
}
