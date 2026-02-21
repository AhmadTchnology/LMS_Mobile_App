import 'package:cloud_firestore/cloud_firestore.dart';

class LectureModel {
  final String id;
  final String title;
  final String subject;
  final String stage;
  final String pdfUrl;
  final String uploadedBy;
  final String uploadDate;

  LectureModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.stage,
    required this.pdfUrl,
    required this.uploadedBy,
    required this.uploadDate,
  });

  factory LectureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LectureModel(
      id: doc.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      stage: data['stage'] ?? '',
      pdfUrl: data['pdfUrl'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      uploadDate: data['uploadDate'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subject': subject,
      'stage': stage,
      'pdfUrl': pdfUrl,
      'uploadedBy': uploadedBy,
      'uploadDate': uploadDate,
    };
  }
}
