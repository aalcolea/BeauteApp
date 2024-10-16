import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

class testPrint extends StatefulWidget {
  @override
  _testPrintState createState() => _testPrintState();
}

class _testPrintState extends State<testPrint> {

  List<Map<String, dynamic>> ventas = [
    {'cantidad': 3, 'prod' : 'Shampo para calvos', 'precio' : 100.0, 'importe' : 20.0},
    {'cantidad': 1, 'prod' : 'Gel para barba', 'precio' : 100.0, 'importe' : 100.0},
    {'cantidad': 6, 'prod' : 'Crema hidratante', 'precio' : 150.0, 'importe' : 900.0},
    {'cantidad': 6, 'prod' : 'Crema hidratante', 'precio' : 150.0, 'importe' : 9000.0},
  ];

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;
  String targeDevice = '0ED2DB67-8733-2C1D-0ACB-557F656FFCF3';
  BluetoothCharacteristic? characteristic;

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }
  void checkConnectedDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      setState(() {
        selectedDevice = connectedDevices.first;
      });
      discoverServices(selectedDevice!);
    }
  }

  void scanForDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    for (BluetoothDevice device in connectedDevices) {
      if (device.id.toString() == targeDevice) {
        selectedDevice = device;
        discoverServices(selectedDevice!);
        print("Dispositivo ya conectado: ${device.name}");
        return;
      }
    }
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.id.toString() == targeDevice) {
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

  void sendMessage(String message) async {
    if (characteristic != null) {
      List<int> bytes = utf8.encode(message + "\n");
      await characteristic!.write(bytes, withoutResponse: true);
    }
  }

  Future<List<int>> generateImageBytes(String imagePath) async {
    List<int> bytes = [];

    // Cargar la imagen desde los assets
    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List byteArray = data.buffer.asUint8List();

    // Decodificar la imagen
    img.Image? image = img.decodeImage(byteArray);

    if (image == null) {
      throw Exception("No se pudo decodificar la imagen");
    }

    // Convertir a escala de grises
    image = img.grayscale(image);

    // Redimensionar si es necesario (ajustar a 384 píxeles de ancho para una impresora de 58 mm)
    int targetWidth = 384;
    image = img.copyResize(image, width: targetWidth);

    // Convertir a datos de bytes en formato ESC/POS
    for (int y = 0; y < image.height; y++) {
      bytes.add(0x1B); // ESC
      bytes.add(0x2A); // *
      bytes.add(0x21); // m=33
      bytes.add(targetWidth ~/ 8); // ancho en bytes

      for (int x = 0; x < targetWidth; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          int pixelColor = image.getPixel(x + bit, y);
          int luminance = img.getLuminance(pixelColor);
          if (luminance < 128) {
            byte |= (1 << (7 - bit));
          }
        }
        bytes.add(byte);
      }

      bytes.add(0x0A); // Nueva línea
    }

    // Alimentar el papel después de imprimir la imagen
    bytes.addAll([0x1B, 0x64, 0x03]); // ESC d 3 (3 líneas en blanco)

    return bytes;
  }

  void generateEscPosTicket() async {
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
      double importe = ventas[3]['importe'];
      int amountLength = importe.toStringAsFixed(0).length;
      int lineWidth = 16 - (amountLength - 10).clamp(0, 19);

      String totalText = 'TOTAL';
      String amountText = '\$${importe.toStringAsFixed(2)}';


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

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic charac in service.characteristics) {
        if (charac.properties.write) {
          setState(() {
            characteristic = charac;
          });
        }
      }
    }
  }

  void printImage() async {
    try {
      List<int> imageBytes = await generateImageBytes('assets/imgLog/pikachu.jpg');
      await characteristic!.write(imageBytes, withoutResponse: true);
    } catch (e) {
      print('Error al imprimir la imagen: $e');
    }
  }

  Future<Uint8List> imagePathToUint8List(String path) async {
    ByteData data = await rootBundle.load(path);
    Uint8List imageBytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return imageBytes;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Escoger impresora"),
      ),
      body: Column(
        children: [
          IconButton(onPressed: (){
            Navigator.of(context).pop();

          }, icon: Icon(Icons.ac_unit)),
          IconButton(onPressed: () async {
            generateEscPosTicket();
            //sendComplexTicket();
          }, icon: Icon(Icons.access_alarm_rounded)),

          IconButton(onPressed: () async {
            printImage();
          }, icon: Icon(Icons.accessible_forward_outlined)),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].name),
                  subtitle: Text('asas ${devicesList[index].id.toString()}'),
                  onTap: () async {
                    setState(() {
                      selectedDevice = devicesList[index]; //'0ED2DB67-8733-2C1D-0ACB-557F656FFCF3'
                    });
                    await selectedDevice!.connect();
                    discoverServices(selectedDevice!);
                  },
                );
              },
            ),
          ),
          if (selectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(labelText: "mensaje "),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      sendMessage(messageController.text);
                    },
                    child: Text("Imprimir"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
