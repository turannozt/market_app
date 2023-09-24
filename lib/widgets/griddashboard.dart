// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market/screens/product_add.dart';
import 'package:market/screens/sales_screen.dart';
import 'package:market/screens/storage_info.dart';
import '../screens/producst_screen.dart';

class GridDashboard extends StatelessWidget {
  Items item1 = Items(
      onTapNumber: 0,
      title: "Ürünler",
      subtitle: "Sigara, Alkol, Diğer",
      event: "Ürün Sayısı",
      img: "assets/food.png");

  Items item2 = Items(
    onTapNumber: 1,
    title: "Ürün Ekle",
    subtitle: "Ürün Ekler",
    event: "Yeni Ürün Oluştur",
    img: "assets/todo.png",
  );

  Items item3 = Items(
    onTapNumber: 2,
    title: "Satışlar",
    subtitle: "Satış Yapılan Ürünler ",
    event: "Ürün Sayısı",
    img: "assets/map.png",
  );

  Items item4 = Items(
    onTapNumber: 3,
    title: "Depo Bilgileri",
    subtitle: "Depo Bilgilerini Listeler ",
    event: "Ürün Sayısı",
    img: "assets/festival.png",
  );

  GridDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    List<Items> myList = [item1, item2, item3, item4];
    var color = 0xff453658;
    return Flexible(
      child: GridView.count(
          childAspectRatio: 1.0,
          padding: const EdgeInsets.only(left: 16, right: 16),
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          children: myList.map((data) {
            return GestureDetector(
              onTap: () {
                if (data.onTapNumber == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProductsPage(),
                    ),
                  );
                } else if (data.onTapNumber == 1) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProductAddScreen(),
                    ),
                  );
                } else if (data.onTapNumber == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SalesPage(),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StorageInfoScreen(),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Color(color),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      data.img,
                      width: 42,
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      data.title,
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      data.subtitle,
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      data.event,
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          }).toList()),
    );
  }
}

class Items {
  String title;
  String subtitle;
  String event;
  String img;
  int onTapNumber;
  Items(
      {required this.title,
      required this.subtitle,
      required this.event,
      required this.img,
      required this.onTapNumber});
}
