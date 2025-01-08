// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import '../models/driver.dart';
import '../utils/exceptions.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  
  // Referencia a la colección de repartidores
  final CollectionReference _driversCollection = 
      FirebaseFirestore.instance.collection('drivers');

  // Stream de repartidores para escuchar cambios en tiempo real
  Stream<List<Driver>> getDriversStream() {
    return _driversCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Driver.fromJson({...data, 'id': doc.id});
          }).toList();
        });
  }

  // Obtener un repartidor específico por ID
  Future<Driver?> getDriverById(String driverId) async {
    try {
      final docSnapshot = await _driversCollection.doc(driverId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return Driver.fromJson({...data, 'id': docSnapshot.id});
      }
      return null;
    } catch (e) {
      throw CustomException('Error al obtener el repartidor: $e');
    }
  }

  // Crear un nuevo repartidor con credenciales de autenticación
  Future<void> createDriver(Driver driver, String password) async {
    try {
      // 1. Crear usuario de autenticación
      final UserCredential userCredential = 
          await _authService.createUserWithEmailAndPassword(
        email: driver.email,
        password: password,
      );

      // 2. Asignar rol de repartidor
      await _authService.assignRole(
        userCredential.user!.uid, 
        UserRoles.driver
      );

      // 3. Crear documento del repartidor en Firestore
      await _driversCollection.doc(userCredential.user!.uid).set({
        'name': driver.name,
        'email': driver.email,
        'phoneNumber': driver.phoneNumber,
        'address': driver.address,
        'photoUrl': driver.photoUrl,
        'status': DriverStatus.available.index,
        'rating': 0.0,
        'totalDeliveries': 0,
        'averageDeliveryTime': 0.0,
        'onTimeDeliveryPercentage': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // 4. Enviar email de verificación
      await _authService.sendEmailVerification(userCredential.user!);

    } catch (e) {
      // Si algo falla, limpiamos los datos creados
      await _cleanupFailedCreation(driver.email);
      throw CustomException('Error al crear el repartidor: $e');
    }
  }

  // Actualizar información del repartidor
  Future<void> updateDriver(String driverId, Map<String, dynamic> data) async {
    try {
      // Validar que el repartidor existe
      final driverDoc = await _driversCollection.doc(driverId).get();
      if (!driverDoc.exists) {
        throw CustomException('Repartidor no encontrado');
      }

      // Actualizar datos
      await _driversCollection.doc(driverId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw CustomException('Error al actualizar el repartidor: $e');
    }
  }

  // Actualizar estado del repartidor
  Future<void> updateDriverStatus(String driverId, DriverStatus status) async {
    try {
      await _driversCollection.doc(driverId).update({
        'status': status.index,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw CustomException('Error al actualizar el estado: $e');
    }
  }

  // Actualizar foto de perfil del repartidor
  Future<void> updateDriverPhoto(String driverId, String photoUrl) async {
    try {
      await _driversCollection.doc(driverId).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw CustomException('Error al actualizar la foto: $e');
    }
  }

  // Eliminar un repartidor
  Future<void> deleteDriver(String driverId) async {
    try {
      // Obtener el email del repartidor antes de eliminar
      final driverDoc = await _driversCollection.doc(driverId).get();
      if (!driverDoc.exists) {
        throw CustomException('Repartidor no encontrado');
      }

      final driverEmail = (driverDoc.data() as Map<String, dynamic>)['email'];

      // Eliminar documento de Firestore
      await _driversCollection.doc(driverId).delete();

      // Eliminar usuario de Authentication
      await _authService.deleteUserByEmail(driverEmail);

    } catch (e) {
      throw CustomException('Error al eliminar el repartidor: $e');
    }
  }

  // Obtener estadísticas del repartidor
 Future<Map<String, dynamic>> getDriverStats(String driverId) async {
  try {
    final deliveriesSnapshot = await _firestore
        .collection('orders')
        .where('deliveryPersonId', isEqualTo: driverId)
        .get();

    int totalDeliveries = deliveriesSnapshot.size;
    double totalTime = 0;
    int onTimeDeliveries = 0;
    double totalRating = 0;
    int ratedDeliveries = 0;

    for (var doc in deliveriesSnapshot.docs) {
      final data = doc.data();

      // Calcular tiempo de entrega basado en statusHistory
      if (data['statusHistory'] != null && data['statusHistory'] is List) {
        final statusHistory = List<Map<String, dynamic>>.from(data['statusHistory']);

        DateTime? inProgressTime;
        DateTime? deliveredTime;

        for (var statusEntry in statusHistory) {
          if (statusEntry['status'] == 'inProgress') {
            inProgressTime = (statusEntry['timestamp'] as Timestamp).toDate();
          } else if (statusEntry['status'] == 'delivered') {
            deliveredTime = (statusEntry['timestamp'] as Timestamp).toDate();
          }

          // Si ya tenemos ambos tiempos, salir del bucle
          if (inProgressTime != null && deliveredTime != null) {
            break;
          }
        }

        if (inProgressTime != null && deliveredTime != null) {
          totalTime += deliveredTime.difference(inProgressTime).inMinutes;
        }
      }

      // Contar entregas a tiempo
      if (data['isOnTime'] == true) {
        onTimeDeliveries++;
      }

      // Sumar calificaciones
      if (data['rating'] != null) {
        totalRating += data['rating'];
        ratedDeliveries++;
      }
    }

    // Calcular promedios
    double averageTime = totalDeliveries > 0 ? totalTime / totalDeliveries : 0;
    double onTimePercentage = totalDeliveries > 0
        ? (onTimeDeliveries / totalDeliveries) * 100
        : 0;
    double averageRating = ratedDeliveries > 0
        ? totalRating / ratedDeliveries
        : 0;

    // Actualizar estadísticas en el documento del repartidor
    await _driversCollection.doc(driverId).update({
      'totalDeliveries': totalDeliveries,
      'averageDeliveryTime': averageTime,
      'onTimeDeliveryPercentage': onTimePercentage,
      'rating': averageRating,
      'statsUpdatedAt': FieldValue.serverTimestamp(),
    });

    return {
      'totalDeliveries': totalDeliveries,
      'averageDeliveryTime': averageTime,
      'onTimeDeliveryPercentage': onTimePercentage,
      'rating': averageRating,
    };
  } catch (e) {
    throw CustomException('Error al obtener estadísticas: $e');
  }
}

  // Limpiar datos si falla la creación
  Future<void> _cleanupFailedCreation(String email) async {
    try {
      // Intentar eliminar el usuario de Authentication si fue creado
      // ignore: deprecated_member_use
      final user = await _auth.fetchSignInMethodsForEmail(email);
      if (user.isNotEmpty) {
        await _authService.deleteUserByEmail(email);
      }

      // Intentar eliminar el documento de Firestore si fue creado
      final driverQuery = await _driversCollection
          .where('email', isEqualTo: email)
          .get();
      
      if (driverQuery.docs.isNotEmpty) {
        await _driversCollection.doc(driverQuery.docs.first.id).delete();
      }
    } catch (e) {
      print('Error en limpieza: $e');
    }
  }

  // Buscar repartidores
  Future<List<Driver>> searchDrivers(String query) async {
    try {
      // Buscar por nombre o teléfono
      final querySnapshot = await _driversCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final phoneQuerySnapshot = await _driversCollection
          .where('phoneNumber', isEqualTo: query)
          .get();

      // Combinar resultados
      final Set<String> driverIds = {};
      final List<Driver> drivers = [];

      for (var doc in [...querySnapshot.docs, ...phoneQuerySnapshot.docs]) {
        if (driverIds.add(doc.id)) {
          final data = doc.data() as Map<String, dynamic>;
          drivers.add(Driver.fromJson({...data, 'id': doc.id}));
        }
      }

      return drivers;
    } catch (e) {
      throw CustomException('Error en la búsqueda: $e');
    }
  }

  // Obtener repartidores disponibles
  Future<List<Driver>> getAvailableDrivers() async {
    try {
      final querySnapshot = await _driversCollection
          .where('status', isEqualTo: DriverStatus.available.index)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Driver.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw CustomException('Error al obtener repartidores disponibles: $e');
    }
  }

  
  
}