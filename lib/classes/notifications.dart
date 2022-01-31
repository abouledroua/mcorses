import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mcorses/classes/data.dart';
import 'package:mcorses/pages/lists/list_formations.dart';
import 'package:shared_preferences/shared_preferences.dart';

int createUniqueId() => DateTime.now().millisecondsSinceEpoch.remainder(100000);

String _appTitle = 'Medical Courses';
int _idDemande = 1, _idAnnounce = 2, _idUpload = 3;

Future<void> createDemandeAccessNotification(int cp, List<String> ids) async {
  String s = cp > 1 ? 's' : '';
  String x = cp > 1 ? 'x' : '';
  String list = ids.join(',');
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: _idDemande,
          channelKey: 'demande_channel',
          title: _appTitle,
          payload: {'id': list},
          body:
              "Vous avez $cp nouvelle$x demande$s d'accés au$x formation$s...",
          notificationLayout: NotificationLayout.BigText));
}

listenDemandeNotification() =>
    AwesomeNotifications().actionStream.listen((notification) async {
      if (notification.channelKey == "demande_channel") {
        AwesomeNotifications()
            .getGlobalBadgeCounter()
            .then((value) => AwesomeNotifications().setGlobalBadgeCounter(0));
      }
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      String prefKey = 'DemandesAccess';
      List<String> _demandes = _prefs.getStringList(prefKey) ?? [];
      Map<String, String>? myPayload = notification.payload;
      String? p = myPayload!['id'];
      if (p != null) {
        List<String> myList = p.split(',');
        _demandes.addAll(myList);
        _prefs.setStringList(prefKey, _demandes);
      }
      if (Data.currentUser != null) {
        var route = PageRouteBuilder(
            transitionDuration: const Duration(seconds: 1),
            transitionsBuilder: (context, animation, secAnimation, child) {
              return Data.myAnimation(child, animation);
            },
            pageBuilder: (context, animation, secondaryAnimation) {
              return const ListFormation();
            });
        Navigator.push(Data.myContext, route);
      }
    });

Future<void> cancelDemandeAccessNotification() async =>
    await AwesomeNotifications().cancel(_idDemande);

Future<void> createAnnounceNotification() async =>
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: _idAnnounce,
            channelKey: 'annonce_channel',
            title: _appTitle,
            body: 'Nouvelle Annonces',
            notificationLayout: NotificationLayout.BigText));

Future<void> createUploadNotification(String notifTitle) async =>
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: _idUpload,
            progress: 5,
            channelKey: 'upload_Image_channel',
            title: _appTitle,
            body: notifTitle, //'En cours de chargement des images ...'
            notificationLayout: NotificationLayout.BigText));

Future<void> cancelAnnounceNotification() async =>
    await AwesomeNotifications().cancel(_idAnnounce);

Future<void> cancelUploadNotification() async =>
    await AwesomeNotifications().cancel(_idUpload);
