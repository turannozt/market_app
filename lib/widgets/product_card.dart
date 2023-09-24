// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, unnecessary_type_check, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:market/resource/firestore_methods.dart';


class ProductCard extends StatefulWidget {
  final snap;

  const ProductCard({super.key, this.snap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _price = TextEditingController();
  Future<void> _dialogBuilder(BuildContext contexts, VoidCallback onTap) {
    return showDialog<void>(
      context: contexts,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Satış Ekranı'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customerName,
                decoration: const InputDecoration(hintText: 'Müşteri Adı'),
              ),
              TextField(
                controller: _amount,
                decoration: const InputDecoration(hintText: 'Kaç Adet Satıldı'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _price,
                decoration: const InputDecoration(hintText: 'Satış Fiyatı '),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: onTap, child: const Text('Satış Yap')),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool rememberMe = false;
  @override
  Widget build(BuildContext context) {
    Future<void> _dialogBuilderDelete(
        BuildContext context, VoidCallback onTap) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Silmek İstediğinden Emin misin ?'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('İptal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                onPressed: onTap,
                child: const Text('Evet'),
              ),
            ],
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        _dialogBuilderDelete(context, () {
          FireStoreMethods().deleteProduct(widget.snap['productId']);
          Navigator.pop(context);
        });
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
                          widget.snap['productName'],
                          style: _TextStyle,
                        ),
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(
                            widget.snap['productImage'],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: Text(
                            widget.snap['tag'],
                            style: _TextStyle1,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Ürünü Seç: ',
                              style: _TextStyle1,
                            ),
                          
                          ],
                        )
                      ],
                    ),
                    Expanded(child: Container()),
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
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
                                  TextButton(
                                    child: const Text('Sat'),
                                    onPressed: () {
                                      _dialogBuilder(context, () {
                                        var myInt = int.parse(_amount.text);
                                        assert(myInt is int);
                                        if (myInt > widget.snap['amount']) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Adet Sayısı Depodan Fazla Olamaz.",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 2,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        } else {
                                          var myDouble =
                                              double.parse(_price.text);
                                          assert(myDouble is double);
                                          FireStoreMethods().salesProduct(
                                              widget.snap['productId'],
                                              _customerName.text,
                                              myInt,
                                              myDouble,
                                              widget.snap['tag'],
                                              widget.snap['productImage'],
                                              widget.snap['productName'],
                                              false);

                                          FireStoreMethods().updateAmount(
                                              widget.snap['productId'],
                                              widget.snap['amount'] - myInt);

                                          _customerName.text = "";
                                          _price.text = "";
                                          _amount.text = "";
                                          Navigator.pop(context);
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '${widget.snap['amount'].toString()} Adet',
                                    style: _TextStyle1,
                                  ),
                                  TextButton(
                                    child: const Text('Ekle'),
                                    onPressed: () {
                                      FireStoreMethods().updateAmount(
                                          widget.snap['productId'],
                                          widget.snap['amount'] + 1);
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text('${widget.snap['price'].toString()} TL',
                                style: _TextStyle1),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                //   Text('${widget.snap['price'].toString()} TL', style: _TextStyle1),
                Row(
                  children: [
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat.yMd().add_jm().format(
                              widget.snap['datePublished'].toDate(),
                            ),
                        style: _TextStyle,
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
  }

  final _TextStyle =
      GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600);
  final _TextStyle1 =
      GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w500);
}
