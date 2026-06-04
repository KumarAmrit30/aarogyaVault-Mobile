import 'package:mobile_app/features/auth/domain/entities/auth_user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  Authenticated(this.user);

  final AuthUser user;
}

class Unauthenticated extends AuthState {}
