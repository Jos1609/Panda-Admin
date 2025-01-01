// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_person_model.dart';
import '../utils/app_exception.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'drivers';

  Future<List<DeliveryPerson>> getAvailableDeliveryPeople() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 0)
          .get();

      return querySnapshot.docs
          .map((doc) => DeliveryPerson.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AppException('Error al obtener repartidores: $e');
    }
  }

  /// Actualizar el estado (`status`) de un repartidor.
  Future<void> updateDeliveryPersonStatus(
    String deliveryPersonId,
    int status,
  ) async {
    try {
      await _firestore.collection(_collection).doc(deliveryPersonId).update({
        'status': status,
      });
    } catch (e) {
      throw AppException('Error al actualizar estado del repartidor: $e');
    }
  }

  /// Asignar un pedido a un repartidor.
  Future<void> addOrderToDeliveryPerson(
    String deliveryPersonId,
    String orderId,
  ) async {
    try {
      await _firestore.collection(_collection).doc(deliveryPersonId).update({
        'activeOrderIds': FieldValue.arrayUnion([orderId]),
      });
    } catch (e) {
      throw AppException('Error al asignar pedido al repartidor: $e');
    }
  }

  /// Remover un pedido de un repartidor.
  Future<void> removeOrderFromDeliveryPerson(
    String deliveryPersonId,
    String orderId,
  ) async {
    try {
      await _firestore.collection(_collection).doc(deliveryPersonId).update({
        'activeOrderIds': FieldValue.arrayRemove([orderId]),
      });
    } catch (e) {
      throw AppException('Error al remover pedido del repartidor: $e');
    }
  }

  /// Obtener un repartidor específico por su ID.
  Future<DeliveryPerson?> getDeliveryPersonById(String deliveryPersonId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(deliveryPersonId).get();
      if (docSnapshot.exists) {
        return DeliveryPerson.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      throw AppException('Error al obtener los detalles del repartidor: $e');
    }
  }

  /// Actualizar el `rating` de un repartidor.
  Future<void> updateDeliveryPersonRating(
    String deliveryPersonId,
    int newRating,
  ) async {
    try {
      await _firestore.collection(_collection).doc(deliveryPersonId).update({
        'rating': newRating,
      });
    } catch (e) {
      throw AppException('Error al actualizar el rating del repartidor: $e');
    }
  }
 
}
