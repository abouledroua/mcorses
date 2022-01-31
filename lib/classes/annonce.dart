import 'package:azlistview/azlistview.dart';

class Annonce extends ISuspensionBean {
  String designation, date;
  int id, etat;
  List idImages;
  List chemin;
  Annonce(
      {required this.designation,
      required this.date,
      required this.id,
      required this.idImages,
      required this.chemin,
      required this.etat});

  @override
  String getSuspensionTag() => designation[0].toUpperCase();
}
