
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../agenda/utils/showToast.dart';
import '../../agenda/utils/toastWidget.dart';
import '../listenerPrintService.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart' as img;


class PrintService extends ChangeNotifier {
  @override
    void dispose() {
      _connectionSubscription?.cancel();
      super.dispose();
    }

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? characteristic;
  String targetDevice = '0ED2DB67-8733-2C1D-0ACB-557F656FFCF3';
  StreamSubscription<BluetoothDeviceState>? _connectionSubscription;
  bool isConnected = false;
  ListenerPrintService listenerPrintService = ListenerPrintService();
  String nameTargetDevice = 'MP210';
  Future<void> ensureCharacteristicAvailable() async {
    if (characteristic == null && selectedDevice != null) {
      await discoverServices(selectedDevice!);
    }
    int retryCount = 0;
    while (characteristic == null && retryCount < 10) {
      await Future.delayed(Duration(milliseconds: 500));
      retryCount++;
    }
    if (characteristic == null) {
      throw Exception("Error: Característica de impresión no disponible");
    }
  }
  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic charac in service.characteristics) {
        if (charac.properties.write) {
          characteristic = charac;
          notifyListeners();
          return;
        }
      }
    }
  }

    void initDeviceStatus() {
      isConnected = selectedDevice != null;
      selectedDevice !=null ? listenerPrintService.setChange(3) : null;
    }


  void scanForDevices(context) async {
    try {
      List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
      for (BluetoothDevice device in connectedDevices) {
        if (device.id.toString() == targetDevice) {
          selectedDevice = device;
          disconnect(context);
          /*discoverServices(selectedDevice!);
          listenToDeviceState(context);
          notifyListeners();*/
          return;
        }
      }
      flutterBlue.startScan(timeout: const Duration(seconds: 5));
      flutterBlue.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.name == nameTargetDevice) {
            print("name ${r.device.name}");
            flutterBlue.stopScan();
            selectedDevice = r.device;
            print("Dispositivo encontrado: ${selectedDevice?.name}");
            try {
              await Future.delayed(const Duration(seconds: 2));
              await selectedDevice?.connect();
              isConnected = true;
              listenerPrintService.setChange(1);
              print("Dispositivo conectado: ${selectedDevice?.name}");
              discoverServices(selectedDevice!);
              showOverlay(context, const CustomToast(message: "Dispositivo conectado correctamente"));
              listenToDeviceState(context);
              notifyListeners();
            } catch (e) {
              print("Error al conectar con el dispositivo: $e");
              selectedDevice = null;
              showOverlay(context, const CustomToast(message: "Espere mientras se reconecta automáticamente"));
              await Future.delayed(const Duration(seconds: 8));
              scanForDevices(context);
              notifyListeners();
            }
            break;
          }}});
    } catch (e) {
      print("Error durante el escaneo: $e");
    }}

  void listenToDeviceState(context) {
    _connectionSubscription?.cancel();
    if (selectedDevice != null) {
      _connectionSubscription = selectedDevice!.state.listen((state) {
        if (state == BluetoothDeviceState.disconnected) {
          selectedDevice = null;
          showOverlay(context, const CustomToast(message: 'Impresora desconectada'));
          notifyListeners();
        }});}}

  void generateEscPosTicket(List<Map<String, dynamic>> carrito, BluetoothCharacteristic? characteristic) async {
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

      for (var venta in carrito) {
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

      double total = carrito.fold(0.0, (suma, venta) => suma + (venta['importe'] as double));
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
      await characteristic.write(bytes, withoutResponse: true);
    }
  }

  void disconnect(context) async {
    if (selectedDevice != null) {
      try {
        _connectionSubscription?.cancel();
        await selectedDevice?.disconnect();
        selectedDevice = null;
        isConnected = false;
        listenerPrintService.setChange(0);
        notifyListeners();
        print("Dispositivo desconectado correctamente");
        showOverlay(context, const CustomToast(message: 'Dispositivo desconectado correctamente'));
      } catch (e) {
        print("Error al desconectar el dispositivo: $e");
      }
    }
  }
  Future<Uint8List> loadImageFromFile(String path) async {
    try {
      return await rootBundle.load(path).then((byteData) => byteData.buffer.asUint8List());
    } catch (e) {
      throw Exception("Error al cargar la imagen: $e");
    }
  }

  Uint8List convertImageToGrayscale(Uint8List originalImageData) {
    img.Image? image = img.decodeImage(originalImageData);
    if (image == null) {
      throw Exception("No se pudo cargar la imagen");
    }

    img.grayscale(image);

    return Uint8List.fromList(img.encodePng(image));
  }

  img.Image resizeImage(img.Image image, int maxWidth, int maxHeight) {
    return img.copyResize(image, width: maxWidth, height: maxHeight);
  }
  Uint8List convertToBinary(img.Image image) {
    int width = image.width;
    int height = image.height;
    List<int> binary = [];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          if (x + bit < width) {
            int pixelColor = image.getPixel(x + bit, y);
            int luminance = img.getLuminance(pixelColor);
            if (luminance < 128) {
              byte |= (1 << (7 - bit));
            }
          }
        }
        binary.add(byte);
      }
    }

    return Uint8List.fromList(binary);
  }
  Uint8List encodeToEscPos(Uint8List binaryData, int width) {
    List<int> bytes = [];
    bytes.addAll([0x1B, 0x40]);
    bytes.addAll([0x1D, 0x76, 0x30, 0x00]);
    bytes.addAll([width & 0xFF, (width >> 8) & 0xFF]);
    int height = (binaryData.length / (width / 8)).ceil();
    bytes.addAll([height & 0xFF, (height >> 8) & 0xFF]);
    bytes.addAll(binaryData);
    bytes.addAll([0x0A, 0x1D, 0x56, 0x42, 0x00]);

    return Uint8List.fromList(bytes);
  }

  Uint8List convertToMonochrome(img.Image image) {
    int width = image.width;
    int height = image.height;
    List<int> binary = [];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          if (x + bit < width) {
            int pixelColor = image.getPixel(x + bit, y);
            int luminance = img.getLuminance(pixelColor);
            if (luminance < 128) {
              byte |= (1 << (7 - bit));
            }
          }
        }
        binary.add(byte);
      }
    }

    return Uint8List.fromList(binary);
  }

  Future<void> printImageInChunks(String imagePath, BluetoothCharacteristic? characteristic, int maxWidth, int maxHeight) async {
    if (characteristic == null) {
      print("Error: No se encontró la característica para imprimir.");
      return;
    }
    try {
      Uint8List imageData = await loadImageFromFile(imagePath);
      img.Image? image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception("Error al decodificar la imagen");
      }
      img.Image resizedImage = resizeImage(image, maxWidth, maxHeight);
      Uint8List binaryData = convertToMonochrome(resizedImage);
      Uint8List escPosData = encodeToEscPos(binaryData, resizedImage.width);
      await characteristic.write(escPosData, withoutResponse: true);
      print("Imagen impresa exitosamente.");
    } catch (e) {
      print("Error al imprimir la imagen: $e");
    }
  }
  img.Image resizeImageWithDynamicMargin(img.Image image, int maxWidth, int maxHeight) {
    int imageWidth = image.width;
    int margin = (maxWidth - imageWidth) ~/ 2;
    if (margin < 0) margin = 0;
    int newWidth = imageWidth;
    int newHeight = maxHeight;

    img.Image resizedImage = img.copyResize(image, width: newWidth, height: newHeight);

    img.Image finalImage = img.Image(maxWidth, maxHeight);
    img.fill(finalImage, img.getColor(255, 255, 255));
    img.drawImage(finalImage, resizedImage, dstX: margin, dstY: 0);

    return finalImage;
  }

  Uint8List convertToMonochromeOptimized(img.Image image) {
    int width = image.width;
    int height = image.height;
    List<int> binary = [];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          if (x + bit < width) {
            int pixelColor = image.getPixel(x + bit, y);
            int luminance = img.getLuminance(pixelColor);
            if (luminance < 200) {
              byte |= (1 << (7 - bit));
            }
          }
        }
        binary.add(byte);
      }
    }

    return Uint8List.fromList(binary);
  }

  Uint8List encodeToEscPosCentered(Uint8List binaryData, int width) {
    List<int> bytes = [];
    bytes.addAll([0x1B, 0x40]);
    bytes.addAll([0x1B, 0x61, 0x01]);

    bytes.addAll([0x1D, 0x76, 0x30, 0x00]);

    // Añadir el ancho y alto
    bytes.addAll([width & 0xFF, (width >> 8) & 0xFF]);
    int height = (binaryData.length / (width / 8)).ceil();
    bytes.addAll([height & 0xFF, (height >> 8) & 0xFF]);

    bytes.addAll(binaryData);
    bytes.addAll([0x0A, 0x1D, 0x56, 0x42, 0x00]);

    return Uint8List.fromList(bytes);
  }

  img.Image resizeImageWithMargin(img.Image image, int maxWidth, int maxHeight) {
    int margin = 20;
    int newWidth = maxWidth - (2 * margin);
    int newHeight = maxHeight;
    img.Image resizedImage = img.copyResize(image, width: newWidth, height: newHeight);
    img.Image finalImage = img.Image(maxWidth, maxHeight);
    img.fill(finalImage, img.getColor(255, 255, 255));
    img.drawImage(finalImage, resizedImage, dstX: margin, dstY: 0);

    return finalImage;
  }
