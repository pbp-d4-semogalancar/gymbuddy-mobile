import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/providers/user_provider.dart';

class UserAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool isCurrentUser;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20.0,
    this.onTap,
    this.isCurrentUser = false,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  final String _baseUrl = "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id";

  @override
  void initState() {
    super.initState();
    // Jika ini adalah Current User, widget ini inisiatif fetch data sendiri
    if (widget.isCurrentUser) {
      // Panggil fetch setelah frame build selesai agar aman akses context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchMyProfile();
      });
    }
  }

  Future<void> _fetchMyProfile() async {
    final request = context.read<CookieRequest>();
    final userProvider = context.read<UserProvider>();
    
    // Pastikan user sudah login (punya ID)
    if (userProvider.userId == null) return;

    try {
      final response = await request.get('$_baseUrl/profile/json/${userProvider.userId}/');
      String? rawUrl = response['profile_picture'];

      // Cek mounted sebelum update state/provider
      if (mounted) {
        // Kita update Provider, agar SEMUA UserAvatar di aplikasi (Drawer dll) ikut berubah
        userProvider.setProfilePicture(rawUrl);
      }
    } catch (e) {
      // Silent error (biar gak ngerusak UI)
    }
  }

  String? _getProxyUrl(String? originalUrl) {
    if (originalUrl == null || originalUrl.trim().isEmpty) return null;
    String encodedUrl = Uri.encodeComponent(originalUrl);
    return "$_baseUrl/profile/proxy-image/?url=$encodedUrl";
  }

  @override
  Widget build(BuildContext context) {
    String? finalUrl = widget.imageUrl;

    // Jika mode Current User, abaikan parameter imageUrl, ambil dari Provider
    if (widget.isCurrentUser) {
      // Kita 'watch' provider. Jadi kalau _fetchMyProfile selesai update provider,
      // widget ini akan rebuild otomatis dengan gambar baru.
      finalUrl = context.watch<UserProvider>().profilePicture;
    }

    final String? displayUrl = _getProxyUrl(finalUrl);

    Widget avatar = CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.grey.shade700,
      backgroundImage: displayUrl != null
          ? NetworkImage(displayUrl, headers: const {"Connection": "close"})
          : null,
      onBackgroundImageError: displayUrl != null ? (_, __) {} : null,
      child: displayUrl == null
          ? Icon(
              Icons.account_circle,
              size: widget.radius * 2,
              color: Colors.white,
            )
          : null,
    );

    if (widget.onTap != null) {
      return GestureDetector(onTap: widget.onTap, child: avatar);
    }

    return avatar;
  }
}