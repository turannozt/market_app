// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, unnecessary_type_check
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market/resource/firestore_methods.dart';

class StorageProductCard extends StatefulWidget {
  final snap;
  const StorageProductCard({super.key, this.snap});

  @override
  State<StorageProductCard> createState() => _StorageProductCardState();
}

class _StorageProductCardState extends State<StorageProductCard> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200,
            ),
            child: Row(
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    FireStoreMethods().updateAmount(
                                        widget.snap['productId'],
                                        widget.snap['amount'] - 1);
                                  },
                                  icon: const Icon(Icons.remove)),
                              Text(
                                '${widget.snap['amount'].toString()} Adet',
                                style: _TextStyle1,
                              ),
                              IconButton(
                                  onPressed: () {
                                    FireStoreMethods().updateAmount(
                                        widget.snap['productId'],
                                        widget.snap['amount'] + 1);
                                  },
                                  icon: const Icon(Icons.add)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${widget.snap['price'].toString()} TL',
                            style: _TextStyle1),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          //   Text('${widget.snap['price'].toString()} TL', style: _TextStyle1),
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
