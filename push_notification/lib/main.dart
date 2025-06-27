import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔕 [BG] Notificação: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: android, iOS: ios);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    try {
      // Solicita permissões para Android 13+ e iOS
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          await FirebaseMessaging.instance.requestPermission();
        }
      } else {
        await FirebaseMessaging.instance.requestPermission();
      }

      // Obtém token FCM
      final token = await FirebaseMessaging.instance.getToken();
      print("📱 Token FCM: $token");

      setState(() {
        _token = token;
      });

      // Listener para mensagens em foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("🔔 [FG] Notificação: ${message.notification?.title}");

        if (message.notification != null) {
          final notification = message.notification!;
          final android = message.notification?.android;

          flutterLocalNotificationsPlugin.show(
            0,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'default_channel',
                'Notificações',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _token = 'Erro ao obter token: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Push Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('FCM Push Demo')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              _token != null ? "Token:\n$_token" : "Carregando token...",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}