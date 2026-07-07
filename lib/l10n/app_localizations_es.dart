// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get loginTitle => 'Bienvenido';

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
  String profDetailReviews(String count, String reviews) {
    return '$count ($reviews opiniones)';
  }

  @override
  String get profDetailFindMe => 'Encuentrame en:';

  @override
  String get profDetailDocuments => 'Documentos';

  @override
  String get profDetailContact => 'Contactar';

  @override
  String get addressDialogTitle => 'Tu dirección';

  @override
  String get addressDialogAdd => 'Agregar nueva dirección';

  @override
  String get addressDialogYes => 'Si';

  @override
  String get addressDialogNo => 'No';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get favoritesEmptyTitle => 'No tienes favoritos aún';

  @override
  String get favoritesEmptySubtitle =>
      'Guarda a tus profesionales de confianza para encontrarlos más rápido la próxima vez.';

  @override
  String get favoritesExplore => 'Explorar profesionales';

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
  String get jobsFinished => 'Finalizadas';

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

  @override
  String get matchingConfirmTitle => '¡Antes de solicitar!';

  @override
  String get matchingConfirmSubtitle =>
      'Recuerda confirmar que esta es la dirección a solicitar';

  @override
  String get matchingConfirmAddressLabel => 'Confirmar dirección';

  @override
  String get matchingConfirmWarning =>
      'Ten en cuenta que la dirección no se podrá cambiar en medio de la solicitud. Revisa con atención la dirección a solicitar el servicio';

  @override
  String get matchingConfirmAction => 'Solicitar';

  @override
  String get settingsPersonalInfo => 'Información personal';

  @override
  String get settingsEditData => 'Editar mis datos';

  @override
  String get settingsMyPlan => 'Mi plan actual';

  @override
  String get settingsMyDocs => 'Mis documentos';

  @override
  String get settingsVerificationStatus => 'Estado de verificación';

  @override
  String get settingsChooseLanguage => 'Cambiar idioma';

  @override
  String get settingsSupport => 'Soporte técnico';

  @override
  String get settingsTerms => 'Términos y condiciones';

  @override
  String get chatActionEnrich => 'Enriquecer';

  @override
  String get chatActionJob => 'Trabajo';

  @override
  String get chatJobCreatedSuccess => 'Trabajo creado exitosamente';

  @override
  String get chatJobCreatedMessage => 'He creado una solicitud de trabajo.';

  @override
  String get chatEnrichTitle => 'Enriquecer Solicitud';

  @override
  String get chatEnrichHint =>
      'Describe el problema en mayor detalle, agrega marcas de equipos, accesos o instrucciones...';

  @override
  String get chatEnrichAttachPhoto => 'Adjuntar Foto del Problema';

  @override
  String get chatEnrichEnterDetailsError =>
      'Por favor escribe los detalles adicionales.';

  @override
  String get chatEnrichSuccess => 'Solicitud enriquecida exitosamente.';

  @override
  String get chatEnrichMessage =>
      'He enriquecido la solicitud con nuevos detalles.';

  @override
  String get chatEnrichConfirm => 'Confirmar y Enviar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navJobs => 'Trabajos';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navSettings => 'Perfil';
}
