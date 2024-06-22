import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isDocLog = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.07,
                color: const Color(0xFFC5B6CD),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.003,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4F2263),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/assistantScreen');
              //Navigator.pushReplacementNamed(context, '/drScreen');
            },
            style: ElevatedButton.styleFrom(
              splashFactory: InkRipple.splashFactory,
              padding: EdgeInsets.zero,
              elevation: 10,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Color(0xFF4F2263), width: 2),
              ),
              fixedSize: Size(
                MediaQuery.of(context).size.width * 0.8,
                MediaQuery.of(context).size.height * 0.06,
              ),
              backgroundColor: Colors.white,
            ),
            child: const Center(
              child: Text(
                'FlyBtn',
                style: TextStyle(
                  color: Color(0xFF8AB6DD),
                  fontSize: 26,
                ),
              ),
            ),
          ),
          Image.asset(
            'assets/imgLog/logoBeauteWhiteSqr.png',
            width: MediaQuery.of(context).size.width * 0.55,
            height: MediaQuery.of(context).size.height * 0.16,
          ),
          ElevatedButton(
            onPressed: () {
              isDocLog = true;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PinEntryScreen(userId: 1, docLog: isDocLog,)),
              );
            },
            style: ElevatedButton.styleFrom(
              splashFactory: InkRipple.splashFactory,
              padding: EdgeInsets.zero,
              elevation: 10,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Color(0xFF4F2263), width: 2),
              ),
              fixedSize: Size(
                MediaQuery.of(context).size.width * 0.8,
                MediaQuery.of(context).size.height * 0.16,
              ),
              backgroundColor: Colors.white,
            ),
            child: const Center(
              child: Text(
                'Doctor1',
                style: TextStyle(
                  color: Color(0xFF8AB6DD),
                  fontSize: 26,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              isDocLog = true;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PinEntryScreen(userId: 2, docLog: isDocLog,)),
              );
            },
            style: ElevatedButton.styleFrom(
              splashFactory: InkRipple.splashFactory,
              padding: EdgeInsets.zero,
              elevation: 10,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Color(0xFF4F2263), width: 2),
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
            onPressed: () {
              isDocLog = false;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PinEntryScreen(userId: 3, docLog: isDocLog,)),
              );
            },
            style: ElevatedButton.styleFrom(
              splashFactory: InkRipple.splashFactory,
              padding: EdgeInsets.zero,
              elevation: 10,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Color(0xFF4F2263), width: 2),
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
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.003,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4F2263),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(2, -0),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.07,
                color: const Color(0xFFC5B6CD),
              ),
            ],
          )
        ],
      ),
    );
  }
}
