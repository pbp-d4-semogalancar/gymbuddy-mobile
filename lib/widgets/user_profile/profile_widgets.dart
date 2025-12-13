import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymbuddy/widgets/profile_picture_display.dart';

// 1. Widget Editor Gambar
class ProfileImageEditor extends StatelessWidget {
  final File? selectedImage;
  final String currentImageUrl;
  final bool isOwner;
  final VoidCallback onPickImage;

  const ProfileImageEditor({
    super.key,
    required this.selectedImage,
    required this.currentImageUrl,
    required this.isOwner,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          selectedImage != null
              ? Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 2),
              image: DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover),
            ),
          )
              : ProfilePictureDisplay(imageUrl: currentImageUrl, size: 120),
          if (isOwner)
            Positioned(
              bottom: 0, right: 0,
              child: InkWell(
                onTap: onPickImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 2. Widget List Workout (Chips)
class WorkoutListEditor extends StatelessWidget {
  final List<String> workouts;
  final bool isOwner;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const WorkoutListEditor({
    super.key,
    required this.workouts,
    required this.isOwner,
    required this.onAdd,
    required this.onRemove,
  });

  void _showAddDialog(BuildContext context) {
    String val = "";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Workout"),
        content: TextField(onChanged: (v) => val = v, decoration: const InputDecoration(hintText: "e.g. Push Up")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(onPressed: () { if (val.isNotEmpty) onAdd(val); Navigator.pop(ctx); }, child: const Text("Add")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: [
        ...workouts.map((w) => Chip(
          label: Text(w, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          backgroundColor: Colors.white,
          onDeleted: isOwner ? () => onRemove(w) : null,
        )),
        if (isOwner)
          ActionChip(
            label: const Icon(Icons.add, size: 18, color: Colors.white),
            backgroundColor: Colors.blueAccent,
            onPressed: () => _showAddDialog(context),
          ),
      ],
    );
  }
}