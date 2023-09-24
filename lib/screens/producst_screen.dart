// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:market/resource/firestore_methods.dart';

class Product {
  final String productId;
  final String customerName;
  String productName;
  final DateTime datePublished;
  late final String productImage;
  final double price;
  final String tag;
  int amount;
  final bool odemeDurumu;

  Product({
    required this.productId,
    required this.customerName,
    required this.productName,
    required this.datePublished,
    required this.productImage,
    required this.price,
    required this.tag,
    required this.amount,
    required this.odemeDurumu,
  });
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  List<Product> selectedProducts = [];
  String selectedOption = '';
  List<String> options = ['Alkol', 'Sigara', 'Diğer'];
  Map<String, int> sellQuantities = {};
  Map<String, double> sellPrices = {};

  String customerName = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  final _textStyle =
      GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600);
  final _textStyle1 =
      GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w500);

  void fetchProducts() {
    FirebaseFirestore.instance
        .collection('Products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<Product> fetchedProducts = [];
      for (var doc in querySnapshot.docs) {
        fetchedProducts.add(Product(
          productId: doc.id,
          customerName: doc['customerName'],
          productName: doc['productName'],
          datePublished: doc['datePublished'].toDate(),
          productImage: doc['productImage'],
          price: doc['price'].toDouble(),
          tag: doc['tag'],
          amount: doc['amount'],
          odemeDurumu: doc['odemeDurumu'],
        ));
      }
      setState(() {
        products = fetchedProducts;
      });
    });
  }

  void toggleProductSelection(Product product) {
    setState(() {
      if (selectedProducts.contains(product)) {
        selectedProducts.remove(product);
      } else {
        selectedProducts.add(product);
      }
    });
  }

  void updateSellQuantity(String productId, int quantity) {
    setState(() {
      sellQuantities[productId] = quantity;
    });
  }

  void updateSellPrice(String productId, double price) {
    setState(() {
      sellPrices[productId] = price;
    });
  }

  void sellSelectedProducts() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Satış Yap'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Müşteri Adı',
                  ),
                  onChanged: (value) {
                    setState(() {
                      customerName = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  children: selectedProducts.map((Product product) {
                    final String productId = product.productId;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Ürün Adı: '),
                            Text(product.productName,
                                style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                        Text('Adet: ${product.amount}',
                            style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Satış Miktarı',
                          ),
                          onChanged: (value) {
                            int quantity = int.tryParse(value) ?? 0;
                            updateSellQuantity(productId, quantity);
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Fiyat',
                          ),
                          onChanged: (value) {
                            double price = double.tryParse(value) ?? 0.0;
                            updateSellPrice(productId, price);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                sellProducts();
                Navigator.pop(context);
              },
              child: const Text('Satış Yap'),
            ),
          ],
        );
      },
    );
  }

  void sellProducts() {
    if (customerName.isNotEmpty) {
      for (var product in selectedProducts) {
        final String productId = product.productId;
        final int sellQuantity = sellQuantities[productId] ?? 0;
        final double sellPrice = sellPrices[productId] ?? 0.0;

        if (sellQuantity > 0 && sellPrice > 0) {
          FirebaseFirestore.instance.collection('sales').add({
            'customerName': customerName,
            'productId': product.productId,
            'productName': product.productName,
            'datePublished': product.datePublished,
            'productImage': product.productImage,
            'price': sellPrice,
            'tag': product.tag,
            'amount': sellQuantity,
            'odemeDurumu': product.odemeDurumu,
            'documentId': '', // Döküman ID'si için boş bir alan
          }).then((docRef) {
            // Eklenen dökümanın ID'sini güncelle
            docRef.update({'documentId': docRef.id});

            int updatedAmount = product.amount - sellQuantity;
            FirebaseFirestore.instance
                .collection('Products')
                .doc(product.productId)
                .update({'amount': updatedAmount});

            // Güncellenen stok bilgisini lokal olarak da güncelle
            setState(() {
              product.amount = updatedAmount;
            });
          });
        }
      }

      setState(() {
        selectedProducts.clear();
        sellQuantities.clear();
        sellPrices.clear();
        customerName = '';
      });
    }
  }

  void deleteProduct(String docId) {
    // Ürünü silme işlemini burada gerçekleştirin
    FireStoreMethods().deleteProduct(docId);
    setState(() {
      fetchProducts();
    });
    // Örneğin, Firestore'dan dökümanı silmek gibi
  }

  void showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ürünü Sil'),
          content:
              const Text('Seçili ürünü silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                deleteProduct(docId);
                Navigator.pop(context);
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = products;

    if (selectedOption == 'Alkol') {
      filteredProducts =
          products.where((product) => product.tag == 'Alkol').toList();
      debugPrint(selectedOption);
    } else if (selectedOption == 'Sigara') {
      filteredProducts =
          products.where((product) => product.tag == 'Sigara').toList();
      debugPrint(selectedOption);
    } else if (selectedOption == 'Diğer') {
      filteredProducts =
          products.where((product) => product.tag == 'Diğer').toList();
      debugPrint(selectedOption);
    }
    void _showEditProductDialog(Product product) {
      String updatedProductName = product.productName;
      int updatedAmount = product.amount;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ürünü Düzenle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Ürün Adı',
                  ),
                  onChanged: (value) {
                    updatedProductName = value;
                  },
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Adet',
                  ),
                  onChanged: (value) {
                    updatedAmount = int.tryParse(value) ?? 0;
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Değişiklikleri uygula
                  setState(() {
                    product.productName = updatedProductName;
                   
                    product.amount = updatedAmount;
                  });

                  // Değişiklikleri Firestore'a kaydet
                  FireStoreMethods().updateProduct(
                    product.productId,
                    updatedProductName,
                    updatedAmount,
                  );

                  Navigator.pop(context);
                },
                child: const Text('Güncelle'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori Seç',
                style: _textStyle,
              ),
              PopupMenuButton<String>(
                iconSize: 26,
                icon: const Icon(Icons.menu_open),
                tooltip: 'Kategori Seç',
                onSelected: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return options.map((String option) {
                    return PopupMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (BuildContext context, int index) {
          final Product product = filteredProducts[index];
          final bool isSelected = selectedProducts.contains(product);

          return GestureDetector(
            onLongPress: () {
              showDeleteConfirmation(product.productId);
            },
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade200,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                product.productName,
                                style: _textStyle,
                              ),
                              const SizedBox(height: 10),
                              CircleAvatar(
                                radius: 26,
                                backgroundImage: NetworkImage(
                                  product.productImage,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: Text(
                                  product.tag,
                                  style: _textStyle1,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Ürünü Seç: ',
                                    style: _textStyle1,
                                  ),
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) =>
                                        toggleProductSelection(product),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Expanded(child: Container()),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${product.amount.toString()} Adet',
                                          style: _textStyle1,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text('${product.price.toString()} TL',
                                      style: _textStyle1),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _showEditProductDialog(product),
                            child: const Text('Ürün Güncelle'),
                          ),
                          Expanded(child: Container()),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat.yMd().add_jm().format(
                                    product.datePublished,
                                  ),
                              style: _textStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider()
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sellSelectedProducts,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
