

import 'package:beaute_app/inventory/testPrinter/printService.dart';

class ListenerPrintService {
  int _printServiceActivated = 0;
  final List<Function(int)> _observadores = [];

  void setChange(int value) {
    _printServiceActivated = value;
    notificarObservadores();
  }

  void registrarObservador(Function(int) callback) {
    _observadores.add(callback);
  }

  void notificarObservadores() {
    for (var callback in _observadores) {
      callback(_printServiceActivated);
    }
  }

  int get printServiceActivated => _printServiceActivated;
}
