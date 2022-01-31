// ignore_for_file: avoid_print

import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcorses/classes/data.dart';
import 'package:mcorses/classes/formation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mcorses/classes/mycours.dart';
import 'package:mcorses/pages/lists/list_admin_formation.dart';
import 'package:mcorses/pages/others/access_page.dart';
import 'package:mcorses/pages/others/demande_access_page.dart';
import 'package:mcorses/pages/others/file_reader.dart';
import 'package:path/path.dart' as p;
import 'package:mcorses/pages/fiches/fiche_formation.dart';

class InfoFormation extends StatefulWidget {
  final Formation formation;
  const InfoFormation({Key? key, required this.formation}) : super(key: key);

  @override
  _InfoFormationState createState() => _InfoFormationState();
}

class _InfoFormationState extends State<InfoFormation> {
  late Formation formation;
  int idDemande = 0, idAccess = 0, nbDemande = 0;
  List<MyCours> myCourses = [];
  bool loadingCours = false,
      loadingDemandeAccess = false,
      isFormationAdmin = false,
      loadingAccess = false,
      loadingdemande = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    formation = widget.formation; //all widgets are rendered here
    isFormationAdmin =
        formation.idAdmin.contains(Data.currentUser!.idUser.toString()) ||
            Data.currentUser!.isAdmin;
    getFormationCours();
    if (!isFormationAdmin) {
      haveDemandeAccess();
      haveAccess();
    } else {
      existDemandeAccess();
    }
    super.initState();
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: GestureDetector(onTap: () {}, child: child));

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return makeDismissible(
        child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (_, controller) => Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25))),
                padding: const EdgeInsets.all(10),
                child: ListView(controller: controller, children: [
                  Center(
                      child: Text(formation.titre,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.laila(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20))),
                  Text(formation.details,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.laila(
                          color: Colors.grey.shade700, fontSize: 16)),
                  const Divider(),
                  docSpace(),
                  const Divider(),
                  Wrap(alignment: WrapAlignment.spaceEvenly, children: [
                    Visibility(
                        visible: isFormationAdmin,
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                    onPrimary: Colors.white),
                                onPressed: () {
                                  var route = MaterialPageRoute(
                                      builder: (context) =>
                                          FicheFormation(id: formation.id));
                                  Navigator.push(context, route).then((value) {
                                    Data.updList = true;
                                    Navigator.pop(context);
                                  });
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Modifier"))),
                        replacement: Visibility(
                            child: const Center(
                                child: CircularProgressIndicator()),
                            visible: loadingdemande ||
                                loadingDemandeAccess ||
                                loadingAccess,
                            replacement: Visibility(
                                visible: idAccess == 0,
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.amber,
                                        onPrimary: Colors.white),
                                    onPressed:
                                        idDemande == 0 ? demandeAccess : null,
                                    icon: const Icon(Icons.edit),
                                    label: Text(idDemande == 0
                                        ? "Demander l'inscription"
                                        : "En cours de traitement de votre demande"))))),
                    Visibility(
                        visible: isFormationAdmin,
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                    onPrimary: Colors.white),
                                onPressed: () {
                                  var route = MaterialPageRoute(
                                      builder: (context) =>
                                          AccessPage(formation: formation));
                                  Navigator.of(context)
                                      .push(route)
                                      .then((value) {});
                                },
                                icon: const Icon(Icons.group_outlined),
                                label: Text(
                                    "Candidats Inscris (${formation.nbInscris.toString()})"))),
                        replacement: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            color: idAccess == 0 ? Colors.red : Colors.green,
                            child: Text(
                                idAccess == 0
                                    ? "Pas Authorisé"
                                    : "Vous êtes inscris",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 22)))),
                    Visibility(
                        visible: isFormationAdmin,
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Stack(children: [
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.amber,
                                      onPrimary: Colors.white),
                                  onPressed: () {
                                    var route = MaterialPageRoute(
                                        builder: (context) => DemandeAccessPage(
                                            formation: formation));
                                    Navigator.of(context)
                                        .push(route)
                                        .then((value) {});
                                  },
                                  icon: const Icon(Icons.vpn_key),
                                  label:
                                      const Text("Demandes d'Inscription  ")),
                              Visibility(
                                  visible: nbDemande > 0,
                                  child: Positioned(
                                      right: 0,
                                      child: ClipOval(
                                          child: Container(
                                              color: Colors.blue,
                                              padding: nbDemande < 10
                                                  ? const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 8)
                                                  : const EdgeInsets.all(4),
                                              child: Text(
                                                  nbDemande > 99
                                                      ? "+99"
                                                      : nbDemande.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white))))))
                            ]))),
                    Visibility(
                        visible: isFormationAdmin,
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                    onPrimary: Colors.white),
                                onPressed: () {
                                  var route = MaterialPageRoute(
                                      builder: (context) => AdminListFormation(
                                          formation: formation));
                                  Navigator.of(context)
                                      .push(route)
                                      .then((value) {});
                                },
                                icon: const Icon(Icons.add_moderator_outlined),
                                label: Text(
                                    "Administrateurs (${formation.idAdmin.length.toString()})")))),
                    /*        Visibility(
                        visible: isFormationAdmin,
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    onPrimary: Colors.white),
                                onPressed: () {
                                  Data.updList = true;
                                  AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.QUESTION,
                                          showCloseIcon: true,
                                          title: 'Confirmation',
                                          btnOkText: "Oui",
                                          btnCancelText: "Non",
                                          btnOkOnPress: deleteFormation,
                                          btnCancelOnPress: () {
                                            Navigator.pop(context);
                                          },
                                          desc:
                                              'Voulez vraiment supprimer cette formation ?')
                                      .show();
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text("Supprimer Formation"))))
              */
                  ])
                ]))));
  }

  deleteFormation() {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/DELETE_FORMATION.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "ID_FORMATION": formation.id.toString(),
          "ID_USER": Data.currentUser!.idUser.toString()
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var result = response.body;
            if (result != "0") {
              Data.showSnack('Formation supprimé ...', Colors.green);
              Navigator.pop(context);
            } else {
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.ERROR,
                      showCloseIcon: true,
                      title: 'Erreur',
                      desc: "Probleme lors de la suppression !!!")
                  .show();
            }
          } else {
            AwesomeDialog(
                    context: context,
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
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme de Connexion avec le serveur 6!!!')
              .show();
        });
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
                child: Text("Pas de cours dans cette formation",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)))
            : ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: myCourses.length,
                itemBuilder: (context, i) => ListTile(
                    onTap: () {
                      openPDF(i);
                    },
                    title: Text(myCourses[i].designation.isEmpty
                        ? p.basename(myCourses[i].path)
                        : myCourses[i].designation),
                    leading: Container(
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
                    contentPadding: const EdgeInsets.all(0)));
  }

  openPDF(int i) {
    if ((idAccess == 0 || loadingAccess) && (!isFormationAdmin)) {
      Navigator.pop(context);
      Data.showSnack(
          "Vous n'êtes pas inscris dans cette formation !!!!", Colors.red);
    } else {
      String name = myCourses[i].designation.isEmpty
          ? p.basename(myCourses[i].path)
          : myCourses[i].designation;
      var route = MaterialPageRoute(
          builder: (context) =>
              FileReader(file: myCourses[i].path, name: name));
      Navigator.push(context, route);
    }
  }

  haveDemandeAccess() async {
    setState(() {
      loadingDemandeAccess = true;
    });
    idDemande = 0;
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/HAVE_DEMANDE_ACCESS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "ID_FORMATION": formation.id.toString(),
          "ID_USER": Data.currentUser!.idUser.toString()
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            for (var m in responsebody) {
              idDemande = int.parse(m['ID']);
            }
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
            loadingDemandeAccess = false;
          });
        })
        .catchError((error) {
          print("erreur : $error");
          setState(() {
            loadingDemandeAccess = false;
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

  haveAccess() async {
    setState(() {
      loadingAccess = true;
    });
    idAccess = 0;
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/HAVE_ACCESS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "ID_FORMATION": formation.id.toString(),
          "ID_USER": Data.currentUser!.idUser.toString()
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            for (var m in responsebody) {
              idAccess = int.parse(m['ID']);
            }
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
            loadingAccess = false;
          });
        })
        .catchError((error) {
          print("erreur : $error");
          setState(() {
            loadingAccess = false;
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

  demandeAccess() async {
    setState(() {
      loadingdemande = true;
    });
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_DEMANDE.php";
    print(url);
    var body = {};
    body['ID_FORMATION'] = formation.id.toString();
    body['ID_USER'] = Data.currentUser!.idUser.toString();

    Uri myUri = Uri.parse(url);
    http.post(myUri, body: body).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("responsebody=${response.body}");
        if (responsebody != "0") {
          haveDemandeAccess();
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
        loadingdemande = false;
      });
    }).catchError((error) {
      print("erreur : $error");
      setState(() {
        loadingdemande = false;
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

  existDemandeAccess() async {
    setState(() {
      loadingdemande = true;
    });
    nbDemande = 0;
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/EXIST_DEMANDE_ACCESS.php";
    print(url);
    var body = {};
    body['ID_FORMATION'] = formation.id.toString();
    body['ID_USER'] = Data.currentUser!.idUser.toString();

    Uri myUri = Uri.parse(url);
    http.post(myUri, body: body).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        print("responsebody=$responsebody");
        for (var m in responsebody) {
          nbDemande = int.parse(m['ID']);
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
        loadingdemande = false;
      });
    }).catchError((error) {
      print("erreur : $error");
      setState(() {
        loadingdemande = false;
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
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_COURSES_FORMATIONS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "ID_FORMATION": formation.id.toString(),
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
                  idFormation: formation.id,
                  path: m['FILE']);
              myCourses.add(c);
            }
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
