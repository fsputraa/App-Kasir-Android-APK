import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/custom_appbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class EditProduk extends StatefulWidget {
  final String docId;
  final String imageBase64;
  final String namaProduk;
  final double harga;
  final int jumlah;

  const EditProduk({
    Key? key,
    required this.docId,
    required this.imageBase64,
    required this.namaProduk,
    required this.harga,
    required this.jumlah,
  }) : super(key: key);

  @override
  State<EditProduk> createState() => _EditProdukState();
}

class _EditProdukState extends State<EditProduk> {
  final _formKey = GlobalKey<FormState>();

  late String _imagePath;
  late TextEditingController _namaProdukController;
  late TextEditingController _hargaController;
  late TextEditingController _jumlahController;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imageBase64;
    _namaProdukController = TextEditingController(text: widget.namaProduk);
    _hargaController = TextEditingController(text: widget.harga.toString());
    _jumlahController = TextEditingController(text: widget.jumlah.toString());
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          _imagePath = base64Encode(bytes);
        });
      }
    } catch (e) {
      print('Kesalahan saat mengambil gambar: $e');
    }
  }

  Future<void> updateProduk(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    _showLoadingDialog(context);

    try {
      await FirebaseFirestore.instance.collection('produk').doc(widget.docId).update({
        'imageBase64': _imagePath,
        'namaProduk': _namaProdukController.text,
        'harga': double.parse(_hargaController.text),
        'jumlah': int.parse(_jumlahController.text),
      });

      Navigator.of(context, rootNavigator: true).pop(); // tutup loading
      _showNotification(context);
      Navigator.pop(context); // kembali ke halaman sebelumnya
    } catch (e) {
      print('Gagal update produk: $e');
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showNotification(BuildContext context) async {
    const androidDetails = AndroidNotificationDetails(
      'transaction_channel_id',
      'Transaction Channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(android: androidDetails);

    await FlutterLocalNotificationsPlugin().show(
      0,
      'Produk Diperbarui',
      'Produk berhasil diperbarui.',
      notifDetails,
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: LoadingAnimationWidget.threeRotatingDots(
          color: Colors.pink,
          size: 35,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomCurvedAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _imagePath.isEmpty
                  ? Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(10.0),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _getImageFromGallery,
                        child: Stack(
                          children: [
                            Image.asset(
                              'images/blank.jpg',
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                            Positioned.fill(
                              top: 190,
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    'Choose Your Image',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(10.0),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _getImageFromGallery,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.memory(
                            base64Decode(_imagePath),
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Material(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 15.0),
                    child: TextFormField(
                      controller: _namaProdukController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        contentPadding: EdgeInsets.only(left: 0),
                        border: UnderlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Material(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 15.0),
                    child: TextFormField(
                      controller: _hargaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        prefixText: 'Rp ',
                        contentPadding: EdgeInsets.only(left: 0),
                        border: UnderlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Wajib diisi';
                        if (double.tryParse(value) == null) return 'Harus angka';
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Material(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 15.0),
                    child: TextFormField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        contentPadding: EdgeInsets.only(left: 0),
                        border: UnderlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Wajib diisi';
                        if (int.tryParse(value) == null) return 'Harus angka';
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
             ElevatedButton(
              onPressed: () async {
                await updateProduk(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.pink,
                minimumSize: const Size(180, 50),
                padding: const EdgeInsets.all(15),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(fontSize: 16),
              ),
            )
            ],
          ),
        ),
      ),
    );
  }
}
