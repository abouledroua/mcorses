// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcorses/classes/data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mcorses/classes/gest_files.dart';
import 'package:mcorses/classes/mycours.dart';
import 'package:path/path.dart' as p;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class FicheFormation extends StatefulWidget {
  final int id;
  const FicheFormation({Key? key, required this.id}) : super(key: key);

  @override
  _FicheFormationState createState() => _FicheFormationState();
}

class _FicheFormationState extends State<FicheFormation> {
  String myPhoto = "", titre = "", details = "";
  late int idFormation, nbCourses = 0;
  TextEditingController txtTitre = TextEditingController(text: "");
  TextEditingController txtDetails = TextEditingController(text: "");
  TextEditingController txtDes = TextEditingController(text: "");
  bool loading = false,
      loadingCours = false,
      valider = false,
      _existFormation = false,
      selectPhoto = false,
      _valTitre = false;
  List<MyCours> myCourses = [];
  List<int> deletedCourses = [];

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    idFormation = widget.id;
    nbCourses = 0;
    if (idFormation == 0) {
      setState(() {
        loading = false;
      });
    } else {
      getFormationInfo();
      getFormationCours();
    }
    super.initState();
  }

  getPhoto(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(source: source);
    if (image == null) return;
    setState(() {
      myPhoto = image.path;
      selectPhoto = true;
    });
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
                  ? null
                  : selectPhoto
                      ? DecorationImage(
                          image: FileImage(File(myPhoto)), fit: BoxFit.cover)
                      : DecorationImage(
                          image:
                              NetworkImage(Data.getImage(myPhoto, "FORMATION")),
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

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                drawer: Data.myDrawer(context),
                appBar: AppBar(
                    backgroundColor: Colors.green,
                    centerTitle: true,
                    title: const Text("Fiche Formation"),
                    leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.white))),
                body: bodyContent())));
  }

  bodyContent() {
    return loading
        ? Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(
                        color: Data.darkColor[
                            Random().nextInt(Data.darkColor.length)])),
                const Text("Chargement en cours ...")
              ]))
        : Padding(
            padding: EdgeInsets.all(Data.widthScreen / 30),
            child: ListView(primary: false, shrinkWrap: true, children: [
              circularPhoto(),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  child: TextField(
                      enabled: !valider,
                      controller: txtTitre,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                          errorText: _valTitre
                              ? 'Champs Obligatoire'
                              : _existFormation
                                  ? 'Formation déjà Existante'
                                  : null,
                          prefixIcon: const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.title, color: Colors.black)),
                          contentPadding: const EdgeInsets.only(bottom: 3),
                          labelText: "Titre",
                          labelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          hintText: "Titre de la formation",
                          hintStyle:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          floatingLabelBehavior:
                              FloatingLabelBehavior.always))),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 30),
                  child: TextField(
                      enabled: !valider,
                      maxLines: null,
                      controller: txtDetails,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: const InputDecoration(
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.subject, color: Colors.black)),
                          contentPadding: EdgeInsets.only(bottom: 6, top: 6),
                          labelText: "Détails",
                          labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          hintText: "Détails sur la formation",
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                          floatingLabelBehavior:
                              FloatingLabelBehavior.always))),
              const Divider(),
              Stack(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.picture_as_pdf),
                  const SizedBox(width: 10),
                  Text("Cours ( ${myCourses.length} )",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.laila(
                          decoration: TextDecoration.underline,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip)
                ]),
                Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                        onTap: valider
                            ? null
                            : () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                      'pdf',
                                      //       'ppt',
                                      //       'pptx',
                                      'mp4',
                                      'mp3'
                                    ]);
                                if (result != null) {
                                  String path = result.files.single.path!;
                                  if (existCours(path)) {
                                    Data.showSnack(
                                        msg: "Fichier déjà sélectionné !!!!",
                                        color: Colors.red);
                                  } else {
                                    int i = myCourses.length;
                                    txtDes.text =
                                        p.basenameWithoutExtension(path);
                                    modifDesCours(i);
                                    MyCours c = MyCours(
                                        idCours: 0,
                                        extension: p.extension(path),
                                        base64Image: base64Encode(
                                            File(path).readAsBytesSync()),
                                        idFormation: 0,
                                        designation: txtDes.text,
                                        path: path);
                                    setState(() {
                                      myCourses.add(c);
                                    });
                                  }
                                }
                              },
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.green),
                            child: const Icon(Icons.add, color: Colors.white))))
              ]),
              docSpace(),
              Container(
                  margin: EdgeInsets.symmetric(vertical: Data.widthScreen / 40),
                  child: valider
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 1),
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
                                              fontSize: 16,
                                              color: Colors.black)))),
                              Container(
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
                                              color: Colors.white))))
                            ]))
            ]));
  }

  modifDesCours(int i) {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Center(
                    child: FittedBox(
                        child: Text("Titre du cours",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: GoogleFonts.laila(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 26)))),
                const SizedBox(height: 15),
                TextField(
                    onChanged: (value) => setState(() {
                          myCourses[i].designation = value;
                        }),
                    controller: txtDes,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    decoration: const InputDecoration(
                        prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.title, color: Colors.black)),
                        contentPadding: EdgeInsets.only(bottom: 3),
                        labelText: "",
                        labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        hintText: "Titre du cours",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        floatingLabelBehavior: FloatingLabelBehavior.always)),
                const SizedBox(height: 5),
                ElevatedButton(
                    child: const Text('Valider'),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                const SizedBox(height: 5)
              ]));
        });
  }

  bool existCours(String paths) {
    for (var item in myCourses) {
      if (item.path == paths) {
        return true;
      }
    }
    return false;
  }

  docSpace() {
    return loadingCours
        ? Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(
                        color: Data.darkColor[
                            Random().nextInt(Data.darkColor.length)])),
                const Text("Chargement en cours ...")
              ]))
        : myCourses.isEmpty
            ? const Center(
                child: Text("Pas de cours",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)))
            : ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: myCourses.length,
                itemBuilder: (context, i) => ListTile(
                    title: Text(myCourses[i].designation.isEmpty
                        ? p.basename(myCourses[i].path)
                        : myCourses[i].designation),
                    leading: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                            p.extension(myCourses[i].path).toUpperCase() ==
                                    ".PDF"
                                ? "images/pdf.png"
                                : p
                                            .extension(myCourses[i].path)
                                            .toUpperCase() ==
                                        ".MP4"
                                    ? "images/mp4.png"
                                    : p
                                                .extension(myCourses[i].path)
                                                .toUpperCase() ==
                                            ".MP3"
                                        ? "images/audio.jpg"
                                        : p
                                                        .extension(
                                                            myCourses[i].path)
                                                        .toUpperCase() ==
                                                    ".PPT" ||
                                                p
                                                        .extension(
                                                            myCourses[i].path)
                                                        .toUpperCase() ==
                                                    ".PPTX"
                                            ? "images/power.png"
                                            : "images/doc.png",
                            fit: BoxFit.contain)),
                    contentPadding: const EdgeInsets.all(0),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(
                          onTap: valider
                              ? null
                              : () {
                                  txtDes.text = myCourses[i].designation;
                                  modifDesCours(i);
                                },
                          child: const Icon(Icons.edit, color: Colors.blue)),
                      InkWell(
                          onTap: valider
                              ? null
                              : () {
                                  AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.QUESTION,
                                          showCloseIcon: true,
                                          btnCancelText: "Non",
                                          btnOkText: "Oui",
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () {
                                            if (i < nbCourses) {
                                              deletedCourses
                                                  .add(myCourses[i].idCours);
                                              nbCourses--;
                                            }
                                            setState(() {
                                              myCourses.removeAt(i);
                                            });
                                          },
                                          desc:
                                              'Voulez-vous vraiment supprimer ce cours ?')
                                      .show();
                                },
                          child: const Icon(Icons.delete, color: Colors.red))
                    ])));
  }

  updateFormation() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_FORMATION.php";
    print(url);
    var body = {};
    body['ID_FORMATION'] = idFormation.toString();
    body['TITRE'] = txtTitre.text;
    body['DETAILS'] = txtDetails.text;
    body['ID_USER'] = Data.currentUser!.idUser.toString();
    body['IMAGE'] = selectPhoto ? "1" : "0";
    if (selectPhoto) {
      body['EXT'] = p.extension(myPhoto);
      body['DATA'] = base64Encode(File(myPhoto).readAsBytesSync());
    }
    for (var i = 0; i < nbCourses; i++) {
      body['ID_' + i.toString()] = myCourses[i].idCours.toString();
      body['DES_' + i.toString()] = myCourses[i].designation;
    }
    body['NB_COURS'] = nbCourses.toString();
    for (var i = 0; i < deletedCourses.length; i++) {
      body['DEL_' + i.toString()] = deletedCourses[i].toString();
    }
    body['NB_DELETED'] = deletedCourses.length.toString();
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: body).then((response) async {
      if (response.statusCode == 200) {
        var result = response.body;
        print("result=$result");
        if (result != "0") {
          loadFiles();
          //Data.showSnack('Information mis à jours ...', Colors.green);
          Navigator.pop(context);
        } else {
          setState(() {
            valider = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme lors de la mise a jour des informations !!!')
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

  existFormation() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/EXIST_FORMATION.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "TITRE": txtTitre.text,
          "ID_FORMATION": idFormation.toString(),
          "ID_USER": Data.currentUser!.idUser.toString()
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            switch (responsebody) {
              case 0:
                print('im here');
                if (idFormation == 0) {
                  insertFormation();
                } else {
                  updateFormation();
                }
                break;
              case 1:
                setState(() {
                  _existFormation = true;
                  valider = false;
                });
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: "Nom d'Utilisateur existe déjà !!!");
                break;
              case -1:
                setState(() {
                  valider = false;
                });
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: "Erreur Serveur !!!");
                break;
              default:
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
        })
        .catchError((error) {
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

  insertFormation() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_FORMATION.php";
    print(url);
    var body = {};
    body['TITRE'] = txtTitre.text;
    body['DETAILS'] = txtDetails.text;
    body['ID_USER'] = Data.currentUser!.idUser.toString();
    body['IMAGE'] = selectPhoto ? "1" : "0";
    if (selectPhoto) {
      body['EXT'] = p.extension(myPhoto);
      body['DATA'] = base64Encode(File(myPhoto).readAsBytesSync());
    }

    Uri myUri = Uri.parse(url);
    http.post(myUri, body: body).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("responsebody=${response.body}");
        if (responsebody != "0") {
          idFormation = int.parse(responsebody);
          loadFiles();
          // Data.showSnack('Formation ajoutée  ...', Colors.green);
          Navigator.pop(context);
        } else {
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: "Probleme lors de l'ajout !!!")
              .show();
        }
      } else {
        AwesomeDialog(
                context: context,
                dialogType: DialogType.ERROR,
                showCloseIcon: true,
                title: 'Erreur',
                desc: 'Probleme de Connexion avec le serveur 1 !!!')
            .show();
      }
      setState(() {
        valider = false;
      });
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

  loadFiles() {
    late MyCours e;
    //   bool exist = false;
    for (var i = nbCourses; i < myCourses.length; i++) {
      var item = myCourses[i];
      e = MyCours(
          idCours: 0,
          base64Image: item.base64Image,
          designation: item.designation,
          extension: item.extension,
          idFormation: idFormation,
          path: item.path);
      GestFiles.myFiles.add(e);
      // exist = true;
    }
    // if (exist) {
    // Data.showSnack("En cours de chargement des images ...", Colors.blueGrey);
    //  }
  }

  String getFileName(String chemin, File updfile) {
    String ext = updfile.path.split('.').last;
    String bddFileName = idFormation.toString() + "." + ext;
    String fileName = chemin + "\\" + bddFileName;
    return fileName;
  }

  verifierChamps() {
    txtTitre.text.replaceAll("'", "");
    txtDetails.text.replaceAll("'", "");
    setState(() {
      _existFormation = false;
      _valTitre = txtTitre.text.isEmpty;
    });
  }

  saveParent() {
    setState(() {
      valider = true;
    });
    verifierChamps();

    if (_valTitre) {
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
      existFormation();
    }
  }

  getFormationInfo() async {
    setState(() {
      loading = true;
    });
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_INFO_FORMATIONS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "ID_FORMATION": idFormation.toString(),
          "ID_USER": Data.currentUser!.idUser.toString()
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            for (var m in responsebody) {
              txtTitre.text = m['TITRE'];
              txtDetails.text = m['DETAILS'];
              myPhoto = m['IMAGE'];
            }
            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              loading = false;
            });
            AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: 'Probleme de Connexion avec le serveur !!!')
                .show();
          }
        })
        .catchError((error) {
          print("erreur : $error");
          setState(() {
            loading = false;
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

  getFormationCours() async {
    setState(() {
      loadingCours = true;
    });
    nbCourses = 0;
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_COURSES_FORMATIONS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "ID_FORMATION": idFormation.toString(),
          "ID_USER": Data.currentUser!.idUser.toString()
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            late MyCours c;
            for (var m in responsebody) {
              c = MyCours(
                  base64Image: "",
                  designation: m['DESIGNATION'],
                  extension: "",
                  idCours: int.parse(m['ID_COURS']),
                  idFormation: idFormation,
                  path: m['FILE']);
              myCourses.add(c);
            }
            nbCourses = myCourses.length;
          } else {
            AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: 'Probleme de Connexion avec le serveur !!!')
                .show();
          }
          setState(() {
            loadingCours = false;
          });
        })
        .catchError((error) {
          print("erreur : $error");
          setState(() {
            loadingCours = false;
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
}
