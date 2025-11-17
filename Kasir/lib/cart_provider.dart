import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CartProvider extends ChangeNotifier {
  List<String> isAddedToCartList = [];
  List<Map<String, dynamic>> cartItems = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Getter otomatis untuk total produk
  int get totalProdukDiKeranjang {
    int total = 0;
    for (var item in cartItems) {
      total += item['jumlah'] as int;
    }
    return total;
  }

  Future<void> addToCart(
      String productId, Map<String, dynamic> productDetails) async {
    DocumentSnapshot<Object?> productSnapshot =
        await firestore.collection('produk').doc(productId).get();

    Map<String, dynamic>? data =
        productSnapshot.data() as Map<String, dynamic>?;

    if (data != null &&
        data.containsKey('namaProduk') &&
        data.containsKey('harga') &&
        data.containsKey('jumlah')) {
      int jumlahDiFirestore = data['jumlah'] ?? 0;

      final String? productName = data['namaProduk'] as String?;

      if (productName != null) {
        if (jumlahDiFirestore > 0) {
          if (!isAddedToCartList.contains(productId)) {
            isAddedToCartList.add(productId);

            Map<String, dynamic> cartItem = {
              'productId': productId,
              'namaProduk': productName,
              'harga': data['harga'],
              'jumlah': 1,
            };

            cartItems.add(cartItem);

            await firestore
                .collection('produk')
                .doc(productId)
                .update({'jumlah': jumlahDiFirestore - 1});

            notifyListeners();
          } else {
            print('Produk sudah ada di keranjang');
          }
        } else {
          print('Stok produk habis.');
        }
      } else {
        print('Nama produk bernilai null di dokumen Firestore.');
      }
    } else {
      print('Field yang diperlukan tidak ditemukan di dokumen Firestore.');
    }
  }

  void increaseQuantity(String productId) async {
    for (var i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['productId'] == productId) {
        var productDoc =
            await firestore.collection('produk').doc(productId).get();
        var productData = productDoc.data();
        var currentStock = productData!['jumlah'] ?? 0;

        if (currentStock > 0) {
          cartItems[i]['jumlah']++;
          notifyListeners();

          await firestore
              .collection('produk')
              .doc(productId)
              .update({'jumlah': FieldValue.increment(-1)});
        } else {
          print('Stok produk $productId sudah habis.');
        }
        break;
      }
    }
  }

  void decreaseQuantity(String productId) async {
    for (var i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['productId'] == productId) {
        if (cartItems[i]['jumlah'] > 1) {
          cartItems[i]['jumlah']--;
          notifyListeners();

          await firestore
              .collection('produk')
              .doc(productId)
              .update({'jumlah': FieldValue.increment(1)});
        } else {
          cartItems.removeAt(i);
          isAddedToCartList.remove(productId);
          notifyListeners();

          await firestore
              .collection('produk')
              .doc(productId)
              .update({'jumlah': FieldValue.increment(1)});
        }
        break;
      }
    }
  }

  Future<double> saveTransactionToFirestore(BuildContext context) async {
  try {
    double totalHarga = getTotalHarga(); // Ambil total sebelum clearCart

    CollectionReference transactions = firestore.collection('transaksi');

    Map<String, dynamic> transactionData = {
      'tanggal': DateTime.now(),
      'items': List<Map<String, dynamic>>.from(cartItems), // salin isi
      'totalHarga': totalHarga,
    };

    await transactions.add(transactionData);

    await clearCart();

    _showTransactionNotification(context);

    return totalHarga; // Return total
  } catch (error) {
    print('Error saving transaction: $error');
    return 0.0;
  }
}

  Future<void> _showTransactionNotification(BuildContext context) async {
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
      'Transaksi Disimpan',
      'Transaksi berhasil disimpan!',
      platformChannelSpecifics,
      payload: 'Transaction Payload',
    );
  }

  double getTotalHarga() {
    double totalHarga = 0.0;
    for (var cartItem in cartItems) {
      final double harga = cartItem['harga'] as double;
      final int jumlah = cartItem['jumlah'];
      totalHarga += harga * jumlah;
    }
    return totalHarga;
  }

  Future<void> clearCart() async {
    try {
      for (var cartItem in cartItems) {
        final String productId = cartItem['productId'];
        final int jumlah = cartItem['jumlah'];
        await firestore
            .collection('produk')
            .doc(productId)
            .update({'jumlah': FieldValue.increment(jumlah)});
      }

      cartItems.clear();
      isAddedToCartList.clear();
      notifyListeners();
    } catch (error) {
      print('Error clearing cart: $error');
    }
  }

  void removeFromCart(String productId) async {
    int index = cartItems.indexWhere((item) => item['productId'] == productId);

    if (index != -1) {
      int removedQty = cartItems[index]['jumlah'] ?? 0;

      await firestore
          .collection('produk')
          .doc(productId)
          .update({'jumlah': FieldValue.increment(removedQty)});

      cartItems.removeAt(index);
      isAddedToCartList.remove(productId);
      notifyListeners();
    } else {
      print('Produk tidak ditemukan di cartItems.');
    }
  }
}
