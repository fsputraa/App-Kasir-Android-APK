import 'package:flutter/material.dart';
import 'package:kasir/custom_appbar.dart';

class PetunjukPage extends StatelessWidget {
  const PetunjukPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomCurvedAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('📷 Tambah Produk'),
          _buildInstruction('Klik area gambar untuk memilih foto produk dari galeri.'),
          _buildInstruction('Isi nama produk, harga (dalam angka), dan jumlah stok.'),
          _buildInstruction('Tekan tombol "Simpan" untuk menyimpan produk ke database.'),
          const SizedBox(height: 20),

          _buildSectionTitle('✏️ Edit Produk'),
          _buildInstruction('Buka tab daftar produk.'),
          _buildInstruction('Tekan ikon pensil di kartu produk untuk mengedit.'),
          _buildInstruction('Ubah data yang diperlukan, lalu tekan "Simpan Perubahan".'),
          const SizedBox(height: 20),

          _buildSectionTitle('🗑️ Hapus Produk'),
          _buildInstruction('Geser kartu produk ke kiri untuk menghapus dari daftar.'),
          const SizedBox(height: 20),

          _buildSectionTitle('🛒 Keranjang'),
          _buildInstruction('Produk dapat ditambahkan ke keranjang.'),
          const SizedBox(height: 20),

          _buildSectionTitle('📄 Halaman Transaksi'),
          _buildInstruction('Setiap transaksi yang terjadi akan tercatat otomatis di halaman ini.'),
          _buildInstruction('Ditampilkan tanggal dan waktu transaksi secara detail.'),
          _buildInstruction('Setiap produk dalam transaksi ditampilkan dengan harga satuan, jumlah, dan total per produk.'),
          _buildInstruction('Total keseluruhan harga belanja ditampilkan di bagian bawah setiap kartu transaksi.'),
          _buildInstruction('Sebelum mencetak transaksi harap sambungkan printer terlebih dahulu'),
          _buildInstruction('Setelah terhubung tekan tombol cetak dan pilih printer yang terhubung dan tunggu proses cetaknya'),
          const SizedBox(height: 20),

          _buildSectionTitle('📌 Catatan Penting'),
          _buildInstruction('Pastikan semua kolom diisi dengan benar.'),
          _buildInstruction('Harga harus berupa angka desimal (contoh: 25000 atau 19999.99).'),
          _buildInstruction('Jumlah harus berupa angka bulat (contoh: 10, 25).'),
          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontSize: 16)),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          ],
        ),
        const Divider(color: Colors.pink, height: 20, thickness: 1),
      ],
    );
  }
}
