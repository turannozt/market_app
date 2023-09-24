import 'package:flutter/material.dart';

class TextFielInput extends StatelessWidget {
  const TextFielInput({
    super.key,
    required this.subTitle,
    required this.controller,
    required this.icon,
    required this.textInputType,
  });
  final String subTitle;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType textInputType;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      padding: const EdgeInsets.only(left: 20, right: 20),
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.grey[200],
        boxShadow: const [
          BoxShadow(
              offset: Offset(0, 10), blurRadius: 50, color: Color(0xFF363567)),
        ],
      ),
      child: TextField(
        controller: controller,
        cursorColor: const Color(0xFF363567),
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: subTitle,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        keyboardType: textInputType,
      ),
    );
  }
}
