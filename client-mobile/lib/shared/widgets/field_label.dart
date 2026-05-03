import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFB6B6B6),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.5,
      ),
    );
  }
}
