import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool obscurePassword;
  final bool rememberDevice;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.obscurePassword = true,
    this.rememberDevice = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? obscurePassword,
    bool? rememberDevice,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberDevice: rememberDevice ?? this.rememberDevice,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, obscurePassword, rememberDevice];
}
