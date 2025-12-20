import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gymbuddy/providers/user_provider.dart';

class UserAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool isCurrentUser;
  final int? userId;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20.0,
    this.onTap,
    this.isCurrentUser = false,
    this.userId
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  final String _baseUrl = "https://rexy-adrian-gymbuddy.pbp.cs.ui.ac.id";

  String? _fetchedUrl;

  @override
  void initState() {
    super.initState();
  
    if (widget.isCurrentUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchMyProfile();
      });
    } 
    else if (widget.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchUserProfileById(widget.userId!);
      });
    }
  }

  Future<void> _fetchMyProfile() async {
    final request = context.read<CookieRequest>();
    final userProvider = context.read<UserProvider>();
    
    if (userProvider.userId == null) return;

    try {
      final response = await request.get('$_baseUrl/profile/json/${userProvider.userId}/');
      String? rawUrl = response['profile_picture'];

      if (mounted) {
        userProvider.setProfilePicture(rawUrl);
      }
    } catch (e) {
    }
  }

  Future<void> _fetchUserProfileById(int id) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$_baseUrl/profile/json/$id/');
      String? rawUrl = response['profile_picture'];

      if (mounted) {
        setState(() {
          _fetchedUrl = rawUrl;
        });
      }
    } catch (e) {
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

    if (widget.isCurrentUser) {
      finalUrl = context.watch<UserProvider>().profilePicture;
    } 
    else if (widget.userId != null) {
      finalUrl = _fetchedUrl ?? widget.imageUrl;
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