// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:mcorses/classes/data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:mcorses/home_page.dart';
import 'package:mcorses/pages/widgets/privacy_policy.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:mcorses/classes/user.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String nom = "", myPhoto = "", prenom = "", email = "54";
  late int idParent, idUser;
  TextEditingController txtNom = TextEditingController(text: "");
  TextEditingController txtAge = TextEditingController(text: "");
  TextEditingController txtFonction = TextEditingController(text: "");
  TextEditingController txtAdresse = TextEditingController(text: "");
  TextEditingController txtFacebook = TextEditingController(text: "");
  TextEditingController txtTel = TextEditingController(text: "");
  TextEditingController txtEmail = TextEditingController(text: "");
  bool valider = false,
      downImage = false,
      selectPhoto = false,
      _valNom = false,
      _valAge = false,
      _valFonction = false,
      _valTelEmail = false,
      _valAdresse = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    idUser = 0;
    txtEmail.text = Data.currentUser!.email;
    txtNom.text = Data.currentUser!.fullName;
    txtAdresse.text = Data.currentUser!.adresse;
    txtAge.text =
        Data.currentUser!.age == 0 ? '' : Data.currentUser!.age.toString();
    txtFacebook.text = Data.currentUser!.facebook;
    txtFonction.text = Data.currentUser!.fonction;
    txtTel.text = Data.currentUser!.phone;
    myPhoto = Data.currentUser!.photo;
    if (myPhoto.contains("http")) {
      _asyncMethod();
    }
    super.initState();
  }

  Future<bool> _onWillPop() async {
    if (!Data.isLogged) {
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
                          "Voulez-vous vraiment annuler votre inscription ?"),
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
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: Colors.indigo,
                  centerTitle: true,
                  title: const Text("Mon Profil"),
                  leading: IconButton(
                      onPressed: Navigator.canPop(context)
                          ? () {
                              if (!Data.isLogged) {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.QUESTION,
                                        showCloseIcon: true,
                                        title: 'Confirmation',
                                        btnOkText: "Oui",
                                        btnCancelText: "Non",
                                        btnOkOnPress: () {
                                          Navigator.pop(context, false);
                                        },
                                        btnCancelOnPress: () {},
                                        desc:
                                            'Voulez-vous vraiment annuler votre inscription ?')
                                    .show();
                              } else {
                                Navigator.pop(context, false);
                              }
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back, color: Colors.white))),
              body: bodyContent())),
    ));
  }

  _asyncMethod() async {
    setState(() {
      downImage = true;
    });
    var url = Data.currentUser!.photo; // <-- 1
    Uri myUri = Uri.parse(url);
    var response = await http.get(myUri); // <--2
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/images";
    var filePathAndName = documentDirectory.path + '/images/pic.jpg';
    await Directory(firstPath).create(recursive: true); // <-- 1
    File file2 = File(filePathAndName); // <-- 2
    file2.writeAsBytesSync(response.bodyBytes); // <-- 3
    selectPhoto = true;
    Data.currentUser!.photo = file2.path;
    setState(() {
      myPhoto = file2.path;
      downImage = false;
    });
  }

  insertProfil() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_PROFILE.php";
    print(url);
    var body = {};
    body['NOM'] = txtNom.text.toUpperCase();
    body['ID_USER'] = Data.currentUser!.idUser.toString();
    body['EMAIL'] = txtEmail.text;
    body['TEL'] = txtTel.text;
    body['FONCTION'] = txtFonction.text;
    body['ADRESSE'] = txtAdresse.text;
    body['FACEBOOK'] = txtFacebook.text;
    body['AGE'] = txtAge.text;

    body['IMAGE'] = selectPhoto ? "1" : "0";
    if (selectPhoto) {
      body['EXT'] = p.extension(myPhoto);
      body['DATA'] = base64Encode(File(myPhoto).readAsBytesSync());
    }
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: body).then((response) async {
      if (response.statusCode == 200) {
        var result = response.body;
        print("result=$result");
        if (result != "") {
          validateData(result);
        } else {
          setState(() {
            valider = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: "Probleme lors de l'ajout !!!")
              .show();
        }
      } else {
        setState(() {
          valider = false;
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
        valider = false;
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

  updateProfil() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_PROFILE.php";
    print(url);
    var body = {};
    body['NOM'] = txtNom.text.toUpperCase();
    body['ID_USER'] = Data.currentUser!.idUser.toString();
    body['EMAIL'] = txtEmail.text;
    body['TEL'] = txtTel.text;
    body['FONCTION'] = txtFonction.text;
    body['ADRESSE'] = txtAdresse.text;
    body['FACEBOOK'] = txtFacebook.text;
    body['AGE'] = txtAge.text;

    body['IMAGE'] = selectPhoto ? "1" : "0";
    if (selectPhoto) {
      body['EXT'] = p.extension(myPhoto);
      body['DATA'] = base64Encode(File(myPhoto).readAsBytesSync());
    }
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: body).then((response) async {
      if (response.statusCode == 200) {
        var result = response.body;
        print("result=$result");
        if (result != "") {
          validateData(result);
        } else {
          setState(() {
            valider = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: "Probleme lors de l'ajout !!!")
              .show();
        }
      } else {
        setState(() {
          valider = false;
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
        valider = false;
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

  validateData(String result) {
    String photo = selectPhoto
        ? result.substring(0, result.length - 1)
        : Data.currentUser!.photo;
    Data.currentUser = User(
        adresse: txtAdresse.text,
        age: int.parse(txtAge.text),
        email: txtEmail.text,
        etat: Data.currentUser!.etat,
        facebook: txtFacebook.text,
        fonction: txtFonction.text,
        fullName: txtNom.text,
        idUser: Data.currentUser!.idUser,
        isAdmin: Data.currentUser!.isAdmin,
        isFormateur: Data.currentUser!.isFormateur,
        newUser: 0,
        phone: txtTel.text,
        photo: photo);
    Data.showSnack('Profil mis à jours ...', Colors.green);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false);
  }

  verifierChamps() {
    txtNom.text.replaceAll("'", "");
    txtFonction.text.replaceAll("'", "");
    txtFacebook.text.replaceAll("'", "");
    txtAdresse.text.replaceAll("'", "");
    setState(() {
      _valTelEmail = txtTel.text.isEmpty && txtEmail.text.isEmpty;
      _valFonction = txtFonction.text.isEmpty;
      _valAdresse = txtAdresse.text.isEmpty;
      _valNom = txtNom.text.isEmpty;
      _valAge = txtAge.text.isEmpty;
    });
  }

  saveParent() {
    setState(() {
      valider = true;
    });
    verifierChamps();

    if (_valNom || _valAge || _valTelEmail || _valFonction || _valAdresse) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: 'Erreur',
              desc: 'Veuillez remplir tous les champs obligatoire !!!')
          .show();
      setState(() {
        valider = false;
      });
    } else {
      if (Data.currentUser!.newUser == 1) {
        var route = PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
          return const PrivacyPolicy();
        });
        Navigator.push(context, route).then((value) {
          if (value) {
            insertProfil();
          } else {
            AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: "Vous devez accepter les regles d'utilisations !!!")
                .show();
          }
        });
      } else {
        updateProfil();
      }
    }
  }

  Widget circularPhoto() {
    return Center(
        child: Stack(children: [
      Container(
          width: min(Data.heightScreen, Data.widthScreen) / 3,
          height: min(Data.heightScreen, Data.widthScreen) / 3,
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
                  : selectPhoto
                      ? DecorationImage(
                          image: FileImage(File(myPhoto)), fit: BoxFit.cover)
                      : myPhoto.contains("http")
                          ? DecorationImage(
                              image: NetworkImage(myPhoto), fit: BoxFit.cover)
                          : DecorationImage(
                              image: NetworkImage(
                                  Data.getImage(myPhoto, "PROFIL")),
                              fit: BoxFit.cover))),
      Positioned(
          bottom: 0,
          right: 0,
          child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 4,
                      color: Theme.of(context).scaffoldBackgroundColor),
                  color: Colors.green),
              child: GestureDetector(
                  onTap: valider
                      ? null
                      : () {
                          showModalBottomSheet(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              context: context,
                              builder: (context) {
                                return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      getPhoto(
                                                          ImageSource.gallery);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child:
                                                        Column(children: const [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                              Icons.photo_album,
                                                              size: 30)),
                                                      Text("Gallery",
                                                          style: TextStyle(
                                                              fontSize: 20))
                                                    ])),
                                                GestureDetector(
                                                    onTap: () {
                                                      getPhoto(
                                                          ImageSource.camera);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child:
                                                        Column(children: const [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                              Icons.camera,
                                                              size: 30)),
                                                      Text("Camera",
                                                          style: TextStyle(
                                                              fontSize: 20))
                                                    ]))
                                              ]))
                                    ]);
                              });
                        },
                  child: const Icon(Icons.edit, color: Colors.white))))
    ]));
  }

  getPhoto(source) async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(source: source);
    if (image == null) return;
    setState(() {
      myPhoto = image.path;
      selectPhoto = true;
    });
  }

  bodyContent() {
    return Padding(
        padding: EdgeInsets.all(Data.widthScreen / 30),
        child: ListView(primary: false, shrinkWrap: true, children: [
          circularPhoto(),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: TextField(
                  enabled: !valider,
                  controller: txtNom,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                      errorText: _valNom ? 'Champs Obligatoire' : null,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.supervised_user_circle_outlined,
                              color: Colors.black)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Nom",
                      labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "Nom",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
              child: TextField(
                  enabled: !valider,
                  controller: txtFonction,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                      errorText: _valFonction ? 'Champs Obligatoire' : null,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.forward_outlined,
                              color: Colors.black)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Fonction",
                      labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "Fonction",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
              child: TextField(
                  enabled: !valider,
                  controller: txtTel,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                      errorText: _valTelEmail ? 'Champs Obligatoire' : null,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.phone, color: Colors.black)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Telephone",
                      labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "Telephone",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
              child: TextField(
                  enabled: false,
                  controller: txtEmail,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                      errorText: _valTelEmail ? 'Champs Obligatoire' : null,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.email, color: Colors.black)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Email",
                      labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "Email",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
              child: TextField(
                  enabled: !valider,
                  controller: txtFacebook,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: const InputDecoration(
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.forward_outlined,
                              color: Colors.black)),
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: "Facebook",
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "Facebook",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
              child: Row(children: [
                Expanded(
                    child: TextField(
                        enabled: !valider,
                        controller: txtAge,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        decoration: InputDecoration(
                            errorText: _valAge ? 'Champs Obligatoire' : null,
                            prefixIcon: const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.date_range_outlined,
                                    color: Colors.black)),
                            contentPadding: const EdgeInsets.only(bottom: 3),
                            labelText: "Age",
                            labelStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            hintText: "Age",
                            hintStyle: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always))),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("An(s)"))
              ])),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
              child: TextField(
                  enabled: !valider,
                  controller: txtAdresse,
                  textInputAction: TextInputAction.newline,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                      errorText: _valAdresse ? 'Champs Obligatoire' : null,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.assistant_direction_sharp,
                              color: Colors.black)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Adresse",
                      labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "Adresse",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Container(
              margin: EdgeInsets.symmetric(vertical: Data.widthScreen / 40),
              child: valider
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      CircularProgressIndicator(
                          color: Data.darkColor[
                              Random().nextInt(Data.darkColor.length)]),
                      const SizedBox(width: 20),
                      const Text("validation en cours ...")
                    ])
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: TextButton(
                                  onPressed: () {
                                    AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.QUESTION,
                                            showCloseIcon: true,
                                            btnCancelText: "Non",
                                            btnOkText: "Oui",
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: () {
                                              setState(() {
                                                Navigator.pop(context);
                                              });
                                            },
                                            desc:
                                                'Voulez-vous vraiment annuler tous les changements !!!')
                                        .show();
                                  },
                                  child: const Text("Annuler",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black)))),
                          Visibility(
                              visible: !downImage,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: TextButton(
                                      onPressed: saveParent,
                                      child: const Text("Valider",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)))))
                        ]))
        ]));
  }
}
