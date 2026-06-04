import 'package:mobile_app/features/user/domain/entities/app_user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoaded extends UserState {
  UserLoaded(this.user);

  final AppUser user;
}

class UserError extends UserState {
  UserError(this.message);

  final String message;
}
