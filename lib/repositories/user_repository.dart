import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  static const _collection = 'users';

  UserRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final credential = await _authService.register(email, password);
    final uid = credential.user!.uid;

    final user = UserModel(
      id: uid,
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestoreService.setDocument(_collection, uid, user.toJson());

    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signIn(email, password);
    final uid = credential.user!.uid;

    final user = await fetchUser(uid);
    if (user == null) {
      throw Exception('User profile not found for uid: $uid');
    }
    return user;
  }

  Future<void> signOut() {
    return _authService.signOut();
  }

  Future<UserModel?> fetchUser(String uid) async {
    final data = await _firestoreService.getDocument(_collection, uid);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<void> updateUser({
    required String uid,
    String? name,
    String? email,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;

    if (updates.isNotEmpty) {
      await _firestoreService.updateDocument(_collection, uid, updates);
    }
  }

  Future<void> deleteUser(String uid) async {
    await _firestoreService.deleteDocument(_collection, uid);
  }

  Stream<UserModel?> streamUser(String uid) {
    return _firestoreService.streamDocument(_collection, uid).map(
      (data) => data != null ? UserModel.fromJson(data) : null,
    );
  }

  Future<void> saveFcmToken(String uid, String token) {
    return _firestoreService.updateDocument(_collection, uid, {
      'fcmToken': token,
    });
  }

  Future<void> deleteFcmToken(String uid) {
    return _firestoreService.updateDocument(_collection, uid, {
      'fcmToken': null,
    });
  }

  User? get currentUser => _authService.currentUser;
}
