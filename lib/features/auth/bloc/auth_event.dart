import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignInWithGoogle extends AuthEvent {
  const SignInWithGoogle();
}

class TogglePasswordVisibility extends AuthEvent {
  const TogglePasswordVisibility();
}

class ClearAuthError extends AuthEvent {
  const ClearAuthError();
}

class SignUpWithEmail extends AuthEvent {
  final String email;
  final String password;
  const SignUpWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class ToggleConfirmPasswordVisibility extends AuthEvent {
  const ToggleConfirmPasswordVisibility();
}
