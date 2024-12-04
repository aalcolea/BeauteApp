
import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';

import '../../agenda/utils/showToast.dart';
import '../../agenda/utils/toastWidget.dart';

class SelBt {


  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? characteristic;

  Future<void> ensureCharacteristicAvailable() async {
    if (characteristic == null && selectedDevice != null) {
      discoverServices(selectedDevice!);
    }
    int retryCount = 0;
    while (characteristic == null && retryCount < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      retryCount++;
    }
    if (characteristic == null) {
      print('error $characteristic');
      throw Exception("Error: Característica de impresión no disponible");
    }
  }

  void checkConnectedDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    if (connectedDevices.isNotEmpty) {
        selectedDevice = connectedDevices.first;
      discoverServices(selectedDevice!);
    }
  }

  Future <void> scanForDevices() async {
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.contains(r.device)) {
            devicesList.add(r.device);
        }
      }
    });

    flutterBlue.stopScan();
  }

  void sendMessage(String message) async {
    if (characteristic != null) {
      List<int> bytes = utf8.encode(message + "\n");
      await characteristic!.write(bytes, withoutResponse: true);
    }
  }

  Future <void> discoverServices(BluetoothDevice? device) async {
    List<BluetoothService>? services = await device?.discoverServices();
    for (BluetoothService service in services!) {
      for (BluetoothCharacteristic charac in service.characteristics) {
        if (charac.properties.write) {
            characteristic = charac;
        }
      }
    }
  }

  Future<void> connectTo (BluetoothDevice? btDevice) async {
    await btDevice?.connect();
    discoverServices(btDevice!);
  }

  void disconnect(context, BluetoothDevice? selectedDevice) async {
    if (selectedDevice != null ) {
      try {
        await selectedDevice.disconnect();
        selectedDevice = null;
        showOverlay(context, const CustomToast(message: 'Dispositivo SELBT desconectado correctamente'));
      } catch (e) {
        print("Error al desconectar el dispositivo: $e");
      }
    }
  }
}