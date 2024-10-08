import 'package:beaute_app/views/admin/assistantAdmin.dart';
import 'package:beaute_app/views/admin/drAdmin.dart';
import 'package:beaute_app/views/admin/toDate.dart';
import 'package:beaute_app/views/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'forms/appoinmentForm.dart';
import 'models/notificationsForAssistant.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('Permiso de notificación aceptado: ${settings.authorizationStatus}');
  try {
    String? fcmToken = await messaging.getToken();
    print('FCM Token: $fcmToken');
  } catch (e) {
    print('Error al obtener el token FCM: $e');
  }
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensaje recibido en primer plano (app abierta): ${message.notification?.title}');
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }
void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token != null) {
      var response = await http.get(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if(response.statusCode == 200){
        setState(() {
          _isLoggedIn = true;
        });
      }else{
        setState(() {
          _isLoggedIn = false;
        });
        prefs.remove('jtw_token');
      }
    }else{
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

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
      home: _isLoggedIn ? const DoctorAdmin(docLog: true) : const Login(),
      routes: {
        '/login': (context) => const Login(),
        '/drScreen': (context) => const DoctorAdmin(docLog: true),
        '/assistantScreen': (context) => const AssistantAdmin(docLog: false),
        '/citaScreen': (context) => AppointmentForm(isDoctorLog: false),
      },
      navigatorObservers: [routeObserver],
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
