import UIKit
import Flutter
import PrinterLibs
import CoreBluetooth

@main
@objc class AppDelegate: FlutterAppDelegate, BLEPrintingDiscoverDelegate, BLEPrintingOpenDelegate, BLEPrintingDisconnectDelegate {

    var blePrinter: BLEPrinting?
    var posPrinter: POSPrinting?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let controller = window?.rootViewController as! FlutterViewController
        let printerChannel = FlutterMethodChannel(name: "printer_channel", binaryMessenger: controller.binaryMessenger)

        printerChannel.setMethodCallHandler { [weak self] (call, result) in
            guard call.method == "printImage" else {
                result(FlutterMethodNotImplemented)
                return
            }

            if let args = call.arguments as? [String: Any],
               let imagePath = args["path"] as? String {
                // Usamos el ID del dispositivo hardcoded para pruebas
                self?.printImageFromFramework(imagePath: imagePath, deviceId: "6D4699DA-9BAD-A1E8-DE95-4B0497AF2D29")
                result("Imagen impresa correctamente")
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Ruta de imagen inválida o dispositivo no encontrado", details: nil))
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func printImageFromFramework(imagePath: String, deviceId: String) {
        // Inicializar la clase BLEPrinting
        blePrinter = BLEPrinting()
        blePrinter?.myDiscoverDelegate = self
        blePrinter?.myOpenDelegate = self
        blePrinter?.myDisconnectDelegate = self

        // Escanear dispositivos BLE
        blePrinter?.scan()

        // Buscar la imagen directamente en el bundle de la app (iOS)
        guard let imgPath = Bundle.main.path(forResource: imagePath, ofType: nil),
              let img = UIImage(contentsOfFile: imgPath) else {
            print("Error: No se pudo cargar la imagen desde Xcode")
            return
        }

        // Intentar conectar con el dispositivo BLE usando el deviceId hardcoded
        if let peripheral = getPeripheralById(deviceId: deviceId) {
            let connected = blePrinter?.open(peripheral)
            if connected == true {
                // Inicializar POSPrinting y configurar la conexión BLE
                posPrinter = POSPrinting()
                posPrinter?.setIO(blePrinter) // Utilizamos BLEPrinting como IO
                // Verificar el estado de la impresora
                let success = posPrinter?.pos_QueryStatus(nil, timeout: 1000)
                if success == true {
                    posPrinter?.pos_PrintPicture(img, nWidth: 100, nHeight: 200, nAlign: 1, nMethod: 0)
                    print("Imagen enviada a la impresora con PrinterLibs")
                } else {
                    print("Error: La impresora no está lista o no respondió.")
                }
            } else {
                print("Error: No se pudo conectar con la impresora.")
            }
        } else {
            print("Error: No se pudo encontrar el dispositivo con ID \(deviceId)")
        }
    }

    // Crear una lista para almacenar los periféricos descubiertos
    var discoveredPeripherals: [CBPeripheral] = []
    let hardcodedDeviceId = "6D4699DA-9BAD-A1E8-DE95-4B0497AF2D29"
    
    // Implementar el método para manejar la búsqueda de periféricos BLE
    func didDiscoverBLE(_ peripheral: CBPeripheral, address: String, rssi: Int) {
        print("Dispositivo BLE descubierto: \(peripheral.name ?? "") con dirección: \(address)")
        
        // Agregar el periférico a la lista si aún no existe
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
        
        // Comprobar si el dispositivo hardcoded está presente
        if peripheral.identifier.uuidString == hardcodedDeviceId {
            print("Dispositivo hardcoded \(hardcodedDeviceId) encontrado.")
        }
    }

    // Función para buscar un periférico por `deviceId`
    func getPeripheralById(deviceId: String) -> CBPeripheral? {
        // Aquí asumimos que blePrinter ha escaneado los dispositivos y tiene una lista de periféricos
        guard let blePrinter = blePrinter else { return nil }
        
        // Verificar si el dispositivo hardcoded ya está en la lista
        for peripheral in discoveredPeripherals {
            if peripheral.identifier.uuidString == deviceId {
                return peripheral
            }
        }
        
        // Si no se encuentra durante el escaneo, crear un periférico ficticio manualmente con el hardcoded ID

        
        print("Error: No se encontró un dispositivo con ID \(deviceId)")
        return nil
    }





}
