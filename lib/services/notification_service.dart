// ignore: depend_on_referenced_packages
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:panda_admin/models/order_model.dart';


class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Solicitar permisos
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configurar handlers para diferentes estados de la app
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Mostrar notificación en la UI cuando la app está abierta
    if (message.data['type'] == 'order_update') {
      //Implementar notificación en la UI
    }
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Manejar cuando se abre la app desde la notificación
    if (message.data['type'] == 'order_update') {
      //Navegar a la pantalla correspondiente
    }
  }

  Future<void> sendOrderStatusUpdate(DeliveryOrder order) async {
    // Enviar notificación al backend para que la procese
    // Implementar según tu backend
  }

  Future<void> subscribeToOrderUpdates(String orderId) async {
    await _messaging.subscribeToTopic('order_$orderId');
  }

  Future<void> unsubscribeFromOrderUpdates(String orderId) async {
    await _messaging.unsubscribeFromTopic('order_$orderId');
  }
}