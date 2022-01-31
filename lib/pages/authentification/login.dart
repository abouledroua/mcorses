// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:mcorses/classes/data.dart';
import 'package:mcorses/classes/user.dart';
import 'package:mcorses/pages/fiches/fiche_profil.dart';
import 'package:mcorses/home_page.dart';
import 'package:mcorses/pages/settings.dart';
import 'package:mcorses/pages/widgets/privacy_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

String identif = "";
bool showPassword = false;
late TextEditingController controller;

class _LoginPageState extends State<LoginPage> {
  String? serverIP = "", userPref = "";
  String userName = "admin";
  bool reconnect = false;
  int typeAuth = 1;
  late double margin, maxHeight;

  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Row(children: const [
                      Icon(Icons.exit_to_app_sharp, color: Colors.red),
                      Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('Etes-vous sur ?'))
                    ]),
                    content: const Text(
                        "Voulez-vous vraiment quitter l'application ?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Non',
                              style: TextStyle(color: Colors.red))),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Oui',
                              style: TextStyle(color: Colors.green)))
                    ]))) ??
        false;
  }

  initData() {
    Data.currentUser = null;
    reconnect = false;
    Data.isLogged = false;
    Data.googleSignOut();
    Data.myContext = context;
    if (Data.production) {
      userName = "";
    }
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    print("i'm back to login");
    getSharedPrefs().then((_) {
      initData();
    });
    controller = TextEditingController();
    //initPlatformState();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    String? privacy = prefs.getString('Privacy') ?? "";
    if (privacy.isEmpty) {
      var route = PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
        return const PrivacyPolicy();
      });
      Navigator.pushReplacement(context, route);
    }
    serverIP = prefs.getString('ServerIp');
    var local = prefs.getString('LocalIP');
    var intenet = prefs.getString('InternetIP');
    var mode = prefs.getInt('NetworkMode');
    mode ??= 2;
    Data.setNetworkMode(mode);
    local ??= "192.168.1.152";
    intenet ??= "atlasschool.dz";
    serverIP ??= mode == 1 ? local : intenet;
    if (serverIP != "") Data.setServerIP(serverIP);
    if (local != "") Data.setLocalIP(local);
    if (intenet != "") Data.setInternetIP(intenet);
    print("serverIP=$serverIP");
    if (serverIP == "" && !Data.production) {
      var route = PageRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          transitionsBuilder: (context, animation, secAnimation, child) {
            return Data.myAnimation(child, animation);
          },
          pageBuilder: (context, animation, secondaryAnimation) {
            return const SettingPage();
          });
      Navigator.push(context, route);
    }
    userPref = prefs.getString('LastUser');
    //  passPref = prefs.getString('LastPass');
    print("userPref = $userPref");
    //  print("passPref = $passPref");
    if (userPref != null && userPref!.isNotEmpty) {
      setState(() {
        reconnect = true;
        userName = userPref!;
        // password = passPref!;
      });
      existUser(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("building ...");
    Data.setSizeScreen(context);
    return SafeArea(
        child: WillPopScope(
            onWillPop: _onWillPop,
            child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    appBar: AppBar(
                        leading: const Icon(Icons.vpn_key, color: Colors.white),
                        title: const Text("Athentification",
                            style: TextStyle(color: Colors.white)),
                        centerTitle: true,
                        actions: Data.production
                            ? null
                            : [
                                IconButton(
                                    icon: const FaIcon(FontAwesomeIcons.cogs,
                                        color: Colors.white),
                                    onPressed: () {
                                      var route = PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(seconds: 1),
                                          transitionsBuilder: (context,
                                              animation, secAnimation, child) {
                                            return Data.myAnimation(
                                                child, animation);
                                          },
                                          pageBuilder: (context, animation,
                                              secondaryAnimation) {
                                            return const SettingPage();
                                          });
                                      Navigator.push(context, route);
                                    })
                              ]),
                    body: bodyContent()))));
  }

  bodyContent() {
    margin = Data.heightScreen / 25;
    maxHeight = max(Data.heightScreen, Data.widthScreen);
    return SingleChildScrollView(
        child: Column(children: [
      Center(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset('images/ifms.png', fit: BoxFit.contain),
              margin: EdgeInsets.only(top: margin))),
      reconnect ? reConnectContent() : btnWidget(),
      // typeAuth == 1 ? userContent() : phoneContent(),
      Center(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset('images/village_medical.png',
                  fit: BoxFit.contain),
              margin: EdgeInsets.only(top: margin, bottom: margin)))
    ]));
  }

  btnWidget() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          margin: EdgeInsets.only(
              left: Data.widthScreen / 10,
              right: Data.widthScreen / 10,
              top: Data.heightScreen / 20,
              bottom: Data.heightScreen / 40),
          child: FloatingActionButton.extended(
              heroTag: "googleBtn",
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              onPressed: connectGoogle,
              icon:
                  Image.asset('images/google_logo.png', height: 32, width: 32),
              label: const Text("Connecter avec Google"))),
      Container(
          margin: EdgeInsets.only(
              left: Data.widthScreen / 10,
              right: Data.widthScreen / 10,
              top: Data.heightScreen / 20,
              bottom: Data.heightScreen / 40),
          child: FloatingActionButton.extended(
              heroTag: "connectBtn",
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              onPressed: connectIdentifiant,
              icon: const Icon(Icons.numbers),
              // Image.asset('images/connect.png', height: 32, width: 32),
              label: const Text("Connecter avec Identifiant")))
    ]);
  }

  connectIdentifiant() {
    identif = '';
    controller.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Connecter Avec un Identifiant"),
              content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.numbers, color: Colors.grey),
                      hintText: 'Entrer votre Identifiant')),
              actions: [
                TextButton(
                    onPressed: () {
                      identif = "";
                      Navigator.pop(context);
                    },
                    child: const Text("Annuler",
                        style: TextStyle(color: Colors.red))),
                Container(
                    decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: TextButton(
                        onPressed: () {
                          if (controller.text.replaceAll(' ', '').isNotEmpty) {
                            identif = controller.text;
                            Navigator.pop(context);
                            existUser(2);
                          }
                        },
                        child: const Text("Connect",
                            style: TextStyle(color: Colors.white))))
              ]);
        });
  }

  reConnectContent() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: Data.heightScreen - margin) / 6,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  color:
                      Data.darkColor[Random().nextInt(Data.darkColor.length)]),
              const SizedBox(width: 24),
              const Text("Connexion en cours ...",
                  style: TextStyle(fontSize: 18))
            ]));
  }

  userContent() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Center(
          child: Container(
              margin: EdgeInsets.only(
                  left: Data.widthScreen / 10,
                  right: Data.widthScreen / 10,
                  top: Data.heightScreen / 20,
                  bottom: Data.heightScreen / 40),
              child: FloatingActionButton.extended(
                  heroTag: "googleBtn",
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  onPressed: connectGoogle,
                  icon: Image.asset('images/google_logo.png',
                      height: 32, width: 32),
                  label: const Text("Connecter avec Google")))),
      const Spacer(),
      /*   Center(
          child: Container(
              margin: EdgeInsets.only(
                  right: Data.widthScreen / 10,
                  left: Data.widthScreen / 10,
                  bottom: Data.heightScreen / 20),
              child: FloatingActionButton.extended(
                  heroTag: "facebook_btn",
                  foregroundColor: Colors.blue.shade800,
                  backgroundColor: Colors.white,
                  onPressed: connectFacebook,
                  icon: Image.asset('images/facebook_logo.jpg',
                      height: 32, width: 32),
                  label: const Text("Connecter avec Facebook")))),
      Center(
          child: Container(
              margin: EdgeInsets.only(
                  right: Data.widthScreen / 10,
                  left: Data.widthScreen / 10,
                  bottom: Data.heightScreen / 20),
              child: FloatingActionButton.extended(
                  heroTag: "telBtn",
                  foregroundColor: Colors.green.shade800,
                  backgroundColor: Colors.white,
                  onPressed: toPhone,
                  icon: Image.asset('images/phone_logo.png',
                      height: 32, width: 32),
                  label: const Text("Connecter avec N° Téléphone")))),*/
      //Padding(padding: EdgeInsets.symmetric(horizontal: Data.widthScreen / 8),child: const Divider(color: Colors.black, thickness: 2)),
      //const SizedBox(height: 20),
      //adminBtn()
    ]);
  }

  adminBtn() {
    return Center(
        child: Container(
            margin: EdgeInsets.only(
                right: Data.widthScreen / 10,
                left: Data.widthScreen / 10,
                bottom: Data.heightScreen / 20),
            child: FloatingActionButton.extended(
                heroTag: "adminBTn",
                foregroundColor: Colors.blue.shade800,
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    typeAuth = 2;
                  });
                },
                icon: Image.asset('images/admin.jpg', height: 32, width: 32),
                label: Text("Administrateur",
                    style: GoogleFonts.laila(
                        fontWeight: FontWeight.bold, fontSize: 24)))));
  }

  toPhone() {
    /*  setState(() {
      typeAuth = 3;
    });*/
    Data.showSnack(msg: "En cours de développement ...", color: Colors.amber);
  }

  addGoogleUser(String email) async {
    setState(() {
      reconnect = true;
    });
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_USER_GOOGLE.php";
    print(url);
    var body = {};
    body['EMAIL'] = email;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: body).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        print("EXIST_USER=$responsebody");
        String id = "",
            name = "",
            phone = "",
            photo = "",
            email = "",
            adresse = "",
            fonction = "",
            facebook = "";
        int etat = 0, age = 0, admin = 0, formateur = 0, newUser = 0;
        for (var m in responsebody) {
          id = m['ID'];
          name = m['NAME'];
          photo = m['PHOTO'];
          admin = int.parse(m['ADMIN']);
          formateur = int.parse(m['FORMATEUR']);
          phone = m['PHONE'];
          email = m['EMAIL'];
          adresse = m['ADRESSE'];
          fonction = m['FONCTION'];
          facebook = m['FACEBOOK'];
          age = int.parse(m['AGE']);
          etat = int.parse(m['ETAT']);
          newUser = int.parse(m['NEW']);
        }
        if (id == "") {
          setState(() {
            reconnect = false;
          });
          AwesomeDialog(
                  width: min(Data.widthScreen, 400),
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Nom d' 'utilisateur ou mot de passe invalide !!!')
              .show();
        } else if (etat == 1) {
          print("Its Ok ----- Google Connected ----------------");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userPref = email;
          prefs.setString('LastUser', userPref!);
          print("Data.googleAcount!.photoUrl=${Data.googleAcount!.photoUrl}");
          User u = User(
              adresse: adresse,
              age: age,
              facebook: facebook,
              fonction: fonction,
              newUser: newUser,
              photo: newUser == 1 && Data.googleAcount!.photoUrl != null
                  ? Data.googleAcount!.photoUrl!
                  : photo,
              email: newUser == 1 ? Data.googleAcount!.email : email,
              fullName: newUser == 1 && Data.googleAcount!.displayName != null
                  ? Data.googleAcount!.displayName!
                  : name,
              phone: phone,
              etat: 1,
              idUser: int.parse(id),
              isAdmin: (admin == 2),
              isFormateur: (formateur == 2));
          Data.setCurrentUser(u);
          if (newUser == 1) {
            var route =
                MaterialPageRoute(builder: (context) => const ProfilPage());
            Navigator.push(context, route).then((value) {
              initData();
              prefs.setString('LastUser', "");
              setState(() {});
            });
          } else {
            openHomePage();
          }
        } else {
          setState(() {
            reconnect = false;
          });
          print("etat = $etat");
          AwesomeDialog(
                  width: min(Data.widthScreen, 400),
                  context: context,
                  dialogType: DialogType.WARNING,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc:
                      "Utilisateur inactif !!! \nVeuillez contacter l'administration ...")
              .show();
        }
      } else {
        setState(() {
          reconnect = false;
        });
        AwesomeDialog(
                context: context,
                dialogType: DialogType.ERROR,
                showCloseIcon: true,
                title: 'Erreur',
                desc: 'Probleme de Connexion avec le serveur !!!')
            .show();
      }
    }).catchError((error) {
      print("erreur : $error");
      setState(() {
        reconnect = false;
      });
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: 'Erreur',
              desc: 'Probleme de Connexion avec le serveur !!!')
          .show();
    });
  }

  connectGoogle() {
    typeAuth = 1;
    setState(() {
      reconnect = true;
    });
    Data.glogin().then((googleAcount) {
      if (googleAcount != null) {
        print("Google Account : displayName=${googleAcount.displayName}");
        print("Google Account : email=${googleAcount.email}");
        print("Google Account : id=${googleAcount.id}");
        print("Google Account : photoUrl=${googleAcount.photoUrl}");
        print("Google Account : serverAuthCode=${googleAcount.serverAuthCode}");
        addGoogleUser(googleAcount.email);
      } else {
        setState(() {
          reconnect = false;
        });
      }
    }).onError((error, stackTrace) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: 'Erreur',
              desc: 'Erreur lors de la connexion !!!')
          .show();
      print(" erreur : $error");
      setState(() {
        reconnect = false;
      });
    });
  }

  connectFacebook() {
    Data.showSnack(msg: "En cours de développement ...", color: Colors.amber);
  }

  connectPhone() {
    Data.showSnack(msg: "En cours de développement ...", color: Colors.amber);
  }

  existUser(int type) async {
    setState(() {
      reconnect = true;
    });
    Data.currentUser = null;
    bool err = true;
    serverIP = Data.getServerIP();
    if (serverIP != "") {
      String serverDir = Data.getServerDirectory();
      final String url = "$serverDir/EXIST_USER.php";
      print(url);
      var body = {};
      if (type == 1) {
        body['USERNAME'] = userName;
      } else {
        body['IDENTIF'] = identif;
      }
      Uri myUri = Uri.parse(url);
      http.post(myUri, body: body).then((response) async {
        if (response.statusCode == 200) {
          var responsebody = jsonDecode(response.body);
          print("EXIST_USER=$responsebody");
          String id = "",
              name = "",
              phone = "",
              photo = "",
              email = "",
              adresse = "",
              fonction = "",
              facebook = "";
          int etat = 0, admin = 0, formateur = 0, age = 0, newUser = 0;
          for (var m in responsebody) {
            id = m['ID_USER'];
            name = m['NAME'];
            photo = m['PHOTO'];
            admin = int.parse(m['ADMIN']);
            formateur = int.parse(m['FORMATEUR']);
            phone = m['PHONE'];
            email = m['EMAIL'];
            userName = m['USERNAME'];
            adresse = m['ADRESSE'];
            fonction = m['FONCTION'];
            facebook = m['FACEBOOK'];
            age = int.parse(m['AGE']);
            newUser = int.parse(m['NEW']);
            etat = int.parse(m['ETAT']);
          }
          if (id == "") {
            setState(() {
              reconnect = false;
            });
            AwesomeDialog(
                    width: min(Data.widthScreen, 400),
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: 'Nom d' 'utilisateur ou mot de passe invalide !!!')
                .show();
          } else if (etat == 1) {
            print("Its Ok ----- Connected ----------------");
            //      if (isSwitched) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            userPref = userName;
            //        passPref = password;
            prefs.setString('LastUser', userPref!);
            //     prefs.setString('LastPass', passPref!);
            //       }
            User u = User(
                adresse: adresse,
                age: age,
                fonction: fonction,
                facebook: facebook,
                newUser: newUser,
                photo: photo,
                email: email,
                fullName: name,
                phone: phone,
                etat: 1,
                idUser: int.parse(id),
                isFormateur: (formateur == 2),
                isAdmin: (admin == 2));
            Data.setCurrentUser(u);
            //Data.setUserKey();
            err = false;
            if (newUser == 1) {
              var route =
                  MaterialPageRoute(builder: (context) => const ProfilPage());
              Navigator.push(context, route);
            } else {
              openHomePage();
            }
          } else {
            setState(() {
              reconnect = false;
            });
            print("etat = $etat");
            AwesomeDialog(
                    width: min(Data.widthScreen, 400),
                    context: context,
                    dialogType: DialogType.WARNING,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc:
                        "Utilisateur inactif !!! \nVeuillez contacter l'administration ...")
                .show();
          }
        } else {
          setState(() {
            reconnect = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme lors de la connexion avec le serveur !!!')
              .show();
        }
      }).catchError((error) {
        print("erreur : $error");
        setState(() {
          reconnect = false;
        });
        print("error : ${e.toString()}");
        AwesomeDialog(
                context: context,
                dialogType: DialogType.ERROR,
                showCloseIcon: true,
                title: 'Erreur',
                desc: 'Probleme de Connexion avec le serveur !!!')
            .show();
      });
    } else {
      setState(() {
        reconnect = false;
      });
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: 'Erreur',
              desc:
                  'Adresse de serveur introuvable \n Configuer les paramêtres !!!')
          .show();
    }
    if (err) {
      setState(() {});
    }
  }

  openHomePage() {
    var route = MaterialPageRoute(builder: (context) => const HomePage());
    Navigator.pushReplacement(context, route);
  }
}
