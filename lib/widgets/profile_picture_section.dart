import 'package:flutter/material.dart';
import 'profile_picture_display.dart';

class ProfilePictureSection extends StatelessWidget {
  final String imageUrl;
  final bool isOwner;
  final bool showUrlField;
  final VoidCallback onToggleEdit;
  final TextEditingController controller;

  const ProfilePictureSection({
    super.key,
    required this.imageUrl,
    required this.isOwner,
    required this.showUrlField,
    required this.onToggleEdit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            ProfilePictureDisplay(
              imageUrl: imageUrl,
              size: 120,
            ),
            if (isOwner)
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: onToggleEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      showUrlField ? Icons.close : Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (showUrlField && isOwner) ...[
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Image URL",
              hintText: "Paste image link here...",
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
        ],
      ],
    );
  }
}