/*  Future<void> resetPrinter(BluetoothCharacteristic? characteristic) async {
    Uint8List resetCommand = Uint8List.fromList([0x1B, 0x40]);
    await characteristic?.write(resetCommand, withoutResponse: true);
  }*/

  Uint8List encodeToEscPosWithManualMargins(Uint8List binaryData, int width, int maxWidth) {
    List<int> bytes = [];

    // Inicializar impresora y forzar alineación a la izquierda
    bytes.addAll([0x1B, 0x40]); // Resetear impresora
    bytes.addAll([0x1B, 0x61, 0x00]); // Alinear a la izquierda

    // Calcular márgenes manualmente si la imagen es más pequeña que el ancho máximo
    if (width < maxWidth) {
      int marginSize = (maxWidth - width) ~/ 2;
      bytes.addAll(List<int>.filled(marginSize, 0x20)); // Añadir espacios como margen izquierdo
    }

    // Modo gráfico para imprimir la imagen
    bytes.addAll([0x1D, 0x76, 0x30, 0x00]);

    // Añadir el ancho y alto
    bytes.addAll([width & 0xFF, (width >> 8) & 0xFF]); // Ancho en bytes
    int height = (binaryData.length / (width / 8)).ceil();
    bytes.addAll([height & 0xFF, (height >> 8) & 0xFF]); // Alto en bytes

    // Añadir los datos binarios de la imagen
    bytes.addAll(binaryData);

    // Comando de avance de papel y corte
    bytes.addAll([0x0A, 0x1D, 0x56, 0x42, 0x00]);

    return Uint8List.fromList(bytes);
  }
  Future<void> printImageDirectWithManualMargins(String imagePath, BluetoothCharacteristic? characteristic, int maxWidth, int maxHeight) async {
    if (characteristic == null) {
      print("Error: No se encontró la característica para imprimir.");
      return;
    }

    try {
      // Cargar la imagen desde el archivo
      Uint8List imageData = await loadImageFromFile(imagePath);
      img.Image? image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception("Error al decodificar la imagen");
      }

      // Redimensionar la imagen para que no exceda el ancho máximo permitido
      img.Image resizedImage = resizeImageWithDynamicMargin(image, maxWidth, maxHeight);

      // Convertir la imagen a monocromático (1 bit por píxel)
      Uint8List binaryData = convertToMonochromeOptimized(resizedImage);

      // Codificar la imagen en formato ESC/POS con márgenes manuales
      Uint8List escPosData = encodeToEscPosWithManualMargins(binaryData, resizedImage.width, maxWidth);

      // Enviar la imagen completa a la impresora
      await characteristic.write(escPosData, withoutResponse: true);

      print("Imagen impresa exitosamente.");
    } catch (e) {
      print("Error al imprimir la imagen: $e");
    }
  }
  Future<void> resetToOrigin(BluetoothCharacteristic? characteristic) async {
    // Comando para volver al origen (al inicio de la línea)
    Uint8List originCommand = Uint8List.fromList([0x1B, 0x61, 0x00]); // Alinear a la izquierda
    await characteristic?.write(originCommand, withoutResponse: true);
  }
  Future<void> printImageDirectWithPositionReset(String imagePath, BluetoothCharacteristic? characteristic, int maxWidth, int maxHeight) async {
    if (characteristic == null) {
      print("Error: No se encontró la característica para imprimir.");
      return;
    }

    try {
      // Reiniciar la impresora al origen antes de cada impresión
      await resetToOrigin(characteristic);

      // Cargar la imagen desde el archivo
      Uint8List imageData = await loadImageFromFile(imagePath);
      img.Image? image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception("Error al decodificar la imagen");
      }

      // Redimensionar la imagen para que no exceda el ancho máximo permitido
      img.Image resizedImage = resizeImageWithDynamicMargin(image, maxWidth, maxHeight);

      // Convertir la imagen a monocromático (1 bit por píxel)
      Uint8List binaryData = convertToMonochromeOptimized(resizedImage);

      // Codificar la imagen en formato ESC/POS con márgenes manuales
      Uint8List escPosData = encodeToEscPosWithManualMargins(binaryData, resizedImage.width, maxWidth);

      // Enviar la imagen completa a la impresora
      await characteristic.write(escPosData, withoutResponse: true);

      // Reiniciar la posición de la impresora después de la impresión
      await resetToOrigin(characteristic);

      print("Imagen impresa exitosamente.");
    } catch (e) {
      print("Error al imprimir la imagen: $e");
    }
  }

  Future<void> printImageDirectOptimized(String imagePath, BluetoothCharacteristic? characteristic, int maxWidth, int maxHeight) async {
    if (characteristic == null) {
      print("Error: No se encontró la característica para imprimir.");
      return;
    }

    try {
      Uint8List imageData = await loadImageFromFile(imagePath);
      img.Image? image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception("Error al decodificar la imagen");
      }
      img.Image resizedImage = resizeImageWithDynamicMargin(image, maxWidth, maxHeight);
      Uint8List binaryData = convertToMonochromeOptimized(resizedImage);
      Uint8List escPosData = encodeToEscPosCentered(binaryData, resizedImage.width);
      await characteristic.write(escPosData, withoutResponse: true);
      await resetPrinter(characteristic);
      print("Imagen impresa exitosamente.");
    } catch (e) {
      print("Error al imprimir la imagen: $e");
    }
  }

