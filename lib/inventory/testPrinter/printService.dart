
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

// Función para cargar la imagen desde un path
  Future<Uint8List> loadImageFromFile(String path) async {
    // Cargar la imagen desde los assets
    try {
      return await rootBundle.load(path).then((byteData) => byteData.buffer.asUint8List());
    } catch (e) {
      throw Exception("Error al cargar la imagen: $e");
    }
  }

// Función para convertir la imagen a escala de grises
  Uint8List convertImageToGrayscale(Uint8List originalImageData) {
    img.Image? image = img.decodeImage(originalImageData);
    if (image == null) {
      throw Exception("No se pudo cargar la imagen");
    }

    img.grayscale(image);

    return Uint8List.fromList(img.encodePng(image));
  }

// Función para redimensionar la imagen al ancho máximo
  img.Image resizeImage(img.Image image, int maxWidth) {
    if (image.width > maxWidth) {
      return img.copyResize(image, width: maxWidth);
    }
    return image;
  }

// Función para convertir la imagen en formato binario
  Uint8List convertToBinary(img.Image image) {
    int width = image.width;
    int height = image.height;
    List<int> binary = [];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Obtener el píxel
        img.Pixel pixel = image.getPixel(x, y); // Obtiene el objeto Pixel

        // Extraer componentes de color utilizando el objeto Pixel
        num red = pixel.r;   // Obtener el valor rojo
        num green = pixel.g; // Obtener el valor verde
        num blue = pixel.b;  // Obtener el valor azul

        // Calcular la luminancia utilizando los componentes RGB
        int luminance = (0.299 * red + 0.587 * green + 0.114 * blue).toInt();

        // Si la luminancia es mayor a un umbral, se considera blanco (0), de lo contrario negro (1)
        binary.add(luminance > 128 ? 0 : 1);
      }
    }

    return Uint8List.fromList(binary);
  }


// Función para codificar en formato ESC/POS
  Uint8List encodeToEscPos(Uint8List binaryData, int width) {
    List<int> bytes = [];
    bytes.addAll([0x1B, 0x40]); // Inicializar impresora
    bytes.addAll([0x1D, 0x76, 0x30, 0x00]); // Modo gráfico

    bytes.addAll([width & 0xFF, (width >> 8) & 0xFF]); // Ancho
    int height = (binaryData.length / width).ceil();
    bytes.addAll([height & 0xFF, (height >> 8) & 0xFF]); // Alto

    for (int i = 0; i < binaryData.length; i += 8) {
      int byte = 0;
      for (int bit = 0; bit < 8; bit++) {
        if (i + bit < binaryData.length && binaryData[i + bit] == 1) {
          byte |= (1 << (7 - bit));
        }
      }
      bytes.add(byte);
    }

    bytes.addAll([0x0A, 0x1D, 0x56, 0x41, 0x00]); // Avanzar papel y cortar

    return Uint8List.fromList(bytes);
  }

// Función principal para preparar la imagen y enviarla a la impresora
  Future<void> printImage(String imagePath, BluetoothCharacteristic? characteristic, int maxWidth) async {
    print(imagePath);
    try {
      // Cargar la imagen
      Uint8List imageData = await loadImageFromFile(imagePath);

      // Convertir a escala de grises
      Uint8List grayscaleImageData = convertImageToGrayscale(imageData);

      // Decodificar la imagen
      img.Image? image = img.decodeImage(grayscaleImageData);
      if (image == null) {
        throw Exception("Error al decodificar la imagen");
      }

      // Redimensionar la imagen al ancho máximo de la impresora
      img.Image resizedImage = resizeImage(image, maxWidth);

      // Convertir la imagen a formato binario (1 bit por píxel)
      Uint8List binaryData = convertToBinary(resizedImage);

      // Codificar en formato ESC/POS
      Uint8List escPosData = encodeToEscPos(binaryData, resizedImage.width);

      // Enviar a la impresora
      await characteristic!.write(escPosData, withoutResponse: true);
      print("Imagen impresa exitosamente");
    } catch (e) {
      print("Error al imprimir la imagen: $e");
    }
  }


}