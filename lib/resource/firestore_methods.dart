import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market/model/product.dart';
import 'package:market/resource/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> uploadProduct(String productName, Uint8List file, String tag,
      double price, int amount, bool odemeDurumu) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String productImage = await StorageMethods()
          .uploadImageToStorage('ProductImage', file, true, tag);
      String productId = const Uuid().v1(); // creates unique id based on time
      Product product = Product(
        odemeDurumu: odemeDurumu,
        customerName: 'Jhon',
        productId: productId,
        productName: productName,
        datePublished: DateTime.now(),
        productImage: productImage,
        price: price,
        tag: tag,
        amount: amount,
      );
      _firestore.collection('Products').doc(productId).set(product.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadProductNoImage(String productName, String tag,
      double price, int amount, bool odemeDurumu) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String productId = const Uuid().v1(); // creates unique id based on time
      Product product = Product(
        odemeDurumu: odemeDurumu,
        customerName: 'Jhon',
        productId: productId,
        productName: productName,
        datePublished: DateTime.now(),
        productImage: "https://blog.sogoodweb.com/upload/510/ZDqhSBYemO.jpg",
        price: price,
        tag: tag,
        amount: amount,
      );
      _firestore.collection('Products').doc(productId).set(product.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> updateAmount(String productId, int newValue) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('Products').doc(productId).update({
        "amount": newValue,
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

//Delete Product
  Future<String> deleteAndTrashProduct(
      String productId,
      String productName,
      String productImage,
      double price,
      String tag,
      int amount,
      bool odemeDurumu) async {
    String res = "Some error occurred";
    try {
      Product product = Product(
        odemeDurumu: odemeDurumu,
        customerName: 'Jhon',
        productId: productId,
        productName: productName,
        datePublished: DateTime.now(),
        productImage: productImage,
        price: price,
        tag: tag,
        amount: amount,
      );

      await _firestore
          .collection('TrashProducts')
          .doc(productId)
          .set(product.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteProduct(String productId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('Products').doc(productId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> salesProduct(
      String productId,
      String customerName,
      int amount,
      double price,
      String tag,
      String productImage,
      String productName,
      bool odemeDurumu) async {
    String res = "Some error occurred";
    try {
      String orderId = const Uuid().v1(); // creates unique id based on time
      await _firestore.collection('ProductsSold').doc(orderId).set({
        "customerName": customerName,
        "odemeDurumu": odemeDurumu,
        "orderId": orderId,
        "amount": amount,
        "productId": productId,
        "datePublished": DateTime.now(),
        "price": price,
        "tag": tag,
        "productImage": productImage,
        "productName": productName
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> orderCancel(
    String productId,
    String customerName,
    int amount,
  ) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('Products').doc(productId).update({
        "customerName": customerName,
        "amount": amount,
      });
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> orderDelete(
    String orderId,
  ) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('ProductsSold').doc(orderId).delete();
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> odemeControl(String orderId, bool newValue) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('sales')
          .doc(orderId)
          .update({'odemeDurumu': newValue});
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  void updateProduct(
      String productId, String productName, int amount) {
    FirebaseFirestore.instance.collection('Products').doc(productId).update({
      'productName': productName,
      'amount': amount,
      // Diğer güncellenecek alanları da buraya ekleyebilirsiniz
    }).then((_) {
      print('Ürün güncellendi!');
    }).catchError((error) {
      print('Ürün güncellenirken hata oluştu: $error');
    });
  }
}
