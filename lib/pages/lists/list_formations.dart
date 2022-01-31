// ignore_for_file: avoid_print

import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcorses/classes/data.dart';
import 'package:mcorses/classes/formation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:azlistview/azlistview.dart';
import 'package:mcorses/pages/fiches/fiche_formation.dart';
import 'package:mcorses/pages/widgets/widget_info_formation.dart';

List<Formation> formations = [];
String query = "";

class ListFormation extends StatefulWidget {
  const ListFormation({Key? key}) : super(key: key);

  @override
  _ListFormationState createState() => _ListFormationState();
}

class _ListFormationState extends State<ListFormation> {
  bool loading = true, error = false, searching = false;

  getFormations() async {
    setState(() {
      loading = true;
      error = false;
    });
    formations.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_FORMATIONS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri,
            body: {"WHERE": "", "ID_USER": Data.currentUser!.idUser.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            Formation p;
            String ch = "";
            List list = [];
            for (var m in responsebody) {
              ch = m['ADMINS'];
              list = ch == "" ? [] : ch.split(",");
              p = Formation(
                  details: m['DETAILS'],
                  image: m['IMAGE'],
                  titre: m['TITRE'],
                  nbDemande: int.parse(m['NB_DEMANDE']),
                  nbInscris: int.parse(m['NB_INSCRIS']),
                  id: int.parse(m['ID_FORMATION']),
                  idAdmin: list,
                  etat: int.parse(m['ETAT']));
              formations.add(p);
            }
          } else {
            setState(() {
              formations.clear();
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
            formations.clear();
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
    getFormations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Scaffold(
            drawer: Data.myDrawer(context),
            appBar: AppBar(
                backgroundColor: Colors.green,
                centerTitle: true,
                titleSpacing: 0,
                title: const Center(child: Text("Liste des Formations")),
                actions: [
                  IconButton(
                      onPressed: () {
                        getFormations();
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
            floatingActionButton: Data.currentUser!.isFormateur
                ? FloatingActionButton(
                    backgroundColor: Colors.green,
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
          return const FicheFormation(id: 0);
        });
    Navigator.push(context, route).then((value) {
      getFormations();
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
        : formations.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Center(
                        child: Text(
                            error
                                ? "Erreur de connexion !!!"
                                : "Aucune Formation !!!!",
                            style: TextStyle(
                                fontSize: 22,
                                color: error ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blue, onPrimary: Colors.white),
                        onPressed: getFormations,
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
                    child: AlphabetScrollPage(
                        items: formations,
                        onCLickedItem: (int i) {
                          print("item:${formations[i].titre}");
                          _showModal(i);
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
        // transitionAnimationController: animController,
        builder: (context) {
          return InfoFormation(
            formation: formations[i],
          );
        }).then((value) {
      getFormations();
    });
  }
}

class AlphabetScrollPage extends StatefulWidget {
  final List<Formation> items;
  final ValueChanged<int> onCLickedItem;
  const AlphabetScrollPage(
      {Key? key, required this.items, required this.onCLickedItem})
      : super(key: key);

  @override
  _AlphabetScrollPageState createState() => _AlphabetScrollPageState();
}

class _AlphabetScrollPageState extends State<AlphabetScrollPage> {
  late List<Formation> items;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    initList(widget.items);
    super.initState();
  }

  void initList(List<Formation> items) {
    this.items = widget.items;
    SuspensionUtil.sortListBySuspensionTag(this.items);
    SuspensionUtil.setShowSuspensionStatus(this.items);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => AzListView(
      indexBarItemHeight: (Data.heightScreen - 80) / 40,
      data: items,
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if ((query.isEmpty) ||
            (item.titre.toUpperCase().contains(query.toUpperCase())) ||
            (item.details.toUpperCase().contains(query.toUpperCase()))) {
          return _buildListItem(item);
        } else {
          return Container();
        }
      },
      indexHintBuilder: (context, tag) => Container(
          alignment: Alignment.center,
          width: 60,
          height: 60,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
          child: Text(tag,
              style: const TextStyle(color: Colors.white, fontSize: 28))),
      indexBarOptions: IndexBarOptions(
          needRebuild: true,
          selectTextStyle: TextStyle(
              color: Colors.white, fontSize: Data.isPortrait ? 12 : 7),
          textStyle: TextStyle(
              color: Colors.black, fontSize: Data.isPortrait ? 12 : 7),
          selectItemDecoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
          indexHintAlignment: Alignment.centerRight,
          indexHintOffset: const Offset(-20, 0)),
      padding: const EdgeInsets.all(16));

  Widget _buildListItem(Formation item) {
    bool isFormationAdmin =
        item.idAdmin.contains(Data.currentUser!.idUser.toString()) ||
            Data.currentUser!.isAdmin;
    final tag = item.getSuspensionTag();
    final offstage = !item.isShowSuspension;
    return Column(children: [
      Offstage(offstage: offstage, child: buildHeader(tag)),
      ListTile(
          tileColor: item.etat == 1 ? Colors.transparent : Colors.grey.shade400,
          title: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(item.titre,
                  style: GoogleFonts.laila(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold))),
          subtitle: Text(item.details,
              maxLines: 4,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          trailing: Visibility(
              visible: isFormationAdmin,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Visibility(
                    visible: item.nbDemande > 0,
                    child: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Text(item.nbDemande.toString(),
                            style: const TextStyle(color: Colors.black)))),
                const SizedBox(width: 5),
                CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(item.nbInscris.toString(),
                        style: const TextStyle(color: Colors.white)))
              ])),
          minLeadingWidth: 0,
          //isThreeLine: isFormationAdmin,
          contentPadding: const EdgeInsets.only(right: 8),
          leading: item.image.isEmpty
              ? Image.asset("images/logo.png")
              : Image.network(Data.getImage(item.image, 'FORMATION')),
          horizontalTitleGap: 6,
          onTap: () {
            widget.onCLickedItem(formations.indexOf(item));
          })
    ]);
  }

  buildHeader(String tag) => Container(
      height: 40,
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      child: Text(tag,
          softWrap: false,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
}
