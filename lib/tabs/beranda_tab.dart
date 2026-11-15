import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finance_models.dart';
import '../theme/app_template.dart';
import '../utils/formatters.dart';
import '../widgets/template_picker_sheet.dart';
import '../widgets/smooth_widgets.dart';

class BerandaTab extends StatefulWidget {
  final AppTemplate template;
  final Future<void> Function(AppTemplate) onPilihTemplate;
  final bool sensorSaldo;
  final VoidCallback onToggleSensor;
  final List<Transaksi> transaksi;
  final List<Dompet> dompet;
  final List<TransferDompet> transfer;
  final List<Anggaran> anggaran;
  final int bulanDipilih;
  final int tahunDipilih;
  final bool tampilkanSemuaWaktu;
  final String dompetFilter;
  final int totalSemuaDompet;
  final int Function(Dompet) hitungSaldoDompet;
  final KategoriItem Function(String, bool) cariKategori;
  final void Function(int) onGantiBulan;
  final void Function(bool) onToggleSemuaWaktu;
  final void Function(String) onPilihDompet;
  final void Function(Transaksi) onEditTransaksi;
  final void Function(Transaksi) onHapusTransaksi;
  final VoidCallback onBukaTransfer;
  final void Function(String) onHapusTransfer;

  const BerandaTab({
    super.key,
    required this.template,
    required this.onPilihTemplate,
    required this.sensorSaldo,
    required this.onToggleSensor,
    required this.transaksi,
    required this.dompet,
    required this.transfer,
    required this.anggaran,
    required this.bulanDipilih,
    required this.tahunDipilih,
    required this.tampilkanSemuaWaktu,
    required this.dompetFilter,
    required this.totalSemuaDompet,
    required this.hitungSaldoDompet,
    required this.cariKategori,
    required this.onGantiBulan,
    required this.onToggleSemuaWaktu,
    required this.onPilihDompet,
    required this.onEditTransaksi,
    required this.onHapusTransaksi,
    required this.onBukaTransfer,
    required this.onHapusTransfer,
  });

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  bool _modeCari = false;
  bool _tampilkanRincian = true;
  String _kataKunci = '';
  String _filterKategori = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Transaksi> get _txPeriodeDompet {
    return widget.transaksi.where((t) {
      final cocokDompet =
          widget.dompetFilter == 'Semua' || t.dompet == widget.dompetFilter;
      final cocokWaktu = widget.tampilkanSemuaWaktu ||
          (t.tanggal.month == widget.bulanDipilih &&
              t.tanggal.year == widget.tahunDipilih);
      return cocokDompet && cocokWaktu;
    }).toList();
  }

