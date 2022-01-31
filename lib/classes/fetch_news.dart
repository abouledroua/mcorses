// ignore_for_file: avoid_print

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mcorses/classes/data.dart';
import 'package:mcorses/classes/notifications.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Fetch {
  static late SharedPreferences _prefs;
  static bool _fetchDemandes = false;

  static void fetchNewDemandes() async {
    while (true) {
      if (Data.currentUser == null || _fetchDemandes) {
        print(_fetchDemandes
            ? "Someone else is fetching Demandes d'access ..."
            : "you are not connected");
      } else {
        _getNewDemandes();
      }
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  static _getNewDemandes() async {
    _fetchDemandes = true;
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_DEMANDE_ACCESS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_USER": Data.currentUser!.idUser.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            int cp = 0;
            String idDemande;
            _prefs = await SharedPreferences.getInstance();
            String prefKey = 'DemandesAccess';
            //_prefs.setStringList(prefKey, []);
            List<String> list = [];
            List<String> _demandes = _prefs.getStringList(prefKey) ?? [];
            for (var m in responsebody) {
              idDemande = m['ID_DEMANDE'];
              if (idDemande.isNotEmpty) {
                if (!_demandes.contains(idDemande)) {
                  cp++;
                  list.add(idDemande);
                }
              }
            }
            if (cp > 0) {
              print("cp=$cp");
              cancelDemandeAccessNotification();
              createDemandeAccessNotification(cp, list);
            }
            print("responsebody=$responsebody");
          }
        })
        .catchError((error) {
          print("erreur : $error");
        });
    _fetchDemandes = false;
  }
}
