import 'dart:io';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kasir/custom_appbar.dart';
import 'package:kasir/custom_clipappbar.dart';
import 'dart:convert';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override

  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class Product {
  final String name;
  final double price;

  Product({
    required this.name,
    required this.price,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  double xOffset = 0;
  double yOffset = 0;

  bool isDrawerOpen = false;

  bool get drawerStatus => isDrawerOpen;

  void openDrawer() {
    setState(() {
      xOffset = 290;
      yOffset = 80;
      isDrawerOpen = true;
    });
  }

  final List<Widget> _children = [
    const FristTab(),
    const SecondTab(),
    ThirdTab(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      transform: Matrix4.translationValues(xOffset, yOffset, 0)
        ..scale(isDrawerOpen ? 0.85 : 1.00)
        ..rotateZ(isDrawerOpen ? -50 : 0),
      duration: const Duration(milliseconds: 200),
      child: Stack(
        children: [
          _children[_currentIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CurvedNavigationBar(
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              color: Colors.pink,
              buttonBackgroundColor: Colors.pink,
              height: 55,
              index: _currentIndex,
              items: const <Widget>[
                Icon(Icons.shopping_cart_sharp),
                Icon(Icons.add),
                Icon(Icons.history),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FristTab extends StatefulWidget {
  const FristTab({Key? key}) : super(key: key);

  @override
  _FristTabState createState() => _FristTabState();
}

class _FristTabState extends State<FristTab> {
  String searchText = '';

  Future<void> hapusProduk(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('produk')
          .doc(productId)
          .delete();
    } catch (error) {
      print('Terjadi kesalahan saat menghapus produk: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: AppBar(
          backgroundColor: Colors.pink,
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      final _HomeScreenState? homeScreenState =
                          context.findAncestorStateOfType<_HomeScreenState>();
                      if (homeScreenState != null) {
                        homeScreenState.setState(() {
                          if (homeScreenState.isDrawerOpen) {
                            homeScreenState.xOffset = 0; // Tutup drawer
                            homeScreenState.yOffset = 0;
                            homeScreenState.isDrawerOpen = false;
                          } else {
                            homeScreenState.xOffset = 290; // Buka drawer
                            homeScreenState.yOffset = 80;
                            homeScreenState.isDrawerOpen = true;
                          }
                        });
                      }
                    },
                    child: const Icon(Icons.menu),
                  ),
                  Container(
                    width: 230,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: TextField(
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Cari produk...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.shopping_cart),
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            return Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 9,
                                backgroundColor: Colors.red,
                                child: Text(
                                  cartProvider.totalProdukDiKeranjang
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('produk').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error: Something went wrong'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Products available'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot<Object?> document =
                  snapshot.data!.docs[index];
              final Map<String, dynamic>? data =
                  document.data() as Map<String, dynamic>?;

              if (data == null) {
                return const SizedBox();
              }

              final String productName = data['namaProduk'] ?? '';
              final double harga = (data['harga'] ?? 0).toDouble();
              final String imageBase64 = data['imageBase64'] ?? '';

              final formatCurrency =
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

              if (!productName.toLowerCase().contains(searchText)) {
                return const SizedBox();
              }

              return Dismissible(
                key: Key(document.id),
                onDismissed: (direction) {
                  hapusProduk(document.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$productName dihapus'),
                      action: SnackBarAction(
                        label: 'Batal',
                        onPressed: () {
                          // Undo logic bisa ditambahkan di sini jika diperlukan
                        },
                      ),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(productName),
                      subtitle: Text(formatCurrency.format(harga)),
                      leading: imageBase64.isNotEmpty
                          ? Image.memory(
                              base64Decode(imageBase64),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey,
                            ),
                      trailing: Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final String productId = document.id;

                          return IconButton(
                            onPressed: () {
                              if (cartProvider.isAddedToCartList
                                  .contains(productId)) {
                                // 🔴 Ganti ini dari decreaseQuantity ke removeFromCart agar langsung dihapus
                                cartProvider.removeFromCart(productId);
                              } else {
                                final Map<String, dynamic> productDetails = {
                                  'namaProduk': productName,
                                  'harga': harga,
                                };
                                cartProvider.addToCart(
                                    productId, productDetails);
                              }
                            },
                            icon: Icon(
                              cartProvider.isAddedToCartList.contains(productId)
                                  ? Icons
                                      .remove_shopping_cart // bisa diganti icon lainnya
                                  : Icons.add_shopping_cart,
                            ),
                            color: cartProvider.isAddedToCartList
                                    .contains(productId)
                                ? Colors.red
                                : Colors.green,
                          );
                        },
                      ),
                    ),
                    const Divider(
                      color: Colors.pink,
                      thickness: 2,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SecondTab extends StatefulWidget {
  const SecondTab({Key? key}) : super(key: key);

  @override
  _SecondTabState createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  late String _imagePath = '';
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        String base64Image = base64Encode(bytes);
        setState(() {
          _imagePath = base64Image;
        });
      } else {
        print('Pemilihan gambar dibatalkan.');
      }
    } catch (e) {
      print('Kesalahan dalam pemilihan gambar: $e');
    }
  }

  Future<void> _simpanDataKeFirestore(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu')),
      );
      return;
    }

    try {
      _showLoadingDialog(context);
      _showDataNotification(context);

      final firestoreInstance = FirebaseFirestore.instance;
      await firestoreInstance.collection('produk').add({
        'imageBase64': _imagePath,
        'namaProduk': _namaProdukController.text,
        'harga': double.parse(_hargaController.text),
        'jumlah': int.parse(_jumlahController.text),
      });

      Navigator.of(context, rootNavigator: true).pop(); // tutup loading

      print('Data tersimpan di Firestore!');
      _formKey.currentState?.reset();

      setState(() {
        _imagePath = '';
        _namaProdukController.clear();
        _hargaController.clear();
        _jumlahController.clear();
      });
    } catch (e) {
      print('Error saat menyimpan data di Firestore: $e');
    }
  }

  Future<void> _showDataNotification(BuildContext context) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'transaction_channel_id',
      'Transaction Channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await FlutterLocalNotificationsPlugin().show(
      0,
      'Produk Disimpan',
      'Produk berhasil disimpan!',
      platformChannelSpecifics,
      payload: 'Transaction Payload',
    );
  }

  Future<void> _showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: LoadingAnimationWidget.threeRotatingDots(
                color: Colors.pink, size: 35),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomCurvedAppBar(),
      body: SingleChildScrollView(
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
              _buildTextFormField(
                controller: _namaProdukController,
                label: 'Nama Produk',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _hargaController,
                label: 'Harga',
                keyboardType: TextInputType.number,
                prefixText: 'Rp ',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (double.tryParse(value) == null) return 'Harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _jumlahController,
                label: 'Jumlah',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(value) == null) return 'Harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _simpanDataKeFirestore(context),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? prefixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Material(
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
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              prefixText: prefixText,
              contentPadding: const EdgeInsets.only(left: 0),
              border: const UnderlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}

class ThirdTab extends StatelessWidget {
  ThirdTab({super.key});

  final CollectionReference transactions =
      FirebaseFirestore.instance.collection('transaksi');
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // 🔹 Fungsi Cetak PDF
  void selectPrinterAndPrint(
      BuildContext context, Map<String, dynamic> data) async {
    // Minta izin Bluetooth (Android 12+)
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada printer ditemukan")),
      );
      return;
    }

    // Tampilkan daftar printer
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: devices.map((device) {
            return ListTile(
              title: Text(device.name ?? "Unknown"),
              subtitle: Text(device.address ?? ""),
              onTap: () async {
                Navigator.pop(context); // Tutup dialog
                try {
                  bool connected = await bluetooth.isConnected ?? false;
                  if (!connected) {
                    await bluetooth.connect(device);
                    await Future.delayed(const Duration(seconds: 2));
                  }

                  // Proses cetak struk
                  var tanggal = (data['tanggal'] as Timestamp).toDate();
                  var formattedDate = DateFormat('dd-MM-yyyy').format(tanggal);
                  var formattedTime = DateFormat('HH:mm:ss').format(tanggal);

                  double total = 0;
                  List items = data['items'];

                  bluetooth.printNewLine();
                  bluetooth.printCustom("COFFE NOSTALGIA", 3, 1);
                  bluetooth.printNewLine();
                  bluetooth.printCustom("Tanggal: $formattedDate", 1, 0);
                  bluetooth.printCustom("Waktu  : $formattedTime", 1, 0);
                  bluetooth.printCustom("------------------------------", 1, 0);

                  for (var item in items) {
                    var nama = item['namaProduk'];
                    var harga = item['harga'];
                    var jumlah = item['jumlah'] ?? 1;
                    var subtotal = harga * jumlah;
                    total += subtotal;

                    bluetooth.printCustom(nama, 1, 0);
                    bluetooth.printCustom(
                        "Rp$harga x $jumlah = Rp$subtotal", 1, 0);
                  }

                  bluetooth.printCustom("------------------------------", 1, 0);
                  bluetooth.printCustom("TOTAL: Rp$total", 2, 1);
                  bluetooth.printNewLine();
                  bluetooth.printCustom(
                      "--------------------------------", 1, 1);
                  bluetooth.printCustom(
                      "  TERIMA KASIH TELAH BERKUNJUNG", 1, 1);
                  bluetooth.printCustom("SEMOGA HARI ANDA MENYENANGKAN", 1, 1);
                  bluetooth.printCustom(
                      "     ~ Coffee Nostalgia ~      ", 1, 1);
                  bluetooth.printNewLine();
                  bluetooth.paperCut();
                  bluetooth.printNewLine();
                  bluetooth.paperCut();

                  await bluetooth.disconnect(); // Tutup koneksi
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal mencetak: $e")),
                  );
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  // 🔹 Fungsi Cetak PDF
  void generatePdf(BuildContext context, Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final tanggal = (data['tanggal'] as Timestamp).toDate();
    final formattedDate = DateFormat('dd-MM-yyyy').format(tanggal);
    final formattedTime = DateFormat('HH:mm:ss').format(tanggal);

    final List items = data['items'];
    double total = 0;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("COFFE NOSTALGIA",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Tanggal: $formattedDate"),
              pw.Text("Waktu  : $formattedTime"),
              pw.Divider(),
              ...items.map((item) {
                var nama = item['namaProduk'];
                var harga = item['harga'];
                var jumlah = item['jumlah'] ?? 1;
                var subtotal = harga * jumlah;
                total += subtotal;
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(nama),
                    pw.Text("Rp$harga x $jumlah = Rp$subtotal"),
                    pw.SizedBox(height: 5),
                  ],
                );
              }).toList(),
              pw.Divider(),
              pw.Text("TOTAL: Rp$total",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text("TERIMA KASIH TELAH BERKUNJUNG")),
              pw.Center(child: pw.Text("~ Coffee Nostalgia ~")),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomBar(
          iconData: Icons.add,
          title: 'Halaman Transaksi',
          onPressed: () {
            // Navigasi tambah transaksi (jika diperlukan)
          },
          width: 300,
          height: 60,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: transactions.orderBy('tanggal', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                var tanggal = (data['tanggal'] as Timestamp).toDate();
                var formattedDate = DateFormat('dd-MM-yyyy').format(tanggal);
                var formattedTime = DateFormat('HH:mm:ss').format(tanggal);
                var items = data['items'];

                List<Widget> itemsList = [];
                double totalHarga = 0;

                for (var item in items) {
                  var nama = item['namaProduk'];
                  var harga = item['harga'];
                  var jumlah = item['jumlah'] ?? 1;
                  var subtotal = harga * jumlah;
                  totalHarga += subtotal;

                  itemsList.add(Text('$nama'));
                  itemsList.add(Text('Rp$harga x $jumlah = Rp$subtotal'));
                  itemsList.add(const SizedBox(height: 10));
                }

                var totalHargaFormatted =
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                        .format(totalHarga);

                return Card(
                  child: ListTile(
                    title: Row(
                      children: [
                        Text('Tanggal: $formattedDate'),
                        const SizedBox(width: 8),
                        Text('Waktu: $formattedTime'),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...itemsList,
                        const SizedBox(height: 10),
                        const SizedBox(
                          height: 10.0,
                          child: DashedDivider(
                            color: Colors.black,
                            strokeWidth: 2.0,
                            dashWidth: 8.0,
                            dashSpace: 4.0,
                            height: 16.0,
                          ),
                        ),
                        Text('Total Harga: $totalHargaFormatted'),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () =>
                                    selectPrinterAndPrint(context, data),
                                icon: const Icon(Icons.print),
                                label: const Text("Cetak"),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () => generatePdf(context, data),
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text("Cetak PDF"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Belum ada transaksi.'));
        },
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double height;

  const DashedDivider({
    super.key,
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedLinePainter(
        color: color,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
      size: Size.infinite,
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: CustomBar(
          title: '',
          iconData: Icons.history, // Ikon di kanan
          height: 80,
          width: 300,
          showBackButton: true, // Menampilkan tombol kembali di kiri
          onPressed: () {
            Navigator.pop(context); // 👈 Ini kembali ke FirstTab
          },
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cartItems.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Keranjang belanja kosong.',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            );
          }

          return ListView(
            children: [
              ...cartProvider.cartItems.map((cartItem) {
                final String productId =
                    cartItem['productId'] ?? UniqueKey().toString();

                final String productName = cartItem['namaProduk'] ?? 'Produk';
                final double harga = (cartItem['harga'] ?? 0).toDouble();
                final int jumlah = cartItem['jumlah'] ?? 1;
                final double totalHargaItem = harga * jumlah;

                return Dismissible(
                  key: Key(productId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    cartProvider.removeFromCart(productId);
                  },
                  child: Card(
                    color: Colors.pink,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah: $jumlah',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Harga: ${priceFormatter.format(totalHargaItem)}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      trailing: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.remove, color: Colors.pink),
                              onPressed: () {
                                if (jumlah <= 1) {
                                  cartProvider.removeFromCart(productId);
                                } else {
                                  cartProvider.decreaseQuantity(productId);
                                }
                              },
                            ),
                            Text(
                              '$jumlah',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.pink,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.pink),
                              onPressed: () {
                                cartProvider.increaseQuantity(productId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return cartProvider.cartItems.isEmpty
              ? const SizedBox.shrink()
              : FloatingActionButton(
                  onPressed: () async {
                    // ✅ Simpan salinan cart sebelum dikosongkan
                    List<Map<String, dynamic>> itemsCopy =
                        List<Map<String, dynamic>>.from(cartProvider.cartItems);

                    double total =
                        await cartProvider.saveTransactionToFirestore(context);

                    if (total > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TotalPage(
                            total: total,
                            items: itemsCopy, // ✅ Ini tetap punya data
                          ),
                        ),
                      );
                    }
                  },
                  backgroundColor: Colors.pink,
                  child: const Icon(Icons.add_task, color: Colors.white),
                );
        },
      ),
    );
  }
}

class TotalPage extends StatelessWidget {
  final double total;
  final List<Map<String, dynamic>> items;

  const TotalPage({Key? key, required this.total, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Total Pembelian"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Detail Pembelian:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            // Batasi tinggi daftar produk supaya tidak mendorong ke bawah
            SizedBox(
              height: 250, // Atur sesuai kebutuhan, bisa 220, 200, dll
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        item['namaProduk'] ?? 'Produk',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text("Jumlah: ${item['jumlah']}"),
                      trailing: Text(
                        formatter.format(
                            (item['harga'] ?? 0) * (item['jumlah'] ?? 1)),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 1.5),
            const SizedBox(height: 12),

            // Total dan tombol lebih ke atas
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Total: ${formatter.format(total)}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ThirdTab()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text("Riwayat pembelian"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
