
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panda_admin/utils/constants.dart';
import 'package:panda_admin/utils/exceptions.dart';
import '../models/admin_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AdminUser> login(String email, String password) async {
    try {
      // Intentar iniciar sesión con Firebase Auth
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw Exception('Error de autenticación');
      }

      // Obtener datos adicionales del admin desde Firestore
      final DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(result.user!.uid)
          .get();

      if (!adminDoc.exists) {
        await _auth.signOut();
        throw Exception('Usuario no tiene permisos de administrador');
      }

      return AdminUser.fromFirestore(
        adminDoc.data() as Map<String, dynamic>,
        result.user!.uid,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intente más tarde';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Crear el usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear el documento del usuario en Firestore
      await _firestore.collection(FirebaseConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
        details: e.message,
      );
    } catch (e) {
      throw AuthException(
        'Error al crear el usuario',
        details: e.toString(),
      );
    }
  }

  /// Asigna un rol específico a un usuario
  /// 
  /// [userId]: ID del usuario
  /// [role]: Rol a asignar (desde UserRoles)
  Future<void> assignRole(String userId, String role) async {
    try {
      // Validar que el rol sea válido
      if (![UserRoles.admin, UserRoles.driver, UserRoles.customer]
          .contains(role)) {
        throw ValidationException('Rol inválido');
      }

      // Actualizar el rol en Firestore
      await _firestore.collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Crear el claim personalizado en Firebase Auth
      await _auth.currentUser?.getIdTokenResult(true);

    } catch (e) {
      throw AuthException(
        'Error al asignar el rol',
        details: e.toString(),
      );
    }
  }

  /// Envía un email de verificación al usuario actual
  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      throw AuthException(
        'Error al enviar el email de verificación',
        details: e.toString(),
      );
    }
  }

  /// Elimina un usuario por su email
  /// 
  /// Este método es útil para limpieza y gestión de usuarios
  /// [email]: Email del usuario a eliminar
  Future<void> deleteUserByEmail(String email) async {
    try {
      // 1. Buscar el usuario por email
      // ignore: deprecated_member_use
      final userRecord = await _auth.fetchSignInMethodsForEmail(email);
      
      if (userRecord.isEmpty) {
        throw AuthException('Usuario no encontrado');
      }

      // 2. Buscar el documento en Firestore
      final userQuery = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where('email', isEqualTo: email)
          .get();

      // 3. Eliminar el documento de Firestore
      if (userQuery.docs.isNotEmpty) {
        final batch = _firestore.batch();
        
        // Eliminar documento principal
        batch.delete(userQuery.docs.first.reference);
        
        // Eliminar colecciones relacionadas
        await _deleteRelatedCollections(userQuery.docs.first.id);
        
        await batch.commit();
      }

      // 4. Eliminar usuario de Authentication
      final adminAuth = _auth;
      await adminAuth.currentUser?.delete();

    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
        details: e.message,
      );
    } catch (e) {
      throw AuthException(
        'Error al eliminar el usuario',
        details: e.toString(),
      );
    }
  }

  /// Elimina las colecciones relacionadas con un usuario
  Future<void> _deleteRelatedCollections(String userId) async {
    // Lista de colecciones relacionadas a eliminar
    final collections = [
      'driver_reviews',
      'driver_locations',
      'driver_notifications',
      // Agregar otras colecciones según sea necesario
    ];

    for (var collection in collections) {
      final querySnapshot = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Obtiene el mensaje de error correspondiente al código de Firebase Auth
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'El correo electrónico ya está registrado';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      default:
        return 'Error de autenticación';
    }
  }
}