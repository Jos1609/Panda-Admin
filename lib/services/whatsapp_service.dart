// lib/services/whatsapp_service.dart
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<void> shareOrderDetails(String phoneNumber, String message) async {
    final Uri uri = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('No se pudo abrir WhatsApp');
    }
  }
}