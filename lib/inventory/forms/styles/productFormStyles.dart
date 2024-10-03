import 'package:flutter/material.dart';

class TitleContainer extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry alignment;
  final BoxDecoration decoration;
  final Widget? child;

  const TitleContainer({
    super.key,
    this.padding,
    this.margin,
    this.alignment = Alignment.centerLeft,
    this.decoration = const BoxDecoration(
      color: Color(0xFF4F2263),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry defaultPadding = EdgeInsets.symmetric(
      vertical: MediaQuery.of(context).size.width * 0.02,
      horizontal: MediaQuery.of(context).size.width * 0.02,
    );

    final EdgeInsetsGeometry defaultMargin = EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.025,
    );

    return Container(
      padding: padding ?? defaultPadding,
      margin: margin ?? defaultMargin,
      alignment: alignment,
      decoration: decoration,
      child: child,
    );
  }
}
