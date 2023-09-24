import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productId;
  final String productName;
  final DateTime datePublished;
  final String productImage;
  final double price;
  final String tag;
  final int amount;
  final String customerName;
  final bool odemeDurumu;
  const Product(
      {required this.productId,
      required this.customerName,
      required this.productName,
      required this.datePublished,
      required this.productImage,
      required this.price,
      required this.tag,
      required this.amount,
      required this.odemeDurumu});

  static Product fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Product(
      odemeDurumu: snapshot['odemeDurumu'],
      customerName: snapshot['customerName'],
      amount: snapshot['amount'],
      productId: snapshot['productId'],
      productName: snapshot["productName"],
      datePublished: snapshot["datePublished"],
      productImage: snapshot["productImage"],
      price: snapshot["price"],
      tag: snapshot["tag"],
    );
  }

  Map<String, dynamic> toJson() => {
        "odemeDurumu": odemeDurumu,
        "customerName": customerName,
        "amount": amount,
        "productId": productId,
        "productName": productName,
        "datePublished": datePublished,
        "productImage": productImage,
        "price": price,
        "tag": tag,
      };
}
