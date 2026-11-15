import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finance_models.dart';
import '../theme/app_template.dart';
import '../utils/formatters.dart';
import '../widgets/template_picker_sheet.dart';
import '../widgets/smooth_widgets.dart';

class PengaturanTab extends StatelessWidget {
  final AppTemplate template;
  final Future<void> Function(AppTemplate) onPilihTemplate;
  final bool pinAktif;
  final Future<void> Function(String?) onUbahPin;
  final List<Dompet> dompet;
  final List<KategoriItem> kategori;
  final int Function(Dompet) hitungSaldoDompet;
  final void Function(Dompet) onTambahDompet;
  final void Function(String id) onHapusDompet;
  final void Function(KategoriItem) onTambahKategori;
  final void Function(String nama, bool isPemasukan) onHapusKategori;
  final String Function() onExportJson;
  final void Function(String raw) onImportJson;

  const PengaturanTab({
    super.key,
    required this.template,
    required this.onPilihTemplate,
    required this.pinAktif,
    required this.onUbahPin,
    required this.dompet,
    required this.kategori,
    required this.hitungSaldoDompet,
    required this.onTambahDompet,
    required this.onHapusDompet,
    required this.onTambahKategori,
    required this.onHapusKategori,
    required this.onExportJson,
    required this.onImportJson,
  });

