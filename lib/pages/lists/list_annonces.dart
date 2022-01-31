// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:math';
//import 'package:google_fonts/google_fonts.dart';
import 'package:mcorses/classes/annonce.dart';
import 'package:mcorses/classes/data.dart';
//import 'package:mcorses/classes/formation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mcorses/classes/photo.dart';
import 'package:mcorses/pages/fiches/fiche_annonce.dart';
import 'package:mcorses/pages/widgets/widget_gallery.dart';

List<Annonce> annonces = [];
String query = "";

class ListAnnnonces extends StatefulWidget {
  const ListAnnnonces({Key? key}) : super(key: key);

  @override
  _ListAnnnoncesState createState() => _ListAnnnoncesState();
}

class _ListAnnnoncesState extends State<ListAnnnonces> {
  bool loading = true, error = false, searching = false;

  getAnnonces() async {
    setState(() {
      loading = true;
      error = false;
    });
    annonces.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_ANNONCES.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri,
            body: {"WHERE": "", "ID_USER": Data.currentUser!.idUser.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            Annonce p;
            String ch = "";
            List listId = [], listChemin = [];
            for (var m in responsebody) {
              ch = m['ID_IMAGES'];
              listId = ch == "" ? [] : ch.split(",");
              ch = m['CHEMIN_IMAGES'];
              listChemin = ch == "" ? [] : ch.split(",");
              p = Annonce(
                  date: m['DATE_ANNONCE'],
                  designation: m['DESIGNATION'],
                  chemin: listChemin,
                  idImages: listId,
                  id: int.parse(m['ID_ANNONCE']),
                  etat: int.parse(m['ETAT']));
              annonces.add(p);
            }
          } else {
            setState(() {
              annonces.clear();
              error = true;
            });
            AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: 'Probleme de Connexion avec le serveur !!!')
                .show();
          }
          setState(() {
            loading = false;
          });
        })
        .catchError((error) {
          print("erreur : $error");
          setState(() {
            annonces.clear();
            error = true;
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

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    Data.myContext = context;
    loading = true;
    getAnnonces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Scaffold(
            drawer: Data.myDrawer(context),
            appBar: AppBar(
                backgroundColor: Colors.cyan,
                centerTitle: true,
                titleSpacing: 0,
                title: const Center(child: Text("Liste des Annonces")),
                actions: [
                  IconButton(
                      onPressed: () {
                        getAnnonces();
                      },
                      icon: const FaIcon(FontAwesomeIcons.sync,
                          color: Colors.white)),
                  IconButton(
                      onPressed: () {
                        if (searching) {
                          query = "";
                        }
                        setState(() {
                          searching = !searching;
                        });
                      },
                      icon: const FaIcon(FontAwesomeIcons.search,
                          color: Colors.white))
                ],
                leading: Navigator.canPop(context)
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white))
                    : null),
            floatingActionButton: Data.currentUser!.isAdmin
                ? FloatingActionButton(
                    backgroundColor: Colors.cyan,
                    onPressed: btnInsert,
                    child: const Icon(Icons.add))
                : null,
            body: bodyContent()));
  }

  btnInsert() {
    //var route = MaterialPageRoute(builder: (context) => const FicheFormation(id: 0));
    var route = PageRouteBuilder(
        transitionDuration: const Duration(seconds: 1),
        transitionsBuilder: (context, animation, secAnimation, child) {
          return Data.myAnimation(child, animation);
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return const FicheAnnonce(id: 0);
        });
    Navigator.push(context, route).then((value) {
      getAnnonces();
    });
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
        : annonces.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Center(
                        child: Text(
                            error
                                ? "Erreur de connexion !!!"
                                : "Aucune Annonce !!!!",
                            style: TextStyle(
                                fontSize: 22,
                                color: error ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blue, onPrimary: Colors.white),
                        onPressed: getAnnonces,
                        icon: const FaIcon(FontAwesomeIcons.sync,
                            color: Colors.white),
                        label: const Text("Actualiser"))
                  ])
            : Column(children: [
                Visibility(
                    visible: searching,
                    child: TextFormField(
                        initialValue: query,
                        onChanged: (value) {
                          setState(() {
                            query = value;
                          });
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            hintText: "Recherche",
                            suffixIcon: InkWell(
                                onTap: () {
                                  if (searching) {
                                    query = "";
                                  }
                                  setState(() {
                                    searching = !searching;
                                  });
                                },
                                child: const Icon(Icons.clear)),
                            prefixIcon: const Icon(Icons.search)))),
                Expanded(
                    child: ListView.builder(
                        itemCount: annonces.length,
                        itemBuilder: (context, i) {
                          return Card(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                ListTile(
                                    onTap: () {
                                      _showModal(i);
                                    },
                                    title: Text(annonces[i].designation),
                                    trailing: Text(annonces[i].date)),
                                imageSpace(i)
                              ]));
                        }))
              ]);
  }

  _showModal(int i) async {
    Data.updList = false;
    showModalBottomSheet(
        context: context,
        elevation: 5,
        enableDrag: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ModalAnnonce(annonce: annonces[i]);
        }).then((value) {
      if (Data.updList) {
        getAnnonces();
      }
    });
  }

  Widget imageSpace(int i) {
    return Visibility(
        visible: annonces[i].chemin.isNotEmpty,
        child: SizedBox(
            height: Data.heightScreen / 3,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                primary: false,
                itemCount: annonces[i].chemin.length,
                itemBuilder: (context, j) {
                  return GestureDetector(
                      onTap: () {
                        List<Photo> gallery = [];
                        for (var item in annonces[i].chemin) {
                          gallery.add(
                              Photo(chemin: item, date: '', heure: '', id: 0));
                        }
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => GalleryWidget(
                                index: j,
                                myImages: gallery,
                                delete: false,
                                folder: "ANNONCE")));
                      },
                      child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                              Data.getImage(annonces[i].chemin[j], "ANNONCE"),
                              fit: BoxFit.contain, loadingBuilder:
                                  (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                                child: CircularProgressIndicator(
                                    color: Data.darkColor[Random().nextInt(
                                            Data.darkColor.length - 1) +
                                        1]));
                          })));
                })));
  }
}

