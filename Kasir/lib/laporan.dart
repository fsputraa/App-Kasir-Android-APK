import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LaporanTab extends StatefulWidget {
  const LaporanTab({Key? key}) : super(key: key);

  @override
  State<LaporanTab> createState() => _LaporanTabState();
}

class _LaporanTabState extends State<LaporanTab> {
  final CollectionReference transactions =
      FirebaseFirestore.instance.collection('transaksi');

  String selectedFilter = 'Hari Ini';
  double totalUang = 0;
  int totalProdukTerjual = 0;
  Map<String, int> daftarProduk = {};

  final List<String> filterOptions = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Tahun Ini',
  ];

  @override
  void initState() {
    super.initState();
    _getLaporan(); // default Hari Ini
  }

  Future<void> _getLaporan() async {
    DateTime now = DateTime.now();
    DateTime filterDate;

    switch (selectedFilter) {
      case 'Hari Ini':
        filterDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Minggu Ini':
        filterDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Bulan Ini':
        filterDate = DateTime(now.year, now.month, 1);
        break;
      case 'Tahun Ini':
        filterDate = DateTime(now.year, 1, 1);
        break;
      default:
        filterDate = DateTime(now.year, now.month, now.day);
    }

    QuerySnapshot snapshot = await transactions.get();
    double totalFiltered = 0;
    int jumlahProduk = 0;
    Map<String, int> produkTerjual = {};

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime tanggal = (data['tanggal'] as Timestamp).toDate();
      double totalTransaksi = 0;

      if (tanggal.isAfter(filterDate)) {
        for (var item in data['items']) {
          var harga = item['harga'] as num;
          var jumlah = (item['jumlah'] ?? 1) as num;
          var nama = item['namaProduk'] as String;

          totalTransaksi += harga * jumlah;
          jumlahProduk += jumlah.toInt();

          if (produkTerjual.containsKey(nama)) {
            produkTerjual[nama] = produkTerjual[nama]! + jumlah.toInt();
          } else {
            produkTerjual[nama] = jumlah.toInt();
          }
        }

        totalFiltered += totalTransaksi;
      }
    }

    setState(() {
      totalUang = totalFiltered;
      totalProdukTerjual = jumlahProduk;
      daftarProduk = produkTerjual;
    });
  }

  String formatRupiah(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: Colors.pink, // ← Warna AppBar diubah ke pink
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: selectedFilter,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: "Pilih Periode",
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  dropdownColor: Theme.of(context).cardColor,
                  items: filterOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                      _getLaporan();
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _getLaporan,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      laporanCard(
                        selectedFilter,
                        totalUang,
                        totalProdukTerjual,
                        daftarProduk,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget laporanCard(
    String label,
    double total,
    int totalProduk,
    Map<String, int> produk,
  ) {
    return Card(
  elevation: 4,
  color: Theme.of(context).cardColor, // ← Otomatis menyesuaikan tema
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Laporan $label',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pink, // Tetap pink agar mencolok
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.pink),
            const SizedBox(width: 8),
            Text(
              'Total Pendapatan: ${formatRupiah(total)}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.pink),
            const SizedBox(width: 8),
            Text(
              'Total Produk Terjual: $totalProduk',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(),
        const Text(
          'Detail Produk Terjual:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 6),
        ...produk.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                const Icon(Icons.coffee, size: 16, color: Colors.pink),
                const SizedBox(width: 6),
                Text(
                  '${entry.key} x ${entry.value}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  ),
);

  }
}
