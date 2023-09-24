// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market/screens/home_screen.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late Future<Map<String, List<Map<String, dynamic>>>> salesFuture;
  late Future<Map<String, dynamic>> productsFuture;

  @override
  void initState() {
    super.initState();
    salesFuture = fetchSales();
    productsFuture = fetchProducts();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchSales() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('sales').get();
    Map<String, List<Map<String, dynamic>>> salesMap = {};

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic> sale = doc.data()! as Map<String, dynamic>;
      String customerName = sale['customerName'];

      if (salesMap.containsKey(customerName)) {
        salesMap[customerName]!.add(sale);
      } else {
        salesMap[customerName] = [sale];
      }
    }

    return salesMap;
  }

  Future<Map<String, dynamic>> fetchProducts() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Products').get();

    Map<String, dynamic> products = {};

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      products[doc.id] = doc.data()! as Map<String, dynamic>;
    }

    return products;
  }

  Future<void> cancelOrder(
      String customerId, String productId, int amount) async {
    // İlgili siparişi iptal et
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where('customerName', isEqualTo: customerId)
        .where('productId', isEqualTo: productId)
        .where('amount', isEqualTo: amount)
        .get();

    if (snapshot.size > 0) {
      for (var doc in snapshot.docs) {
        String? documentId = doc.id;

        if (documentId != null) {
          await doc.reference.delete();
        }
      }
    }

    // Ürünün stok bilgisini güncelle
    DocumentReference productRef =
        FirebaseFirestore.instance.collection('Products').doc(productId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot productSnapshot = await transaction.get(productRef);
      if (productSnapshot.exists) {
        int currentStock =
            (productSnapshot.data() as Map<String, dynamic>)['amount'];

        transaction.update(productRef, {'amount': currentStock + amount});
      }
    }).then((value) {
      setState(() {
        fetchSales();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
      });
    });
  }

  final _TextStyle =
      GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600);

  void updatePaymentStatus(String documentId, bool status) {
    FirebaseFirestore.instance
        .collection('sales')
        .doc(documentId)
        .update({'odemeDurumu': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Satışlar'),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: salesFuture,
        builder: (context, salesSnapshot) {
          if (salesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (salesSnapshot.hasError) {
            return const Center(child: Text('Veriler alınamadı.'));
          }

          Map<String, List<Map<String, dynamic>>> salesMap =
              salesSnapshot.data ?? {};

          if (salesMap.isEmpty) {
            return const Center(child: Text('Satış bulunamadı.'));
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: productsFuture,
            builder: (context, productsSnapshot) {
              if (productsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productsSnapshot.hasError) {
                return const Center(child: Text('Veriler alınamadı.'));
              }

              Map<String, dynamic> products = productsSnapshot.data ?? {};

              return ListView.builder(
                itemCount: salesMap.length,
                itemBuilder: (context, index) {
                  String customerName = salesMap.keys.elementAt(index);
                  List<Map<String, dynamic>> customerSales =
                      salesMap[customerName] ?? [];

                  return GestureDetector(
                    onTap: () {},
                    child: Card(
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            const Text('Müşteri Adı: '),
                            Text(customerName),
                          ],
                        ),
                        children: customerSales.map((sale) {
                          String productId = sale['productId'];
                          int amount = sale['amount'];
                          String productName =
                              products[productId]['productName'];
                          int stock = products[productId]['amount'];
                          double price = sale['price'];
                          String documentId = sale['documentId'];
                          bool switchValue = sale['odemeDurumu'];

                          return ListTile(
                            title: Row(
                              children: [
                                const Text('Ürün Adı: '),
                                Text(productName),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adet: $amount',
                                  style: _TextStyle,
                                ),
                                Text(
                                  'Stok: $stock',
                                  style: _TextStyle,
                                ),
                                Text(
                                  'Fiyat: $price TL',
                                  style: _TextStyle,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Toplam Fiyat : ${price * amount} TL',
                                  style: _TextStyle,
                                ),
                                SwitchListTile(
                                  title: const Text('Ödeme Durumu'),
                                  value: switchValue,
                                  onChanged: (value) {
                                    setState(() {
                                      switchValue = value;
                                    });
                                    updatePaymentStatus(
                                        documentId, switchValue);
                                  },
                                ),
                              ],
                            ),
                            trailing: Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Siparişi İptal Et'),
                                          content: const Text(
                                              'Bu ürünün siparişini iptal etmek istiyor musunuz?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('İptal'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Evet'),
                                              onPressed: () {
                                                cancelOrder(customerName,
                                                    productId, amount);
                                                setState(() {
                                                  fetchSales();
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
