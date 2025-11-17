import 'dart:convert'; // untuk base64Decode
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // untuk format harga
import 'editproduk.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String searchText = ''; // Bisa dihapus jika tidak pakai pencarian

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Daftar Produk'),  // Judul saja tanpa search bar
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('produk').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final produkList = snapshot.data!.docs;

          if (produkList.isEmpty) {
            return const Center(child: Text('Belum ada produk'));
          }

          return ListView.builder(
            itemCount: produkList.length,
            itemBuilder: (context, index) {
              final doc = produkList[index];
              final data = doc.data() as Map<String, dynamic>;

              final productName = data['namaProduk'] ?? '';
              final harga = (data['harga'] ?? 0).toDouble();

              final dynamic jumlahData = data['jumlah'];
              final int jumlah = (jumlahData is int)
                  ? jumlahData
                  : (jumlahData is double)
                      ? jumlahData.toInt()
                      : int.tryParse(jumlahData?.toString() ?? '0') ?? 0;

              final imageBase64 = data['imageBase64'] ?? '';

              return Column(
                children: [
                  ListTile(
                    leading: imageBase64.isNotEmpty
                        ? Image.memory(
                            base64Decode(imageBase64),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.pink.shade100,
                            child: Text(
                              productName.isNotEmpty ? productName[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.pink),
                            ),
                          ),
                    title: Text(productName),
                    subtitle: Text('Harga: ${formatCurrency.format(harga)} - Jumlah: $jumlah'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.pink),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProduk(
                              docId: doc.id,
                              imageBase64: imageBase64,
                              namaProduk: productName,
                              harga: harga,
                              jumlah: jumlah,
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      // Optional: juga bisa navigasi edit kalau tap listTile
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProduk(
                            docId: doc.id,
                            imageBase64: imageBase64,
                            namaProduk: productName,
                            harga: harga,
                            jumlah: jumlah,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: Colors.pink,
                    thickness: 2,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
