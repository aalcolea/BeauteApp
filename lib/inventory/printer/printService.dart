import 'dart:math';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';

class PrinterService{
  bool connected=false;
  List availableBluetoothDevices = [];
  int batteryLevel=0;

  PrinterService();

  bool getConnectedState(){
    return connected;
  }

  List getAvailableDevices(){
    return availableBluetoothDevices;
  }

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    availableBluetoothDevices = bluetooths!;
  }

  Future<bool> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    if (result == "true") {
      connected = true;
      return connected;
    }
    connected = false;
    return connected;
  }

  Future<String?> getConnectionStatus() async {
    final String? result = await BluetoothThermalPrinter.connectionStatus;
    return result;
  }

  Future<void> getPrinterBatteryLevel() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      batteryLevel = (await BluetoothThermalPrinter.getBatteryLevel)!;
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> print() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getPrint();
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printGraphics() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getGraphics();
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printImage() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getImage();
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {
      //Hadnle Not Connected Senario
    }
  }


  Future<List<int>> getPrint() async {

    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    bytes += generator.feed(1);
    bytes += generator.hr(ch: '-', linesAfter: 0);
    bytes += generator.text( "Flydev", styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr(ch: '-', linesAfter: 0);
    bytes += generator.feed(2);
    return bytes;
  }

  Future<List<int>> getTicket() async {

    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    var rng = Random();
    int sum=0;
    int randomInt;

    final ByteData data = await rootBundle.load('assets/imgLog/logoTicketTres.png');
    final Uint8List byteses = data.buffer.asUint8List();
    var image = decodeImage(byteses);
    bytes += generator.image(image!);

    bytes += generator.text( "BEUATE CLINIQUE", styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text( "Lugar exp: Merida, Yucatan", styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text( "Fecha exp: ${DateFormat.yMd().format(DateTime.now())} ${DateFormat.jm().format(DateTime.now())}",
        styles: const PosStyles(align: PosAlign.left), linesAfter: 0);
    bytes += generator.feed(1);
    bytes += generator.text('Cliente #', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.feed(1);
    sum+=rng.nextInt(1000);
    bytes += generator.row([
      PosColumn(
          text: 'CANT',
          width: 2,
          styles: const PosStyles(
            align: PosAlign.left,
            bold: true,
          )),
      PosColumn(
          text: "PROD",
          width: 4,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true
          )),
      PosColumn(
          text: "PRECIO",
          width: 3,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true
          )),
      PosColumn(
          text: "IMPORTE",
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true
          )),
    ]);
    bytes += generator.hr(ch: '-', linesAfter: 0);
    bytes += generator.row([
      PosColumn(
          text: '3',
          width: 2,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "Shampo para calvos",
          width: 4,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true
          )),
      PosColumn(
          text: "\$100",
          width: 3,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true
          )),
      PosColumn(
          text: "\$300",
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true
          )),
    ]);
    bytes += generator.feed(2);
    bytes += generator.hr(ch: '-', linesAfter: 0);
    bytes += generator.text('GRACIAS POR SU VISITA',styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.feed(1);
    bytes += generator.feed(5);

    return bytes;
  }

  Future<List<int>> getGraphics() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    bytes += generator.qrcode('https://bluicesoftware.com/');

    bytes += generator.hr();

    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.feed(3);//bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> getImage() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    // Cargar la imagen desde los assets
    final ByteData data = await rootBundle.load('assets/imgLog/logoTicketTres.png');
    final Uint8List byteses = data.buffer.asUint8List();

    // Decodificar la imagen
    var image = decodeImage(byteses);

    if (image != null) {
      // Redimensionar la imagen para ajustarla a la impresora (en este caso, 58mm de ancho = 384 píxeles)
      int targetWidth = 384;
      image = copyResize(image, width: targetWidth);

      // Convertir la imagen a escala de grises
      image = grayscale(image);

      // Mejorar el contraste de la imagen
      image = contrast(image, 150); // Puedes ajustar el valor para mejorar más

      // Agregar la imagen a los bytes para imprimir
      bytes += generator.image(image!);
    }
    // Alimentar el papel después de imprimir la imagen
    bytes += generator.feed(3);
    return bytes;
  }

}