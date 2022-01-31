// ignore_for_file: avoid_print

import 'package:mcorses/classes/data.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String serverIP = Data.getServerIP();
  String radio = "LOCAL";
  String local = Data.getLocalIP();
  String internet = Data.getInternetIP();
  int mode = Data.getNetworkMode();

  @override
  void initState() {
    super.initState();
    (mode == 1) ? radio = "LOCAL" : radio = "INTERNET";
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
                drawer:
                    Data.currentUser == null ? null : Data.myDrawer(context),
                appBar: AppBar(
                    centerTitle: true,
                    title: const Text("Paramêtres"),
                    leading: Navigator.canPop(context)
                        ? IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white))
                        : null),
                body: bodyContent())));
  }

  bodyContent() {
    return ListView(primary: false, shrinkWrap: true, children: [
      Padding(
          padding: const EdgeInsets.all(10),
          child: Text("Type du Réseau",
              style: Theme.of(context).textTheme.caption)),
      RadioListTile(
          selectedTileColor: Colors.blue,
          title: Text("Local",
              style: TextStyle(
                  color: (mode == 1)
                      ? Colors.black
                      : Theme.of(context).textTheme.caption!.color,
                  fontWeight:
                      (mode == 1) ? FontWeight.bold : FontWeight.normal)),
          secondary: Icon(Icons.network_wifi,
              color: (mode == 2) ? Colors.blueGrey : Colors.black),
          value: "LOCAL",
          tileColor: (mode == 1) ? Colors.blue[200] : Colors.transparent,
          groupValue: radio,
          onChanged: (val) {
            setState(() {
              mode = 1;
              serverIP = Data.getLocalIP();
            });
            Data.setNetworkMode(1);
            Data.setServerIP(serverIP);
            radio = val.toString();
          }),
      RadioListTile(
          title: Text("Internet",
              style: TextStyle(
                  color: (mode == 2)
                      ? Colors.black
                      : Theme.of(context).textTheme.caption!.color,
                  fontWeight:
                      (mode == 2) ? FontWeight.bold : FontWeight.normal)),
          secondary: Icon(Icons.cast_connected,
              color: (mode == 1) ? Colors.blueGrey : Colors.black),
          value: "INTERNET",
          tileColor: (mode == 2) ? Colors.blue[200] : Colors.transparent,
          groupValue: radio,
          onChanged: (val) {
            setState(() {
              mode = 2;
              serverIP = Data.getInternetIP();
            });
            radio = val.toString();
            Data.setNetworkMode(mode);
            Data.setServerIP(serverIP);
          }),
      Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          child: const Divider(color: Colors.blue)),
      Container(
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.all(8.0),
          child: Text(
              "Adresse du Serveur" + ((mode == 1) ? " Local" : " Internet"),
              style: Theme.of(context).textTheme.caption)),
      Stack(children: [
        Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Visibility(
                visible: mode == 1,
                child: TextFormField(
                    initialValue: local,
                    onChanged: (value) {
                      serverIP = value;
                      setState(() {
                        local = value;
                      });
                      Data.setLocalIP(value);
                      Data.setServerIP(value);
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        hintText: "Serveur Local",
                        prefixIcon: Icon(Icons.pie_chart))))),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Visibility(
                visible: mode != 1,
                child: TextFormField(
                    initialValue: internet,
                    onChanged: (value) {
                      serverIP = value;
                      setState(() {
                        internet = value;
                      });
                      Data.setInternetIP(value);
                      Data.setServerIP(value);
                    },
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        hintText: "Serveur Internet",
                        prefixIcon: Icon(Icons.pie_chart)))))
      ]),
      Visibility(
          visible: Navigator.canPop(context),
          child: Center(
              child: Container(
                  width: 130,
                  color: Colors.blue,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text("Retour",
                          style:
                              TextStyle(color: Colors.white, fontSize: 16))))))
    ]);
  }
}
