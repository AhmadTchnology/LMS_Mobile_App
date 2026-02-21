import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' | 'teacher' | 'student'
  final List<String> favorites;
  final List<String> completedLectures;
  final List<String> unreadAnnouncements;
  final Timestamp? createdAt;
  final int? lastSignOut;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'student',
    this.favorites = const [],
    this.completedLectures = const [],
    this.unreadAnnouncements = const [],
    this.createdAt,
    this.lastSignOut,
  });

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
  bool get canUpload => isTeacher;
  bool get canManageUsers => isAdmin;
  bool get canCreateAnnouncement => isAdmin || isTeacher;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'student',
      favorites: List<String>.from(data['favorites'] ?? []),
      completedLectures: List<String>.from(data['completedLectures'] ?? []),
      unreadAnnouncements: List<String>.from(data['unreadAnnouncements'] ?? []),
      createdAt: data['createdAt'] as Timestamp?,
      lastSignOut: data['lastSignOut'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'favorites': favorites,
      'completedLectures': completedLectures,
      'unreadAnnouncements': unreadAnnouncements,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    List<String>? favorites,
    List<String>? completedLectures,
    List<String>? unreadAnnouncements,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      favorites: favorites ?? this.favorites,
      completedLectures: completedLectures ?? this.completedLectures,
      unreadAnnouncements: unreadAnnouncements ?? this.unreadAnnouncements,
      createdAt: createdAt,
      lastSignOut: lastSignOut,
    );
  }
}
