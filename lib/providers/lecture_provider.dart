import 'package:flutter/material.dart';
import '../models/lecture_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';

class LectureProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<LectureModel> _lectures = [];
  List<CategoryModel> _subjects = [];
  List<CategoryModel> _stages = [];
  bool _isLoading = true;

  List<LectureModel> get lectures => _lectures;
  List<CategoryModel> get subjects => _subjects;
  List<CategoryModel> get stages => _stages;
  bool get isLoading => _isLoading;

  LectureProvider() {
    _init();
  }

  void _init() {
    _firestoreService.lecturesStream().listen((data) {
      _lectures = data;
      _isLoading = false;
      notifyListeners();
    });

    _firestoreService.subjectsStream().listen((data) {
      _subjects = data;
      notifyListeners();
    });

    _firestoreService.stagesStream().listen((data) {
      _stages = data;
      notifyListeners();
    });
  }

}
