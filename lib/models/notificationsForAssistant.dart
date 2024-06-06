
class NotificationsforAssistant {
  String name;
  String hour;
  DateTime date;

  NotificationsforAssistant(this.name, this.hour, this.date);

  @override
  String toString() {
    return 'Elemento(valor1: $name, valor2: $hour, valor3: $date)';
  }
}

class ListaSingleton {
  // Constructor privado
  ListaSingleton._privateConstructor();

  // La instancia única de la clase
  static final ListaSingleton instance = ListaSingleton._privateConstructor();

  // Definir las listas globales dentro de la clase
  List<NotificationsforAssistant> notiforAssistant = [];
}
