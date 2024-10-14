import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class testPrint extends StatefulWidget {
  @override
  _testPrintState createState() => _testPrintState();
}

class _testPrintState extends State<testPrint> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? characteristic;

  @override
  void initState() {
    super.initState();
    checkConnectedDevices();
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

  void scanForDevices() {
    flutterBlue.startScan(timeout: Duration(seconds: 5));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.contains(r.device)) {
          setState(() {
            devicesList.add(r.device);
          });
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

  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Escoger impresora"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].name),
                  subtitle: Text(devicesList[index].id.toString()),
                  onTap: () async {
                    setState(() {
                      selectedDevice = devicesList[index];
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
