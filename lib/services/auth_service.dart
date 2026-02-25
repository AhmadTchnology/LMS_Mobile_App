import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final userModel = await getUserByEmail(email.trim());
    if (userModel == null) {
      throw Exception(
        'User profile not found. Please contact an administrator.',
      );
    }

    // Check force sign-out
    if (userModel.lastSignOut != null) {
      final signInTime = credential.user?.metadata.lastSignInTime;
      if (signInTime != null &&
          userModel.lastSignOut! > signInTime.millisecondsSinceEpoch) {
        await _auth.signOut();
        throw Exception('Your session was terminated by an administrator.');
      }
    }

    // Initialize missing fields
    await _initializeUserFields(userModel);

    // Get the updated user model to return
    final updatedUserModel = await getUserById(credential.user!.uid);
    return updatedUserModel ?? userModel;
  }

  /// Sign up with email and password
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = UserModel(
      id: credential.user!.uid,
      email: email.trim(),
      name: name.trim(),
      role: 'student',
      favorites: [],
      completedLectures: [],
      unreadAnnouncements: [],
    );

    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toFirestore());

    return user;
  }

  /// Create a user account without signing out the current admin
  Future<void> createAdminManagedUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // Initialize a temporary Firebase App instance to keep the main session intact
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'temp_admin_user_creation',
      options: Firebase.app().options,
    );

    try {
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final credential = await tempAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      final user = UserModel(
        id: uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        favorites: [],
        completedLectures: [],
        unreadAnnouncements: [],
      );

      await _firestore.collection('users').doc(uid).set(user.toFirestore());
    } finally {
      // Clean up the temporary app to avoid memory/auth leaks
      await tempApp.delete();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Fetch user profile by email from Firestore
  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromFirestore(snapshot.docs.first);
  }

  /// Fetch user profile by UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Initialize missing fields on user document
  Future<void> _initializeUserFields(UserModel user) async {
    final updates = <String, dynamic>{};

    final doc = await _firestore.collection('users').doc(user.id).get();
    final data = doc.data() ?? {};

    if (!data.containsKey('favorites')) updates['favorites'] = [];
    if (!data.containsKey('completedLectures')) {
      updates['completedLectures'] = [];
    }
    if (!data.containsKey('unreadAnnouncements')) {
      updates['unreadAnnouncements'] = [];
    }

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(user.id).update(updates);
    }
  }
}
