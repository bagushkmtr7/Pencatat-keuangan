class Dompet {
  final String id;
  final String nama;
  final int saldoAwal;
  final String iconKey;
  final int warnaValue;

  Dompet({
    required this.id,
    required this.nama,
    required this.saldoAwal,
    required this.iconKey,
    required this.warnaValue,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nama': nama,
        'saldoAwal': saldoAwal,
        'iconKey': iconKey,
        'warnaValue': warnaValue,
      };

  factory Dompet.fromMap(Map<String, dynamic> m) => Dompet(
        id: m['id'] as String,
        nama: m['nama'] as String,
        saldoAwal: (m['saldoAwal'] as int?) ?? 0,
        iconKey: (m['iconKey'] as String?) ?? 'wallet',
        warnaValue: (m['warnaValue'] as int?) ?? 0xFF10B981,
      );
}

class KategoriItem {
  final String nama;
  final bool isPemasukan;
  final String iconKey;
  final int warnaValue;

  KategoriItem({
    required this.nama,
    required this.isPemasukan,
    required this.iconKey,
    required this.warnaValue,
  });

  Map<String, dynamic> toMap() => {
        'nama': nama,
        'isPemasukan': isPemasukan,
        'iconKey': iconKey,
        'warnaValue': warnaValue,
      };

  factory KategoriItem.fromMap(Map<String, dynamic> m) => KategoriItem(
        nama: m['nama'] as String,
        isPemasukan: m['isPemasukan'] as bool,
        iconKey: (m['iconKey'] as String?) ?? 'other',
        warnaValue: (m['warnaValue'] as int?) ?? 0xFF14B8A6,
      );
}

class Transaksi {
  final String id;
  final String judul;
  final int nominal;
  final bool isPemasukan;
  final String kategori;
  final DateTime tanggal;
  final String dompet;

  Transaksi({
    required this.id,
    required this.judul,
    required this.nominal,
    required this.isPemasukan,
    required this.kategori,
    required this.tanggal,
    required this.dompet,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'judul': judul,
        'nominal': nominal,
        'isPemasukan': isPemasukan,
        'kategori': kategori,
        'tanggal': tanggal.toIso8601String(),
        'dompet': dompet,
      };

  factory Transaksi.fromMap(Map<String, dynamic> m) => Transaksi(
        id: m['id'] as String,
        judul: m['judul'] as String,
        nominal: m['nominal'] as int,
        isPemasukan: m['isPemasukan'] as bool,
        kategori: (m['kategori'] as String?) ?? 'Lainnya',
        tanggal: m['tanggal'] != null
            ? DateTime.parse(m['tanggal'] as String)
            : DateTime.now(),
        dompet: (m['dompet'] as String?) ?? 'Tunai',
      );
}

class TransferDompet {
  final String id;
  final String dariDompet;
  final String keDompet;
  final int nominal;
  final DateTime tanggal;
  final String catatan;

  TransferDompet({
    required this.id,
    required this.dariDompet,
    required this.keDompet,
    required this.nominal,
    required this.tanggal,
    required this.catatan,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'dariDompet': dariDompet,
        'keDompet': keDompet,
        'nominal': nominal,
        'tanggal': tanggal.toIso8601String(),
        'catatan': catatan,
      };

  factory TransferDompet.fromMap(Map<String, dynamic> m) => TransferDompet(
        id: m['id'] as String,
        dariDompet: m['dariDompet'] as String,
        keDompet: m['keDompet'] as String,
        nominal: m['nominal'] as int,
        tanggal: DateTime.parse(m['tanggal'] as String),
        catatan: (m['catatan'] as String?) ?? '',
      );
}

class Anggaran {
  final String kategori;
  final int batasNominal;

  Anggaran({required this.kategori, required this.batasNominal});

  Map<String, dynamic> toMap() => {
        'kategori': kategori,
        'batasNominal': batasNominal,
      };

  factory Anggaran.fromMap(Map<String, dynamic> m) => Anggaran(
        kategori: m['kategori'] as String,
        batasNominal: m['batasNominal'] as int,
      );
}

class TargetTabungan {
  final String id;
  final String nama;
  final int targetNominal;
  final int terkumpulNominal;
  final int warnaValue;

  TargetTabungan({
    required this.id,
    required this.nama,
    required this.targetNominal,
    required this.terkumpulNominal,
    required this.warnaValue,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nama': nama,
        'targetNominal': targetNominal,
        'terkumpulNominal': terkumpulNominal,
        'warnaValue': warnaValue,
      };

  factory TargetTabungan.fromMap(Map<String, dynamic> m) => TargetTabungan(
        id: m['id'] as String,
        nama: m['nama'] as String,
        targetNominal: m['targetNominal'] as int,
        terkumpulNominal: (m['terkumpulNominal'] as int?) ?? 0,
        warnaValue: (m['warnaValue'] as int?) ?? 0xFF10B981,
      );
}

class HutangPiutang {
  final String id;
  final String namaOrang;
  final String keterangan;
  final int totalNominal;
  final int dibayarNominal;
  final bool isHutangSaya;
  final DateTime jatuhTempo;

  HutangPiutang({
    required this.id,
    required this.namaOrang,
    required this.keterangan,
    required this.totalNominal,
    required this.dibayarNominal,
    required this.isHutangSaya,
    required this.jatuhTempo,
  });

  int get sisaNominal => (totalNominal - dibayarNominal).clamp(0, totalNominal);
  bool get lunas => sisaNominal <= 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'namaOrang': namaOrang,
        'keterangan': keterangan,
        'totalNominal': totalNominal,
        'dibayarNominal': dibayarNominal,
        'isHutangSaya': isHutangSaya,
        'jatuhTempo': jatuhTempo.toIso8601String(),
      };

  factory HutangPiutang.fromMap(Map<String, dynamic> m) => HutangPiutang(
        id: m['id'] as String,
        namaOrang: m['namaOrang'] as String,
        keterangan: (m['keterangan'] as String?) ?? '',
        totalNominal: m['totalNominal'] as int,
        dibayarNominal: (m['dibayarNominal'] as int?) ?? 0,
        isHutangSaya: m['isHutangSaya'] as bool,
        jatuhTempo: DateTime.parse(m['jatuhTempo'] as String),
      );
}

class TransaksiRutin {
  final String id;
  final String judul;
  final int nominal;
  final bool isPemasukan;
  final String kategori;
  final String dompet;
  final int tanggalBulanan;
  final String? terakhirBulanTahun;

  TransaksiRutin({
    required this.id,
    required this.judul,
    required this.nominal,
    required this.isPemasukan,
    required this.kategori,
    required this.dompet,
    required this.tanggalBulanan,
    this.terakhirBulanTahun,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'judul': judul,
        'nominal': nominal,
        'isPemasukan': isPemasukan,
        'kategori': kategori,
        'dompet': dompet,
        'tanggalBulanan': tanggalBulanan,
        'terakhirBulanTahun': terakhirBulanTahun,
      };

  factory TransaksiRutin.fromMap(Map<String, dynamic> m) => TransaksiRutin(
        id: m['id'] as String,
        judul: m['judul'] as String,
        nominal: m['nominal'] as int,
        isPemasukan: m['isPemasukan'] as bool,
        kategori: (m['kategori'] as String?) ?? 'Tagihan',
        dompet: (m['dompet'] as String?) ?? 'Tunai',
        tanggalBulanan: (m['tanggalBulanan'] as int?) ?? 1,
        terakhirBulanTahun: m['terakhirBulanTahun'] as String?,
      );
}
