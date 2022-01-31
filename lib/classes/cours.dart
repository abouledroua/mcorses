import 'package:azlistview/azlistview.dart';

class Cours extends ISuspensionBean {
  String designation, file;
  int id, idUser, etat, idFormation, visit, access;
  Cours(
      {required this.designation,
      required this.access,
      required this.visit,
      required this.idFormation,
      required this.idUser,
      required this.file,
      required this.id,
      required this.etat});

  @override
  String getSuspensionTag() => designation[0].toUpperCase();
}
