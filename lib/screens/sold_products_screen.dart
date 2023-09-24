import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/sold_product_card.dart';

class ProductsSoldsScreen extends StatefulWidget {
  const ProductsSoldsScreen({super.key});

  @override
  State<ProductsSoldsScreen> createState() => _ProductsSoldsScreenState();
}

class _ProductsSoldsScreenState extends State<ProductsSoldsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: const Text('Satış Yapılan Ürünler'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('ProductsSold')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          // ignore: unrelated_type_equality_checks
          if (snapshot.connectionState == ConnectionState.values) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) {
              return SProductCard(
                snap: snapshot.data!.docs[index].data(),
              );
            },
          );
        },
      ),
    );
  }
}