class ModalAnnonce extends StatefulWidget {
  final Annonce annonce;
  const ModalAnnonce({Key? key, required this.annonce}) : super(key: key);

  @override
  _ModalAnnonceState createState() => _ModalAnnonceState();
}

class _ModalAnnonceState extends State<ModalAnnonce> {
  late Annonce annonce;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    annonce = widget.annonce; //all widgets are rendered here
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Container(
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  InkWell(
                      onTap: () {
                        var route = MaterialPageRoute(
                            builder: (context) => FicheAnnonce(id: annonce.id));
                        Navigator.push(context, route).then((value) {
                          Data.updList = true;
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.only(
                              left: Data.widthScreen / 8,
                              right: Data.widthScreen / 8,
                              bottom: 10),
                          color: Colors.blue,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.edit, color: Colors.white, size: 30),
                                SizedBox(width: 15),
                                Text("Modifier",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 28))
                              ]))),
                  InkWell(
                      onTap: () {
                        AwesomeDialog(
                                context: context,
                                dialogType: DialogType.QUESTION,
                                showCloseIcon: true,
                                title: 'Confirmation',
                                btnOkText: "Oui",
                                btnCancelText: "Non",
                                btnOkOnPress: () {
                                  deleteAnnonce();
                                },
                                btnCancelOnPress: () {},
                                desc:
                                    "Voulez vraiment supprimer cette annonce ?")
                            .show();
                      },
                      child: Container(
                          margin: EdgeInsets.only(
                              left: Data.widthScreen / 8,
                              right: Data.widthScreen / 8,
                              bottom: 10),
                          color: Colors.red,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete,
                                    color: Colors.grey.shade300, size: 28),
                                const SizedBox(width: 15),
                                Text("Supprimer",
                                    style: TextStyle(
                                        color: Colors.grey.shade300,
                                        fontSize: 26))
                              ])))
                ]))));
  }

  deleteAnnonce() {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/DELETE_ANNONCE.php";
    print(url);
    var body = {};
    body['ID_USER'] = Data.currentUser!.idUser.toString();
    body['ID_ANNONCE'] = annonce.id.toString();

    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: body)
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
      if (response.statusCode == 200) {
        var result = response.body;
        if (result != "0") {
          Data.updList = true;
          Data.showSnack("Annonce supprimée ...", Colors.red);
          Navigator.pop(context);
        } else {
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: "Probleme lors de la suppression  !!!")
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
    }).catchError((error) {
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
}
