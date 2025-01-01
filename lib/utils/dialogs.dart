
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppDialogs {
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? AppTheme.errorColor : null,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> showLoadingDialog({
    required BuildContext context,
    String message = 'Cargando...',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      // ignore: deprecated_member_use
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(message),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        ),
      ),
    );
  }

  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Entendido',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorColor),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(title),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Aceptar',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.successColor),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(title),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String? initialValue,
    String? hintText,
    String confirmText = 'Aceptar',
    String cancelText = 'Cancelar',
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ),
            keyboardType: keyboardType,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, controller.text);
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result;
  }

  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    Color? backgroundColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        actions: actions,
      ),
    );
  }

  static Future<void> showBottomSheetDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = true,
    double? height,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height ?? MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHandle(),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                  vertical: AppTheme.spacingSmall,
                ),
                child: content,
              ),
            ),
            if (actions != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildBottomSheetHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
    );
  }

  static void showSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: isError ? AppTheme.errorColor : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );
  }
}

// Extensión para facilitar el uso de diálogos
extension DialogExtension on BuildContext {
  Future<bool> showConfirmation({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) {
    return AppDialogs.showConfirmationDialog(
      context: this,
      title: title,
      message: message,
      confirmText: confirmText ?? 'Confirmar',
      cancelText: cancelText ?? 'Cancelar',
      isDangerous: isDangerous,
    );
  }

  Future<void> showError({
    required String title,
    required String message,
    String? buttonText,
  }) {
    return AppDialogs.showErrorDialog(
      context: this,
      title: title,
      message: message,
      buttonText: buttonText ?? 'Entendido',
    );
  }

  Future<void> showSuccess({
    required String title,
    required String message,
    String? buttonText,
  }) {
    return AppDialogs.showSuccessDialog(
      context: this,
      title: title,
      message: message,
      buttonText: buttonText ?? 'Aceptar',
    );
  }

  void showLoading({String? message}) {
    AppDialogs.showLoadingDialog(
      context: this,
      message: message ?? 'Cargando...',
    );
  }

  void hideLoading() {
    Navigator.of(this).pop();
  }

  void showSnackBar(
    String message, {
    Duration? duration,
    SnackBarAction? action,
    bool isError = false,
  }) {
    AppDialogs.showSnackBar(
      context: this,
      message: message,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
      isError: isError,
    );
  }
}