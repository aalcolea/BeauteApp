import 'package:beaute_app/views/admin/agendaMain.dart';
import 'package:beaute_app/views/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Iniciar Sesión',
          ),
        ),
        body: const Login(),
      ),
      routes: {
        '/agenda': (context) => AgendaAdmin(),
        //'/cerrarSesion': (context) => MyApp(),
      },
    );
  }
}
