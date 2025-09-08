import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? errorMessage;
  final bool signedIn;

  const AuthState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.errorMessage,
    this.signedIn = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    String? errorMessage,
    bool? signedIn,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      errorMessage: errorMessage,
      signedIn: signedIn ?? this.signedIn,
    );
  }

  @override
  List<Object?> get props => [isLoading, obscurePassword, obscureConfirmPassword, errorMessage, signedIn];
}
