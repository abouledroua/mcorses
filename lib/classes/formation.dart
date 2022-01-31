import 'package:azlistview/azlistview.dart';

class Formation extends ISuspensionBean {
  String titre, details, image;
  int id, etat, nbDemande, nbInscris;
  List idAdmin;
  Formation(
      {required this.titre,
      required this.details,
      required this.nbInscris,
      required this.nbDemande,
      required this.idAdmin,
      required this.image,
      required this.id,
      required this.etat});

  @override
  String getSuspensionTag() => titre[0].toUpperCase();
}
