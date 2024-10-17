
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img; // Usa un alias para la librería 'image'
import 'package:intl/intl.dart';
import '../../agenda/utils/showToast.dart';
import '../../agenda/utils/toastWidget.dart';
import '../listenerPrintService.dart';

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



  Future<void> printImage(BluetoothCharacteristic characteristic) async {
    // Generate the bytes of the image
    print('printIMG');
    List<int> bytes = await generateImageBytes();
    print('bytes $bytes');

    // Send the bytes to the printer using the characteristic's write method
    await characteristic.write(bytes, withoutResponse: true);
  }

  Future<List<int>> generateImageBytes() async {
    List<int> bytes = [];

    // Load the image from the assets
    final ByteData data = await rootBundle.load('assets/imgLog/logoBeauteWhiteSqr.png');
    final Uint8List imageBytes = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(imageBytes); // Use 'img.Image' instead of 'Image'

    if (image == null) {
      print('Error decoding the image');
      return bytes;
    }

    // Convert the image to grayscale
    image = img.grayscale(image);

    // Resize the image if necessary
    const int maxWidth = 384; // Adjust this according to your printer's maximum width
    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }

    // Convert the image to a format compatible with ESC/POS
    bytes += generateImageEscPos(image);

    // Add additional print commands if needed
    bytes += [0x1B, 0x64, 0x02]; // Feed two lines
    bytes += [0x1B, 0x69]; // Cut the paper

    return bytes;
  }

// Function to convert the image to ESC/POS format
// Function to convert the image to ESC/POS format
  List<int> generateImageEscPos(img.Image image) {
    List<int> bytes = [];

    // Command for graphic mode in ESC/POS printer
    bytes += [0x1D, 0x76, 0x30, 0x00];
    bytes += [(image.width + 7) ~/ 8 & 0xFF, 0x00]; // Width in bytes, rounded up
    bytes += [image.height & 0xFF, (image.height >> 8) & 0xFF]; // Height in pixels

    // Traverse the pixels of the image and convert to monochrome
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          if (x + bit < image.width) {
            img.Pixel pixel = image.getPixel(x + bit, y);
            print('pixel $pixel');
            int luminance = 0;
            //int luminance = getLuminance(pixel);
            if (luminance < 128) {
              byte |= (1 << (7 - bit)); // Dark color, will be printed
            }
          }
        }
        bytes.add(byte);
      }
    }

    return bytes;
  }


// Function to get the luminance of a pixel
  int getLuminance(int pixel) {
    int r = getRed(pixel);
    int g = getGreen(pixel);
    int b = getBlue(pixel);
    return ((r * 0.3) + (g * 0.59) + (b * 0.11)).toInt();
  }

// Functions to extract RGB components from a pixel
  int getRed(int pixel) => (pixel >> 16) & 0xFF;
  int getGreen(int pixel) => (pixel >> 8) & 0xFF;
  int getBlue(int pixel) => pixel & 0xFF;

  int pixelToInt(img.Pixel pixel) {
    int r = pixel.r.toInt();
    int g = pixel.g.toInt();
    int b = pixel.b.toInt();
    int a = pixel.a.toInt();

    // Combina los canales de color en un entero ARGB
    return (a << 24) | (r << 16) | (g << 8) | b;
  }


}