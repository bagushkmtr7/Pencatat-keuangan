import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finance_models.dart';
import '../theme/app_template.dart';
import '../utils/formatters.dart';
import '../widgets/smooth_widgets.dart';

class PerencanaanTab extends StatefulWidget {
  final AppTemplate template;
  final int bulanDipilih;
  final int tahunDipilih;
  final List<Transaksi> transaksi;
  final List<KategoriItem> kategori;
  final List<Anggaran> anggaran;
  final List<TargetTabungan> tabungan;
  final List<HutangPiutang> hutangPiutang;
  final List<TransaksiRutin> rutin;
  final List<Dompet> dompet;
  final void Function(String kategori, int batas) onSimpanAnggaran;
  final void Function(String kategori) onHapusAnggaran;
  final void Function(TargetTabungan) onTambahTabungan;
  final void Function(String id, int nominal, String? sumberDompet)
      onSetorTabungan;
  final void Function(String id) onHapusTabungan;
  final void Function(HutangPiutang, String? dompetTerkait)
      onTambahHutangPiutang;
  final void Function(String id, int bayar, String? dompetTerkait)
      onBayarHutangPiutang;
  final void Function(String id) onHapusHutangPiutang;
  final void Function(TransaksiRutin) onTambahRutin;
  final void Function(TransaksiRutin) onCatatRutinManual;
  final void Function(String id) onHapusRutin;

  const PerencanaanTab({
    super.key,
    required this.template,
    required this.bulanDipilih,
    required this.tahunDipilih,
    required this.transaksi,
    required this.kategori,
    required this.anggaran,
    required this.tabungan,
    required this.hutangPiutang,
    required this.rutin,
    required this.dompet,
    required this.onSimpanAnggaran,
    required this.onHapusAnggaran,
    required this.onTambahTabungan,
    required this.onSetorTabungan,
    required this.onHapusTabungan,
    required this.onTambahHutangPiutang,
    required this.onBayarHutangPiutang,
    required this.onHapusHutangPiutang,
    required this.onTambahRutin,
    required this.onCatatRutinManual,
    required this.onHapusRutin,
  });

  @override
  State<PerencanaanTab> createState() => _PerencanaanTabState();
}

class _PerencanaanTabState extends State<PerencanaanTab> {
  int _subTab = 0;

