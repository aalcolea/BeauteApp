import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
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


  void scanForDevices(BuildContext context) async {
    try {
      List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
      for (BluetoothDevice device in connectedDevices) {
        if (device.id.toString() == targetDevice) {
          selectedDevice = device;
          disconnect(context);
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
          }
        }
      });
    } catch (e) {
      print("Error durante el escaneo: $e");
    }
  }


  void listenToDeviceState(context) {
    _connectionSubscription?.cancel();
    if (selectedDevice != null) {
      _connectionSubscription = selectedDevice!.state.listen((state) {
        if (state == BluetoothDeviceState.disconnected) {
          selectedDevice = null;
          showOverlay(context, const CustomToast(message: 'Impresora desconectada'));
          notifyListeners();
        }});}}

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

  static const MethodChannel _channel = MethodChannel('printer_channel');

  Future<void> printImage(String imagePath) async {
    try {
      // Usar identificador de dispositivo hardcoded
      final String hardcodedDeviceId = '6D4699DA-9BAD-A1E8-DE95-4B0497AF2D29';

      final result = await _channel.invokeMethod('printImage', {
        "path": imagePath,
        "deviceId": hardcodedDeviceId,  // Pasar el identificador hardcoded
      });
      print("Resultado de impresión: $result");
    } on PlatformException catch (e) {
      print("Error al imprimir: $e");
    }
  }



}
