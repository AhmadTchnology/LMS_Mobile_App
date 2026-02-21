import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/firestore_service.dart';

class AnnouncementProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;

  AnnouncementProvider() {
    _init();
  }

  void _init() {
    _firestoreService.announcementsStream().listen((data) {
      _announcements = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String userId, String announcementId) async {
    await _firestoreService.markAnnouncementRead(userId, announcementId);
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    await _firestoreService.deleteAnnouncement(announcementId);
  }
}
