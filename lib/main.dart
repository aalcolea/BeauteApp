import 'dart:convert';
import 'package:beaute_app/agenda/themes/colors.dart';
import 'package:beaute_app/inventory/sellpoint/cart/services/cartService.dart';
import 'package:beaute_app/agenda/views/admin/admin.dart';
import 'package:beaute_app/agenda/views/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'globalVar.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
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
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
    child: const MyApp(),),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    bool isDocLog = false;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors3.primaryColor),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const Login(),
      },
      debugShowCheckedModeBanner: false,
      ///pendiente unificacion
      home: SplashScreen(),
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
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    await Future.delayed(const Duration(seconds: 2));
    if (token != null) {
      var response = await http.get(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data);
        if (data['user']['id'] == 1 || data['user']['id'] == 2) {
          SessionManager.instance.isDoctor = true;
        } else {
          SessionManager.instance.isDoctor = false;
        }
        SessionManager.instance.Nombre = data['user']['name'];
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => AssistantAdmin(docLog: SessionManager.instance.isDoctor)));
      } else {
        prefs.remove('jwt_token');
        goToLogin();
      }
    } else {
      goToLogin();
    }
  }

  void goToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors3.primaryColor,
            ),
            SizedBox(height: 20),
            Text('Cargando...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
