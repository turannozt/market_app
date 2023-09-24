// ignore_for_file: unnecessary_type_check, use_build_context_synchronously

import 'dart:typed_data';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../resource/firestore_methods.dart';
import '../utils/utils.dart';
import '../widgets/textfiled_input.dart';

class ProductAddScreen extends StatefulWidget {
  const ProductAddScreen({super.key});

  @override
  State<ProductAddScreen> createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  Uint8List? _file;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productPAdetController = TextEditingController();
  final List<String> items = [
    'Alkol',
    'Sigara',
    'Diğer',
  ];
  bool isLoading = false;
  void postProduct(String productName, double price, int amount) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db

      if (_file == null) {
        String res = await FireStoreMethods().uploadProductNoImage(
            productName, selectedValue.toString(), price, amount, false);
        if (res == "success") {
          setState(() {
            isLoading = false;
            _productNameController.text = "";
            _productPriceController.text = "";
            _productPAdetController.text = "";
          });
          final snackBar = SnackBar(
            /// need to set following properties for best effect of awesome_snackbar_content
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Yeni Ürün Eklendi',
              message: 'Ürün Bilgileri Kaydedildi.',

              /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        } else {}
      } else {
        String res = await FireStoreMethods().uploadProduct(productName, _file!,
            selectedValue.toString(), price, amount, false);
        if (res == "success") {
          setState(() {
            isLoading = false;
            _productNameController.text = "";
            _productPriceController.text = "";
            _productPAdetController.text = "";
          });

          clearImage();
          final snackBar = SnackBar(
            /// need to set following properties for best effect of awesome_snackbar_content
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Yeni Ürün Eklendi',
              message: 'Ürün Bilgileri Kaydedildi.',

              /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
              contentType: ContentType.warning,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        } else {}
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
  }

  String? selectedValue;
  selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Gönderi Oluştur',
            style: GoogleFonts.openSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Kameradan Çek',
                  style: GoogleFonts.openSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Galeriden Seç',
                  style: GoogleFonts.openSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: Text(
                "İptal",
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Ekle'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                _file != null
                    ? CircleAvatar(
                        radius: 72,
                        backgroundImage: MemoryImage(_file!),
                        backgroundColor: Colors.transparent,
                      )
                    : const Center(
                        child: CircleAvatar(
                          radius: 72,
                          backgroundImage: NetworkImage(
                              "https://blog.sogoodweb.com/upload/510/ZDqhSBYemO.jpg"),
                        ),
                      ),
                Positioned(
                  bottom: -11,
                  left: 200,
                  child: IconButton(
                    onPressed: () => selectImage(context),
                    icon: const Icon(Icons.add_a_photo_sharp),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 18),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    hint: Text(
                      'Kategori Seçin',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: items
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                    value: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value as String;
                      });
                    },
                    buttonStyleData: const ButtonStyleData(
                      height: 40,
                      width: 140,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
            const SizedBox(height: 10),
            TextFielInput(
              controller: _productNameController,
              icon: Icons.add_chart_outlined,
              subTitle: 'Ürün Adı Giriniz',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 5),
            TextFielInput(
              controller: _productPriceController,
              icon: Icons.price_change,
              subTitle: 'Ürün Fiyatını Giriniz',
              textInputType: TextInputType.number,
            ),
            const SizedBox(height: 5),
            TextFielInput(
              controller: _productPAdetController,
              icon: Icons.numbers,
              subTitle: 'Kaç Adet ?',
              textInputType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.black,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    minimumSize: const Size(double.infinity, 50), //////// HERE
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.indigo.shade800, // foreground
                  ),
                  onPressed: () {
                    var myDouble = double.parse(_productPriceController.text);
                    assert(myDouble is double);

                    var myInt = int.parse(_productPAdetController.text);
                    assert(myInt is int);

                    postProduct(_productNameController.text, myDouble, myInt);
                  },
                  icon: const Icon(
                    Icons.save_as,
                    size: 24,
                  ),
                  label: isLoading
                      ? Text(
                          'Bekleniyor...',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        )
                      : Text(
                          'Kaydet',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        )),
            )
          ],
        ),
      ),
    );
  }
}
