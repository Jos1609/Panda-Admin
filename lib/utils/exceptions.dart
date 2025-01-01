// lib/utils/exceptions.dart

import 'package:flutter/foundation.dart';

/// Excepción base personalizada para la aplicación
class CustomException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  CustomException(
    this.message, {
    this.code,
    this.details,
  }) {
    // Log de la excepción en modo debug
    if (kDebugMode) {
      print('CustomException: $message');
      if (code != null) print('Code: $code');
      if (details != null) print('Details: $details');
    }
  }

  @override
  String toString() => message;
}

/// Excepciones relacionadas con la autenticación
class AuthException extends CustomException {
  AuthException(super.message, {super.code, super.details});
}

/// Excepciones relacionadas con la red
class NetworkException extends CustomException {
  NetworkException(super.message, {super.code, super.details});
}

/// Excepciones relacionadas con la base de datos
class DatabaseException extends CustomException {
  DatabaseException(super.message, {super.code, super.details});
}

/// Excepciones relacionadas con la validación de datos
class ValidationException extends CustomException {
  final Map<String, String> errors;

  ValidationException(
    super.message, {
    this.errors = const {},
    super.code,
    super.details,
  });
}

/// Excepciones relacionadas con los repartidores
class DriverException extends CustomException {
  DriverException(super.message, {super.code, super.details});
}

/// Excepciones relacionadas con los pedidos
class OrderException extends CustomException {
  OrderException(super.message, {super.code, super.details});
}

/// Excepciones relacionadas con los permisos
class PermissionException extends CustomException {
  PermissionException(super.message, {super.code, super.details});
}

/// Excepciones relacionadas con el almacenamiento
class StorageException extends CustomException {
  StorageException(super.message, {super.code, super.details});
}

/// Utilidad para manejar excepciones de Firebase y convertirlas a nuestras excepciones personalizadas
class ExceptionHandler {
  static CustomException handleException(dynamic error) {
    if (error is CustomException) {
      return error;
    }

    // Firebase Auth Errors
    if (error.code != null) {
      switch (error.code) {
        case 'email-already-in-use':
          return AuthException(
            'El correo electrónico ya está registrado',
            code: error.code,
            details: error.message,
          );
        case 'invalid-email':
          return AuthException(
            'El correo electrónico no es válido',
            code: error.code,
            details: error.message,
          );
        case 'weak-password':
          return AuthException(
            'La contraseña debe tener al menos 6 caracteres',
            code: error.code,
            details: error.message,
          );
        case 'user-not-found':
          return AuthException(
            'Usuario no encontrado',
            code: error.code,
            details: error.message,
          );
        case 'wrong-password':
          return AuthException(
            'Contraseña incorrecta',
            code: error.code,
            details: error.message,
          );
        case 'PERMISSION_DENIED':
          return PermissionException(
            'No tienes permisos para realizar esta acción',
            code: error.code,
            details: error.message,
          );
      }
    }

    // Network Errors
    if (error is NetworkException) {
      return NetworkException(
        'Error de conexión. Verifica tu conexión a internet.',
        code: 'network-error',
        details: error.toString(),
      );
    }

    // Default Error
    return CustomException(
      'Ha ocurrido un error inesperado',
      code: 'unknown',
      details: error.toString(),
    );
  }

  /// Muestra un mensaje de error amigable para el usuario
  static String getUserFriendlyMessage(CustomException exception) {
    if (exception is AuthException) {
      return exception.message;
    }

    if (exception is NetworkException) {
      return 'Error de conexión. Por favor, verifica tu conexión a internet y vuelve a intentarlo.';
    }

    if (exception is ValidationException) {
      return exception.message;
    }

    if (exception is PermissionException) {
      return 'No tienes permisos para realizar esta acción. Contacta al administrador si crees que esto es un error.';
    }

    return 'Ha ocurrido un error. Por favor, inténtalo de nuevo más tarde.';
  }

  /// Obtiene un código de error para tracking
  static String getTrackingCode(CustomException exception) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final type = exception.runtimeType.toString().substring(0, 3).toUpperCase();
    final code = exception.code ?? 'UNK';
    return '$type-$code-$timestamp';
  }
}

/// Extension para manejar excepciones en el contexto de UI
extension ExceptionHandlerExtension on CustomException {
  /// Obtiene el mensaje amigable para el usuario
  String get userMessage => ExceptionHandler.getUserFriendlyMessage(this);

  /// Obtiene el código de tracking
  String get trackingCode => ExceptionHandler.getTrackingCode(this);

  /// Verifica si la excepción es de un tipo específico
  bool isA<T extends CustomException>() => this is T;
}