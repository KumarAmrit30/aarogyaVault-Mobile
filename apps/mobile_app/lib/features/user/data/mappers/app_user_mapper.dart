import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/user/domain/entities/app_user.dart';

class AppUserMapper {
  AppUserMapper._();

  static AppUser fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: _toDateTime(map['createdAt']),
      lastLoginAt: _toDateTime(map['lastLoginAt']),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> toMap(AppUser user) {
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'lastLoginAt': Timestamp.fromDate(user.lastLoginAt),
      'isActive': user.isActive,
    };
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    throw FormatException('Expected Timestamp or DateTime, got ${value.runtimeType}.');
  }
}
