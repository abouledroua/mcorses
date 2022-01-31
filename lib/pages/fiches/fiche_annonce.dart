// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcorses/classes/data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:mcorses/classes/gest_files.dart';
import 'package:mcorses/classes/myphoto.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FicheAnnonce extends StatefulWidget {
  final int id;
  const FicheAnnonce({Key? key, required this.id}) : super(key: key);

  @override
  _FicheAnnonceState createState() => _FicheAnnonceState();
}

class _FicheAnnonceState extends State<FicheAnnonce> {
  String designation = "";
  late int idAnnonce, nbImages = 0;
  TextEditingController txtDes = TextEditingController(text: "");
  bool loading = false,
      loadingImages = false,
      valider = false,
      _existAnnonce = false,
      _valDes = false;
  List<MyPhoto> myImages = [];
  List<int> deletedImages = [];

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    idAnnonce = widget.id;
    nbImages = 0;
    if (idAnnonce == 0) {
      setState(() {
        loading = false;
      });
    } else {
      getAnnonceInfo();
      getAnnonceImages();
    }
    super.initState();
  }

  getPhoto(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(source: source);
    if (image == null) return;
    String chemin = image.path;
    MyPhoto p = MyPhoto(
        chemin: chemin,
        idAnnonce: idAnnonce,
        idPhoto: 0,
        base64Image: "",
        extension: "");
    myImages.add(p);
    nbImages = myImages.length;
    setState(() {});
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
                    backgroundColor: Colors.cyan,
                    centerTitle: true,
                    title: const Text("Fiche Annonce"),
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
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  child: TextField(
                      enabled: !valider,
                      controller: txtDes,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                          errorText: _valDes
                              ? 'Champs Obligatoire'
                              : _existAnnonce
                                  ? 'Annonce déjà Existante'
                                  : null,
                          prefixIcon: const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.title, color: Colors.black)),
                          contentPadding: const EdgeInsets.only(bottom: 3),
                          labelText: "Sujet",
                          labelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          hintText: "Sujet de l'annonce",
                          hintStyle:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          floatingLabelBehavior:
                              FloatingLabelBehavior.always))),
              const Divider(),
              Stack(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.picture_as_pdf),
                  const SizedBox(width: 10),
                  Text("Images ( ${myImages.length} )",
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
                            : () {
                                pickPhoto();
                              },
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.green),
                            child: const Icon(Icons.add, color: Colors.white))))
              ]),
              imageSpace(),
              const Divider(),
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

  imageSpace() {
    return loadingImages
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
        : myImages.isEmpty
            ? const Center(
                child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Pas d'Images",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)),
              ))
            : SizedBox(
                height: Data.heightScreen / 3,
                child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: myImages.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      String chemin = myImages[i].chemin;
                      return Stack(children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: myImages[i].idPhoto == 0
                                ? Image.file(File(chemin))
                                : Image.network(
                                    Data.getImage(chemin, "ANNONCE"))),
                        Positioned(
                            right: -4,
                            top: -4,
                            child: IconButton(
                                onPressed: () {
                                  AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.QUESTION,
                                          showCloseIcon: true,
                                          btnCancelText: "Non",
                                          btnOkText: "Oui",
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () {
                                            if (i < nbImages) {
                                              deletedImages
                                                  .add(myImages[i].idPhoto);
                                              nbImages--;
                                            }
                                            setState(() {
                                              myImages.removeAt(i);
                                            });
                                          },
                                          desc:
                                              'Voulez-vous vraiment supprimer cette image ?')
                                      .show();
                                },
                                icon: const Icon(Icons.delete,
                                    color: Colors.red)))
                      ]);
                    }));
  }

  updateAnnonce() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_ANNONCE.php";
    print(url);
    var body = {};
    body['ID_ANNONCE'] = idAnnonce.toString();
    body['DESIGNATION'] = txtDes.text;
    body['ID_USER'] = Data.currentUser!.idUser.toString();

    for (var i = 0; i < deletedImages.length; i++) {
      body['DEL_' + i.toString()] = deletedImages[i].toString();
    }
    body['NB_DELETED'] = deletedImages.length.toString();
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: body).then((response) async {
      if (response.statusCode == 200) {
        var result = response.body;
        print("result=$result");
        if (result != "0") {
          loadImages();
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

  insertAnnonce() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_ANNONCE.php";
    print(url);
    var body = {};
    body['DESIGNATION'] = txtDes.text;
    body['ID_USER'] = Data.currentUser!.idUser.toString();

    Uri myUri = Uri.parse(url);
    http.post(myUri, body: body).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("responsebody=${response.body}");
        if (responsebody != "0") {
          idAnnonce = int.parse(responsebody);
          loadImages();
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

  loadImages() {
    late MyPhoto e;
    for (var i = 0; i < myImages.length; i++) {
      var item = myImages[i];
      if (item.idPhoto == 0) {
        e = MyPhoto(
            chemin: item.chemin,
            idAnnonce: idAnnonce,
            idPhoto: 0,
            extension: p.extension(item.chemin),
            base64Image: base64Encode(File(item.chemin).readAsBytesSync()));
        GestFiles.myImages.add(e);
      }
    }
  }

  String getFileName(String chemin, File updfile) {
    String ext = updfile.path.split('.').last;
    String bddFileName = idAnnonce.toString() + "." + ext;
    String fileName = chemin + "\\" + bddFileName;
    return fileName;
  }

  verifierChamps() {
    txtDes.text.replaceAll("'", "");
    setState(() {
      _existAnnonce = false;
      _valDes = txtDes.text.isEmpty;
    });
  }

  saveParent() {
    setState(() {
      valider = true;
    });
    verifierChamps();

    if (_valDes) {
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
      if (idAnnonce == 0) {
        insertAnnonce();
      } else {
        updateAnnonce();
      }
    }
  }

  getAnnonceInfo() async {
    setState(() {
      loading = true;
    });
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_INFO_ANNONCE.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "ID_ANNONCE": idAnnonce.toString(),
          "ID_USER": Data.currentUser!.idUser.toString()
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            for (var m in responsebody) {
              txtDes.text = m['DESIGNATION'];
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

  getAnnonceImages() async {
    setState(() {
      loadingImages = true;
    });
    nbImages = 0;
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_IMAGES_ANNONCE.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "ID_ANNONCE": idAnnonce.toString(),
          "ID_USER": Data.currentUser!.idUser.toString()
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            late MyPhoto im;
            for (var m in responsebody) {
              im = MyPhoto(
                  chemin: m['CHEMIN'],
                  idAnnonce: idAnnonce,
                  base64Image: "",
                  extension: "",
                  idPhoto: int.parse(m['NUM']));
              myImages.add(im);
            }
            nbImages = myImages.length;
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
            loadingImages = false;
          });
        })
        .catchError((error) {
          print("erreur : $error");
          setState(() {
            loadingImages = false;
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

  pickPhoto() {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            var cameraStatus =
                                await Permission.mediaLibrary.status;
                            if (!cameraStatus.isGranted) {
                              await Permission.mediaLibrary.request();
                            }
                            if (await Permission
                                .mediaLibrary.status.isGranted) {
                              getPhoto(ImageSource.gallery);
                            } else {
                              AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.ERROR,
                                      showCloseIcon: true,
                                      title: 'Erreur',
                                      desc:
                                          "Vous n'avez pas le drois d'accées à la camera !!!")
                                  .show();
                            }
                            Navigator.of(context).pop();
                          },
                          child: Column(children: const [
                            Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.photo_album, size: 30)),
                            Text("Gallery", style: TextStyle(fontSize: 20))
                          ])),
                      GestureDetector(
                          onTap: () async {
                            var cameraStatus = await Permission.camera.status;
                            if (!cameraStatus.isGranted) {
                              await Permission.camera.request();
                            }
                            if (await Permission.camera.status.isGranted) {
                              getPhoto(ImageSource.camera);
                            } else {
                              AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.ERROR,
                                      showCloseIcon: true,
                                      title: 'Erreur',
                                      desc:
                                          "Vous n'avez pas le drois d'accées à la camera !!!")
                                  .show();
                            }
                            Navigator.of(context).pop();
                          },
                          child: Column(children: const [
                            Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.camera, size: 30)),
                            Text("Camera", style: TextStyle(fontSize: 20))
                          ]))
                    ]))
          ]);
        });
  }
}
