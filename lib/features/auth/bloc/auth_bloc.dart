import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import '../../../core/core.dart';
import '../../../core/services/background_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(const AuthState()) {
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<ClearAuthError>(_onClearAuthError);
    on<SignInWithEmail>(_onSignInWithEmail);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignUpWithEmail>(_onSignUpWithEmail);
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword, errorMessage: state.errorMessage));
  }

  void _onToggleConfirmPasswordVisibility(
    ToggleConfirmPasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword, errorMessage: state.errorMessage));
  }

  void _onClearAuthError(
    ClearAuthError event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(errorMessage: null));
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, signedIn: false));
    try {
      await authService.signIn(email: event.email.trim(), password: event.password);
      emit(state.copyWith(isLoading: false, signedIn: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Login failed: ${e.toString()}', signedIn: false));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, signedIn: false));
    try {
      final result = await authService.signInWithGoogle(forceAccountSelection: true);
      if (result != null) {
        try {
          await DataService().initialize();
          await DataService().clearAllLocalData();
          await BackgroundService().resetStudyStreak();
          await DataService().loadDataFromFirestore();
        } catch (_) {}
        emit(state.copyWith(isLoading: false, signedIn: true));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: 'Google sign-in was cancelled', signedIn: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Google sign-in failed: ${e.toString()}', signedIn: false));
    }
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, signedIn: false));
    try {
      await authService.createAccount(email: event.email.trim(), password: event.password);
      emit(state.copyWith(isLoading: false, signedIn: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Sign up failed: ${e.toString()}', signedIn: false));
    }
  }
}
