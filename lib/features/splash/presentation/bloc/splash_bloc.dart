import 'package:clanship_cliente/core/error/failures.dart';
import 'package:clanship_cliente/core/usecases/usecase.dart';
import 'package:clanship_cliente/features/auth/domain/entities/user.dart';
import 'package:clanship_cliente/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_event.dart';
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  SplashBloc(this.getCurrentUserUseCase) : super(SplashInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());

    final startTime = DateTime.now();

    // Reintentar ante fallos de conexión (p.ej. backend reiniciándose tras deploy)
    Either<Failure, User>? result;
    const maxAttempts = 3;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      result = await getCurrentUserUseCase(NoParams());

      bool shouldRetry = false;
      result.fold(
        (failure) {
          // Si es un fallo explícito de autenticación (sin token o token caducado), NO reintentar
          if (failure is AuthFailure) {
            shouldRetry = false;
          } else {
            // Es un error temporal de red / 502 / conexión rechazada
            shouldRetry = attempt < maxAttempts;
          }
        },
        (_) => shouldRetry = false,
      );

      if (shouldRetry) {
        await Future.delayed(const Duration(seconds: 2));
      } else {
        break;
      }
    }

    final elapsedTime = DateTime.now().difference(startTime);
    const minDelay = Duration(milliseconds: 1500);
    if (elapsedTime < minDelay) {
      await Future.delayed(minDelay - elapsedTime);
    }

    result?.fold(
      (failure) {
        if (failure is AuthFailure) {
          emit(SplashUnauthenticated());
        } else {
          // Si falló por conexión tras reintentos, no desloguear al usuario
          emit(SplashConnectionError(failure.message));
        }
      },
      (user) => emit(SplashAuthenticated(user)),
    );
  }
}