// Función de reset de impresora
  Future<void> resetPrinter(BluetoothCharacteristic? characteristic) async {
    Uint8List resetCommand = Uint8List.fromList([0x1B, 0x40]); // Comando de reset
    await characteristic?.write(resetCommand, withoutResponse: true);
  }// Función de reset de impresora mejorada con comando de vaciado de búfer
  Future<void> resetPrinterAndClearBuffer(BluetoothCharacteristic? characteristic) async {
    // Comando para resetear la impresora y vaciar el búfer
    Uint8List resetAndClearBufferCommand = Uint8List.fromList([
      0x1B, 0x40, // Resetear impresora
      0x1B, 0x63, 0x30, 0x02, // Vaciado de búfer
      0x1B, 0x64, 0x03, // Avanzar el papel para finalizar el trabajo actual
    ]);

    await characteristic?.write(resetAndClearBufferCommand, withoutResponse: true);
  }

// Función para enviar impresiones vacías múltiples (n veces)

  // Función para enviar una impresión vacía completa con "corte de papel"
  Future<void> sendFullEmptyPrintJobWithCut(BluetoothCharacteristic? characteristic) async {
    List<int> emptyJob = [];

    // Comando para imprimir una línea vacía
    emptyJob += utf8.encode('--------------------------------\n');
    emptyJob += utf8.encode('\n\n\n'); // Espacio vacío

    // Comando para avanzar el papel y cortar
    emptyJob += [0x1D, 0x56, 0x41, 0x00]; // Comando ESC/POS para cortar papel

    await characteristic?.write(Uint8List.fromList(emptyJob), withoutResponse: true);
  }
