import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrintService2 {
  BluetoothCharacteristic? characteristic;

  PrintService2(this.characteristic);

  Future<void> connectAndPrint(List<Map<String, dynamic>> carrito, String imagePath) async {
    if (characteristic == null) {
      print("Error: No se encontró la característica para imprimir.");
      return;
    }

    await printText(carrito);
    await Future.delayed(Duration(milliseconds: 500));
    await printImageWithAtkinsonDithering(imagePath, maxWidth: 200, maxHeight: 200);
  }

  Future<void> printText(List<Map<String, dynamic>> carrito) async {
    if (characteristic == null) return;

    List<int> bytes = [];
    bytes += utf8.encode('\x1B\x61\x01');
    bytes += utf8.encode('\x1B\x45\x01');
    bytes += utf8.encode('CLINICA FL3\n\n');
    bytes += utf8.encode('\x1B\x45\x00');
    bytes += utf8.encode('\x1B\x61\x00');

    for (var item in carrito) {
      String productName = item['product'];
      double productPrice = item['price'];
      int productQuantity = item['cant_cart'].toInt();
      double total = productPrice * productQuantity;

      bytes += utf8.encode('$productName: $productQuantity x \$${productPrice.toStringAsFixed(2)} = \$${total.toStringAsFixed(2)}\n');
    }

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
