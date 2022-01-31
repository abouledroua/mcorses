// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mcorses/classes/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:mcorses/classes/myhist.dart';

class HistDemande extends StatefulWidget {
  final int idFormation;
  const HistDemande({Key? key, required this.idFormation}) : super(key: key);

  @override
  _HistDemandeState createState() => _HistDemandeState();
}

class _HistDemandeState extends State<HistDemande> {
  late int idFormation;
  bool loading = false;
  List<MyHist> myHist = [];

  getHist() async {
    setState(() {
      loading = true;
    });
    myHist.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_HIST_DEMANDE.php";
    print("url=$url");
    var body = {};
    body['ID_FORMATION'] = idFormation.toString();
    body['ID_USER'] = Data.currentUser!.idUser.toString();
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: body)
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        print("responsebody=$responsebody");
        MyHist e;
        for (var m in responsebody) {
          e = MyHist(
              adminName: m['ADMINNAME'],
              userName: m['USERNAME'],
              date: m['DATE_ACTION'],
              datetime: m['DATETIME_ACTION'],
              heure: m['HEURE_ACTION'],
              action: int.parse(m['ACTION']),
              idAdmin: int.parse(m['ID_ADMIN']),
              idUser: int.parse(m['ID_USER']));
          myHist.add(e);
        }
      } else {
        setState(() {
          myHist.clear();
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
    }).catchError((error) {
      print("erreur : $error");
      setState(() {
        myHist.clear();
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
    WidgetsFlutterBinding.ensureInitialized();
    idFormation = widget.idFormation; //all widgets are rendered here
    getHist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Scaffold(
            drawer: Data.myDrawer(context),
            appBar: AppBar(
                backgroundColor: Colors.amber,
                centerTitle: true,
                titleSpacing: 0,
                title: const Center(child: Text("Historique des Demandes")),
                leading: Navigator.canPop(context)
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white))
                    : null),
            body: bodyContent()));
  }

  String constructTitle(int i) {
    return myHist[i].adminName +
        (myHist[i].action == 2
            ? " à accepté la demande d'insription du candidat "
            : myHist[i].action == 4
                ? " à ajouter une inscription pour le candidat "
                : " à annulé la demande d'insription du candidat ") +
        myHist[i].userName;
  }

  bodyContent() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: loading
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
            : myHist.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                        const Center(
                            child: Text("Aucune action faite !!!",
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue, onPrimary: Colors.white),
                            onPressed: getHist,
                            icon: const FaIcon(FontAwesomeIcons.sync,
                                color: Colors.white),
                            label: const Text("Actualiser"))
                      ])
                : InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: myHist.length,
                        itemBuilder: (context, i) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            minVerticalPadding: 0,
                            horizontalTitleGap: 4,
                            title: Text(constructTitle(i),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: myHist[i].action == 3
                                        ? Colors.red.shade600
                                        : Colors.green.shade700)),
                            trailing: Text(
                                Data.printDate(DateTime.parse(myHist[i].date)),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12))))));
  }
}
