// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mcorses/classes/data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcorses/classes/formation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:mcorses/pages/others/hist_demande.dart';

class DemandeAccessPage extends StatefulWidget {
  final Formation formation;
  const DemandeAccessPage({Key? key, required this.formation})
      : super(key: key);
  @override
  _DemandeAccessPageState createState() => _DemandeAccessPageState();
}

class _DemandeAccessPageState extends State<DemandeAccessPage> {
  late Formation formation;
  bool loading = false;
  List<MyPersons> persons = [];

  getDemandes() async {
    setState(() {
      loading = true;
    });
    persons.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_DEMANDE_ACCESS.php";
    print("url=$url");
    var body = {};
    body['ID_FORMATION'] = formation.id.toString();
    body['ID_USER'] = Data.currentUser!.idUser.toString();

    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: body)
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        print("responsebody=$responsebody");
        MyPersons p;
        for (var m in responsebody) {
          p = MyPersons(
              idFormation: int.parse(m['ID_FORMATION']),
              idUser: int.parse(m['ID_USER']),
              etat: int.parse(m['ETAT']),
              idDemande: int.parse(m['ID_DEMANDE']),
              titreFormation: m['TITRE'],
              fullname: m['NOM'],
              date: m['DATE_DEMANDE'],
              email: m['EMAIL'],
              heure: m['HEURE_DEMANDE'],
              photo: m['PHOTO'],
              tel: m['TEL']);
          persons.add(p);
        }
      } else {
        setState(() {
          persons.clear();
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
        persons.clear();
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
    formation = widget.formation;
    getDemandes();
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
                title: const Center(child: Text("Demande d'Inscription")),
                actions: [
                  IconButton(
                      onPressed: () {
                        var route = MaterialPageRoute(
                            builder: (context) =>
                                HistDemande(idFormation: formation.id));
                        Navigator.push(context, route);
                      },
                      icon: const Icon(Icons.history))
                ],
                leading: Navigator.canPop(context)
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white))
                    : null),
            body: bodyContent()));
  }

  itemTap(int i) {
    print("$i selected");
    Data.updList = false;
    showModalBottomSheet(
        context: context,
        elevation: 5,
        enableDrag: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ResponseDemandeAccess(person: persons[i]);
        }).then((value) {
      if (Data.updList) {
        getDemandes();
      }
    });
  }

  bodyContent() {
    String s = persons.length > 1 ? "s" : "";
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Text(formation.titre,
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: GoogleFonts.laila(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22)),
          SizedBox(
              width: double.infinity,
              child: Text(persons.length.toString() + " Demande$s d'accés",
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(color: Colors.black, fontSize: 16))),
          const Divider(),
          loading
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
              : persons.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                          const Center(
                              child: Text("Aucune Demande d'Accès !!!!",
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold))),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white),
                              onPressed: getDemandes,
                              icon: const FaIcon(FontAwesomeIcons.sync,
                                  color: Colors.white),
                              label: const Text("Actualiser"))
                        ])
                  : Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: persons.length,
                          itemBuilder: (context, i) => ListTile(
                              onTap: () => itemTap(i),
                              contentPadding: EdgeInsets.zero,
                              horizontalTitleGap: 8,
                              title: Text(persons[i].fullname),
                              subtitle: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.email,
                                          color: Colors.blue),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          child: Text(persons[i].email,
                                              overflow: TextOverflow.clip,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: Colors.blue)))
                                    ]),
                                    Row(children: [
                                      const Icon(Icons.phone,
                                          color: Colors.green),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Text(persons[i].tel,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: Colors.green)))
                                    ])
                                  ]),
                              trailing: Text(
                                  persons[i].date + "\n" + persons[i].heure,
                                  textAlign: TextAlign.center),
                              leading: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: persons[i].photo.isNotEmpty
                                      ? Image.network(Data.getImage(
                                          persons[i].photo, "PROFIL"))
                                      : Image.asset("images/noPhoto.png",
                                          fit: BoxFit.cover)))))
        ]));
  }
}

class MyPersons {
  int idDemande, idUser, etat, idFormation;
  String fullname, date, photo, tel, email, heure, titreFormation;
  MyPersons({
    required this.idDemande,
    required this.etat,
    required this.titreFormation,
    required this.idFormation,
    required this.idUser,
    required this.heure,
    required this.date,
    required this.photo,
    required this.tel,
    required this.email,
    required this.fullname,
  });
}

class ResponseDemandeAccess extends StatefulWidget {
  final MyPersons person;
  const ResponseDemandeAccess({Key? key, required this.person})
      : super(key: key);

  @override
  _ResponseDemandeAccessState createState() => _ResponseDemandeAccessState();
}

class _ResponseDemandeAccessState extends State<ResponseDemandeAccess> {
  late MyPersons person;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    person = widget.person;
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
                        AwesomeDialog(
                                context: context,
                                dialogType: DialogType.QUESTION,
                                showCloseIcon: true,
                                title: 'Confirmation',
                                btnOkText: "Oui",
                                btnCancelText: "Non",
                                btnOkOnPress: () {
                                  reponseDemande(2);
                                },
                                btnCancelOnPress: () {},
                                desc:
                                    'Voulez vraiment autoriser cette formation à cet utilisateur ?')
                            .show();
                      },
                      child: Container(
                          margin: EdgeInsets.only(
                              left: Data.widthScreen / 8,
                              right: Data.widthScreen / 8,
                              bottom: 10),
                          color: Colors.green,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 30),
                                SizedBox(width: 15),
                                Text("Autoriser",
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
                                  reponseDemande(3);
                                },
                                btnCancelOnPress: () {},
                                desc:
                                    "Voulez vraiment annuler la demande d'inscription de cet utilisateur à cette formation ?")
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
                                Icon(Icons.cancel_outlined,
                                    color: Colors.grey.shade300, size: 28),
                                const SizedBox(width: 15),
                                Text("Annuler",
                                    style: TextStyle(
                                        color: Colors.grey.shade300,
                                        fontSize: 26))
                              ])))
                ]))));
  }

  reponseDemande(int type) {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/REPONSE_DEMANDE.php";
    print(url);
    var body = {};
    body['ID_DEMANDE'] = person.idDemande.toString();
    body['ETAT'] = type.toString();
    body['ID_ADMIN'] = Data.currentUser!.idUser.toString();
    body['ID_FORMATION'] = person.idFormation.toString();
    body['ID_USER'] = person.idUser.toString();

    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: body)
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
      if (response.statusCode == 200) {
        var result = response.body;
        if (result != "0") {
          Data.updList = true;
          Data.showSnack(
              msg: type == 2
                  ? 'Formation Auhtorisé a cet utilisateur ...'
                  : "Demande d'inscription annulée ...",
              color: type == 2 ? Colors.green : Colors.red);
          Navigator.pop(context);
        } else {
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: "Probleme lors de l'autorisation  !!!")
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
