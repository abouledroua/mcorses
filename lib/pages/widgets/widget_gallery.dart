// ignore_for_file: avoid_print

import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:mcorses/classes/data.dart';
import 'package:mcorses/classes/photo.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view_gallery.dart';

class GalleryWidget extends StatefulWidget {
  final PageController pageController;
  final int index;
  final String folder;
  final bool delete;
  final List<Photo> myImages;
  GalleryWidget(
      {Key? key,
      required this.folder,
      required this.delete,
      required this.index,
      required this.myImages})
      : pageController = PageController(initialPage: index),
        super(key: key);

  @override
  _GalleryWidgetState createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  late int index = widget.index;
  late bool delete;
  late String folder;
  late List<Photo> myImages;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    folder = widget.folder;
    myImages = widget.myImages;
    delete = widget.delete;
    super.initState();
  }

  deleteEnseignant() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/DELETE_GALLERY.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_PHOTO": myImages[index].id.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var result = response.body;
            if (result != "0") {
              Data.showSnack('Image supprimé ...', Colors.green);
              Navigator.of(context).pop("delete");
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
                    desc: 'Probleme de Connexion avec le serveur !!!')
                .show();
          }
        })
        .catchError((error) {
          print("erreur : $error");
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme de Connexion avec le serveur !!!')
              .show();
        });
  }

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath =
        '$appDocumentsPath/GALLERY/${myImages[index].chemin}'; // 3
    return filePath;
  }

  void saveFile() async {
    Uri myUri = Uri.parse(Data.getImage(myImages[index].chemin, "GALLERY"));
    var response = await http.get(myUri);
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    File file = File(documentDirectory.path + myImages[index].chemin);
    file.writeAsBytesSync(response.bodyBytes);
    Data.showSnack("Image enregistré avec succée ...", Colors.green);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Scaffold(
              body: Stack(alignment: Alignment.bottomCenter, children: [
        PhotoViewGallery.builder(
            loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                      color: Data.darkColor[
                          Random().nextInt(Data.darkColor.length - 1) + 1]),
                ),
            onPageChanged: (index) => setState(() => this.index = index),
            pageController: widget.pageController,
            itemCount: myImages.length,
            builder: (context, i) {
              final image = myImages[i];
              return PhotoViewGalleryPageOptions(
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 4,
                  imageProvider:
                      NetworkImage(Data.getImage(image.chemin, folder)));
            }),
        Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Photo ${index + 1} / ${myImages.length}",
                      style: const TextStyle(color: Colors.white)),
                  /*   InkWell(
                      onTap: () {
                        saveFile();
                      },
                      child: Row(children: const [
                        Text("Enregistrer ",
                            style: TextStyle(color: Colors.white)),
                        Icon(Icons.download, color: Colors.white)
                      ])),*/
                  !Data.currentUser!.isAdmin && delete
                      ? InkWell(
                          onTap: () {
                            AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.QUESTION,
                                    showCloseIcon: true,
                                    title: 'Confirmation',
                                    btnOkText: "Oui",
                                    btnCancelText: "Non",
                                    btnOkOnPress: () {
                                      setState(() {
                                        deleteEnseignant();
                                      });
                                    },
                                    btnCancelOnPress: () {},
                                    desc:
                                        'Voulez vraiment supprimer cette photo ?')
                                .show();
                          },
                          child: Row(children: const [
                            Text("Supprimer ",
                                style: TextStyle(color: Colors.white)),
                            Icon(Icons.delete, color: Colors.white)
                          ]))
                      : const SizedBox(height: 0, width: 0)
                ]))
      ])));
}
