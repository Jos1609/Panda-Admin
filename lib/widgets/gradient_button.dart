// lib/widgets/gradient_button.dart
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
 final String text;
 final VoidCallback? onPressed;
 final bool isLoading;

 const GradientButton({
   super.key,
   required this.text,
   this.onPressed,
   this.isLoading = false,
 });

 @override
 Widget build(BuildContext context) {
   return Container(
     decoration: BoxDecoration(
       gradient: const LinearGradient(
         colors: [
           Colors.black87,
           Colors.black, 
         ],
         begin: Alignment.centerLeft,
         end: Alignment.centerRight,
       ),
       borderRadius: BorderRadius.circular(15),
       boxShadow: [
         BoxShadow(
           // ignore: deprecated_member_use
           color: Colors.black.withOpacity(0.3),
           blurRadius: 8,
           offset: const Offset(0, 4),
         ),
       ],
     ),
     child: ElevatedButton(
       onPressed: isLoading ? null : onPressed,
       style: ElevatedButton.styleFrom(
         backgroundColor: Colors.transparent,
         shadowColor: Colors.transparent,
         padding: const EdgeInsets.symmetric(vertical: 16),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(15),
         ),
       ),
       child: isLoading
           ? const SizedBox(
               height: 20,
               width: 20,
               child: CircularProgressIndicator(
                 strokeWidth: 2,
                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
               ),
             )
           : Text(
               text,
               style: const TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w600,
                 letterSpacing: 0.5,
                 color: Colors.white, // Color del texto en blanco
               ),
             ),
     ),
   );
 }
}