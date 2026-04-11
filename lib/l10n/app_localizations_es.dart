// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginEmailLabel => 'Correo electrónico';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginSignInButton => 'Iniciar sesión';

  @override
  String loginWelcomeMessage(String name) {
    return 'Bienvenido $name';
  }

  @override
  String loginError(String message) {
    return 'Error: $message';
  }

  @override
  String homeGreeting(String name) {
    return 'Hola $name';
  }

  @override
  String get homeSearchPlaceholder => '¿Qué profesional buscas?';

  @override
  String get homeTagNear => 'Más cercanos';

  @override
  String get homeTagTopRated => 'Mejor valorados';

  @override
  String get homeViewAll => 'Ver todos';

  @override
  String get profDetailHire => 'Contratar ahora';

  @override
  String get profDetailAbout => 'Sobre mí';

  @override
  String get profDetailStats => 'Estadísticas';

  @override
  String get matchingCancel => 'Cancelar solicitud';

  @override
  String get matchingSearching => 'Buscando match...';

  @override
  String matchingConnecting(String name) {
    return 'Conectando con $name';
  }

  @override
  String get matchingSuccess => '¡Match Exitoso!';

  @override
  String matchingAccepted(String name) {
    return '$name ha aceptado contactarte.';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsDarkMode => 'Modo Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsEnglish => 'Inglés';

  @override
  String get settingsSpanish => 'Español';

  @override
  String get chatStatusOnline => 'En línea';

  @override
  String get chatInputPlaceholder => 'Escribe un mensaje...';

  @override
  String get jobsTitle => 'Mis Trabajos';

  @override
  String get jobsEmptyTitle => 'Aún no tienes trabajos activos';

  @override
  String get jobsEmptySubtitle => 'Tus matches aparecerán aquí.';

  @override
  String get jobsViewDetail => 'Ver Detalle';

  @override
  String get jobsStatusPending => 'Pendiente';

  @override
  String get jobsStatusActive => 'Activo';

  @override
  String get jobsStatusRejected => 'Rechazado';

  @override
  String get jobsStatusCompleted => 'Completado';

  @override
  String get jobsRequestsTitle => 'Solicitudes';

  @override
  String get jobsInProcess => 'En proceso';

  @override
  String jobsArrivalInfo(String time) {
    return 'llega en $time';
  }

  @override
  String get jobsDetailTitle => 'Detalles del trabajo';

  @override
  String get jobsTotalValue => 'Valor total';

  @override
  String get jobsGoToChat => 'Ir al chat';

  @override
  String get jobsCancel => 'Cancelar';

  @override
  String get jobsBack => 'Regresar';

  @override
  String get chatActionUrgent => 'Urgente';

  @override
  String get chatActionCall => 'Llamar';

  @override
  String get chatActionLocation => 'Ubicación';
}
