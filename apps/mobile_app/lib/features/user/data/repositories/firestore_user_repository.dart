import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/user/data/mappers/app_user_mapper.dart';
import 'package:mobile_app/features/user/domain/entities/app_user.dart';
import 'package:mobile_app/features/user/domain/repositories/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _usersCollection = 'users';

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(_usersCollection);

  @override
  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    return AppUserMapper.fromMap(uid, data);
  }

  @override
  Future<void> createUser(AppUser user) async {
    await _users.doc(user.uid).set(AppUserMapper.toMap(user));
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await _users.doc(user.uid).update(AppUserMapper.toMap(user));
  }

  @override
  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();
      if (data == null) {
        return null;
      }

      return AppUserMapper.fromMap(uid, data);
    });
  }
}
