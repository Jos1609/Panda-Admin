// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_person_model.dart';
import '../utils/app_exception.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'delivery_people';

  Future<List<DeliveryPerson>> getAvailableDeliveryPeople() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DeliveryPerson.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw AppException('Error al obtener repartidores: $e');
    }
  }

  Future<void> updateDeliveryPersonStatus(
    String deliveryPersonId,
    bool isAvailable,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(deliveryPersonId)
          .update({'isAvailable': isAvailable});
    } catch (e) {
      throw AppException('Error al actualizar estado del repartidor: $e');
    }
  }

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
}