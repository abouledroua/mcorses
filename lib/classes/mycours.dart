import 'package:azlistview/azlistview.dart';

class MyCours extends ISuspensionBean {
  String designation, path, base64Image, extension;
  int idFormation, idCours;
  MyCours(
      {required this.designation,
      required this.idCours,
      required this.base64Image,
      required this.extension,
      required this.path,
      required this.idFormation});

  @override
  String getSuspensionTag() => designation[0].toUpperCase();
}
