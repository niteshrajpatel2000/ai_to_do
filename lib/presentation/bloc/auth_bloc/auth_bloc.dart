import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthBloc({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const AuthState()) {
    on<AuthSignInWithEmail>(_onSignInWithEmail);
    on<AuthSignUpWithEmail>(_onSignUpWithEmail);
    on<AuthSignInWithGoogle>(_onSignInWithGoogle);
    on<AuthSignInWithApple>(_onSignInWithApple);
    on<AuthSignOut>(_onSignOut);
    on<AuthResetPassword>(_onResetPassword);
    on<AuthTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<AuthToggleRememberDevice>(_onToggleRememberDevice);
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final credential = await _authService.signInWithEmail(
        event.email,
        event.password,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: credential.user,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message ?? 'Sign in failed',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.signUpWithEmail(
        event.email,
        event.password,
        event.name,
      );
      await _firestoreService.saveUserProfile(event.name, event.email);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: _authService.currentUser,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message ?? 'Sign up failed',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final credential = await _authService.signInWithGoogle();
      await _firestoreService.saveUserProfile(
        credential.user?.displayName ?? '',
        credential.user?.email ?? '',
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: credential.user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google sign in failed',
      ));
    }
  }

  Future<void> _onSignInWithApple(
    AuthSignInWithApple event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final credential = await _authService.signInWithApple();
      await _firestoreService.saveUserProfile(
        credential.user?.displayName ?? '',
        credential.user?.email ?? '',
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: credential.user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Apple sign in failed',
      ));
    }
  }

  Future<void> _onSignOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> _onResetPassword(
    AuthResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.resetPassword(event.email);
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to send reset email',
      ));
    }
  }

  void _onTogglePasswordVisibility(
    AuthTogglePasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onToggleRememberDevice(
    AuthToggleRememberDevice event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(rememberDevice: !state.rememberDevice));
  }
}
