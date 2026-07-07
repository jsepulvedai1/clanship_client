import 'package:clanship_cliente/core/usecases/usecase.dart';
import 'package:clanship_cliente/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_event.dart';
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_state.dart';
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

    final result = await getCurrentUserUseCase(NoParams());

    final elapsedTime = DateTime.now().difference(startTime);
    const minDelay = Duration(milliseconds: 1500);
    if (elapsedTime < minDelay) {
      await Future.delayed(minDelay - elapsedTime);
    }

    result.fold(
      (failure) => emit(SplashUnauthenticated()),
      (user) => emit(SplashAuthenticated(user)),
    );
  }
}
