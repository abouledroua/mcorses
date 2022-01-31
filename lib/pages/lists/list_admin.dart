// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mcorses/classes/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

List<MyUser> admins = [];

class AdminList extends StatefulWidget {
  const AdminList({Key? key}) : super(key: key);

  @override
  _AdminListState createState() => _AdminListState();
}

class _AdminListState extends State<AdminList> {
  bool loading = false;

  getAdmins() async {
    setState(() {
      loading = true;
    });
    admins.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_FORMATEURS.php";
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
              admins.add(e);
            }
          } else {
            setState(() {
              admins.clear();
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
            admins.clear();
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
    getAdmins();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Scaffold(
            drawer: Data.myDrawer(context),
            appBar: AppBar(
                backgroundColor: Colors.indigo,
                centerTitle: true,
                titleSpacing: 0,
                title: const Center(child: Text("Liste des Formateurs")),
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
    await showDialog(context: context, builder: (_) => const SearchUser())
        .then((value) {
      getAdmins();
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
          return AnnulerAdmin(person: admins[i]);
        }).then((value) {
      if (Data.updList) {
        getAdmins();
      }
    });
  }

  bodyContent() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
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
              : admins.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                          const Center(
                              child: Text("Aucun Administrateur !!!",
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold))),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white),
                              onPressed: getAdmins,
                              icon: const FaIcon(FontAwesomeIcons.sync,
                                  color: Colors.white),
                              label: const Text("Actualiser"))
                        ])
                  : Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: admins.length,
                          itemBuilder: (context, i) => ListTile(
                              onTap: () => itemTap(i),
                              contentPadding: EdgeInsets.zero,
                              horizontalTitleGap: 8,
                              title: Text(admins[i].fullname),
                              subtitle: Text(
                                  admins[i].tel.isEmpty
                                      ? "Email : ${admins[i].email}"
                                      : "Phone : ${admins[i].tel}",
                                  style:
                                      TextStyle(color: Colors.grey.shade700)),
                              leading: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: admins[i].photo.isNotEmpty
                                      ? Image.network(Data.getImage(
                                          admins[i].photo, "PROFIL"))
                                      : Image.asset("images/noPhoto.png",
                                          fit: BoxFit.cover)))))
        ]));
  }
}

class AnnulerAdmin extends StatefulWidget {
  final MyUser person;
  const AnnulerAdmin({Key? key, required this.person}) : super(key: key);

  @override
  _AnnulerAdminState createState() => _AnnulerAdminState();
}

class _AnnulerAdminState extends State<AnnulerAdmin> {
  late MyUser person;

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
                                  modifAccess(person, 1, context);
                                },
                                btnCancelOnPress: () {},
                                desc:
                                    "Voulez vraiment annuler le droit administrateur pour cet utilisateur ?")
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
}

modifAccess(MyUser person, int type, BuildContext context) {
  String serverDir = Data.getServerDirectory();
  var url = "$serverDir/MODIFIER_FORMATEUR.php";
  print(url);
  var body = {};
  body['ID_USER'] = person.idUser.toString();
  body['TYPE'] = type.toString();

  Uri myUri = Uri.parse(url);
  http
      .post(myUri, body: body)
      .timeout(Duration(seconds: Data.timeOut))
      .then((response) async {
    if (response.statusCode == 200) {
      var result = response.body;
      if (result != "0") {
        Data.updList = true;
        Data.showSnack(msg: 
            type == 2
                ? "Accéss d'administration attribué ..."
                : "Accéss d'administration annulée ...",
          color:   type == 2 ? Colors.green : Colors.red);
        Navigator.pop(context);
      } else {
        AwesomeDialog(
                context: context,
                dialogType: DialogType.ERROR,
                showCloseIcon: true,
                title: 'Erreur',
                desc: "Probleme lors de la modification de l'accées  !!!")
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
  const SearchUser({Key? key}) : super(key: key);

  @override
  _SearchEnfantState createState() => _SearchEnfantState();
}

class _SearchEnfantState extends State<SearchUser> {
  late String query;
  late List<int> indName;
  List<MyUser> allusers = [];
  bool loading = true, error = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    query = "";
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
    for (var i = 0; i < admins.length; i++) {
      if (admins[i].idUser == id) {
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
                            admins.isEmpty
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
                                    children: admins
                                        .map((item) => Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                      onTap: () {
                                                        modifAccess(
                                                            item, 1, context);
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
                                        visible: !existEnfant(
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
                                                        modifAccess(
                                                            suggestionList[i],
                                                            2,
                                                            context);
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
}
