import 'package:flutter/material.dart';

class ProfilePictureDisplay extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProfilePictureDisplay({
    super.key,
    required this.imageUrl,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400, width: 2),
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        headers: const {"Connection": "close"},

        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.account_circle, size: size, color: Colors.grey);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return Icon(Icons.account_circle, size: size, color: Colors.grey);
    }
  }
}