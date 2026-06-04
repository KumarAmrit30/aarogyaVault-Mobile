import 'package:mobile_app/features/user/domain/entities/app_user.dart';

abstract class UserRepository {
  Future<AppUser?> getUser(String uid);

  Future<void> createUser(AppUser user);

  Future<void> updateUser(AppUser user);

  Stream<AppUser?> watchUser(String uid);
}
