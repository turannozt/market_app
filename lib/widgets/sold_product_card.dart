// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:market/resource/firestore_methods.dart';

class SProductCard extends StatefulWidget {
  final snap;
  const SProductCard({super.key, this.snap});

  @override
  State<SProductCard> createState() => _SProductCardState();
}

class _SProductCardState extends State<SProductCard> {
  bool isLoading = false;
  var userData = {};
  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Products')
          .doc(widget.snap['productId'])
          .get();
      userData = userSnap.data()!;
      setState(
        () {},
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> orderCancel(BuildContext context, VoidCallback onTap) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İptal Etmek İstediğinizden Emin misiniz ?'),
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

  bool isLikeAnimating = false;

  final _TextStyle =
      GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600);
  final _TextStyle1 =
      GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w500);
  @override
  Widget build(BuildContext context) {
    bool switchValue = widget.snap['odemeDurumu'];
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.shade200,
          ),
          padding: const EdgeInsets.symmetric(vertical: 3),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(
                      widget.snap['productImage'],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.snap['productName'],
                        style: _TextStyle,
                      ),
                      Text(
                        widget.snap['tag'],
                        style: _TextStyle1,
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${widget.snap['amount'].toString()} Adet',
                                  style: _TextStyle1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                              '${widget.snap['price'] * widget.snap['amount']} TL',
                              style: _TextStyle1),
                        ],
                      ),
                    ],
                  ),
                  TextButton.icon(
                      onPressed: () {
                        orderCancel(context, () {
                          FireStoreMethods().orderCancel(
                            widget.snap['productId'],
                            'Jhon',
                            userData['amount'] + widget.snap['amount'],
                          );
                          FireStoreMethods()
                              .orderDelete(widget.snap['orderId']);
                          Navigator.pop(context);
                        });
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('İptal'))
                ],
              ),
              Text(
                widget.snap['customerName'].toString(),
                style: _TextStyle,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                DateFormat.yMd().add_jm().format(
                      widget.snap['datePublished'].toDate(),
                    ),
                style: _TextStyle,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Ödeme Durumu:', style: _TextStyle),
                  Switch(
                    value: switchValue,
                    onChanged: (value) {
                      setState(() {
                        switchValue = value;
                      });
                      FireStoreMethods()
                          .odemeControl(widget.snap['orderId'], switchValue);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider()
      ],
    );
  }
}
