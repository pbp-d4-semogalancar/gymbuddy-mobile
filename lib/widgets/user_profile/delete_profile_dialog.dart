import 'package:flutter/material.dart';

class DeleteProfileDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteProfileDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE0E0),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Hapus Profil Permanen?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Tindakan ini tidak dapat dibatalkan...",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE02424),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: const Text(
                    "Ya, Hapus",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
