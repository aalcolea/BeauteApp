import 'package:beaute_app/views/admin/assistantAdmin.dart';
import 'package:beaute_app/views/admin/drAdmin.dart';
import 'package:beaute_app/views/admin/toDate.dart';
import 'package:beaute_app/views/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'forms/appoinmentForm.dart';
import 'models/notificationsForAssistant.dart';

void main() {

  ListaSingleton.instance.notiforAssistant.add(NotificationsforAssistant('Valor 1A', 'Valor 2A', DateTime.now()));
  ListaSingleton.instance.notiforAssistant.add(NotificationsforAssistant('Valor 3A', 'Valor 4A',  DateTime.now()));
  print(ListaSingleton.instance.notiforAssistant[0]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDocLog = false;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Login(),
      ),
      routes: {
        '/drScreen': (context) => const DoctorAdmin(),
        '/assistantScreen': (context) => const AssistantAdmin(),
        '/citaScreen': (context) => AppointmentForm(
              isDoctorLog: isDocLog
            ),
      },
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
