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
import 'package:mcorses/pages/others/hist_inscription.dart';

List<MyUser> selUsers = [];
List<MyPersons> persons = [];

class AccessPage extends StatefulWidget {
  final Formation formation;
  const AccessPage({Key? key, required this.formation}) : super(key: key);

  @override
  _AccessPageState createState() => _AccessPageState();
}

class _AccessPageState extends State<AccessPage> {
  late Formation formation;
  bool loading = false;

  getAccess() async {
    setState(() {
      loading = true;
    });
    persons.clear();
    selUsers.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_ACCESS.php";
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
        MyUser e;
        for (var m in responsebody) {
          p = MyPersons(
              idFormation: int.parse(m['ID_FORMATION']),
              idUser: int.parse(m['ID_USER']),
              etat: int.parse(m['ETAT']),
              idAcess: int.parse(m['ID']),
              idAdmin: int.parse(m['ID_ADMIN']),
              titreFormation: m['TITRE'],
              fullname: m['NOM'],
              dateAccess: m['DATE_ACCESS'],
              email: m['EMAIL'],
              photo: m['PHOTO'],
              tel: m['TEL']);
          persons.add(p);
          e = MyUser(
              email: m['EMAIL'],
              fullname: m['NOM'],
              idUser: int.parse(m['ID_USER']),
              tel: m['TEL'],
              photo: m['PHOTO']);
          selUsers.add(e);
        }
      } else {
        setState(() {
          persons.clear();
          selUsers.clear();
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
        selUsers.clear();
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
    getAccess();
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
                title: const Center(child: Text("Candidats Inscris")),
                actions: [
                  IconButton(
                      onPressed: () {
                        var route = MaterialPageRoute(
                            builder: (context) =>
                                HistInsciption(idFormation: formation.id));
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
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: btnInsert,
                child: const Icon(Icons.add)),
            body: bodyContent()));
  }

  btnInsert() async {
    await showDialog(
        context: context,
        builder: (_) => SearchUser(idFormation: formation.id)).then((value) {
      getAccess();
    });
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
        getAccess();
      }
    });
  }

  bodyContent() {
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
              child: Text(persons.length.toString() + " Inscris",
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
                              child: Text("Aucun Candidat Inscris !!!",
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold))),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white),
                              onPressed: getAccess,
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
                              trailing: Text(persons[i].dateAccess,
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
  int idAcess, idUser, idAdmin, etat, idFormation;
  String fullname, photo, tel, email, titreFormation, dateAccess;
  MyPersons({
    required this.idAcess,
    required this.etat,
    required this.dateAccess,
    required this.titreFormation,
    required this.idFormation,
    required this.idUser,
    required this.idAdmin,
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
                padding: const EdgeInsets.all(10),
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
                                  annulerAccess(3);
                                },
                                btnCancelOnPress: () {},
                                desc:
                                    "Voulez vraiment annuler l'inscription de cet utilisateur à cette formation ?")
                            .show();
                      },
                      child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: Data.widthScreen / 8),
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

  annulerAccess(int type) {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/ANNULER_ACCESS.php";
    print(url);
    var body = {};
    body['ID_ACCESS'] = person.idAcess.toString();
    body['ID_ADMIN'] = Data.currentUser!.idUser.toString();
    body['ID_USER'] = person.idUser.toString();
    body['ID_FORMATION'] = person.idFormation.toString();

    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: body)
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
      if (response.statusCode == 200) {
        var result = response.body;
        if (result != "0") {
          Data.updList = true;
          Data.showSnack("L'inscription à été annulée ...", Colors.red);
          Navigator.pop(context);
        } else {
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: "Probleme lors de l'annulation de l'accées  !!!")
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

class MyUser {
  int idUser;
  String fullname, photo, tel, email;
  MyUser({
    required this.idUser,
    required this.photo,
    required this.tel,
    required this.email,
    required this.fullname,
  });
}

class SearchUser extends StatefulWidget {
  final int idFormation;
  const SearchUser({Key? key, required this.idFormation}) : super(key: key);

  @override
  _SearchEnfantState createState() => _SearchEnfantState();
}

class _SearchEnfantState extends State<SearchUser> {
  late String query;
  late int idFormation;
  late List<int> indName;
  List<MyUser> allusers = [];
  bool loading = true, error = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    query = "";
    idFormation = widget.idFormation;
    loading = true;
    getAllUsers();
    super.initState();
  }

  getAllUsers() async {
    setState(() {
      loading = true;
      error = false;
    });
    allusers.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_USERS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri,
            body: {"WHERE": "", "ID_USER": Data.currentUser!.idUser.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            print("responsebody=$responsebody");
            MyUser e;
            for (var m in responsebody) {
              e = MyUser(
                  email: m['EMAIL'],
                  fullname: m['NOM'],
                  idUser: int.parse(m['ID_USER']),
                  tel: m['TEL'],
                  photo: m['PHOTO']);
              allusers.add(e);
            }
          } else {
            setState(() {
              allusers.clear();
              error = true;
            });
            AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: 'Probleme de Connexion avec le serveur 19!!!')
                .show();
          }
          setState(() {
            loading = false;
          });
        })
        .catchError((error) {
          print("erreur : $error");
          setState(() {
            allusers.clear();
            loading = false;
            error = true;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme de Connexion avec le serveur 20!!!')
              .show();
        });
  }

  List<MyUser> filtrerCours() {
    indName = [];
    List<MyUser> list = [];
    for (var item in allusers) {
      if (item.fullname.toUpperCase().contains(query.toUpperCase())) {
        list.add(item);
        indName.add(item.fullname.toUpperCase().indexOf(query.toUpperCase()));
      }
    }
    return list;
  }

  bool existEnfant(int id) {
    for (var i = 0; i < selUsers.length; i++) {
      if (selUsers[i].idUser == id) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    final List<MyUser> suggestionList =
        query.isEmpty ? allusers : filtrerCours();
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                elevation: 1,
                backgroundColor: Colors.white,
                title: const Text("Selectionner Utilisateur(s)",
                    style: TextStyle(color: Colors.black)),
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black))),
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Data.darkColor[
                                Random().nextInt(Data.darkColor.length)]))
                    : allusers.isEmpty
                        ? Container(
                            color: Colors.white,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                      child: Text(
                                          error
                                              ? "Erreur de connexion !!!"
                                              : "Aucun Utilisateur !!!!",
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: error
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold))),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.blue,
                                          onPrimary: Colors.white),
                                      onPressed: getAllUsers,
                                      icon: const FaIcon(FontAwesomeIcons.sync,
                                          color: Colors.white),
                                      label: const Text("Actualiser"))
                                ]))
                        : Column(children: [
                            selUsers.isEmpty
                                ? Center(
                                    child: Container(
                                        padding: const EdgeInsets.all(10),
                                        width: double.infinity,
                                        color: Colors.amber,
                                        child: const Text(
                                            "Pas d'utilisateur sélectionné",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white))))
                                : Wrap(
                                    children: selUsers
                                        .map((item) => Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                      onTap: () {
                                                        deleteUser(item);
                                                      },
                                                      child: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red)),
                                                  Container(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              item.fullname,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                      color: Colors.blue)
                                                ])))
                                        .toList()
                                        .cast<Widget>()),
                            const Divider(),
                            TextFormField(
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
                                          setState(() {
                                            query = "";
                                          });
                                        },
                                        child: const Icon(Icons.clear)),
                                    prefixIcon: const Icon(Icons.search))),
                            Expanded(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: suggestionList.length,
                                    itemBuilder: (context, i) => Visibility(
                                        visible: existEnfant(
                                            suggestionList[i].idUser),
                                        child: Card(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ListTile(
                                                    onTap: () {
                                                      print("i did select : " +
                                                          suggestionList[i]
                                                              .fullname);
                                                      if (!existEnfant(
                                                          suggestionList[i]
                                                              .idUser)) {
                                                        insertUser(
                                                            suggestionList[i]);
                                                      }
                                                    },
                                                    title: Text(
                                                        suggestionList[i]
                                                            .fullname,
                                                        style: TextStyle(
                                                            color: existEnfant(
                                                                    suggestionList[
                                                                            i]
                                                                        .idUser)
                                                                ? Colors.grey
                                                                : Colors
                                                                    .black))))))))
                          ]))));
  }

  insertUser(MyUser user) {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_ACCESS.php";
    print(url);
    var body = {};
    body['ID_FORMATION'] = idFormation.toString();
    body['ID_USER'] = user.idUser.toString();
    body['ID_ADMIN'] = Data.currentUser!.idUser.toString();
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: body)
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
      if (response.statusCode == 200) {
        var result = response.body;
        if (result != "0") {
          setState(() {
            selUsers.add(user);
          });
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

  deleteUser(MyUser user) {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/DELETE_ACCESS.php";
    print(url);
    var body = {};
    body['ID_FORMATION'] = idFormation.toString();
    body['ID_USER'] = user.idUser.toString();
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: body)
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
      if (response.statusCode == 200) {
        var result = response.body;
        if (result != "0") {
          setState(() {
            selUsers.removeAt(selUsers.indexOf(user));
          });
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
