class UserProfile {
  final String username;
  final String displayName;
  final String avatarUrl;
  final String timeAgo;

  UserProfile({
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.timeAgo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? "User",
      displayName: json['display_name'] ?? json['username'] ?? "User",
      avatarUrl: json['profile_picture'] ?? "https://thumbs.dreamstime.com/b/default-avatar-profile-trendy-style-social-media-user-icon-187599373.jpg",
      timeAgo: json['time_ago'] ?? "",
    );
  }
}

class Reply {
  final int id;
  final UserProfile user;
  final String content;
  final List<Reply> children;
  final bool isMine;

  Reply({
    required this.id,
    required this.user,
    required this.content,
    this.children = const [],
    required this.isMine,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    var childrenList = json['children'] as List? ?? [];
    List<Reply> childrenParsed = childrenList.map((i) => Reply.fromJson(i)).toList();

    return Reply(
      id: json['id'],
      user: UserProfile.fromJson(json['user']),
      content: json['content'],
      children: childrenParsed,
      isMine: json['is_mine'] ?? false,
    );
  }
}

class ThreadDetail {
  final int id;
  final String title;
  final UserProfile user;
  final String content;

  ThreadDetail({required this.id, required this.title, required this.user, required this.content});

  factory ThreadDetail.fromJson(Map<String, dynamic> json) {
    return ThreadDetail(
      id: json['id'],
      title: json['title'],
      user: UserProfile.fromJson(json['user']),
      content: json['content'],
    );
  }
}