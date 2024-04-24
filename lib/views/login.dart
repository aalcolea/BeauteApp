import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.07,
            color: const Color(0xFFC5B6CD),
          ),
          /*Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [*/

          Image.asset(
            'assets/imgLog/logoBeauteWhiteSqr.png',
            width: MediaQuery.of(context).size.width *
                0.55, // Establece el ancho de la imagen
            height: MediaQuery.of(context).size.height *
                0.16, // Establece la altura de la imagen
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              splashFactory: InkRipple.splashFactory,
              padding: EdgeInsets.zero,
              elevation: 10,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              fixedSize: Size(
                MediaQuery.of(context).size.width * 0.8,
                MediaQuery.of(context).size.height * 0.16,
              ),
              backgroundColor: Colors.white,
            ),
            child: const Center(
              child: Text(
                'Doctor',
                style: TextStyle(
                  color: Color(0xFF8AB6DD),
                  fontSize: 26,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              splashFactory: InkRipple.splashFactory,
              padding: EdgeInsets.zero,
              elevation: 10,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              fixedSize: Size(
                MediaQuery.of(context).size.width * 0.8,
                MediaQuery.of(context).size.height * 0.16,
              ),
              backgroundColor: Colors.white,
            ),
            child: const Center(
              child: Text(
                'Doctor',
                style: TextStyle(
                  color: Color(0xFF8AB6DD),
                  fontSize: 26,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              splashFactory: InkRipple.splashFactory,
              padding: EdgeInsets.zero,
              elevation: 10,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              fixedSize: Size(
                MediaQuery.of(context).size.width * 0.8,
                MediaQuery.of(context).size.height * 0.16,
              ),
              backgroundColor: Colors.white,
            ),
            child: const Center(
              child: Text(
                'Asistente',
                style: TextStyle(
                  color: Color(0xFF8AB6DD),
                  fontSize: 26,
                ),
              ),
            ),
          ),

          /*],
          ),*/
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.07,
            color: const Color(0xFFC5B6CD),
          ),
        ],
      ),
    );
  }
}
