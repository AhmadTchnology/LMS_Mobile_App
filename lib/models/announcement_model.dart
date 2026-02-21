import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String type; // 'homework' | 'exam' | 'event' | 'other'
  final String createdBy;
  final String creatorName;
  final DateTime createdAt;
  final String? expiryDate;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdBy,
    this.creatorName = '',
    required this.createdAt,
    this.expiryDate,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['createdAt'];
    DateTime parsedDate;
    if (ts is Timestamp) {
      parsedDate = ts.toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return AnnouncementModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: data['type'] ?? 'other',
      createdBy: data['createdBy'] ?? '',
      creatorName: data['creatorName'] ?? '',
      createdAt: parsedDate,
      expiryDate: data['expiryDate'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'type': type,
      'createdBy': createdBy,
      'creatorName': creatorName,
      'createdAt': FieldValue.serverTimestamp(),
      if (expiryDate != null) 'expiryDate': expiryDate,
    };
  }
}
