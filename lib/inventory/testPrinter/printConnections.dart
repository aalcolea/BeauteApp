import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
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
  StreamSubscription<BluetoothDeviceState>? _connectionSubscription;
  bool? isConnect;
  ListenerPrintService listenerPrintService = ListenerPrintService();
  String nameTargetDevice = 'MP210';

  Future<void> connectToBluetoothIOSDevice(context) async {
    PermissionStatus bluetoothScanStatus;
    PermissionStatus bluetoothConnectStatus;

    bluetoothScanStatus = await Permission.bluetoothScan.request();
    bluetoothConnectStatus = await Permission.bluetoothConnect.request();

    if (bluetoothScanStatus.isGranted && bluetoothConnectStatus.isGranted) {
      try {
        scanForDevices(context);
      } catch (e) {
        print("Error al conectar: $e");
      }
    } else {
      listenerPrintService.setChange(2, false);
      print("Permisos de Bluetooth no concedidos.");
    }
  }

  Future<void> connectToBluetoothDevice(context) async {
    PermissionStatus bluetoothScanStatus;
    PermissionStatus bluetoothConnectStatus;
    PermissionStatus locationStatus;

    bluetoothScanStatus = await Permission.bluetoothScan.request();
    bluetoothConnectStatus = await Permission.bluetoothConnect.request();
    locationStatus = await Permission.location.request();

    if (bluetoothScanStatus.isGranted && bluetoothConnectStatus.isGranted && locationStatus.isGranted) {
      try {
        scanForDevices(context);
      } catch (e) {
        print("Error al conectar: $e");
      }
    } else {
      listenerPrintService.setChange(2, false);
      print("Permisos de Bluetooth no concedidos.");
    }
  }
  Future<void> ensureCharacteristicAvailable() async {
    if (characteristic == null && selectedDevice != null) {
      await discoverServices(selectedDevice!);
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
  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic charac in service.characteristics) {
        if (charac.properties.write) {
          characteristic = charac;
          listenerPrintService.setChange(1, true);
          notifyListeners();
          return;
        }
      }
    }
  }


/*
  void sendMessage(String message) async {
    if (characteristic != null) {
      print('char android $characteristic');
      List<int> bytes = utf8.encode(message + "\n");
      await characteristic!.write(bytes, withoutResponse: true);
    }
  }
*/
  void sendMessage(String message) async {
    if (characteristic != null) {
      List<int> bytes = utf8.encode(message + "\n");
      int retryCount = 0;
      bool success = false;
      while (!success && retryCount < 3) {
        try {
          await characteristic!.write(bytes, withoutResponse: true);
          success = true;
        } catch (e) {
          retryCount++;
          print("Retry $retryCount: $e");
          await Future.delayed(Duration(milliseconds: 50)); // Pausa antes del próximo intento
        }
      }
      if (!success) {
        print("Error: No se pudo enviar el mensaje después de varios intentos.");
      }
    }
  }

/*
  void initDeviceStatus() {
    isConnect = selectedDevice != null;
    selectedDevice !=null ? listenerPrintService.setChange(3, isConnect) : null;
  }
*/


  void scanForDevices(context) async {
    bool isBluetoothOn = await flutterBlue.isOn;
    if (!isBluetoothOn) {
      showOverlay(context, const CustomToast(message: 'Encienda Bluethooth'));
    } else {
      try {
       /* List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
        for (BluetoothDevice device in connectedDevices) {
          if (device.name == nameTargetDevice) {
            selectedDevice = device;
            disconnect(context);
            discoverServices(selectedDevice!);
            listenToDeviceState(context);
            notifyListeners();
            return;
          }
        }*/
        listenerPrintService.setChange(0, null);
        await flutterBlue.startScan(timeout: const Duration(seconds: 5));
        flutterBlue.scanResults.listen((results) async {
          for (ScanResult r in results) {
            if (r.device.name == nameTargetDevice) {
              print("name ${r.device.name}");
              flutterBlue.stopScan();
              selectedDevice = r.device;
              print('seldevvv $selectedDevice');
              isConnect = true;
              print("Dispositivo encontrado: ${selectedDevice?.name}");
              try {
                await Future.delayed(const Duration(milliseconds: 50));
                await selectedDevice!.connect();
                discoverServices(selectedDevice!);
                isConnect = true;
                listenerPrintService.setChange(1, true);
                print("Dispositivo conectado: ${selectedDevice?.name}");
                print('seldevvv $selectedDevice');
                showOverlay(context, const CustomToast(message: "Dispositivo conectado correctamente"));
                listenToDeviceState(context);
                notifyListeners();
              } catch (e) {
                print("Error al conectar con el dispositivo: $e");
                selectedDevice = null;
                listenerPrintService.setChange(0, null);
                showOverlay(context, const CustomToast(message: "Espere mientras se reconecta automáticamente"));
                await Future.delayed(const Duration(seconds: 8));
                scanForDevices(context);
                notifyListeners();
              }
              break;
            }}});
      } catch (e) {
        print("Error durante el escaneo: $e");
      }
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
    print('disconect1');
    print('selDev $selectedDevice');
    print('iscon $isConnect');
    if (selectedDevice != null) {
      try {
        print('disconect2');
        _connectionSubscription?.cancel();
        await selectedDevice?.disconnect();
        selectedDevice = null;
        isConnect = false;
        listenerPrintService.setChange(2, false);
        notifyListeners();
        print("Dispositivo desconectado correctamente");
        showOverlay(context, const CustomToast(message: 'Dispositivo desconectado correctamente'));
      } catch (e) {
        print("Error al desconectar el dispositivo: $e");
      }
    }
  }
}