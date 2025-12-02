import 'package:flutter/material.dart';

class ProfileInfoBox extends StatelessWidget {
  final String text;
  final bool isMultiLine;

  static const Color _bgColor = Color(0xFF4A4A4A);

  const ProfileInfoBox({
    super.key,
    required this.text,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      height: isMultiLine ? 100 : null,
      alignment: isMultiLine ? Alignment.topLeft : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }
}