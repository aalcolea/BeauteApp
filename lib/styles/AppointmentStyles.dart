import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class FieldsPading extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget child;

  const FieldsPading({
    super.key,
    this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry defaultPadding = EdgeInsets.symmetric(
      vertical: MediaQuery.of(context).size.width * 0.02,
      horizontal: MediaQuery.of(context).size.width * 0.02,
    );

    return Padding(
      padding: padding ?? defaultPadding,
      child: child,
    );
  }
}

class CalendarContainer extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final Widget? child;

  const CalendarContainer({
    super.key,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.decoration,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final BoxDecoration defaultDecoration = BoxDecoration(
      border: Border.all(color: Colors.black54, width: 0.5),
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    );

    final EdgeInsetsGeometry defaultMargin = EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.023,
    );

    final double defaultWidth = MediaQuery.of(context).size.width;
    final double defaultHeight = MediaQuery.of(context).size.height * 0.4;

    final EdgeInsetsGeometry defaultPadding = EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        bottom: MediaQuery.of(context).size.width * 0.04);

    return Container(
      margin: margin ?? defaultMargin,
      padding: padding ?? defaultPadding,
      width: width ?? defaultWidth,
      height: height ?? defaultHeight,
      decoration: decoration ?? defaultDecoration,
      child: child,
    );
  }
}

class DoctorsMenu extends StatefulWidget {
  final void Function(
    bool,
    bool,
    TextEditingController,
    int,
    bool,
  ) onAssignedDoctor;
  final int optSelectedToRecieve;

  const DoctorsMenu(
      {super.key,
      required this.onAssignedDoctor,
      required this.optSelectedToRecieve});

  @override
  State<DoctorsMenu> createState() => _DoctorsMenuState();
}

class _DoctorsMenuState extends State<DoctorsMenu> {
  bool dr1sel = false;
  bool dr2sel = false;
  bool showdrChooseWidget = false;
  final drSelected = TextEditingController();
  int optSelectedToSend = 0;
  int optSelected = 0;

  @override
  void initState() {
    super.initState();
    optSelected = widget.optSelectedToRecieve;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 0.5),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              setState(() {
                drSelected.text = 'Doctor1';
                widget.onAssignedDoctor(
                  dr1sel = true,
                  dr2sel = false,
                  drSelected,
                  optSelectedToSend = 1,
                  showdrChooseWidget = false,
                );
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * 0.02),
              decoration: BoxDecoration(
                  color:
                      optSelected == 1 || optSelectedToSend == 1 ? const Color(0xFF4F2263) : Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                        right: MediaQuery.of(context).size.width * 0.02),
                    child: optSelected == 1 ||  optSelectedToSend == 1
                        ? SvgPicture.asset(
                            'assets/imgLog/docVector2.svg',
                            width: MediaQuery.of(context).size.width * 0.06,
                            height: MediaQuery.of(context).size.width * 0.06,
                          )
                        : SvgPicture.asset(
                            'assets/imgLog/docVector2.svg',
                            colorFilter: const ColorFilter.mode(Color(0xFF4F2263), BlendMode.srcIn),
                            width: MediaQuery.of(context).size.width * 0.07,
                            height: MediaQuery.of(context).size.width * 0.07,
                          ),
                  ),
                  Text(
                    'Doctor 1',
                    style: TextStyle(
                        color: optSelected == 1 ||  optSelectedToSend == 1
                            ? Colors.white
                            : const Color(0xFF4F2263),
                        fontSize: MediaQuery.of(context).size.width * 0.054),
                  )
                ],
              ),
            ),
          ),

          ///
          Container(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.02),
            color: Colors.black54,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.0009,
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              setState(() {
                drSelected.text = 'Doctor2';
                widget.onAssignedDoctor(
                  dr2sel = true,
                  dr1sel = false,
                  drSelected,
                  optSelectedToSend = 2,
                  showdrChooseWidget = false,
                );
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * 0.02),
              decoration: BoxDecoration(
                  color: optSelected == 2 ||  optSelectedToSend == 2 ? const Color(0xFF4F2263) : Colors.white,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                        right: MediaQuery.of(context).size.width * 0.02),
                    child: optSelected == 2 ||  optSelectedToSend == 2
                        ? SvgPicture.asset(
                          'assets/imgLog/docVector2.svg',
                          width: MediaQuery.of(context).size.width * 0.06,
                          height: MediaQuery.of(context).size.width * 0.06,
                        )
                        : SvgPicture.asset(
                          'assets/imgLog/docVector2.svg',
                          colorFilter: const ColorFilter.mode(Color(0XFF4F2263), BlendMode.srcIn),
                          width: MediaQuery.of(context).size.width * 0.07,
                          height: MediaQuery.of(context).size.width * 0.07,
                        ), /*Icon(
                      CupertinoIcons.person_crop_circle_fill,
                      color: optSelected == 2
                          ? Colors.white
                          : const Color(0xFF4F2263),
                    ),*/
                  ),
                  Text(
                    'Doctor 2',
                    style: TextStyle(
                        color: optSelected == 2 ||  optSelectedToSend == 2
                            ? Colors.white
                            : const Color(0xFF4F2263),
                        fontSize: MediaQuery.of(context).size.width * 0.054),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FieldsToWrite extends StatelessWidget {
  final String labelText;
  final Icon? suffixIcon;
  final Icon? preffixIcon;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool? eneabled;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function()? onEdComplete;
  final void Function(PointerDownEvent)? onTapOutside;
  final List<TextInputFormatter>? inputFormatters;
  final String? initVal;

  const FieldsToWrite({
    super.key,
    required this.labelText,
    this.suffixIcon,
    this.fillColor,
    this.contentPadding,
    this.controller,
    required this.readOnly,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.eneabled,
    this.onEdComplete,
    this.textInputAction,
    this.onTapOutside,
    this.inputFormatters,
    this.preffixIcon,
    this.initVal,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry defaultContentPadding = EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.03,
    );

    return TextFormField(
      initialValue: initVal,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onEditingComplete: onEdComplete,
      enabled: eneabled,
      focusNode: focusNode,
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: labelText,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ?? defaultContentPadding,
        prefixIcon: preffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: fillColor != null,
        fillColor: fillColor ?? Colors.white,
      ),
      onChanged: onChanged,
      onTap: onTap,
      onTapOutside: onTapOutside,
    );
  }
}
