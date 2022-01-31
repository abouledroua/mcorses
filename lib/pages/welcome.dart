// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mcorses/classes/data.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:mcorses/classes/notifications.dart';
import 'package:mcorses/pages/authentification/login.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        if (Data.production) {
          secureScreen();
        } else {
          unsecureScreen();
        }
      }
    } catch (e) {
      print("error : $e");
    }
    Data.getNotificationPermission();
    listenDemandeNotification();
    super.initState();
    Timer(const Duration(seconds: 3), onClose);
  }

  secureScreen() async {
    // DISABLE SCREEN CAPTURE
    await FlutterWindowManager.addFlags(
        FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  unsecureScreen() async {
    // DISABLE SCREEN CAPTURE
    await FlutterWindowManager.addFlags(
        FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }

  void onClose() {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            maintainState: true,
            opaque: true,
            pageBuilder: (context, _, __) => const LoginPage(),
            transitionDuration: const Duration(seconds: 2),
            transitionsBuilder: (context, anim1, anim2, child) {
              return FadeTransition(child: child, opacity: anim1);
            }));
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Scaffold(
            body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
          Container(
              padding:
                  EdgeInsets.all(min(Data.heightScreen, Data.widthScreen) / 6),
              child: Center(
                  child: Image.asset("images/ifms.png", fit: BoxFit.cover))),
          Container(
              padding:
                  EdgeInsets.all(min(Data.heightScreen, Data.widthScreen) / 6),
              child: Center(
                  child: Image.asset("images/village_medical.png",
                      fit: BoxFit.cover)))
        ])));
  }
}
