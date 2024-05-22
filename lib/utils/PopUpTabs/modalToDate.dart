import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../views/admin/toDate.dart';


class ModalDateHandler extends StatefulWidget {
  final CalendarTapDetails details;
  final void Function(
      bool,
      )? showContentToModify;

  const ModalDateHandler({Key? key, required this.details, this.showContentToModify}) : super(key: key);

  @override
  _ModalDateHandlerState createState() => _ModalDateHandlerState();
}

class _ModalDateHandlerState extends State<ModalDateHandler> {
  bool _VarmodalReachTop = false;
  bool _isTaped = false;

  void _showModaltoDate() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: _VarmodalReachTop,
      showDragHandle: false,
      barrierColor: Colors.black54,
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: AppointmentScreen(
              selectedDate: widget.details.date!,
              reachTop: (bool reachTop, bool isTaped) {
                setState(() {
                  _VarmodalReachTop = reachTop;
                  _isTaped = isTaped;
                });
                Navigator.pop(context);
                _showModaltoDate();
                _VarmodalReachTop = false;
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Este widget no tiene UI propia.
  }
}
