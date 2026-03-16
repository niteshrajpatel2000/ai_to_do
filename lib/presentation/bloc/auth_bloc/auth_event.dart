import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignInWithEmail extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpWithEmail extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthSignUpWithEmail({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class AuthSignInWithGoogle extends AuthEvent {}

class AuthSignInWithApple extends AuthEvent {}

class AuthSignOut extends AuthEvent {}

class AuthResetPassword extends AuthEvent {
  final String email;

  const AuthResetPassword({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthTogglePasswordVisibility extends AuthEvent {}

class AuthToggleRememberDevice extends AuthEvent {}
