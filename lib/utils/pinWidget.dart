import 'package:flutter/material.dart';

class PinWidget extends StatefulWidget {
  const PinWidget({super.key});

  @override
  State<PinWidget> createState() => _PinWidgetState();
}

class _PinWidgetState extends State<PinWidget> {
  String pinCorrectoPruebas = '0000';
  String enteredPin = '';
  bool pinVisible = false;

  Widget numBtn(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding:
              const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
          //const EdgeInsets.all(20),
          backgroundColor: const Color(0xFFA0A0A0),
        ),
        onPressed: () {
          setState(() {
            if (enteredPin.length < 4) {
              enteredPin += number.toString();
              enteredPin == pinCorrectoPruebas
                  ? Navigator.pop(context, true)
                  : print(enteredPin);
            }
          });
        },
        child: Text(
          number.toString(),
          style: const TextStyle(fontSize: 36, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111).withOpacity(0.6),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 95),
        color: Colors.transparent,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          children: [
            const Center(
              child: Text(
                'Ingrese el pin',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            ///codigo para el pin
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    width: pinVisible ? 50 : 20,
                    height: pinVisible ? 60 : 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(width: 3, color: Colors.white),
                      color: index < enteredPin.length
                          ? pinVisible
                              ? Colors.black54
                              : Colors.white
                          : Colors.transparent,
                    ),
                    child: pinVisible && index < enteredPin.length
                        ? Center(
                            child: Text(
                            enteredPin[index],
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ))
                        : null,
                  );
                },
              ),
            ),

            IconButton(
              onPressed: () {
                setState(() {
                  pinVisible = !pinVisible;
                });
              },
              icon: Icon(
                pinVisible ? Icons.visibility_off_outlined : Icons.visibility,
                color: Colors.white,
              ),
            ),
            SizedBox(height: pinVisible ? 20.0 : 12.0),

            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                    (index) => numBtn(1 + 3 * i + index),
                  ).toList(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: SizedBox(),
                  ),
                  numBtn(0),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (enteredPin.isNotEmpty) {
                          enteredPin =
                              enteredPin.substring(0, enteredPin.length - 1);
                        }
                      });
                    },
                    child: const Icon(
                      Icons.backspace_outlined,
                      color: Colors.white,
                      size: 45,
                    ),
                  )
                ],
              ),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  enteredPin = '';
                });
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