// Función para enviar una impresión vacía válida
  Future<void> sendFullEmptyPrintJobWithMinimalContent(BluetoothCharacteristic? characteristic) async {
    List<int> emptyJob = [];

    // Comando para imprimir una línea vacía o mínima
    emptyJob += utf8.encode('--------------------------------\n');
    emptyJob += utf8.encode('\n\n\n'); // Espacio vacío

    // Enviar a la impresora
    await characteristic?.write(Uint8List.fromList(emptyJob), withoutResponse: true);
  }

// Función principal que imprime 9 veces vacías y 1 vez real
  Future<void> generateEscPosTicketWithImageMultipleTimes(String imagePath, BluetoothCharacteristic? characteristic, int maxWidth, int maxHeight) async {
    if (characteristic == null) {
      print("Error: No se encontró la característica para imprimir.");
      return;
    }

    // Repetimos el ciclo de impresión completo 10 veces
    for (int i = 0; i < 10; i++) {
      if (i < 9) {
        // Imprimir trabajos vacíos (primeras 9 iteraciones)
        await sendFullEmptyPrintJobWithMinimalContent(characteristic);
        print("Impresión vacía enviada: $i");
      } else {
        // En la décima iteración, imprimir el ticket y la imagen real
        print("Impresión real enviada");

        List<Map<String, dynamic>> carrito = [
          {
            'cantidad': 2,
            'prod': 'Producto 1',
            'precio': 10.50,
            'importe': 21.00,
          },
          {
            'cantidad': 1,
            'prod': 'Producto 2',
            'precio': 5.25,
            'importe': 5.25,
          },
          {
            'cantidad': 3,
            'prod': 'Producto 3',
            'precio': 2.75,
            'importe': 8.25,
          },
        ];

        // Generar el ticket con texto
        String lugar = 'Lugar exp: Merida, Yucatan\n';
        List<int> bytes = [];

        // Comando ESC/POS para centrar y poner en negrita el texto "CLINICA FLY"
        bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
        bytes += utf8.encode('\x1B\x45\x01'); // Negrita ON
        bytes += utf8.encode('CLINICA FLY\n\n');
        bytes += utf8.encode('\x1B\x45\x00'); // Negrita OFF
        bytes += utf8.encode('\x1B\x61\x00'); // Alinear izquierda
        bytes += utf8.encode('$lugar');
        bytes += utf8.encode('Fecha exp: ${DateFormat.yMd().format(DateTime.now())} ${DateFormat.jm().format(DateTime.now())}\n');
        bytes += utf8.encode('\n');
        bytes += utf8.encode('Cliente #\n');
        bytes += utf8.encode('CANT |   PROD   |PRECIO |IMPORTE\n');
        bytes += utf8.encode('--------------------------------\n');

        for (var venta in carrito) {
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
            } else if (j < 3) {
              bytes += utf8.encode('      ${partesProducto[j]}\n');
            } else {
              break;
            }
          }
        }

        double total = carrito.fold(0.0, (suma, venta) => suma + (venta['importe'] as double));
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

        await characteristic.write(Uint8List.fromList(bytes), withoutResponse: true);

        // Imprimir la imagen después del ticket
        await printImageDirectWithManualMargins(imagePath, characteristic, maxWidth, maxHeight);
      }
    }
  }

}