  void _dialogAnggaran() {
    final katPengeluaran = widget.kategori
        .where((k) => !k.isPemasukan)
        .map((k) => k.nama)
        .toList();
    final opsi = ['Total Bulanan', ...katPengeluaran];
    String dipilih = opsi.first;
    final batasCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Atur Batas Anggaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: dipilih,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: opsi
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDlg(() => dipilih = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: batasCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Batas Maksimal per Bulan',
                  prefixText: 'Rp ',
                ),
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
                final batas = int.tryParse(batasCtrl.text.trim()) ?? 0;
                if (batas <= 0) return;
                widget.onSimpanAnggaran(dipilih, batas);
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogTargetTabungan() {
    final namaCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    int warna = kPilihanWarna.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Target Tabungan Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama Tujuan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Nominal',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: kPilihanWarna.map((w) {
                  return GestureDetector(
                    onTap: () => setDlg(() => warna = w),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(w),
                      child: warna == w
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
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
                final nama = namaCtrl.text.trim();
                final target = int.tryParse(targetCtrl.text.trim()) ?? 0;
                if (nama.isEmpty || target <= 0) return;
                widget.onTambahTabungan(
                  TargetTabungan(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    nama: nama,
                    targetNominal: target,
                    terkumpulNominal: 0,
                    warnaValue: warna,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogSetor(TargetTabungan item) {
    final nominalCtrl = TextEditingController();
    String? dompetSumber =
        widget.dompet.isNotEmpty ? widget.dompet.first.nama : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text('Nabung: ${item.nama}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nominalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Setoran',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: dompetSumber,
                decoration:
                    const InputDecoration(labelText: 'Potong dari Dompet'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Jangan potong saldo dompet'),
                  ),
                  ...widget.dompet.map((d) => DropdownMenuItem<String?>(
                        value: d.nama,
                        child: Text(d.nama),
                      )),
                ],
                onChanged: (v) => setDlg(() => dompetSumber = v),
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
                final nom = int.tryParse(nominalCtrl.text.trim()) ?? 0;
                if (nom <= 0) return;
                widget.onSetorTabungan(item.id, nom, dompetSumber);
                Navigator.pop(ctx);
              },
              child: const Text('Setor'),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogHutangPiutang() {
    bool isHutangSaya = false;
    final namaCtrl = TextEditingController();
    final ketCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    DateTime tempo = DateTime.now().add(const Duration(days: 30));
    String? dompetTerkait =
        widget.dompet.isNotEmpty ? widget.dompet.first.nama : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Catat Hutang / Piutang'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Piutang')),
                    ButtonSegment(value: true, label: Text('Hutang Saya')),
                  ],
                  selected: {isHutangSaya},
                  onSelectionChanged: (v) =>
                      setDlg(() => isHutangSaya = v.first),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: namaCtrl,
                  decoration: InputDecoration(
                    labelText: isHutangSaya
                        ? 'Nama Pemberi Pinjaman'
                        : 'Nama Peminjam',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nomCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ketCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan (opsional)',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  value: dompetTerkait,
                  decoration: InputDecoration(
                    labelText: isHutangSaya
                        ? 'Masukkan dana ke Dompet'
                        : 'Ambil dana dari Dompet',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Jangan ubah saldo dompet'),
                    ),
                    ...widget.dompet.map((d) => DropdownMenuItem<String?>(
                          value: d.nama,
                          child: Text(d.nama),
                        )),
                  ],
                  onChanged: (v) => setDlg(() => dompetTerkait = v),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final h = await showDatePicker(
                      context: ctx,
                      initialDate: tempo,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (h != null) setDlg(() => tempo = h);
                  },
                  icon: const Icon(Icons.event_rounded, size: 18),
                  label: Text('Jatuh Tempo: ${formatTanggal(tempo)}'),
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
                final nom = int.tryParse(nomCtrl.text.trim()) ?? 0;
                if (nama.isEmpty || nom <= 0) return;
                widget.onTambahHutangPiutang(
                  HutangPiutang(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    namaOrang: nama,
                    keterangan: ketCtrl.text.trim(),
                    totalNominal: nom,
                    dibayarNominal: 0,
                    isHutangSaya: isHutangSaya,
                    jatuhTempo: tempo,
                  ),
                  dompetTerkait,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogCicilHutangPiutang(HutangPiutang item) {
    final bayarCtrl = TextEditingController(text: item.sisaNominal.toString());
    String? dompetTerkait =
        widget.dompet.isNotEmpty ? widget.dompet.first.nama : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(item.isHutangSaya
              ? 'Bayar Hutang: ${item.namaOrang}'
              : 'Terima Piutang: ${item.namaOrang}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bayarCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Pembayaran',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: dompetTerkait,
                decoration: InputDecoration(
                  labelText: item.isHutangSaya
                      ? 'Potong dari Dompet'
                      : 'Simpan ke Dompet',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Jangan ubah saldo dompet'),
                  ),
                  ...widget.dompet.map((d) => DropdownMenuItem<String?>(
                        value: d.nama,
                        child: Text(d.nama),
                      )),
                ],
                onChanged: (v) => setDlg(() => dompetTerkait = v),
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
                final bayar = int.tryParse(bayarCtrl.text.trim()) ?? 0;
                if (bayar <= 0) return;
                widget.onBayarHutangPiutang(item.id, bayar, dompetTerkait);
                Navigator.pop(ctx);
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogRutin() {
    final judulCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    bool isPemasukan = false;
    int tgl = 1;
    String dompetDipilih =
        widget.dompet.isNotEmpty ? widget.dompet.first.nama : 'Tunai';

    List<String> listKat(bool pemasukan) => widget.kategori
        .where((k) => k.isPemasukan == pemasukan)
        .map((k) => k.nama)
        .toList();

    String katDipilih =
        listKat(false).isNotEmpty ? listKat(false).first : 'Tagihan';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final daftarKat = listKat(isPemasukan);
          if (daftarKat.isNotEmpty && !daftarKat.contains(katDipilih)) {
            katDipilih = daftarKat.first;
          }

          return AlertDialog(
            title: const Text('Jadwal Rutin Bulanan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Tagihan')),
                      ButtonSegment(value: true, label: Text('Gaji/Masuk')),
                    ],
                    selected: {isPemasukan},
                    onSelectionChanged: (v) =>
                        setDlg(() => isPemasukan = v.first),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: judulCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama (mis. Wi-Fi, Gaji Bulanan)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nomCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: tgl,
                    decoration: const InputDecoration(
                      labelText: 'Setiap Tanggal',
                    ),
                    items: List.generate(28, (i) => i + 1)
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text('Tanggal $d setiap bulan'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDlg(() => tgl = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: dompetDipilih,
                    decoration: const InputDecoration(labelText: 'Dompet'),
                    items: widget.dompet
                        .map((d) => DropdownMenuItem(
                            value: d.nama, child: Text(d.nama)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDlg(() => dompetDipilih = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: katDipilih,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: daftarKat
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDlg(() => katDipilih = v);
                    },
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
                  final judul = judulCtrl.text.trim();
                  final nom = int.tryParse(nomCtrl.text.trim()) ?? 0;
                  if (judul.isEmpty || nom <= 0) return;
                  widget.onTambahRutin(
                    TransaksiRutin(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      judul: judul,
                      nominal: nom,
                      isPemasukan: isPemasukan,
                      kategori: katDipilih,
                      dompet: dompetDipilih,
                      tanggalBulanan: tgl,
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;

    final txBulanIni = widget.transaksi.where((tx) =>
        !tx.isPemasukan &&
        tx.tanggal.month == widget.bulanDipilih &&
        tx.tanggal.year == widget.tahunDipilih);

    final totalPiutang = widget.hutangPiutang
        .where((h) => !h.isHutangSaya && !h.lunas)
        .fold(0, (s, h) => s + h.sisaNominal);
    final totalHutang = widget.hutangPiutang
        .where((h) => h.isHutangSaya && !h.lunas)
        .fold(0, (s, h) => s + h.sisaNominal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perencanaan Keuangan'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Target')),
                ButtonSegment(value: 1, label: Text('Hutang')),
                ButtonSegment(value: 2, label: Text('Rutin')),
              ],
              selected: {_subTab},
              onSelectionChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _subTab = v.first);
              },
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _subTab == 0
                  ? ListView(
                      key: const ValueKey('sub_0'),
                      padding: const EdgeInsets.all(16),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Anggaran ${kNamaBulan[widget.bulanDipilih - 1]} ${widget.tahunDipilih}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _dialogAnggaran,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Atur'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (widget.anggaran.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: dekorasiKartu(t),
                            child: const Text(
                              'Belum ada batas anggaran bulanan.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        else
                          ...widget.anggaran.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final a = entry.value;
                            final terpakai = a.kategori == 'Total Bulanan'
                                ? txBulanIni.fold(0, (s, tx) => s + tx.nominal)
                                : txBulanIni
                                    .where((tx) => tx.kategori == a.kategori)
                                    .fold(0, (s, tx) => s + tx.nominal);
                            final rasio = a.batasNominal > 0
                                ? terpakai / a.batasNominal
                                : 0.0;
                            final warna = rasio >= 1.0
                                ? const Color(0xFFF43F5E)
                                : (rasio >= 0.8
                                    ? const Color(0xFFF59E0B)
                                    : t.primaryColor);
                            final sisa = a.batasNominal - terpakai;

                            return AnimatedAppear(
                              index: idx,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: dekorasiKartu(t),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          a.kategori,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${(rasio * 100).toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: warna,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => widget
                                                  .onHapusAnggaran(a.kategori),
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SmoothProgressBar(
                                      value: rasio,
                                      color: warna,
                                      backgroundColor:
                                          warna.withValues(alpha: 0.15),
                                      minHeight: 8,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Terpakai: ${formatRupiah(terpakai)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          sisa >= 0
                                              ? 'Sisa: ${formatRupiah(sisa)}'
                                              : 'Lewat: ${formatRupiah(sisa.abs())}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: warna,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Target Tabungan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _dialogTargetTabungan,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Target'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (widget.tabungan.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: dekorasiKartu(t),
                            child: const Text(
                              'Belum ada target tabungan.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        else
                          ...widget.tabungan.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final tb = entry.value;
                            final rasio = tb.targetNominal > 0
                                ? tb.terkumpulNominal / tb.targetNominal
                                : 0.0;
                            final warna = Color(tb.warnaValue);

                            return AnimatedAppear(
                              index: idx,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: dekorasiKartu(t),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              warna.withValues(alpha: 0.16),
                                          child: Icon(Icons.savings_rounded,
                                              color: warna),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tb.nama,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                '${formatRupiah(tb.terkumpulNominal)} / ${formatRupiah(tb.targetNominal)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: warna,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                          onPressed: () => _dialogSetor(tb),
                                          child: const Text('+ Nabung'),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              widget.onHapusTabungan(tb.id),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SmoothProgressBar(
                                      value: rasio,
                                      color: warna,
                                      backgroundColor:
                                          warna.withValues(alpha: 0.15),
                                      minHeight: 8,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    )
                  : _subTab == 1
                      ? ListView(
                          key: const ValueKey('sub_1'),
                          padding: const EdgeInsets.all(16),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: t.primaryColor
                                          .withValues(alpha: 0.14),
                                      borderRadius:
                                          BorderRadius.circular(t.cardRadius),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Piutang (Akan Diterima)',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        const SizedBox(height: 4),
                                        AnimatedCurrencyText(
                                          value: totalPiutang,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: t.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF43F5E)
                                          .withValues(alpha: 0.14),
                                      borderRadius:
                                          BorderRadius.circular(t.cardRadius),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Hutang Saya',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        const SizedBox(height: 4),
                                        AnimatedCurrencyText(
                                          value: totalHutang,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFFF43F5E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daftar Hutang & Piutang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: _dialogHutangPiutang,
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Catat'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (widget.hutangPiutang.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: dekorasiKartu(t),
                                child: const Text(
                                  'Belum ada catatan hutang maupun piutang.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              )
                            else
                              ...widget.hutangPiutang
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final idx = entry.key;
                                final h = entry.value;
                                final warna = h.isHutangSaya
                                    ? const Color(0xFFF43F5E)
                                    : t.primaryColor;
                                return AnimatedAppear(
                                  index: idx,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: dekorasiKartu(t),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: warna.withValues(
                                                    alpha: 0.16),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                h.lunas
                                                    ? 'LUNAS'
                                                    : (h.isHutangSaya
                                                        ? 'HUTANG'
                                                        : 'PIUTANG'),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: warna,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                h.namaOrang,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            if (!h.lunas)
                                              FilledButton(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: warna,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                ),
                                                onPressed: () =>
                                                    _dialogCicilHutangPiutang(
                                                        h),
                                                child: Text(h.isHutangSaya
                                                    ? 'Bayar'
                                                    : 'Terima'),
                                              ),
                                            IconButton(
                                              onPressed: () => widget
                                                  .onHapusHutangPiutang(h.id),
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (h.keterangan.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            h.keterangan,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Tempo: ${formatTanggal(h.jatuhTempo)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              h.lunas
                                                  ? 'Total: ${formatRupiah(h.totalNominal)}'
                                                  : 'Sisa: ${formatRupiah(h.sisaNominal)} / ${formatRupiah(h.totalNominal)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],
                        )
                      : ListView(
                          key: const ValueKey('sub_2'),
                          padding: const EdgeInsets.all(16),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transaksi Rutin Bulanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: _dialogRutin,
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Jadwal'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Otomatis tercatat saat aplikasi dibuka pada atau setelah tanggal jatuh tempo setiap bulan.',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            if (widget.rutin.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: dekorasiKartu(t),
                                child: const Text(
                                  'Belum ada jadwal rutin (mis. Gaji, Wi-Fi, Kos).',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              )
                            else
                              ...widget.rutin.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final r = entry.value;
                                final warna = r.isPemasukan
                                    ? t.primaryColor
                                    : const Color(0xFFF43F5E);
                                return AnimatedAppear(
                                  index: idx,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: dekorasiKartu(t),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              warna.withValues(alpha: 0.15),
                                          child: Icon(Icons.autorenew_rounded,
                                              color: warna),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                r.judul,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'Tiap tgl ${r.tanggalBulanan} • ${r.dompet} • ${formatRupiah(r.nominal)}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              widget.onCatatRutinManual(r),
                                          child: const Text('Catat'),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              widget.onHapusRutin(r.id),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
