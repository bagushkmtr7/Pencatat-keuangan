import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/finance_models.dart';
import '../theme/app_template.dart';
import '../utils/formatters.dart';
import '../tabs/beranda_tab.dart';
import '../tabs/rencana_tab.dart';
import '../tabs/statistik_tab.dart';
import '../tabs/kelola_tab.dart';

class MainShell extends StatefulWidget {
  final AppTemplate template;
  final Future<void> Function(AppTemplate) onPilihTemplate;
  final bool pinAktif;
  final Future<void> Function(String?) onUbahPin;

  const MainShell({
    super.key,
    required this.template,
    required this.onPilihTemplate,
    required this.pinAktif,
    required this.onUbahPin,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 0;
  bool _sensorSaldo = false;

  final List<Transaksi> _transaksi = [];
  final List<Dompet> _dompet = [];
  final List<KategoriItem> _kategori = [];
  final List<TransferDompet> _transfer = [];
  final List<Anggaran> _anggaran = [];
  final List<TargetTabungan> _tabungan = [];
  final List<HutangPiutang> _hutangPiutang = [];
  final List<TransaksiRutin> _rutin = [];

  int _bulanDipilih = DateTime.now().month;
  int _tahunDipilih = DateTime.now().year;
  bool _tampilkanSemuaWaktu = false;
  String _dompetFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _muatSemuaData();
  }

  List<Dompet> _defaultDompet() => [
        Dompet(
          id: 'd1',
          nama: 'Tunai',
          saldoAwal: 0,
          iconKey: 'wallet',
          warnaValue: 0xFF10B981,
        ),
        Dompet(
          id: 'd2',
          nama: 'Bank',
          saldoAwal: 0,
          iconKey: 'bank',
          warnaValue: 0xFF38BDF8,
        ),
        Dompet(
          id: 'd3',
          nama: 'E-Wallet',
          saldoAwal: 0,
          iconKey: 'ewallet',
          warnaValue: 0xFFA855F7,
        ),
      ];

  List<KategoriItem> _defaultKategori() => [
        KategoriItem(
            nama: 'Makan',
            isPemasukan: false,
            iconKey: 'food',
            warnaValue: 0xFFF59E0B),
        KategoriItem(
            nama: 'Transport',
            isPemasukan: false,
            iconKey: 'car',
            warnaValue: 0xFF38BDF8),
        KategoriItem(
            nama: 'Belanja',
            isPemasukan: false,
            iconKey: 'bag',
            warnaValue: 0xFFA855F7),
        KategoriItem(
            nama: 'Tagihan',
            isPemasukan: false,
            iconKey: 'bill',
            warnaValue: 0xFFF43F5E),
        KategoriItem(
            nama: 'Lainnya',
            isPemasukan: false,
            iconKey: 'other',
            warnaValue: 0xFF14B8A6),
        KategoriItem(
            nama: 'Gaji',
            isPemasukan: true,
            iconKey: 'salary',
            warnaValue: 0xFF10B981),
        KategoriItem(
            nama: 'Bonus',
            isPemasukan: true,
            iconKey: 'gift',
            warnaValue: 0xFF38BDF8),
        KategoriItem(
            nama: 'Usaha',
            isPemasukan: true,
            iconKey: 'store',
            warnaValue: 0xFFD4AF37),
        KategoriItem(
            nama: 'Lainnya',
            isPemasukan: true,
            iconKey: 'other',
            warnaValue: 0xFF14B8A6),
      ];

  Future<void> _muatSemuaData() async {
    final prefs = await SharedPreferences.getInstance();

    final txStr = prefs.getString('daftar_transaksi');
    final dompetStr = prefs.getString('daftar_dompet');
    final katStr = prefs.getString('daftar_kategori');
    final trfStr = prefs.getString('daftar_transfer');
    final angStr = prefs.getString('daftar_anggaran');
    final tabStr = prefs.getString('daftar_tabungan');
    final hpStr = prefs.getString('daftar_hutang_piutang');
    final rutinStr = prefs.getString('daftar_rutin');

    int jumlahAutoRutin = 0;

    setState(() {
      _transaksi.clear();
      if (txStr != null) {
        final list = jsonDecode(txStr) as List<dynamic>;
        _transaksi.addAll(
          list.map((e) => Transaksi.fromMap(e as Map<String, dynamic>)),
        );
      }

      _dompet.clear();
      if (dompetStr != null) {
        final list = jsonDecode(dompetStr) as List<dynamic>;
        _dompet.addAll(
          list.map((e) => Dompet.fromMap(e as Map<String, dynamic>)),
        );
      }
      if (_dompet.isEmpty) _dompet.addAll(_defaultDompet());

      _kategori.clear();
      if (katStr != null) {
        final list = jsonDecode(katStr) as List<dynamic>;
        _kategori.addAll(
          list.map((e) => KategoriItem.fromMap(e as Map<String, dynamic>)),
        );
      }
      if (_kategori.isEmpty) _kategori.addAll(_defaultKategori());

      _transfer.clear();
      if (trfStr != null) {
        final list = jsonDecode(trfStr) as List<dynamic>;
        _transfer.addAll(
          list.map((e) => TransferDompet.fromMap(e as Map<String, dynamic>)),
        );
        _transfer.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      }

      _anggaran.clear();
      if (angStr != null) {
        final list = jsonDecode(angStr) as List<dynamic>;
        _anggaran.addAll(
          list.map((e) => Anggaran.fromMap(e as Map<String, dynamic>)),
        );
      }

      _tabungan.clear();
      if (tabStr != null) {
        final list = jsonDecode(tabStr) as List<dynamic>;
        _tabungan.addAll(
          list.map((e) => TargetTabungan.fromMap(e as Map<String, dynamic>)),
        );
      }

      _hutangPiutang.clear();
      if (hpStr != null) {
        final list = jsonDecode(hpStr) as List<dynamic>;
        _hutangPiutang.addAll(
          list.map((e) => HutangPiutang.fromMap(e as Map<String, dynamic>)),
        );
      }

      _rutin.clear();
      if (rutinStr != null) {
        final list = jsonDecode(rutinStr) as List<dynamic>;
        _rutin.addAll(
          list.map((e) => TransaksiRutin.fromMap(e as Map<String, dynamic>)),
        );
      }

      final now = DateTime.now();
      final kunciBulanIni = '${now.year}-${now.month}';
      for (int i = 0; i < _rutin.length; i++) {
        final r = _rutin[i];
        if (now.day >= r.tanggalBulanan &&
            r.terakhirBulanTahun != kunciBulanIni) {
          final maxHari = DateTime(now.year, now.month + 1, 0).day;
          final hariValid =
              r.tanggalBulanan > maxHari ? maxHari : r.tanggalBulanan;
          _transaksi.insert(
            0,
            Transaksi(
              id: '${DateTime.now().millisecondsSinceEpoch}_$i',
              judul: '${r.judul} (Rutin)',
              nominal: r.nominal,
              isPemasukan: r.isPemasukan,
              kategori: r.kategori,
              tanggal: DateTime(now.year, now.month, hariValid),
              dompet: r.dompet,
            ),
          );
          _rutin[i] = TransaksiRutin(
            id: r.id,
            judul: r.judul,
            nominal: r.nominal,
            isPemasukan: r.isPemasukan,
            kategori: r.kategori,
            dompet: r.dompet,
            tanggalBulanan: r.tanggalBulanan,
            terakhirBulanTahun: kunciBulanIni,
          );
          jumlahAutoRutin++;
        }
      }

      _transaksi.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    });

    if (jumlahAutoRutin > 0) {
      await _simpanSemuaData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$jumlahAutoRutin jadwal transaksi rutin otomatis dicatat bulan ini!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _simpanSemuaData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'daftar_transaksi',
      jsonEncode(_transaksi.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      'daftar_dompet',
      jsonEncode(_dompet.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      'daftar_kategori',
      jsonEncode(_kategori.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      'daftar_transfer',
      jsonEncode(_transfer.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      'daftar_anggaran',
      jsonEncode(_anggaran.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      'daftar_tabungan',
      jsonEncode(_tabungan.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      'daftar_hutang_piutang',
      jsonEncode(_hutangPiutang.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      'daftar_rutin',
      jsonEncode(_rutin.map((e) => e.toMap()).toList()),
    );
  }

  int _hitungSaldoDompet(Dompet d) {
    final masuk = _transaksi
        .where((t) => t.dompet == d.nama && t.isPemasukan)
        .fold(0, (s, t) => s + t.nominal);
    final keluar = _transaksi
        .where((t) => t.dompet == d.nama && !t.isPemasukan)
        .fold(0, (s, t) => s + t.nominal);
    final trfMasuk = _transfer
        .where((tr) => tr.keDompet == d.nama)
        .fold(0, (s, tr) => s + tr.nominal);
    final trfKeluar = _transfer
        .where((tr) => tr.dariDompet == d.nama)
        .fold(0, (s, tr) => s + tr.nominal);
    return d.saldoAwal + masuk - keluar + trfMasuk - trfKeluar;
  }

  int get _totalSemuaDompet =>
      _dompet.fold(0, (sum, d) => sum + _hitungSaldoDompet(d));

  KategoriItem _cariKategori(String nama, bool isPemasukan) {
    return _kategori.firstWhere(
      (k) => k.nama == nama && k.isPemasukan == isPemasukan,
      orElse: () => _kategori.firstWhere(
        (k) => k.nama == nama,
        orElse: () => KategoriItem(
          nama: nama,
          isPemasukan: isPemasukan,
          iconKey: isPemasukan ? 'salary' : 'other',
          warnaValue: isPemasukan ? 0xFF10B981 : 0xFF14B8A6,
        ),
      ),
    );
  }

  void _bukaFormTransaksi({Transaksi? transaksiEdit}) {
    HapticFeedback.lightImpact();
    final t = widget.template;
    final isEdit = transaksiEdit != null;
    final judulCtrl =
        TextEditingController(text: isEdit ? transaksiEdit.judul : '');
    final nominalCtrl = TextEditingController(
        text: isEdit ? transaksiEdit.nominal.toString() : '');
    bool isPemasukan = isEdit ? transaksiEdit.isPemasukan : false;

    List<KategoriItem> listKat(bool pemasukan) =>
        _kategori.where((k) => k.isPemasukan == pemasukan).toList();

    final awalKat = listKat(isPemasukan);
    String katDipilih = isEdit
        ? transaksiEdit.kategori
        : (awalKat.isNotEmpty ? awalKat.first.nama : 'Lainnya');

    String dompetDipilih = isEdit
        ? transaksiEdit.dompet
        : (_dompetFilter != 'Semua'
            ? _dompetFilter
            : (_dompet.isNotEmpty ? _dompet.first.nama : 'Tunai'));

    final maxHari = DateTime(_tahunDipilih, _bulanDipilih + 1, 0).day;
    final hariAman =
        DateTime.now().day > maxHari ? maxHari : DateTime.now().day;
    DateTime tanggalDipilih = isEdit
        ? transaksiEdit.tanggal
        : DateTime(_tahunDipilih, _bulanDipilih, hariAman);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(t.cardRadius + 6),
        ),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final daftarKat = listKat(isPemasukan);
          if (daftarKat.isNotEmpty &&
              !daftarKat.any((k) => k.nama == katDipilih)) {
            katDipilih = daftarKat.first.nama;
          }
          final aksen =
              isPemasukan ? t.primaryColor : const Color(0xFFF43F5E);

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Text(
                    isEdit ? 'Edit Transaksi' : 'Transaksi Baru',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: t.inputColor,
                      borderRadius: BorderRadius.circular(t.cardRadius * 0.7),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModal(() {
                                isPemasukan = false;
                                final l = listKat(false);
                                if (l.isNotEmpty) katDipilih = l.first.nama;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: !isPemasukan
                                    ? const Color(0xFFF43F5E)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(t.cardRadius * 0.5),
                              ),
                              child: Text(
                                'Pengeluaran',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: !isPemasukan
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModal(() {
                                isPemasukan = true;
                                final l = listKat(true);
                                if (l.isNotEmpty) katDipilih = l.first.nama;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: isPemasukan
                                    ? t.primaryColor
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(t.cardRadius * 0.5),
                              ),
                              child: Text(
                                'Pemasukan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isPemasukan ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nominalCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: t.inputColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(t.cardRadius * 0.7),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: judulCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      filled: true,
                      fillColor: t.inputColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(t.cardRadius * 0.7),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Dompet',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _dompet.map((d) {
                      final aktif = dompetDipilih == d.nama;
                      return ChoiceChip(
                        avatar: Icon(
                          ikonDariKey(d.iconKey),
                          size: 16,
                          color: aktif ? Colors.white : Color(d.warnaValue),
                        ),
                        label: Text(d.nama),
                        selected: aktif,
                        selectedColor: Color(d.warnaValue),
                        labelStyle: TextStyle(
                          color: aktif ? Colors.white : null,
                          fontWeight:
                              aktif ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setModal(() => dompetDipilih = d.nama);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: daftarKat.map((k) {
                      final aktif = katDipilih == k.nama;
                      return ChoiceChip(
                        avatar: Icon(
                          ikonDariKey(k.iconKey),
                          size: 16,
                          color: aktif ? Colors.white : Color(k.warnaValue),
                        ),
                        label: Text(k.nama),
                        selected: aktif,
                        selectedColor: aksen,
                        labelStyle: TextStyle(
                          color: aktif ? Colors.white : null,
                          fontWeight:
                              aktif ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setModal(() => katDipilih = k.nama);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () async {
                      final hasil = await showDatePicker(
                        context: ctx,
                        initialDate: tanggalDipilih,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (hasil != null) {
                        setModal(() => tanggalDipilih = hasil);
                      }
                    },
                    borderRadius: BorderRadius.circular(t.cardRadius * 0.7),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: t.inputColor,
                        borderRadius: BorderRadius.circular(t.cardRadius * 0.7),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_rounded,
                              size: 20, color: aksen),
                          const SizedBox(width: 12),
                          Text(formatTanggal(tanggalDipilih)),
                          const Spacer(),
                          const Text('Ubah',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: aksen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(t.cardRadius * 0.8),
                      ),
                    ),
                    onPressed: () {
                      final judul = judulCtrl.text.trim();
                      final nominal =
                          int.tryParse(nominalCtrl.text.trim()) ?? 0;
                      if (judul.isEmpty || nominal <= 0) return;

                      HapticFeedback.mediumImpact();
                      setState(() {
                        if (isEdit) {
                          final idx = _transaksi
                              .indexWhere((tx) => tx.id == transaksiEdit.id);
                          if (idx != -1) {
                            _transaksi[idx] = Transaksi(
                              id: transaksiEdit.id,
                              judul: judul,
                              nominal: nominal,
                              isPemasukan: isPemasukan,
                              kategori: katDipilih,
                              tanggal: tanggalDipilih,
                              dompet: dompetDipilih,
                            );
                          }
                        } else {
                          _transaksi.insert(
                            0,
                            Transaksi(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              judul: judul,
                              nominal: nominal,
                              isPemasukan: isPemasukan,
                              kategori: katDipilih,
                              tanggal: tanggalDipilih,
                              dompet: dompetDipilih,
                            ),
                          );
                        }
                        _transaksi
                            .sort((a, b) => b.tanggal.compareTo(a.tanggal));
                        if (!_tampilkanSemuaWaktu) {
                          _bulanDipilih = tanggalDipilih.month;
                          _tahunDipilih = tanggalDipilih.year;
                        }
                      });
                      _simpanSemuaData();
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Simpan Transaksi',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _bukaFormTransfer() {
    HapticFeedback.lightImpact();
    final t = widget.template;
    if (_dompet.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal butuh 2 dompet buat transfer saldo.'),
        ),
      );
      return;
    }

    String dari = _dompet[0].nama;
    String ke = _dompet[1].nama;
    final nominalCtrl = TextEditingController();
    final catatanCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(t.cardRadius + 6),
        ),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Transfer Antar Dompet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: dari,
                      decoration: const InputDecoration(
                        labelText: 'Dari Dompet',
                        border: OutlineInputBorder(),
                      ),
                      items: _dompet
                          .map((d) => DropdownMenuItem(
                              value: d.nama, child: Text(d.nama)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModal(() => dari = v);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward_rounded),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: ke,
                      decoration: const InputDecoration(
                        labelText: 'Ke Dompet',
                        border: OutlineInputBorder(),
                      ),
                      items: _dompet
                          .map((d) => DropdownMenuItem(
                              value: d.nama, child: Text(d.nama)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModal(() => ke = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nominalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Transfer',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catatanCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: t.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  final nominal = int.tryParse(nominalCtrl.text.trim()) ?? 0;
                  if (nominal <= 0 || dari == ke) return;
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _transfer.insert(
                      0,
                      TransferDompet(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        dariDompet: dari,
                        keDompet: ke,
                        nominal: nominal,
                        tanggal: DateTime.now(),
                        catatan: catatanCtrl.text.trim(),
                      ),
                    );
                  });
                  _simpanSemuaData();
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Pindahkan Saldo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivePage(AppTemplate t) {
    switch (_tabIndex) {
      case 0:
        return BerandaTab(
          key: const ValueKey('tab_0'),
          template: t,
          onPilihTemplate: widget.onPilihTemplate,
          sensorSaldo: _sensorSaldo,
          onToggleSensor: () => setState(() => _sensorSaldo = !_sensorSaldo),
          transaksi: _transaksi,
          dompet: _dompet,
          transfer: _transfer,
          anggaran: _anggaran,
          bulanDipilih: _bulanDipilih,
          tahunDipilih: _tahunDipilih,
          tampilkanSemuaWaktu: _tampilkanSemuaWaktu,
          dompetFilter: _dompetFilter,
          totalSemuaDompet: _totalSemuaDompet,
          hitungSaldoDompet: _hitungSaldoDompet,
          cariKategori: _cariKategori,
          onGantiBulan: (delta) {
            setState(() {
              _tampilkanSemuaWaktu = false;
              final baru = DateTime(_tahunDipilih, _bulanDipilih + delta, 1);
              _bulanDipilih = baru.month;
              _tahunDipilih = baru.year;
            });
          },
          onToggleSemuaWaktu: (val) =>
              setState(() => _tampilkanSemuaWaktu = val),
          onPilihDompet: (nama) => setState(() => _dompetFilter = nama),
          onEditTransaksi: (tx) => _bukaFormTransaksi(transaksiEdit: tx),
          onHapusTransaksi: (item) {
            setState(() => _transaksi.removeWhere((tx) => tx.id == item.id));
            _simpanSemuaData();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Catatan "${item.judul}" dihapus'),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Batal',
                  onPressed: () {
                    setState(() {
                      _transaksi.add(item);
                      _transaksi.sort((a, b) => b.tanggal.compareTo(a.tanggal));
                    });
                    _simpanSemuaData();
                  },
                ),
              ),
            );
          },
          onBukaTransfer: _bukaFormTransfer,
          onHapusTransfer: (id) {
            setState(() => _transfer.removeWhere((tr) => tr.id == id));
            _simpanSemuaData();
          },
        );
      case 1:
        return PerencanaanTab(
          key: const ValueKey('tab_1'),
          template: t,
          bulanDipilih: _bulanDipilih,
          tahunDipilih: _tahunDipilih,
          transaksi: _transaksi,
          kategori: _kategori,
          anggaran: _anggaran,
          tabungan: _tabungan,
          hutangPiutang: _hutangPiutang,
          rutin: _rutin,
          dompet: _dompet,
          onSimpanAnggaran: (kat, batas) {
            setState(() {
              final idx = _anggaran.indexWhere((a) => a.kategori == kat);
              if (idx != -1) {
                _anggaran[idx] = Anggaran(kategori: kat, batasNominal: batas);
              } else {
                _anggaran.add(Anggaran(kategori: kat, batasNominal: batas));
              }
            });
            _simpanSemuaData();
          },
          onHapusAnggaran: (kat) {
            setState(() => _anggaran.removeWhere((a) => a.kategori == kat));
            _simpanSemuaData();
          },
          onTambahTabungan: (tb) {
            setState(() => _tabungan.add(tb));
            _simpanSemuaData();
          },
          onSetorTabungan: (id, nominal, sumberDompet) {
            setState(() {
              final idx = _tabungan.indexWhere((tb) => tb.id == id);
              if (idx != -1) {
                final lama = _tabungan[idx];
                _tabungan[idx] = TargetTabungan(
                  id: lama.id,
                  nama: lama.nama,
                  targetNominal: lama.targetNominal,
                  terkumpulNominal: lama.terkumpulNominal + nominal,
                  warnaValue: lama.warnaValue,
                );
                if (sumberDompet != null) {
                  _transaksi.insert(
                    0,
                    Transaksi(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      judul: 'Tabungan: ${lama.nama}',
                      nominal: nominal,
                      isPemasukan: false,
                      kategori: 'Lainnya',
                      tanggal: DateTime.now(),
                      dompet: sumberDompet,
                    ),
                  );
                }
              }
            });
            _simpanSemuaData();
          },
          onHapusTabungan: (id) {
            setState(() => _tabungan.removeWhere((tb) => tb.id == id));
            _simpanSemuaData();
          },
          onTambahHutangPiutang: (hp, dompetTerkait) {
            setState(() {
              _hutangPiutang.insert(0, hp);
              if (dompetTerkait != null) {
                _transaksi.insert(
                  0,
                  Transaksi(
                    id: '${DateTime.now().millisecondsSinceEpoch}_hp',
                    judul: hp.isHutangSaya
                        ? 'Pinjaman dari ${hp.namaOrang}'
                        : 'Pinjamkan ke ${hp.namaOrang}',
                    nominal: hp.totalNominal,
                    isPemasukan: hp.isHutangSaya,
                    kategori: 'Lainnya',
                    tanggal: DateTime.now(),
                    dompet: dompetTerkait,
                  ),
                );
              }
            });
            _simpanSemuaData();
          },
          onBayarHutangPiutang: (id, bayar, dompetTerkait) {
            setState(() {
              final idx = _hutangPiutang.indexWhere((h) => h.id == id);
              if (idx != -1) {
                final lama = _hutangPiutang[idx];
                final baruBayar =
                    (lama.dibayarNominal + bayar).clamp(0, lama.totalNominal);
                _hutangPiutang[idx] = HutangPiutang(
                  id: lama.id,
                  namaOrang: lama.namaOrang,
                  keterangan: lama.keterangan,
                  totalNominal: lama.totalNominal,
                  dibayarNominal: baruBayar,
                  isHutangSaya: lama.isHutangSaya,
                  jatuhTempo: lama.jatuhTempo,
                );
                if (dompetTerkait != null) {
                  _transaksi.insert(
                    0,
                    Transaksi(
                      id: '${DateTime.now().millisecondsSinceEpoch}_byr',
                      judul: lama.isHutangSaya
                          ? 'Bayar hutang ke ${lama.namaOrang}'
                          : 'Terima piutang dari ${lama.namaOrang}',
                      nominal: bayar,
                      isPemasukan: !lama.isHutangSaya,
                      kategori: 'Lainnya',
                      tanggal: DateTime.now(),
                      dompet: dompetTerkait,
                    ),
                  );
                }
              }
            });
            _simpanSemuaData();
          },
          onHapusHutangPiutang: (id) {
            setState(() => _hutangPiutang.removeWhere((h) => h.id == id));
            _simpanSemuaData();
          },
          onTambahRutin: (r) {
            setState(() => _rutin.add(r));
            _simpanSemuaData();
          },
          onCatatRutinManual: (r) {
            setState(() {
              _transaksi.insert(
                0,
                Transaksi(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  judul: '${r.judul} (Rutin)',
                  nominal: r.nominal,
                  isPemasukan: r.isPemasukan,
                  kategori: r.kategori,
                  tanggal: DateTime.now(),
                  dompet: r.dompet,
                ),
              );
              final now = DateTime.now();
              final idx = _rutin.indexWhere((x) => x.id == r.id);
              if (idx != -1) {
                _rutin[idx] = TransaksiRutin(
                  id: r.id,
                  judul: r.judul,
                  nominal: r.nominal,
                  isPemasukan: r.isPemasukan,
                  kategori: r.kategori,
                  dompet: r.dompet,
                  tanggalBulanan: r.tanggalBulanan,
                  terakhirBulanTahun: '${now.year}-${now.month}',
                );
              }
            });
            _simpanSemuaData();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('"${r.judul}" berhasil dicatat!')),
            );
          },
          onHapusRutin: (id) {
            setState(() => _rutin.removeWhere((r) => r.id == id));
            _simpanSemuaData();
          },
        );
      case 2:
        return StatistikTab(
          key: const ValueKey('tab_2'),
          template: t,
          sensorSaldo: _sensorSaldo,
          transaksi: _transaksi,
        );
      default:
        return PengaturanTab(
          key: const ValueKey('tab_3'),
          template: t,
          onPilihTemplate: widget.onPilihTemplate,
          pinAktif: widget.pinAktif,
          onUbahPin: widget.onUbahPin,
          dompet: _dompet,
          kategori: _kategori,
          hitungSaldoDompet: _hitungSaldoDompet,
          onTambahDompet: (d) {
            setState(() => _dompet.add(d));
            _simpanSemuaData();
          },
          onHapusDompet: (id) {
            if (_dompet.length <= 1) return;
            setState(() {
              final target = _dompet.firstWhere((d) => d.id == id);
              if (_dompetFilter == target.nama) _dompetFilter = 'Semua';
              _dompet.removeWhere((d) => d.id == id);
            });
            _simpanSemuaData();
          },
          onTambahKategori: (k) {
            setState(() => _kategori.add(k));
            _simpanSemuaData();
          },
          onHapusKategori: (nama, isPemasukan) {
            setState(() => _kategori.removeWhere(
                (k) => k.nama == nama && k.isPemasukan == isPemasukan));
            _simpanSemuaData();
          },
          onExportJson: () => jsonEncode({
            'transaksi': _transaksi.map((e) => e.toMap()).toList(),
            'dompet': _dompet.map((e) => e.toMap()).toList(),
            'kategori': _kategori.map((e) => e.toMap()).toList(),
            'transfer': _transfer.map((e) => e.toMap()).toList(),
            'anggaran': _anggaran.map((e) => e.toMap()).toList(),
            'tabungan': _tabungan.map((e) => e.toMap()).toList(),
            'hutangPiutang': _hutangPiutang.map((e) => e.toMap()).toList(),
            'rutin': _rutin.map((e) => e.toMap()).toList(),
          }),
          onImportJson: (raw) {
            final map = jsonDecode(raw) as Map<String, dynamic>;
            setState(() {
              if (map['transaksi'] != null) {
                _transaksi
                  ..clear()
                  ..addAll((map['transaksi'] as List).map(
                      (e) => Transaksi.fromMap(e as Map<String, dynamic>)));
              }
              if (map['dompet'] != null) {
                _dompet
                  ..clear()
                  ..addAll((map['dompet'] as List)
                      .map((e) => Dompet.fromMap(e as Map<String, dynamic>)));
              }
              if (map['kategori'] != null) {
                _kategori
                  ..clear()
                  ..addAll((map['kategori'] as List).map(
                      (e) => KategoriItem.fromMap(e as Map<String, dynamic>)));
              }
              if (map['transfer'] != null) {
                _transfer
                  ..clear()
                  ..addAll((map['transfer'] as List).map((e) =>
                      TransferDompet.fromMap(e as Map<String, dynamic>)));
              }
              if (map['anggaran'] != null) {
                _anggaran
                  ..clear()
                  ..addAll((map['anggaran'] as List)
                      .map((e) => Anggaran.fromMap(e as Map<String, dynamic>)));
              }
              if (map['tabungan'] != null) {
                _tabungan
                  ..clear()
                  ..addAll((map['tabungan'] as List).map((e) =>
                      TargetTabungan.fromMap(e as Map<String, dynamic>)));
              }
              if (map['hutangPiutang'] != null) {
                _hutangPiutang
                  ..clear()
                  ..addAll((map['hutangPiutang'] as List).map(
                      (e) => HutangPiutang.fromMap(e as Map<String, dynamic>)));
              }
              if (map['rutin'] != null) {
                _rutin
                  ..clear()
                  ..addAll((map['rutin'] as List).map((e) =>
                      TransaksiRutin.fromMap(e as Map<String, dynamic>)));
              }
            });
            _simpanSemuaData();
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.018),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildActivePage(t),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _tabIndex == 0
            ? FloatingActionButton.extended(
                key: const ValueKey('fab_catat'),
                onPressed: () => _bukaFormTransaksi(),
                backgroundColor: t.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(t.cardRadius * 0.9),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Catat',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : const SizedBox.shrink(key: ValueKey('fab_empty')),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        backgroundColor: t.cardColor,
        indicatorColor: t.primaryColor.withValues(alpha: 0.2),
        animationDuration: const Duration(milliseconds: 350),
        onDestinationSelected: (idx) {
          if (idx == _tabIndex) return;
          HapticFeedback.selectionClick();
          setState(() => _tabIndex = idx);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            selectedIcon: Icon(Icons.track_changes_rounded),
            label: 'Rencana',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Statistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Kelola',
          ),
        ],
      ),
    );
  }
}
