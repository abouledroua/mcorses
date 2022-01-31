// ignore_for_file: avoid_print

import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcorses/classes/user.dart';
import 'package:mcorses/pages/authentification/login.dart';
import 'package:mcorses/pages/lists/list_admin.dart';
import 'package:mcorses/pages/lists/list_annonces.dart';
import 'package:mcorses/pages/lists/list_formations.dart';
import 'package:mcorses/pages/settings.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/fiches/fiche_profil.dart';

class Data {
  static bool production = true, isLogged = false;
  static String serverIP = "";
  static String localIP = "";
  static String internetIP = "";
  static int networkMode = 1;
  static int nbArticle = 0;
  static bool isLandscape = false, isPortrait = false, updList = false;
  static int timeOut = 0;
  static double minTablet = 450;
  static double widthScreen = double.infinity;
  static late double heightScreen;
  static late double heightmyAppBar;
  static String www = "MCORSES";
  static int index = 1;
  static late GoogleSignIn _googleSignign;
  static GoogleSignInAccount? googleAcount;
  static late BuildContext myContext;
  static User? currentUser;
  static List<bool> selections = [];

  static const MaterialColor white = MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100: Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(0xFFFFFFFF),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  );

  static List<Color> lightColor = [
    Colors.blue.shade50,
    Colors.red.shade50,
    Colors.amber.shade50,
    Colors.blueGrey.shade50,
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.deepPurple.shade50,
    Colors.cyan.shade50,
    Colors.brown.shade50,
    Colors.deepOrange.shade50,
    Colors.deepPurple.shade50,
    Colors.lightBlue.shade50,
    Colors.lime.shade50,
    Colors.orange.shade50,
    Colors.teal.shade50,
    Colors.pink.shade50,
    Colors.indigo.shade50,
    Colors.grey.shade50,
    Colors.yellow.shade50,
    Colors.black12,
    Colors.amberAccent.shade100,
    Colors.blueAccent.shade100,
    Colors.purpleAccent.shade100,
    Colors.cyanAccent.shade100,
    Colors.tealAccent.shade100,
    Colors.greenAccent.shade100,
    Colors.deepPurpleAccent.shade100,
    Colors.tealAccent.shade100
  ];

  static List<Color> darkColor = [
    Colors.amberAccent,
    Colors.blue,
    Colors.red,
    Colors.amber,
    Colors.blueGrey,
    Colors.blue,
    Colors.green,
    Colors.deepPurple,
    Colors.greenAccent,
    Colors.cyan,
    Colors.blueAccent,
    Colors.brown,
    Colors.cyanAccent,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lime,
    Colors.orange,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.deepPurpleAccent,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.grey,
    Colors.yellow,
    Colors.black12
  ];

  static int getTimeOut() => timeOut;

  static User? getCurrentUser() => currentUser;

  static int getNbArticle() => nbArticle;

  static int getNetworkMode() => networkMode;

  static String getServerIP() => serverIP;

  static String getLocalIP() => localIP;

  static String getInternetIP() => internetIP;

  static String getFile(pFile) => getServerDirectory("80") + "/FILES/$pFile";

  static String getServerDirectory([port = "80"]) => ((serverIP == "")
      ? ""
      : "https://$serverIP" +
          (port != "" && networkMode == 1 ? ":" + port : "") +
          "/" +
          www);

  static String getImage(pImage, pType) =>
      getServerDirectory("80") + "/IMAGE/$pType/$pImage";

  static setCurrentUser(User u) {
    currentUser = u;
  }

  static setNbArticle(nb) {
    nbArticle = nb;
  }

  static setServerIP(ip) async {
    serverIP = ip;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ServerIp', serverIP);
  }

  static setLocalIP(ip) async {
    localIP = ip;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('LocalIP', ip);
  }

  static setInternetIP(ip) async {
    internetIP = ip;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('InternetIP', ip);
  }

  static setNetworkMode(mode) async {
    networkMode = mode;
    (mode == 1) ? timeOut = 5 : timeOut = 7;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('NetworkMode', mode);
    prefs.setInt('TIMEOUT', timeOut);
  }

  static showSnack({required String msg, required Color color}) {
    ScaffoldMessenger.of(myContext)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  static setSizeScreen(context) {
    widthScreen = MediaQuery.of(context).size.width;
    heightScreen = MediaQuery.of(context).size.height;
    isLandscape = widthScreen > heightScreen;
    isPortrait = !isLandscape;
    heightmyAppBar = heightScreen * 0.2;
    myContext = context;
  }

  static Widget _drawerButton(
      {required String text,
      required IconData icon,
      required Color? color,
      required onTap}) {
    return InkWell(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: Colors.black, size: 26),
              const SizedBox(width: 10),
              Text(text,
                  style: GoogleFonts.laila(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold))
            ])));
  }

  static Widget circularPhoto(String myPhoto, context) {
    return Center(
        child: Container(
            width: min(heightScreen, widthScreen) / 3,
            height: min(heightScreen, widthScreen) / 4,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 4, color: Theme.of(context).scaffoldBackgroundColor),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 2,
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 10))
                ],
                image: myPhoto.isEmpty
                    ? const DecorationImage(
                        image: AssetImage("images/noPhoto.png"))
                    : DecorationImage(
                        image: NetworkImage(getImage(myPhoto, "PROFIL")),
                        fit: BoxFit.cover))));
  }

  static Drawer myDrawer(context, {Color? color}) {
    return Drawer(
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListView(shrinkWrap: true, primary: false, children: [
                  Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 10),
                                child: Text("Hi",
                                    style: GoogleFonts.donegalOne(
                                        color: Colors.indigoAccent,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold))),
                            Center(
                                child: Wrap(children: [
                              Text(currentUser!.fullName,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.laila(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold))
                            ]))
                          ])),
                  GestureDetector(
                      onTap: () {
                        var route = MaterialPageRoute(
                            builder: (context) => const ProfilPage());
                        Navigator.push(context, route);
                      },
                      child: circularPhoto(currentUser!.photo, context)),
                  const Divider(height: 30),
                  _drawerButton(
                      color: Colors.green.shade50,
                      icon: Icons.book_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        var route = PageRouteBuilder(
                            transitionDuration: const Duration(seconds: 1),
                            transitionsBuilder:
                                (context, animation, secAnimation, child) {
                              return myAnimation(child, animation);
                            },
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return const ListFormation();
                            });
                        Navigator.push(context, route);
                      },
                      text: "Liste des Formations"),
                  _drawerButton(
                      color: Colors.cyan.shade50,
                      icon: Icons.announcement_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        var route = PageRouteBuilder(
                            transitionDuration: const Duration(seconds: 1),
                            transitionsBuilder:
                                (context, animation, secAnimation, child) {
                              return myAnimation(child, animation);
                            },
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return const ListAnnnonces();
                            });
                        Navigator.push(context, route);
                      },
                      text: "Liste des Annonces"),
                  Visibility(
                      visible: currentUser!.isAdmin, child: const Divider()),
                  Visibility(
                      visible: currentUser!.isAdmin,
                      child: _drawerButton(
                          color: Colors.indigo.shade50,
                          icon: Icons.admin_panel_settings_sharp,
                          onTap: () {
                            Navigator.pop(context);
                            var route = PageRouteBuilder(
                                transitionDuration: const Duration(seconds: 1),
                                transitionsBuilder:
                                    (context, animation, secAnimation, child) {
                                  return myAnimation(child, animation);
                                },
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  return const AdminList();
                                });
                            Navigator.push(context, route);
                          },
                          text: "Formateurs")),
                  Visibility(visible: !production, child: const Divider()),
                  _drawerButton(
                      color: Colors.amber.shade50,
                      icon: Icons.perm_device_information_outlined,
                      onTap: () {
                        Navigator.pop(context);
                        var route = PageRouteBuilder(
                            transitionDuration: const Duration(seconds: 1),
                            transitionsBuilder:
                                (context, animation, secAnimation, child) {
                              return myAnimation(child, animation);
                            },
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return const ProfilPage();
                            });
                        Navigator.push(context, route);
                      },
                      text: "Mon Profil"),
                  Visibility(
                      visible: currentUser!.isAdmin,
                      child: _drawerButton(
                          color: Colors.blue.shade50,
                          icon: Icons.settings,
                          onTap: () {
                            Navigator.pop(context);
                            reparerBDD();
                          },
                          text: "Réparer La BDD")),
                  Visibility(
                      visible: !production,
                      child: _drawerButton(
                          color: Colors.blue.shade50,
                          icon: Icons.settings,
                          onTap: () {
                            Navigator.pop(context);
                            var route = PageRouteBuilder(
                                transitionDuration: const Duration(seconds: 1),
                                transitionsBuilder:
                                    (context, animation, secAnimation, child) {
                                  return myAnimation(child, animation);
                                },
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  return const SettingPage();
                                });
                            Navigator.push(context, route);
                          },
                          text: "Paramêtres")),
                  _drawerButton(
                      color: Colors.red.shade50,
                      icon: Icons.logout,
                      onTap: () {
                        _logout(context);
                      },
                      text: "Déconnecter"),
                  const SizedBox(height: 20)
                ]))));
  }

  static makeExternalRequest(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int yy = currentDate.year - birthDate.year;
    int mm = currentDate.month - birthDate.month;
    int dd = currentDate.day - birthDate.day;
    if (mm < 0) {
      yy--;
      mm += 12;
    }
    if (dd < 0) {
      mm--;
      dd += 30;
    }
    String age = "";
    if (yy > 1) {
      age = "$yy an(s)";
    } else {
      mm = yy * 12 + mm;
      if (mm > 0) {
        age = "$mm mois";
      } else if (dd > 0) {
        age = "$dd jours";
      }
    }
    return age;
  }

  static String printDate(DateTime? date) {
    DateTime currentDate = DateTime.now();
    int yy = currentDate.year - date!.year;
    String str = "";
    if (yy > 0) {
      str = DateFormat('yyyy MMM dd').format(date);
    } else {
      int mm = currentDate.month - date.month;
      int dd = currentDate.day - date.day;
      if (mm < 0) {
        yy--;
        mm += 12;
      }
      if (dd < 0) {
        mm--;
        dd += 30;
      }
      if (dd > 6) {
        str = DateFormat('dd MMM ').format(date);
      } else {
        switch (dd) {
          case 0:
            str = "Aujourd'hui";
            break;
          case 1:
            str = "Hier";
            break;
          default:
            str = DateFormat('EEE').format(date);
            break;
        }
      }
    }
    return str;
  }

  static _logout(mContext) {
    String alert = '';
    (currentUser!.isAdmin ||
            currentUser!
                .isFormateur) // && GestGalleryImages.myImages.isNotEmpty)
        ? alert =
            '\n Attention tous les chargement des images et fichiers seront arrêter ....'
        : alert = '';
    AwesomeDialog(
            context: mContext,
            dialogType: DialogType.QUESTION,
            title: '',
            btnOkText: "Oui",
            btnCancelText: "Non",
            btnCancelOnPress: () {},
            btnOkOnPress: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('LastUser', "");
              //   prefs.setString('LastPass', "");
              currentUser = null;
              await _googleSignign.signOut();
              while (Navigator.of(mContext).canPop()) {
                Navigator.of(mContext).pop();
              }
              googleAcount = null;
              var route = PageRouteBuilder(
                  transitionDuration: const Duration(seconds: 1),
                  transitionsBuilder:
                      (context, animation, secAnimation, child) {
                    return myAnimation(child, animation);
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const LoginPage();
                  });
              Navigator.pushReplacement(mContext, route);
            },
            showCloseIcon: true,
            desc: 'Voulez-vous vraiment déconnecter ??' + alert)
        .show();
  }

  static Future<GoogleSignInAccount?> glogin() async {
    _googleSignign = GoogleSignIn();
    await _googleSignign.signOut();
    print("j'ai déconnécter ...");
    googleAcount = await _googleSignign.signIn();
    if (googleAcount != null) {
      print("connexion en cours avec le compte : " +
          googleAcount!.email +
          " ...");
    }
    return googleAcount;
  }

  static googleSignOut() async {
    _googleSignign = GoogleSignIn();
    await _googleSignign.signOut();
  }

  static myAnimation(child, animation) {
    var myAnimation =
        CurvedAnimation(parent: animation, curve: Curves.bounceInOut);
    return ScaleTransition(
        scale: myAnimation, alignment: Alignment.center, child: child);
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  static void reparerBDD() {
    String serverDir = getServerDirectory();
    var url = "$serverDir/REPARER_BDD.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {})
        .timeout(Duration(seconds: timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var result = response.body;
            if (result != "0") {
              showSnack(
                  msg: 'La base de données à été réparer ...',
                  color: Colors.green);
            } else {
              AwesomeDialog(
                      context: myContext,
                      dialogType: DialogType.ERROR,
                      showCloseIcon: true,
                      title: 'Erreur',
                      desc:
                          "Probleme lors de la réparation de la base de données !!!")
                  .show();
            }
          } else {
            AwesomeDialog(
                    context: myContext,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: 'Probleme de Connexion avec le serveur 5!!!')
                .show();
          }
        })
        .catchError((error) {
          print("erreur : $error");
          AwesomeDialog(
                  context: myContext,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme de Connexion avec le serveur 6!!!')
              .show();
        });
  }

  static double truncateToDecimalPlaces(double value, int fractionalDigits) =>
      (value * pow(10, fractionalDigits)).truncate() /
      pow(10, fractionalDigits);

  static getNotificationPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) => {
          if (!isAllowed)
            {
              showDialog(
                  context: myContext,
                  builder: (context) => AlertDialog(
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Ne pas Autoriser",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18))),
                            TextButton(
                                onPressed: () => AwesomeNotifications()
                                    .requestPermissionToSendNotifications()
                                    .then((_) => Navigator.of(context).pop()),
                                child: const Text("Autoriser",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)))
                          ],
                          title: const Text("Autoriser les notifications"),
                          content: const Text(
                              "Notre application souhaite vous envoyer des notifications")))
            }
        });
  }
}
