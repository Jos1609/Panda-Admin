// lib/utils/constants.dart

import 'package:flutter/material.dart';

/// Constantes de la aplicación
class AppConstants {
  // Nombre de la aplicación
  static const String appName = 'DeliveryApp Admin';
  static const String appVersion = '1.0.0';
  
  // Rutas principales
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String driversRoute = '/drivers';
  static const String driverDetailsRoute = '/driver-details';
  static const String ordersRoute = '/orders';
  static const String settingsRoute = '/settings';
}

/// Constantes de diseño
class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF1565C0);
  static const Color accentColor = Color(0xFF64B5F6);
  
  // Colores de estado
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color errorColor = Color(0xFFE53935);
  static const Color infoColor = Color(0xFF2196F3);

  // Colores de fondo
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color scaffoldColor = Color(0xFFFAFAFA);

  // Colores de texto
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textLightColor = Color(0xFF9E9E9E);

  // Radios de borde
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  // Espaciado
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Elevación
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // Tamaños de fuente
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
}

/// Constantes de validación
class ValidationConstants {
  // Expresiones regulares
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );
  static final RegExp phoneRegex = RegExp(
    r'^\+?[\d\s-]{10,}$',
  );
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  // Longitudes mínimas y máximas
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minAddressLength = 5;
  static const int maxAddressLength = 200;
}

/// Constantes de Firebase
class FirebaseConstants {
  // Colecciones
  static const String usersCollection = 'users';
  static const String driversCollection = 'drivers';
  static const String ordersCollection = 'orders';
  static const String deliveriesCollection = 'deliveries';
  static const String settingsCollection = 'settings';

  // Subcollecciones
  static const String reviewsSubcollection = 'reviews';
  static const String locationsSubcollection = 'locations';
  static const String notificationsSubcollection = 'notifications';
}

/// Roles de usuario
class UserRoles {
  static const String admin = 'admin';
  static const String driver = 'driver';
  static const String customer = 'customer';
}

/// Estados de pedidos
class OrderStatus {
  static const String pending = 'pending';
  static const String assigned = 'assigned';
  static const String inProgress = 'in_progress';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
}

/// Constantes de configuración
class ConfigConstants {
  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
  
  // Límites
  static const int maxImageSize = 5242880; // 5MB
  static const int maxUploadRetries = 3;
  static const int maxLoginAttempts = 5;
  
  // Caché
  static const Duration cacheValidDuration = Duration(hours: 24);
  static const int maxCacheSize = 10485760; // 10MB
}

/// Constantes de mensajes
class MessageConstants {
  // Mensajes de éxito
  static const String loginSuccess = 'Inicio de sesión exitoso';
  static const String logoutSuccess = 'Sesión cerrada exitosamente';
  static const String updateSuccess = 'Actualización exitosa';
  static const String createSuccess = 'Creación exitosa';
  static const String deleteSuccess = 'Eliminación exitosa';

  // Mensajes de error
  static const String genericError = 'Ha ocurrido un error. Por favor, intenta de nuevo';
  static const String networkError = 'Error de conexión. Verifica tu conexión a internet';
  static const String authError = 'Error de autenticación';
  static const String validationError = 'Por favor, verifica los datos ingresados';
  static const String permissionError = 'No tienes permisos para realizar esta acción';

  // Mensajes de confirmación
  static const String deleteConfirmation = '¿Estás seguro de que deseas eliminar este elemento?';
  static const String logoutConfirmation = '¿Estás seguro de que deseas cerrar sesión?';
  static const String discardChanges = '¿Deseas descartar los cambios?';
}

/// Constantes de animación
class AnimationConstants {
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve sharpCurve = Curves.easeInOutQuart;
}

/// Constantes de Assets
class AssetConstants {
  // Imágenes
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderPath = 'assets/images/placeholder.png';
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
  
  // Iconos
  static const String appIconPath = 'assets/icons/app_icon.png';
  
  // Animaciones
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';
}