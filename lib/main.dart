import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Keuangan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Transaksi {
  final String id;
  final String judul;
  final int nominal;
  final bool isPemasukan;
  final String kategori;
  final DateTime tanggal;

  Transaksi({
    required this.id,
    required this.judul,
    required this.nominal,
    required this.isPemasukan,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'nominal': nominal,
      'isPemasukan': isPemasukan,
      'kategori': kategori,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'] as String,
      judul: map['judul'] as String,
      nominal: map['nominal'] as int,
      isPemasukan: map['isPemasukan'] as bool,
      kategori: (map['kategori'] as String?) ?? 'Lainnya',
      tanggal: map['tanggal'] != null
          ? DateTime.parse(map['tanggal'] as String)
          : DateTime.now(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Transaksi> _daftarTransaksi = [];

  final List<String> _kategoriPengeluaran = [
    'Makan',
    'Transport',
    'Belanja',
    'Tagihan',
    'Lainnya',
  ];

  final List<String> _kategoriPemasukan = [
    'Gaji',
    'Bonus',
    'Usaha',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('daftar_transaksi');
    if (dataString != null) {
      final List<dynamic> decoded = jsonDecode(dataString);
      setState(() {
        _daftarTransaksi.clear();
        _daftarTransaksi.addAll(
          decoded.map((item) => Transaksi.fromMap(item as Map<String, dynamic>)),
        );
      });
    }
  }

  Future<void> _simpanData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _daftarTransaksi.map((t) => t.toMap()).toList(),
    );
    await prefs.setString('daftar_transaksi', encoded);
  }

  int get _totalPemasukan => _daftarTransaksi
      .where((t) => t.isPemasukan)
      .fold(0, (sum, t) => sum + t.nominal);

  int get _totalPengeluaran => _daftarTransaksi
      .where((t) => !t.isPemasukan)
      .fold(0, (sum, t) => sum + t.nominal);

  int get _saldo => _totalPemasukan - _totalPengeluaran;

  String _formatRupiah(int angka) {
    final str = angka.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${angka < 0 ? '-' : ''}Rp ${buffer.toString()}';
  }

  String _formatTanggal(DateTime dt) {
    const namaBulan = [
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
    return '${dt.day} ${namaBulan[dt.month - 1]} ${dt.year}';
  }

  IconData _ikonKategori(String kategori, bool isPemasukan) {
    switch (kategori) {
      case 'Makan':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Tagihan':
        return Icons.receipt_long;
      case 'Gaji':
        return Icons.payments;
      case 'Bonus':
        return Icons.card_giftcard;
      case 'Usaha':
        return Icons.storefront;
      default:
        return isPemasukan ? Icons.arrow_downward : Icons.arrow_upward;
    }
  }

  void _tambahTransaksi(
    String judul,
    int nominal,
    bool isPemasukan,
    String kategori,
    DateTime tanggal,
  ) {
    setState(() {
      _daftarTransaksi.insert(
        0,
        Transaksi(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          judul: judul,
          nominal: nominal,
          isPemasukan: isPemasukan,
          kategori: kategori,
          tanggal: tanggal,
        ),
      );
      _daftarTransaksi.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    });
    _simpanData();
  }

  void _hapusTransaksi(String id) {
    setState(() {
      _daftarTransaksi.removeWhere((t) => t.id == id);
    });
    _simpanData();
  }

  void _bukaFormTambah() {
    final judulController = TextEditingController();
    final nominalController = TextEditingController();
    bool isPemasukan = false;
    String kategoriDipilih = _kategoriPengeluaran.first;
    DateTime tanggalDipilih = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final daftarKategori =
                isPemasukan ? _kategoriPemasukan : _kategoriPengeluaran;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tambah Catatan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Pengeluaran')),
                        ButtonSegment(value: true, label: Text('Pemasukan')),
                      ],
                      selected: {isPemasukan},
                      onSelectionChanged: (val) {
                        setModalState(() {
                          isPemasukan = val.first;
                          kategoriDipilih = isPemasukan
                              ? _kategoriPemasukan.first
                              : _kategoriPengeluaran.first;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kategori',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: daftarKategori.map((kat) {
                        return ChoiceChip(
                          label: Text(kat),
                          selected: kategoriDipilih == kat,
                          onSelected: (_) {
                            setModalState(() => kategoriDipilih = kat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: judulController,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nominal',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final hasil = await showDatePicker(
                          context: ctx,
                          initialDate: tanggalDipilih,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (hasil != null) {
                          setModalState(() => tanggalDipilih = hasil);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text('Tanggal: ${_formatTanggal(tanggalDipilih)}'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        final judul = judulController.text.trim();
                        final nominal =
                            int.tryParse(nominalController.text.trim()) ?? 0;
                        if (judul.isEmpty || nominal <= 0) return;
                        _tambahTransaksi(
                          judul,
                          nominal,
                          isPemasukan,
                          kategoriDipilih,
                          tanggalDipilih,
                        );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Sisa Saldo',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(_saldo),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Pemasukan',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          _formatRupiah(_totalPemasukan),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Pengeluaran',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          _formatRupiah(_totalPengeluaran),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _daftarTransaksi.isEmpty
                ? const Center(
                    child: Text('Belum ada catatan. Tekan + buat nambah.'),
                  )
                : ListView.builder(
                    itemCount: _daftarTransaksi.length,
                    itemBuilder: (context, index) {
                      final item = _daftarTransaksi[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isPemasukan
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            _ikonKategori(item.kategori, item.isPemasukan),
                            color: item.isPemasukan ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                        title: Text(item.judul),
                        subtitle: Text(
                          '${item.kategori} • ${_formatTanggal(item.tanggal)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.isPemasukan ? '+' : '-'} ${_formatRupiah(item.nominal)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    item.isPemasukan ? Colors.green : Colors.red,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _hapusTransaksi(item.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaFormTambah,
        child: const Icon(Icons.add),
      ),
    );
  }
}
