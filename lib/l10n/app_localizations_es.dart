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
  String get homeSearchNeed => '¿Qué necesitas?';

  @override
  String get homeUrgency => 'Urgencia';

  @override
  String get homeBannerTitle => 'Atenciones Específicas';

  @override
  String get homeBannerSubTitle =>
      'Publica tu requerimiento o revisa tus cotizaciones recibidas';

  @override
  String get homeBtnRequest => 'Solicitar';

  @override
  String get homeBtnMyRequests => 'Mis Solicitudes';

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
  String get settingsFrench => 'Francés';

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
  String get chatActionEnrich => 'Agregar Detalles';

  @override
  String get chatActionJob => 'Trabajo';

  @override
  String get chatJobCreatedSuccess => 'Trabajo creado exitosamente';

  @override
  String get chatJobCreatedMessage => 'He creado una solicitud de trabajo.';

  @override
  String get chatEnrichTitle => 'Detalles de la Solicitud';

  @override
  String get chatEnrichHint =>
      'Describe el problema en mayor detalle, agrega marcas de equipos, accesos o instrucciones...';

  @override
  String get chatEnrichAttachPhoto => 'Adjuntar Foto del Problema';

  @override
  String get chatEnrichEnterDetailsError =>
      'Por favor escribe los detalles adicionales.';

  @override
  String get chatEnrichSuccess => 'Detalles agregados exitosamente.';

  @override
  String get chatEnrichMessage =>
      'He agregado detalles adicionales a la solicitud.';

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

  @override
  String get authSubtitle => 'Inicia sesión para acceder a tu cuenta';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authNoAccount => '¿No tienes una cuenta?';

  @override
  String get authRegisterHere => 'Regístrate aquí';

  @override
  String get authRegisterTitle => 'Crear Cuenta';

  @override
  String get authPersonalData => 'Datos Personales';

  @override
  String get authLocationContact => 'Ubicación y Contacto';

  @override
  String get authFirstName => 'Nombre';

  @override
  String get authLastName => 'Apellido';

  @override
  String get authBirthdate => 'Fecha de Nacimiento';

  @override
  String get authRepeatEmail => 'Repetir correo electrónico';

  @override
  String get authRepeatPassword => 'Repetir contraseña';

  @override
  String get authPhone => 'Teléfono de contacto';

  @override
  String get authAddress => 'Dirección';

  @override
  String get authAcceptTerms => 'Acepto los términos y condiciones de servicio';

  @override
  String get authProfilePhoto => 'Foto de Perfil';

  @override
  String get authCamera => 'Tomar foto con la cámara';

  @override
  String get authGallery => 'Elegir de la galería';

  @override
  String get authNext => 'Siguiente';

  @override
  String get authPrevious => 'Anterior';

  @override
  String get authCompleteRegister => 'Completar Registro';

  @override
  String get authForgotTitle => '¿Olvidaste tu contraseña?';

  @override
  String get authForgotSubtitle =>
      'Ingresa tu correo para recibir instrucciones de recuperación';

  @override
  String get authSendCode => 'Enviar Código';

  @override
  String get authVerifyOtpTitle => 'Verificación de Código';

  @override
  String get authVerifyOtpSubtitle => 'Ingresa el código enviado a tu correo';

  @override
  String get authResetTitle => 'Nueva Contraseña';

  @override
  String get authResetSubtitle => 'Ingresa y confirma tu nueva contraseña';

  @override
  String get authConfirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get authChangePasswordBtn => 'Cambiar Contraseña';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonAccept => 'Aceptar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Éxito';

  @override
  String get versionUpdateTitle => 'Actualización Requerida';

  @override
  String get versionUpdateMessage =>
      'Para continuar usando Clanship de manera segura, por favor actualiza la aplicación a la última versión disponible.';

  @override
  String get versionUpdateBtn => 'Actualizar en la Tienda';

  @override
  String get sessionExpired =>
      'Tu sesión ha sido iniciada en otro dispositivo.';

  @override
  String get settingsConfirmLogoutTitle => '¿Cerrar Sesión?';

  @override
  String get settingsConfirmLogoutMsg =>
      '¿Estás seguro que deseas cerrar tu sesión actual?';

  @override
  String get settingsLogoutBtn => 'Cerrar Sesión';

  @override
  String get searchTitle => 'Buscar Profesional';

  @override
  String get searchFilterSpecialty => 'Filtrar por Especialidad';

  @override
  String get searchNoResults => 'No se encontraron profesionales';

  @override
  String get loginTaglinePart1 => 'Tu red de confianza ';

  @override
  String get loginTaglinePart2 => 'para resolver';

  @override
  String get loginConceptTrustTitle => 'Confianza';

  @override
  String get loginConceptTrustSubtitle => 'Verificación\ny seguridad';

  @override
  String get loginConceptSpeedTitle => 'Rapidez';

  @override
  String get loginConceptSpeedSubtitle => 'Respuesta\ninmediata';

  @override
  String get loginConceptConnectionTitle => 'Conexión';

  @override
  String get loginConceptConnectionSubtitle => 'Personas que\nresuelven';

  @override
  String get loginBenefitVerified => 'Especialistas\nverificados';

  @override
  String get loginBenefitRatings => 'Evaluaciones\nreales';

  @override
  String get loginBenefitTracking => 'Seguimiento\nde servicios';

  @override
  String get loginInvalidCredentials => 'Correo o contraseña incorrecta';

  @override
  String get loginForgotDialogTitle => 'Recuperar contraseña';

  @override
  String get loginForgotDialogMessage =>
      'Ingresa tu correo electrónico y te enviaremos las instrucciones para restablecer tu contraseña.';

  @override
  String get loginForgotDialogEmailRequired =>
      'Por favor, ingresa tu correo electrónico.';

  @override
  String get authRegisterSubtitle => 'Crea tu cuenta para comenzar';

  @override
  String get authStep1Subtitle =>
      'Completa tus datos de contacto para continuar';

  @override
  String get authStep0FillAllFields => 'Por favor completa todos los campos.';

  @override
  String get authStep0NameMaxLength =>
      'El nombre no puede superar los 30 caracteres.';

  @override
  String get authStep0LastNameMaxLength =>
      'El apellido no puede superar los 30 caracteres.';

  @override
  String get authStep0EmailsDoNotMatch =>
      'Los correos electrónicos no coinciden.';

  @override
  String get authStep0InvalidEmail =>
      'Por favor ingresa un correo electrónico válido.';

  @override
  String get authStep0PasswordLength =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get authStep0PasswordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get authStep0AgeRestriction =>
      'Debes ser mayor de 18 años para registrarte.';

  @override
  String get authStep0TermsFooter =>
      'Al registrarte aceptas nuestros\nTérminos y Condiciones y Política de Privacidad';

  @override
  String get authPhotoUploaded => 'Foto de perfil cargada ✓';

  @override
  String get authPhotoRequired =>
      'Foto de perfil * (Obligatoria: sube una foto clara de tu rostro para la validación)';

  @override
  String get authPhotoPermissionError =>
      'No se pudo abrir la cámara o galería. Por favor verifica los permisos.';

  @override
  String get authMyAddress => 'Mi dirección';

  @override
  String get authReadTerms => 'Lee los términos y condiciones de uso';

  @override
  String get authSubmitRegister => 'Registrarme';

  @override
  String get authTermsDialogTitle => 'Términos y Condiciones';

  @override
  String get mapSearchAddressHint => 'Buscar dirección...';

  @override
  String get mapCurrentGpsTooltip => 'GPS Actual';

  @override
  String get mapSelectLocationHint => 'Selecciona una ubicación';

  @override
  String get mapConfirmLocation => 'Confirmar Ubicación';

  @override
  String get addressDialogNoSaved => 'No tienes direcciones guardadas.';

  @override
  String get addressDialogLimitReached => 'Límite de 3 direcciones alcanzado.';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get addressNewTitle => 'Nueva Dirección';

  @override
  String get addressSave => 'Guardar dirección';

  @override
  String get addressSaveError =>
      'Lo sentimos, hubo un error al guardar la dirección.';

  @override
  String get addressNoConfigured =>
      'No has configurado una dirección de servicio.';

  @override
  String get addressChange => 'Cambiar';

  @override
  String get addressAdd => 'Agregar dirección';

  @override
  String get addressMyAddressLabel => 'Mi dirección:';

  @override
  String get jobAddressVisitRequired => 'Dirección de la Visita *';

  @override
  String get jobAddressGoogleMapsHint => 'Buscar dirección en Google Maps...';

  @override
  String get jobAddressValidation => 'Ingresa la dirección';

  @override
  String get addressTypeHint => 'Escribe tu dirección...';

  @override
  String get exploreSearchHint => 'Buscar servicios cercanos...';

  @override
  String get exploreUrgencyMode => 'Modo Urgencia';

  @override
  String get exploreUrgencySubtitle => 'Solo profesionales disponibles ahora';

  @override
  String exploreClearFilters(int count) {
    return 'Limpiar filtros ($count)';
  }

  @override
  String get exploreVerified => 'Verificado';

  @override
  String get exploreViewProfile => 'Ver perfil';

  @override
  String get exploreSearchingServices => 'Buscando servicios...';

  @override
  String get exploreSearchThisArea => 'Buscar en esta área';

  @override
  String get filterSheetCategoriesTitle => 'Categorías';

  @override
  String get filterSheetCategoryBreadcrumb => 'Categoría';

  @override
  String filterSheetSubcategories(int count) {
    return '$count subcategorías';
  }

  @override
  String get filterSheetClearAll => 'Limpiar todo';

  @override
  String get filterSheetSearchPlaceholder => 'Buscar servicio';

  @override
  String get filterSheetInfoTip =>
      'Navega y selecciona los servicios que necesitas';

  @override
  String get filterSheetNoServices => 'No se encontraron servicios.';

  @override
  String filterSheetSelectedServices(int count) {
    return '$count servicios seleccionados';
  }

  @override
  String get filterSheetApply => 'Aplicar filtros';

  @override
  String get filterSheetCancel => 'Cancelar';

  @override
  String get jobsDescription => 'Descripción del trabajo';

  @override
  String get jobsTotal => 'Total';

  @override
  String get jobsVisitProposalTitle => 'Propuesta de Visita';

  @override
  String get jobsVisitProposalDesc =>
      'El profesional ha programado una fecha y hora para realizar la visita:';

  @override
  String jobsRejectedBy(String name) {
    return 'Rechazado por: $name';
  }

  @override
  String get jobsRejectedDefault => 'Trabajo Rechazado / Cancelado';

  @override
  String get jobsRejectionReason => 'Motivo de rechazo:';

  @override
  String get jobsRejectDialogTitle => 'Rechazar Propuesta';

  @override
  String get jobsRejectReasonOptional =>
      '¿Deseas indicar el motivo de rechazo? (Opcional)';

  @override
  String get jobsReasonHint => 'Escribe tu razón aquí...';

  @override
  String get jobsRejectConfirm => 'Confirmar Rechazo';

  @override
  String get jobsCancelDialogTitle => 'Cancelar Solicitud';

  @override
  String get jobsCancelDialogMsg =>
      '¿Estás seguro de que deseas cancelar esta solicitud? El maestro será notificado.';

  @override
  String get jobsCancelReasonLabel => 'Motivo de cancelación (opcional):';

  @override
  String get jobsCancelConfirm => 'Confirmar Cancelación';

  @override
  String get jobsYourRating => 'Tu Calificación';

  @override
  String get jobsRateProfessional => 'Calificar Maestro';

  @override
  String get jobsRejectAction => 'Rechazar';

  @override
  String get jobsConfirmAction => 'Confirmar';
}
