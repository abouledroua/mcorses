// ignore_for_file: avoid_print

import 'dart:io';
import 'package:mcorses/classes/data.dart';
import 'package:mcorses/classes/fetch_news.dart';
import 'package:mcorses/classes/gest_files.dart';
import 'package:mcorses/classes/mycours.dart';
import 'package:mcorses/classes/myphoto.dart';
import 'package:mcorses/pages/lists/list_annonces.dart';
import 'package:mcorses/pages/lists/list_formations.dart';
import 'package:mcorses/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<Widget> screens = [];
  List<Widget> items = <Widget>[];
  bool etatPrec = false;

  verifierEtat() async {
    while ((Data.currentUser != null) &&
        (Data.currentUser!.isAdmin || Data.currentUser!.isFormateur)) {
      if (etatPrec != GestFiles.uploading || GestFiles.uploading) {
        etatPrec = GestFiles.uploading;
        setState(() {});
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<bool> _onWillPop() async {
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
                        "Voulez-vous vraiment quitter l'application ?"),
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
  }

  majItems() {
    items = <Widget>[
      const Icon(Icons.announcement_outlined, color: Colors.white),
      const Icon(Icons.book_outlined, color: Colors.white),
    ];
    if (!Data.production) {
      items.add(const FaIcon(FontAwesomeIcons.cogs, color: Colors.white));
    }
  }

  majScreens() {
    screens = [
      const ListAnnnonces(),
      const ListFormation(),
      const SettingPage()
    ];
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    Data.index = 1;
    Data.isLogged = true;
    Data.myContext = context;
    majItems();
    majScreens();
    GestFiles.uploadFiles();
    verifierEtat();
    Fetch.fetchNewDemandes();
    super.initState();
  }

  Color getItemColor() {
    switch (Data.index) {
      case 0:
        return Colors.cyan;
      case 1:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget bottomNavigationBar() => BottomNavigationBar(
          currentIndex: Data.index,
          onTap: (value) {
            setState(() {
              Data.index = value;
              majScreens();
              majItems();
            });
          },
          elevation: 0,
          backgroundColor: Colors.white,
          fixedColor: Data.index == 0 ? Colors.cyan : Colors.green,
          iconSize: 32,
          selectedLabelStyle:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 18),
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.announcement,
                    color:
                        Data.index == 0 ? Colors.cyan : Colors.grey.shade400),
                label: "Annonces",
                backgroundColor: Colors.white),
            BottomNavigationBarItem(
                icon: Icon(Icons.book,
                    color:
                        Data.index == 1 ? Colors.green : Colors.grey.shade400),
                label: "Formations",
                backgroundColor: Colors.white)
          ]);

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return Container(
        color: getItemColor(),
        child: SafeArea(
            child: WillPopScope(
                onWillPop: _onWillPop,
                child: ClipRect(
                    child: Scaffold(
                        resizeToAvoidBottomInset: true,
                        bottomNavigationBar: bottomNavigationBar(),
                        body: Column(children: [
                          Expanded(child: screens[Data.index]),
                          GestFiles.uploading
                              ? GestFiles.typeSent == 1
                                  ? jaugeUploadCourse()
                                  : jaugeUploadImage()
                              : Container()
                        ]))))));
  }

  Widget jaugeUploadCourse() {
    double pourc =
        GestFiles.total == 0 ? 0 : GestFiles.sent * 100 / GestFiles.total;
    pourc = Data.truncateToDecimalPlaces(pourc, 2);
    MyCours? item = GestFiles.sentItem;
    return Container(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Divider(),
          item == null
              ? Container()
              : Row(children: [
                  CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Image.asset(
                          item.extension.toUpperCase() == ".PDF"
                              ? "images/pdf.png"
                              : item.extension.toUpperCase() == ".MP4"
                                  ? "images/mp4.png"
                                  : item.extension.toUpperCase() == ".MP3"
                                      ? "images/audio.jpg"
                                      : item.extension.toUpperCase() ==
                                                  ".PPT" ||
                                              item.extension.toUpperCase() ==
                                                  ".PPTX"
                                          ? "images/power.png"
                                          : "images/doc.png",
                          fit: BoxFit.contain)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(item.designation,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(fontSize: 20)))
                ]),
          const SizedBox(height: 3),
          Row(children: [
            Text("Chargement ( " + pourc.toStringAsFixed(2) + " % ) "),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: LinearProgressIndicator(
                        value: GestFiles.total == 0
                            ? 0
                            : GestFiles.sent / GestFiles.total)))
          ])
        ]));
  }

  Widget jaugeUploadImage() {
    double pourc =
        GestFiles.total == 0 ? 0 : GestFiles.sent * 100 / GestFiles.total;
    pourc = Data.truncateToDecimalPlaces(pourc, 2);
    MyPhoto? item = GestFiles.sentItem;
    return Container(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Divider(),
          Row(children: [
            CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.file(File(item!.chemin), fit: BoxFit.contain)),
            const SizedBox(width: 6),
            Text("Chargement ( " + pourc.toStringAsFixed(2) + " % ) "),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: LinearProgressIndicator(
                        value: GestFiles.total == 0
                            ? 0
                            : GestFiles.sent / GestFiles.total)))
          ])
        ]));
  }
}
