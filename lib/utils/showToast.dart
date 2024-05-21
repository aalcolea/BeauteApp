import 'package:flutter/material.dart';

void showOverlay(BuildContext context, Widget widget) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height*0.8,
      width: MediaQuery.of(context).size.width,
      child: Material(
        color: Colors.transparent,
        child: widget,
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(const Duration(seconds: 5), () {
    overlayEntry.remove();
  });
}