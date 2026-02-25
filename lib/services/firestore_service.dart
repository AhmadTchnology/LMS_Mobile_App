import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lecture_model.dart';
import '../models/announcement_model.dart';
import '../models/category_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────
  //  LECTURES
  // ──────────────────────────────────────────────

  /// Stream of all lectures (real-time)
  Stream<List<LectureModel>> lecturesStream() {
    return _firestore
        .collection('lectures')
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => LectureModel.fromFirestore(doc)).toList(),
        );
  }

  /// Delete a lecture
  Future<void> deleteLecture(String lectureId) async {
    await _firestore.collection('lectures').doc(lectureId).delete();
  }

  /// Upload a new lecture
  Future<void> addLecture(LectureModel lecture) async {
    await _firestore.collection('lectures').add(lecture.toFirestore());
  }

  // ──────────────────────────────────────────────
  //  CATEGORIES
  // ──────────────────────────────────────────────

  /// Stream of all categories
  Stream<List<CategoryModel>> categoriesStream() {
    return _firestore
        .collection('categories')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList(),
        );
  }

  /// Get subjects (categories where type == 'subject')
  Stream<List<CategoryModel>> subjectsStream() {
    return _firestore
        .collection('categories')
        .where('type', isEqualTo: 'subject')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList(),
        );
  }

  /// Get stages (categories where type == 'stage')
  Stream<List<CategoryModel>> stagesStream() {
    return _firestore
        .collection('categories')
        .where('type', isEqualTo: 'stage')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList(),
        );
  }

  /// Add a new category (subject or stage)
  Future<void> addCategory(String name, String type) async {
    await _firestore.collection('categories').add({
      'name': name,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  // ──────────────────────────────────────────────
  //  ANNOUNCEMENTS
  // ──────────────────────────────────────────────

  /// Stream of all announcements
  Stream<List<AnnouncementModel>> announcementsStream() {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AnnouncementModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Create announcement
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    await _firestore
        .collection('announcements')
        .add(announcement.toFirestore());
  }

  /// Delete announcement
  Future<void> deleteAnnouncement(String announcementId) async {
    await _firestore.collection('announcements').doc(announcementId).delete();
  }

  // ──────────────────────────────────────────────
  //  USER PROFILE UPDATES
  // ──────────────────────────────────────────────

  /// Toggle favorite lecture
  Future<void> toggleFavorite(
    String userId,
    String lectureId,
    bool isFavorite,
  ) async {
    await _firestore.collection('users').doc(userId).set({
      'favorites': isFavorite
          ? FieldValue.arrayUnion([lectureId])
          : FieldValue.arrayRemove([lectureId]),
    }, SetOptions(merge: true));
  }

  /// Toggle lecture completion
  Future<void> toggleCompletion(
    String userId,
    String lectureId,
    bool isComplete,
  ) async {
    await _firestore.collection('users').doc(userId).set({
      'completedLectures': isComplete
          ? FieldValue.arrayUnion([lectureId])
          : FieldValue.arrayRemove([lectureId]),
    }, SetOptions(merge: true));
  }

  /// Mark announcement as read
  Future<void> markAnnouncementRead(
    String userId,
    String announcementId,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'unreadAnnouncements': FieldValue.arrayUnion([announcementId]),
    });
  }

  /// Get user profile stream
  Stream<UserModel?> userStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // ──────────────────────────────────────────────
  //  USER MANAGEMENT (Admin only)
  // ──────────────────────────────────────────────

  /// Stream all users
  Stream<List<UserModel>> usersStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  /// Update user role
  Future<void> updateUserRole(String userId, String role) async {
    await _firestore.collection('users').doc(userId).update({'role': role});
  }

  /// Update user profile
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  /// Force sign-out all users
  Future<void> forceSignOutAll() async {
    final batch = _firestore.batch();
    final users = await _firestore.collection('users').get();

    for (final doc in users.docs) {
      batch.update(doc.reference, {
        'lastSignOut': DateTime.now().millisecondsSinceEpoch,
      });
    }

    await batch.commit();
  }
}