  List<Transaksi> get _txTampil {
    return _txPeriodeDompet.where((t) {
      final cocokKat =
          _filterKategori == 'Semua' || t.kategori == _filterKategori;
      final cocokCari = _kataKunci.isEmpty ||
          t.judul.toLowerCase().contains(_kataKunci.toLowerCase()) ||
          t.kategori.toLowerCase().contains(_kataKunci.toLowerCase());
      return cocokKat && cocokCari;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    final s = widget.sensorSaldo;

    final periodeList = _txPeriodeDompet;
    final pemasukan = periodeList
        .where((tx) => tx.isPemasukan)
        .fold(0, (sum, tx) => sum + tx.nominal);
    final pengeluaran = periodeList
        .where((tx) => !tx.isPemasukan)
        .fold(0, (sum, tx) => sum + tx.nominal);

    final saldoDompetAktif = widget.dompetFilter == 'Semua'
        ? widget.totalSemuaDompet
        : widget.hitungSaldoDompet(
            widget.dompet.firstWhere(
              (d) => d.nama == widget.dompetFilter,
              orElse: () => widget.dompet.first,
            ),
          );

    final Map<String, int> mapKat = {};
    for (final tx in periodeList.where((tx) => !tx.isPemasukan)) {
      mapKat[tx.kategori] = (mapKat[tx.kategori] ?? 0) + tx.nominal;
    }
    final rincian = mapKat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final txBulanIni = widget.transaksi.where((tx) =>
        !tx.isPemasukan &&
        tx.tanggal.month == widget.bulanDipilih &&
        tx.tanggal.year == widget.tahunDipilih);
    final anggaranWaspada = widget.anggaran.where((a) {
      final terpakai = a.kategori == 'Total Bulanan'
          ? txBulanIni.fold(0, (sum, tx) => sum + tx.nominal)
          : txBulanIni
              .where((tx) => tx.kategori == a.kategori)
              .fold(0, (sum, tx) => sum + tx.nominal);
      return a.batasNominal > 0 && (terpakai / a.batasNominal) >= 0.8;
    }).toList();

    final kategoriFilterList = <String>{
      'Semua',
      ...periodeList.map((tx) => tx.kategori),
    }.toList();

    final labelPeriode = widget.tampilkanSemuaWaktu
        ? 'Semua Waktu'
        : '${kNamaBulan[widget.bulanDipilih - 1]} ${widget.tahunDipilih}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: t.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'DompetKu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              tampilkanPemilihTemplate(
                context,
                aktif: t,
                onPilih: widget.onPilihTemplate,
              );
            },
            icon: Icon(Icons.palette_outlined, color: t.primaryColor),
            tooltip: 'Pilih Template Tampilan',
          ),
          IconButton(
            onPressed: widget.onBukaTransfer,
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Transfer antar dompet',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _modeCari = !_modeCari;
                if (!_modeCari) {
                  _searchCtrl.clear();
                  _kataKunci = '';
                }
              });
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _modeCari ? Icons.close_rounded : Icons.search_rounded,
                key: ValueKey(_modeCari),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: _modeCari
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            onChanged: (v) => setState(() => _kataKunci = v),
                            decoration: InputDecoration(
                              hintText: 'Cari transaksi...',
                              prefixIcon:
                                  const Icon(Icons.search_rounded, size: 20),
                              filled: true,
                              fillColor: t.cardColor,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(t.cardRadius * 0.7),
                                borderSide: BorderSide(color: t.borderColor),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                SizedBox(
                  height: 76,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _KartuDompetMini(
                        nama: 'Semua Dompet',
                        saldo: widget.totalSemuaDompet,
                        sensor: s,
                        icon: Icons.layers_rounded,
                        warna: t.primaryColor,
                        aktif: widget.dompetFilter == 'Semua',
                        template: t,
                        onTap: () => widget.onPilihDompet('Semua'),
                      ),
                      ...widget.dompet.map((d) => _KartuDompetMini(
                            nama: d.nama,
                            saldo: widget.hitungSaldoDompet(d),
                            sensor: s,
                            icon: ikonDariKey(d.iconKey),
                            warna: Color(d.warnaValue),
                            aktif: widget.dompetFilter == d.nama,
                            template: t,
                            onTap: () => widget.onPilihDompet(d.nama),
                          )),
                    ],
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: t.cardGradient,
                    ),
                    borderRadius: BorderRadius.circular(t.cardRadius + 4),
                    border: Border.all(
                      color: t.primaryColor.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: t.primaryColor.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.dompetFilter == 'Semua'
                                    ? 'TOTAL SALDO DOMPET'
                                    : 'SALDO ${widget.dompetFilter.toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 6),
                              SmoothTap(
                                scaleDown: 0.85,
                                onTap: widget.onToggleSensor,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    s
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    key: ValueKey(s),
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              labelPeriode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AnimatedCurrencyText(
                        value: saldoDompetAktif,
                        sensor: s,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.22),
                                borderRadius:
                                    BorderRadius.circular(t.cardRadius * 0.7),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pemasukan ($labelPeriode)',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.75),
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  AnimatedCurrencyText(
                                    value: pemasukan,
                                    sensor: s,
                                    style: const TextStyle(
                                      color: Color(0xFF6EE7B7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.22),
                                borderRadius:
                                    BorderRadius.circular(t.cardRadius * 0.7),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pengeluaran ($labelPeriode)',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.75),
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  AnimatedCurrencyText(
                                    value: pengeluaran,
                                    sensor: s,
                                    style: const TextStyle(
                                      color: Color(0xFFFDA4AF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: dekorasiKartu(t),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                widget.onGantiBulan(-1);
                              },
                              icon: const Icon(Icons.chevron_left_rounded),
                              visualDensity: VisualDensity.compact,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: Text(
                                  labelPeriode,
                                  key: ValueKey(labelPeriode),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                widget.onGantiBulan(1);
                              },
                              icon: const Icon(Icons.chevron_right_rounded),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      FilterChip(
                        label: const Text('Semua Waktu'),
                        selected: widget.tampilkanSemuaWaktu,
                        showCheckmark: false,
                        selectedColor: t.primaryColor.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(t.cardRadius * 0.7),
                        ),
                        onSelected: (val) {
                          HapticFeedback.selectionClick();
                          widget.onToggleSemuaWaktu(val);
                        },
                      ),
                    ],
                  ),
                ),

                if (anggaranWaspada.isNotEmpty)
                  AnimatedAppear(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(t.cardRadius * 0.8),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Perhatian: ${anggaranWaspada.map((a) => a.kategori).join(', ')} sudah >=80% batas anggaran bulan ini.',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (rincian.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    padding: const EdgeInsets.all(16),
                    decoration: dekorasiKartu(t),
                    child: Column(
                      children: [
                        SmoothTap(
                          scaleDown: 0.985,
                          onTap: () => setState(
                              () => _tampilkanRincian = !_tampilkanRincian),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Rincian Pengeluaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              AnimatedRotation(
                                turns: _tampilkanRincian ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutCubic,
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          child: _tampilkanRincian
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Column(
                                    children: rincian.map((e) {
                                      final katObj =
                                          widget.cariKategori(e.key, false);
                                      final warna = Color(katObj.warnaValue);
                                      final pct = pengeluaran > 0
                                          ? e.value / pengeluaran
                                          : 0.0;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${e.key} (${(pct * 100).toStringAsFixed(0)}%)',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  formatRupiah(e.value,
                                                      sensor: s),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            SmoothProgressBar(
                                              value: pct,
                                              color: warna,
                                              backgroundColor:
                                                  warna.withValues(alpha: 0.15),
                                              minHeight: 6,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                if (kategoriFilterList.length > 1)
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: kategoriFilterList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final kat = kategoriFilterList[i];
                        final aktif = _filterKategori == kat;
                        return ChoiceChip(
                          label: Text(kat),
                          selected: aktif,
                          showCheckmark: false,
                          selectedColor: t.primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: aktif ? Colors.white : null,
                          ),
                          onSelected: (_) {
                            HapticFeedback.selectionClick();
                            setState(() => _filterKategori = kat);
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          if (_txTampil.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Belum ada transaksi pada filter ini.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final item = _txTampil[i];
                    final katObj =
                        widget.cariKategori(item.kategori, item.isPemasukan);
                    final warna = Color(katObj.warnaValue);

                    return AnimatedAppear(
                      key: ValueKey('appear_${item.id}'),
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => widget.onHapusTransaksi(item),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E),
                              borderRadius: BorderRadius.circular(t.cardRadius),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          child: SmoothTap(
                            onTap: () => widget.onEditTransaksi(item),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: dekorasiKartu(t),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: warna.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(
                                          t.cardRadius * 0.7),
                                    ),
                                    child: Icon(
                                      ikonDariKey(katObj.iconKey),
                                      color: warna,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.judul,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${item.dompet} • ${item.kategori} • ${formatTanggal(item.tanggal)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${item.isPemasukan ? '+' : '-'} ${formatRupiah(item.nominal, sensor: s)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: item.isPemasukan
                                          ? t.primaryColor
                                          : const Color(0xFFF43F5E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _txTampil.length,
                ),
              ),
            ),

          if (widget.transfer.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: dekorasiKartu(t),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Transfer Dompet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.transfer.take(5).map((tr) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(Icons.swap_horiz_rounded,
                                    size: 16, color: t.primaryColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${tr.dariDompet} → ${tr.keDompet} (${formatTanggal(tr.tanggal)})',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Text(
                                  formatRupiah(tr.nominal, sensor: s),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      widget.onHapusTransfer(tr.id),
                                  icon: const Icon(Icons.close_rounded,
                                      size: 16),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
    );
  }
}

class _KartuDompetMini extends StatelessWidget {
  final String nama;
  final int saldo;
  final bool sensor;
  final IconData icon;
  final Color warna;
  final bool aktif;
  final AppTemplate template;
  final VoidCallback onTap;

  const _KartuDompetMini({
    required this.nama,
    required this.saldo,
    required this.sensor,
    required this.icon,
    required this.warna,
    required this.aktif,
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = template;
    return SmoothTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: aktif ? warna.withValues(alpha: 0.16) : t.cardColor,
          borderRadius: BorderRadius.circular(t.cardRadius * 0.9),
          border: Border.all(
            color: aktif ? warna : t.borderColor,
            width: aktif ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(t.cardRadius * 0.6),
              ),
              child: Icon(icon, color: warna, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRupiah(saldo, sensor: sensor),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
