import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';

class PrintService2 {
  BluetoothCharacteristic? characteristic;

  PrintService2(this.characteristic);

  Future<void> connectAndPrint(List<Map<String, dynamic>> carrito, String imagePath) async {
    if (characteristic == null) {
      print("Error: No se encontró la característica para imprimir.");
      return;
    }

    await printImageWithAtkinsonDithering(imagePath, maxWidth: 200, maxHeight: 200);
    await printText(carrito);
    //await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> printText(List<Map<String, dynamic>> carrito) async {
    String lugar = 'Lugar exp: Merida, Yucatan\n';
    double cuentaTotal = 0;

    if (characteristic == null) return;

    List<int> bytes = [];
    // Comando ESC/POS para centrar y poner en negrita el texto "BEUATE CLINIQUE"
    bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
    bytes += utf8.encode('\x1B\x45\x01'); // Negrita ON
    bytes += utf8.encode('CLINICA FLY\n\n');
    bytes += utf8.encode('\x1B\x45\x00'); // Negrita OFF
    bytes += utf8.encode('\x1B\x61\x00'); // Alinear izquierda
    //bytes += utf8.encode('\x1B\x61\x02'); // Alinear der
    bytes += utf8.encode(lugar);
    bytes += utf8.encode('Fecha exp: ${DateFormat.yMd().format(DateTime.now())} ${DateFormat.jm().format(DateTime.now())}\n');

    // Espacio adicional
    bytes += utf8.encode('\n');
    bytes += utf8.encode('Cliente #\n');
    bytes += utf8.encode('\n');

    // Encabezados de la tabla//5
    bytes += utf8.encode('CANT |     PROD     |  IMPORTE\n');
    bytes += utf8.encode('--------------------------------\n');

       for (var item in carrito) {
      String productName = item['product'];
      double productPrice = item['price'];
      int productQuantity = item['cant_cart'].toInt();
      double total = productPrice * productQuantity;

      print('Qtt $productQuantity');
      print('Price $productPrice');
      print('TT$total');

      cuentaTotal += total;
      print('cuentaTot $cuentaTotal');

      List<String> partesProducto = [];

      int maxCaracteres = 14;
      // Dividir el nombre del producto en partes de maxCaracteres
      for (int i = 0; i < productName.length; i += maxCaracteres) {
        int fin = (i + maxCaracteres < productName.length) ? i + maxCaracteres : productName.length;
        String parte = productName.substring(i, fin);
        // Completar con espacios en blanco si la longitud es menor a maxCaracteres
        partesProducto.add(parte.padRight(maxCaracteres));
      }

      String formattedTotal = ('\$${total.toStringAsFixed(2)}').padLeft(10);
      String formattedCant = (productQuantity.toStringAsFixed(0)).padLeft(3);

      //>>>>>>esto es del precio individual de cada prod
      //String price = productPrice.toStringAsFixed(1);
      //String paddedPrice = price.padRight(6);
      //<<<<<<

      for (int j = 0; j < partesProducto.length; j++) {
        if (j == 0) {
          bytes += utf8.encode('  $formattedCant ${partesProducto[j]}  $formattedTotal');
        } else if (j < 3) {
          bytes += utf8.encode('      ${partesProducto[j]}\n');
        } else {
          break;
        }
      }
      //bytes += utf8.encode('$productName: $productQuantity x \$${productPrice.toStringAsFixed(2)} = \$${total.toStringAsFixed(2)}\n');
    }

    int amountLength = cuentaTotal.toStringAsFixed(0).length;
    int lineWidth = 16 - (amountLength - 10).clamp(0, 19);

    String totalText = 'TOTAL';
    String amountText = '\$${cuentaTotal.toStringAsFixed(2)}';


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

    bytes += utf8.encode('\x1D\x21\x00');
    bytes += utf8.encode('--------------------------------\n');
    bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
    bytes += utf8.encode('\x1B\x45\x01'); // Negrita ON
    bytes += utf8.encode('Gracias por su visita!\n');
    bytes += utf8.encode('\x1B\x45\x00'); // Negrita OFF
    bytes += utf8.encode('\n\n\n');


    await characteristic!.write(Uint8List.fromList(bytes), withoutResponse: true);
    await characteristic!.write(Uint8List.fromList([0x0A]), withoutResponse: true);
  }




  Future<void> printImageWithAtkinsonDithering(String imagePath, {int maxWidth = 384, int maxHeight = 200}) async {
    if (characteristic == null) return;
    ByteData data = await rootBundle.load(imagePath);
    Uint8List bytes = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytes);
    if (image != null) {
      img.Image processedImage = applyAtkinsonDithering(image, maxWidth, maxHeight);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> escPosData = generator.image(processedImage);

      await characteristic!.write(Uint8List.fromList(escPosData), withoutResponse: true);
      await characteristic!.write(Uint8List.fromList([0x0A]), withoutResponse: true);
    } else {
      print("Error al cargar la imagen");
    }
  }

  img.Image applyAtkinsonDithering(img.Image image, int maxWidth, int maxHeight) {
    int width = image.width;
    int height = image.height;
    double scale = (width / height > maxWidth / maxHeight)
        ? maxWidth / width
        : maxHeight / height;
    img.Image resizedImage = img.copyResize(image, width: (width * scale).toInt(), height: (height * scale).toInt(), interpolation: img.Interpolation.cubic);
    img.Image finalImage = img.Image(maxWidth, maxHeight);
    img.fill(finalImage, img.getColor(255, 255, 255));
    img.drawImage(finalImage, resizedImage, dstX: (maxWidth - resizedImage.width) ~/ 2, dstY: (maxHeight - resizedImage.height) ~/ 2);

    for (int y = 0; y < finalImage.height; y++) {
      for (int x = 0; x < finalImage.width; x++) {
        int oldPixel = img.getLuminance(finalImage.getPixel(x, y));
        int newPixel = oldPixel < 128 ? 0 : 255;
        int error = oldPixel - newPixel;
        finalImage.setPixel(x, y, newPixel == 0 ? img.getColor(0, 0, 0) : img.getColor(255, 255, 255));
        if (x + 1 < finalImage.width) applyError(finalImage, x + 1, y, error >> 3);
        if (x + 2 < finalImage.width) applyError(finalImage, x + 2, y, error >> 3);
        if (y + 1 < finalImage.height) {
          if (x - 1 >= 0) applyError(finalImage, x - 1, y + 1, error >> 3);
          applyError(finalImage, x, y + 1, error >> 3);
          if (x + 1 < finalImage.width) applyError(finalImage, x + 1, y + 1, error >> 3);
        }
        if (y + 2 < finalImage.height) {
          applyError(finalImage, x, y + 2, error >> 3);
        }
      }
    }
    return finalImage;
  }

  void applyError(img.Image image, int x, int y, int error) {
    int pixel = img.getLuminance(image.getPixel(x, y));
    int newPixel = (pixel + error).clamp(0, 255).toInt();
    image.setPixel(x, y, img.getColor(newPixel, newPixel, newPixel));
  }
}
