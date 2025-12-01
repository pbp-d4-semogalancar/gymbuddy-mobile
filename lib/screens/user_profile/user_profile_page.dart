import 'package:flutter/material.dart';
import 'package:gymbuddy/models/user_profile.dart';

class UserProfilePage extends StatelessWidget {
  final UserProfileEntry userProfile;

  const UserProfilePage({super.key, required this.userProfile});

  String? _getValidUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    return url.replaceAll('localhost', '10.0.2.2');
  }

  @override
  Widget build(BuildContext context) {
    final String? validImageUrl = _getValidUrl(userProfile.profilePicture);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER IMAGE
            if (validImageUrl != null)
              Image.network(
                validImageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                
                errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
                loadingBuilder: (ctx, child, loading) {
                  if (loading == null) return child;
                  return Container(height: 300, color: Colors.grey[200]);
                },
              )
            else
              _buildPlaceholder(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // USERNAME BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    child: Text(
                      '@${userProfile.username}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  ),

                  // DISPLAY NAME
                  Text(
                    userProfile.displayName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // INFO ROW
                  Row(
                    children: [
                      Icon(Icons.perm_identity, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text("ID #${userProfile.id}", style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text("${userProfile.favoriteWorkouts.length} Workouts", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),

                  const Divider(height: 32, thickness: 1),

                  // BIO
                  const Text("About Me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    userProfile.bio.isNotEmpty ? userProfile.bio : "No bio provided.",
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),

                  // WORKOUTS CHIPS
                  if (userProfile.favoriteWorkouts.isNotEmpty) ...[
                    const Text("Favorite Workouts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: userProfile.favoriteWorkouts.map((w) => Chip(label: Text(w))).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity, height: 300, color: Colors.indigo.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: Colors.indigo.shade200),
          Text("No Picture", style: TextStyle(color: Colors.indigo.shade300)),
        ],
      ),
    );
  }
}