import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:mcorses/pages/welcome.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }
  AwesomeNotifications().initialize(
      'resource://drawable/icone',
      [
        NotificationChannel(
            channelKey: 'demande_channel',
            channelName: "Notifications des Demandes d'access ",
            channelDescription:
                'Notification channel for alerting new access demande',
            defaultColor: Colors.amber.shade600,
            importance: NotificationImportance.High,
            channelShowBadge: false,
            playSound: true,
            icon: 'resource://drawable/icone',
            soundSource: 'resource://raw/res_sms',
            ledColor: Colors.white,
            onlyAlertOnce: true,
            defaultPrivacy: NotificationPrivacy.Private,
            vibrationPattern: lowVibrationPattern),
        NotificationChannel(
            channelKey: 'annonce_channel',
            channelName: 'Annonce notifications',
            channelDescription:
                'Notification channel for alerts about new announce',
            defaultColor: Colors.cyan,
            importance: NotificationImportance.High,
            channelShowBadge: false,
            playSound: true,
            icon: 'resource://drawable/icone',
            soundSource: 'resource://raw/res_announce',
            defaultPrivacy: NotificationPrivacy.Private,
            ledColor: Colors.blue)
      ],
      debug: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mecial Courses',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 32, 99, 162),
                titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500)),
            inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(borderSide: BorderSide(width: 1))),
            textTheme: const TextTheme(
                caption: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
                headline4: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black))),
        home: const WelcomePage());
    /*   routes: {
          "login": (context) => const LoginPage(),
          "setting": (context) => const SettingPage(),
          "profilPage": (context) => const ProfilPage(),
          "listFormation": (context) => const ListFormation()
        } );*/
  }
}