  void _dialogAturPin(BuildContext context) {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(pinAktif ? 'Ganti PIN Keamanan' : 'Pasang PIN 4 Digit'),
        content: TextField(
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Masukkan 4 Digit Angka',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          if (pinAktif)
            TextButton(
              onPressed: () async {
                await onUbahPin(null);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kunci PIN dinonaktifkan.')),
                  );
                }
              },
              child: const Text(
                'Matikan PIN',
                style: TextStyle(color: Color(0xFFF43F5E)),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final p = pinCtrl.text.trim();
              if (p.length != 4 || int.tryParse(p) == null) return;
              await onUbahPin(p);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('PIN keamanan berhasil disimpan!')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _dialogTambahDompet(BuildContext context) {
    final namaCtrl = TextEditingController();
    final saldoCtrl = TextEditingController(text: '0');
    String iconKey = 'wallet';
    int warna = kPilihanWarna.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Tambah Dompet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Dompet (mis. BCA, GoPay)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: saldoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Saldo Awal',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['wallet', 'bank', 'ewallet', 'card'].map((k) {
                    return ChoiceChip(
                      label: Icon(ikonDariKey(k), size: 18),
                      selected: iconKey == k,
                      onSelected: (_) => setDlg(() => iconKey = k),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: kPilihanWarna.map((w) {
                    return GestureDetector(
                      onTap: () => setDlg(() => warna = w),
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Color(w),
                        child: warna == w
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final nama = namaCtrl.text.trim();
                final saldo = int.tryParse(saldoCtrl.text.trim()) ?? 0;
                if (nama.isEmpty) return;
                onTambahDompet(
                  Dompet(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    nama: nama,
                    saldoAwal: saldo,
                    iconKey: iconKey,
                    warnaValue: warna,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogTambahKategori(BuildContext context) {
    final namaCtrl = TextEditingController();
    bool isPemasukan = false;
    String iconKey = 'other';
    int warna = kPilihanWarna.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Tambah Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Pengeluaran')),
                    ButtonSegment(value: true, label: Text('Pemasukan')),
                  ],
                  selected: {isPemasukan},
                  onSelectionChanged: (v) =>
                      setDlg(() => isPemasukan = v.first),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Kategori'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kDaftarIkon.keys.map((k) {
                    return ChoiceChip(
                      label: Icon(ikonDariKey(k), size: 18),
                      selected: iconKey == k,
                      onSelected: (_) => setDlg(() => iconKey = k),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: kPilihanWarna.map((w) {
                    return GestureDetector(
                      onTap: () => setDlg(() => warna = w),
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Color(w),
                        child: warna == w
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final nama = namaCtrl.text.trim();
                if (nama.isEmpty) return;
                onTambahKategori(
                  KategoriItem(
                    nama: nama,
                    isPemasukan: isPemasukan,
                    iconKey: iconKey,
                    warnaValue: warna,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogRestore(BuildContext context) {
    final jsonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Data Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tempel teks backup JSON kamu di bawah ini.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: jsonCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '{"transaksi": ...}',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final data = await Clipboard.getData('text/plain');
                if (data?.text != null) {
                  jsonCtrl.text = data!.text!;
                }
              },
              icon: const Icon(Icons.paste_rounded, size: 16),
              label: const Text('Tempel dari Clipboard'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              try {
                onImportJson(jsonCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil dipulihkan!')),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Format backup JSON tidak valid.'),
                  ),
                );
              }
            },
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = template;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola & Template'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedAppear(
            index: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Template & Gaya Tampilan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: dekorasiKartu(t),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: t.cardGradient),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.palette_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  t.subjudul,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              tampilkanPemilihTemplate(
                                context,
                                aktif: t,
                                onPilih: onPilihTemplate,
                              );
                            },
                            child: const Text('Ganti'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: kDaftarTemplate.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            final item = kDaftarTemplate[i];
                            final aktif = item.id == t.id;
                            return ChoiceChip(
                              avatar: CircleAvatar(
                                backgroundColor: item.primaryColor,
                                radius: 7,
                              ),
                              label: Text(item.nama),
                              selected: aktif,
                              showCheckmark: false,
                              selectedColor:
                                  item.primaryColor.withValues(alpha: 0.25),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    aktif ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) {
                                HapticFeedback.selectionClick();
                                onPilihTemplate(item);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AnimatedAppear(
            index: 1,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: dekorasiKartu(t),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: t.primaryColor.withValues(alpha: 0.16),
                  child: Icon(Icons.lock_rounded, color: t.primaryColor),
                ),
                title: const Text(
                  'Kunci PIN Aplikasi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  pinAktif ? 'Aktif (4 digit PIN)' : 'Nonaktif',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () => _dialogAturPin(context),
                  child: Text(pinAktif ? 'Ubah' : 'Pasang'),
                ),
              ),
            ),
          ),

          AnimatedAppear(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Dompet',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _dialogTambahDompet(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Dompet'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...dompet.map((d) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: dekorasiKartu(t),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Color(d.warnaValue).withValues(alpha: 0.16),
                          child: Icon(ikonDariKey(d.iconKey),
                              color: Color(d.warnaValue)),
                        ),
                        title: Text(d.nama,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Saldo: ${formatRupiah(hitungSaldoDompet(d))}'),
                        trailing: dompet.length > 1
                            ? IconButton(
                                onPressed: () => onHapusDompet(d.id),
                                icon: const Icon(Icons.delete_outline_rounded),
                              )
                            : null,
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          AnimatedAppear(
            index: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Kategori',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _dialogTambahKategori(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Kategori'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: dekorasiKartu(t),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kategori.map((k) {
                      return Chip(
                        avatar: Icon(
                          ikonDariKey(k.iconKey),
                          size: 16,
                          color: Color(k.warnaValue),
                        ),
                        label: Text(
                          '${k.nama} (${k.isPemasukan ? '+' : '-'})',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () => onHapusKategori(k.nama, k.isPemasukan),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          AnimatedAppear(
            index: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Backup & Restore Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: dekorasiKartu(t),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Salin seluruh data keuangan ke format JSON agar aman disimpan di catatan atau dipindahkan ke perangkat lain.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: t.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                final raw = onExportJson();
                                await Clipboard.setData(
                                    ClipboardData(text: raw));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Data backup berhasil disalin ke clipboard!',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Salin Backup'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _dialogRestore(context),
                              icon: const Icon(Icons.restore_rounded, size: 18),
                              label: const Text('Restore'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
