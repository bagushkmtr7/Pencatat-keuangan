import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finance_models.dart';
import '../theme/app_template.dart';
import '../utils/formatters.dart';
import '../widgets/smooth_widgets.dart';

class StatistikTab extends StatefulWidget {
  final AppTemplate template;
  final bool sensorSaldo;
  final List<Transaksi> transaksi;

  const StatistikTab({
    super.key,
    required this.template,
    required this.sensorSaldo,
    required this.transaksi,
  });

  @override
  State<StatistikTab> createState() => _StatistikTabState();
}

class _StatistikTabState extends State<StatistikTab> {
  int _indexBulanAktif = 5;

  String _buatCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Tanggal,Tipe,Keterangan,Kategori,Dompet,Nominal');
    for (final t in widget.transaksi) {
      final tgl =
          '${t.tanggal.year}-${t.tanggal.month.toString().padLeft(2, '0')}-${t.tanggal.day.toString().padLeft(2, '0')}';
      final tipe = t.isPemasukan ? 'Pemasukan' : 'Pengeluaran';
      final judulAman = '"${t.judul.replaceAll('"', '""')}"';
      buffer.writeln(
        '$tgl,$tipe,$judulAman,${t.kategori},${t.dompet},${t.nominal}',
      );
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    final s = widget.sensorSaldo;

    final now = DateTime.now();
    final daftar6Bulan = List.generate(6, (idx) {
      final d = DateTime(now.year, now.month - (5 - idx), 1);
      final txBulan = widget.transaksi.where(
        (tx) => tx.tanggal.month == d.month && tx.tanggal.year == d.year,
      );
      final masuk = txBulan
          .where((tx) => tx.isPemasukan)
          .fold(0, (sum, tx) => sum + tx.nominal);
      final keluar = txBulan
          .where((tx) => !tx.isPemasukan)
          .fold(0, (sum, tx) => sum + tx.nominal);
      return (
        label: kNamaBulan[d.month - 1],
        tahun: d.year,
        masuk: masuk,
        keluar: keluar,
      );
    });

    int maxNominal = 1;
    for (final b in daftar6Bulan) {
      if (b.masuk > maxNominal) maxNominal = b.masuk;
      if (b.keluar > maxNominal) maxNominal = b.keluar;
    }

    final bulanTerpilih = daftar6Bulan[_indexBulanAktif];
    final selisih = bulanTerpilih.masuk - bulanTerpilih.keluar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik & Laporan'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedAppear(
            index: 0,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: dekorasiKartu(t),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tren 6 Bulan Terakhir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: t.primaryColor),
                          const SizedBox(width: 4),
                          const Text('Masuk', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 10),
                          const Icon(Icons.circle,
                              size: 10, color: Color(0xFFF43F5E)),
                          const SizedBox(width: 4),
                          const Text('Keluar', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 170,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(6, (idx) {
                        final data = daftar6Bulan[idx];
                        final aktif = idx == _indexBulanAktif;
                        final tinggiMasuk = (data.masuk / maxNominal) * 130;
                        final tinggiKeluar = (data.keluar / maxNominal) * 130;

                        return Expanded(
                          child: SmoothTap(
                            scaleDown: 0.94,
                            onTap: () => setState(() => _indexBulanAktif = idx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: aktif
                                    ? t.primaryColor.withValues(alpha: 0.14)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 380),
                                        curve: Curves.easeOutCubic,
                                        width: 10,
                                        height:
                                            tinggiMasuk < 4 && data.masuk > 0
                                                ? 4
                                                : tinggiMasuk,
                                        decoration: BoxDecoration(
                                          color: t.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 380),
                                        curve: Curves.easeOutCubic,
                                        width: 10,
                                        height:
                                            tinggiKeluar < 4 && data.keluar > 0
                                                ? 4
                                                : tinggiKeluar,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF43F5E),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: aktif
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color:
                                          aktif ? t.primaryColor : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    'Detail ${bulanTerpilih.label} ${bulanTerpilih.tahun}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pemasukan',
                          style: TextStyle(color: Colors.grey)),
                      AnimatedCurrencyText(
                        value: bulanTerpilih.masuk,
                        sensor: s,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: t.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pengeluaran',
                          style: TextStyle(color: Colors.grey)),
                      AnimatedCurrencyText(
                        value: bulanTerpilih.keluar,
                        sensor: s,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF43F5E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Arus Kas Bersih',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      AnimatedCurrencyText(
                        value: selisih,
                        sensor: s,
                        prefix: selisih > 0 ? '+' : '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selisih >= 0
                              ? t.primaryColor
                              : const Color(0xFFF43F5E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          AnimatedAppear(
            index: 1,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: dekorasiKartu(t),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.table_chart_rounded, color: t.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Export Laporan Excel / CSV',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Salin seluruh ${widget.transaksi.length} catatan transaksi dalam format tabel CSV agar siap ditempel ke Google Sheets atau Microsoft Excel.',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  SmoothTap(
                    onTap: () async {
                      final csv = _buatCsv();
                      await Clipboard.setData(ClipboardData(text: csv));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tabel CSV berhasil disalin ke clipboard!',
                            ),
                          ),
                        );
                      }
                    },
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: t.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        final csv = _buatCsv();
                        await Clipboard.setData(ClipboardData(text: csv));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tabel CSV berhasil disalin ke clipboard!',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_all_rounded),
                      label: const Text(
                        'Salin Tabel CSV',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
