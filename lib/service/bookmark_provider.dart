import 'package:flutter/foundation.dart';

class BookmarkProvider extends ChangeNotifier {
  final Set<int> _bookmarkedIds = {};

  bool isBookmarked(int exerciseId) => _bookmarkedIds.contains(exerciseId);

  void toggle(int exerciseId) {
    if (_bookmarkedIds.contains(exerciseId)) {
      _bookmarkedIds.remove(exerciseId);
    } else {
      _bookmarkedIds.add(exerciseId);
    }
    notifyListeners();
  }

  Set<int> get all => _bookmarkedIds;
}
