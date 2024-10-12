import 'dart:async';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class KeyboardVisibilityManager {
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;

  // Constructor para inicializar la clase
  KeyboardVisibilityManager() {
    checkKeyboardVisibility();
  }

  // Función que configura el listener para detectar la visibilidad del teclado
  void checkKeyboardVisibility() {
    keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilitySubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      visibleKeyboard = visible;
      print("Teclado visible: $visibleKeyboard");
      // Aquí puedes realizar cualquier acción cuando el estado del teclado cambie
    });
  }

  // Método para cancelar la suscripción al evento de visibilidad del teclado
  void dispose() {
    keyboardVisibilitySubscription.cancel();
  }
}