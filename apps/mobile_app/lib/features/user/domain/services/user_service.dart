abstract class UserService {
  Future<void> createUserIfNotExists();

  Future<void> updateLastLogin();
}
