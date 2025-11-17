import 'package:flutter/material.dart';
import 'package:kasir/laporan.dart';
import 'package:kasir/mainscreen.dart';
import 'package:kasir/petunjuk.dart';
import 'package:kasir/produk_listscreen.dart';


class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  final bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 44, 57, 64),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 150,
          ),
          ListTile(
            leading: GestureDetector(
              onTap: () {
                MainScreen.toggleTheme();
              },
              child: Icon(
                _isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: Colors.white,
              ),
            ),
            title: Text(
              _isDarkMode ? 'Ganti ke Light' : 'Ganti ke Dark',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              MainScreen.toggleTheme();
            },
          ),
          const Divider(
            height: 10,
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.white),
            title: const Text('Edit Produk',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_chart, color: Colors.white),
            title: const Text('Laporan Penjualan',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LaporanTab(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline, color: Colors.white),
            title:
                const Text('Petunjuk', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PetunjukPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
