
import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';

class PrintService{

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? characteristic;
  String targetDevice = '0ED2DB67-8733-2C1D-0ACB-557F656FFCF3';

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic charac in service.characteristics) {
        if (charac.properties.write) {
            characteristic = charac;
        }
      }
    }
  }


  void scanForDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    for (BluetoothDevice device in connectedDevices) {
      if (device.id.toString() == targetDevice) {
        selectedDevice = device;
        discoverServices(selectedDevice!);
        print("Dispositivo ya conectado: ${device.name}");
        return;
      }
    }
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.id.toString() == targetDevice) {
          flutterBlue.stopScan();
          selectedDevice = r.device;
          selectedDevice?.connect();
          discoverServices(selectedDevice!);
          print("Dispositivo encontrado y conectado: ${r.device.name}");
          break;
        }
      }
    });
  }

  void generateEscPosTicket(List<Map<String, dynamic>> ventas) async {
    String lugar = 'Lugar exp: Merida, Yucatan\n';

    if(characteristic!=null){
      List<int> bytes = [];

      // Comando ESC/POS para centrar y poner en negrita el texto "BEUATE CLINIQUE"
      bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
      bytes += utf8.encode('\x1B\x45\x01'); // Negrita ON
      bytes += utf8.encode('CLINICA FLY\n\n');
      bytes += utf8.encode('\x1B\x45\x00'); // Negrita OFF
      bytes += utf8.encode('\x1B\x61\x00'); // Alinear izquierda
      //bytes += utf8.encode('\x1B\x61\x02'); // Alinear der
      bytes += utf8.encode('$lugar');
      bytes += utf8.encode('Fecha exp: ${DateFormat.yMd().format(DateTime.now())} ${DateFormat.jm().format(DateTime.now())}\n');

      // Espacio adicional
      bytes += utf8.encode('\n');

      // Texto "Cliente #"
      bytes += utf8.encode('Cliente #\n');

      // Encabezados de la tabla
      bytes += utf8.encode('CANT |   PROD   |PRECIO |IMPORTE\n');
      bytes += utf8.encode('--------------------------------\n');

      for (var venta in ventas) {
        int cantidad = venta['cantidad'];
        String producto = venta['prod'];
        double precio = venta['precio'];
        double importe = venta['importe'];

        List<String> partesProducto = [];

        int maxCaracteres = 9;
        for (int i = 0; i < producto.length; i += maxCaracteres) {
          int fin = (i + maxCaracteres < producto.length) ? i + maxCaracteres : producto.length;
          partesProducto.add(producto.substring(i, fin));
        }

        for (int j = 0; j < partesProducto.length; j++) {
          if (j == 0) {
            bytes += utf8.encode(' $cantidad    ${partesProducto[j]}  \$$precio  \$$importe\n');
          } else if (j < 3){
            bytes += utf8.encode('      ${partesProducto[j]}\n');
          } else{
            break;
          }
        }
      }

      double total = ventas.fold(0.0, (suma, venta) => suma + (venta['importe'] as double));
      int amountLength = total.toStringAsFixed(0).length;
      int lineWidth = 16 - (amountLength - 10).clamp(0, 19);

      String totalText = 'TOTAL';
      String amountText = '\$${total.toStringAsFixed(2)}';


      bytes += utf8.encode('--------------------------------\n');
      int totalLength = totalText.length + amountText.length;
      int spacesToAdd = lineWidth - totalLength;
      String padding = ' ' * spacesToAdd.clamp(0, lineWidth);
      bytes += utf8.encode('\x1D\x21\x11');
      bytes += utf8.encode('$totalText$padding$amountText\n');
      bytes += utf8.encode('\x1D\x21\x00');
      bytes += utf8.encode('--------------------------------\n');
      bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
      bytes += utf8.encode('\x1B\x45\x01'); // Negrita ON
      bytes += utf8.encode('Gracias por su visita!\n');
      bytes += utf8.encode('\x1B\x45\x00'); // Negrita OFF
      bytes += utf8.encode('\n\n\n');
      await characteristic!.write(bytes, withoutResponse: true);
    }
  }



}