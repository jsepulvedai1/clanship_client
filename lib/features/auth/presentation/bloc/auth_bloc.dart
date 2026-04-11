import 'dart:async';
import 'package:clanship_cliente/features/auth/domain/usecases/login_usecase.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AvatarUpdated>(_onAvatarUpdated);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    // Logic to clear user session
    emit(AuthUnauthenticated());
  }

  /// Handles the update of the user's avatar path.
  /// Only applicable if the user is already authenticated.
  void _onAvatarUpdated(AvatarUpdated event, Emitter<AuthState> emit) {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      // Update the user within the AuthAuthenticated state
      final updatedUser = currentUser.copyWith(avatarPath: event.avatarPath);
      emit(AuthAuthenticated(updatedUser));
    }
  }
}
