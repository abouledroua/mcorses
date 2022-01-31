// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'package:mcorses/classes/data.dart';
import 'package:http/http.dart' as http;
import 'package:mcorses/classes/mycours.dart';
import 'package:dio/dio.dart';
import 'package:mcorses/classes/myphoto.dart';

class GestFiles {
  static List<MyCours> myFiles = [];
  static List<MyPhoto> myImages = [];
  static bool uploading = false, isThereNewUploaded = false;
  static int sent = 0, total = 0;
  static var sentItem;
  static int? typeSent;

  static uploadFiles() async {
    while ((Data.currentUser != null) &&
        (Data.currentUser!.isAdmin || Data.currentUser!.isFormateur)) {
      if ((myFiles.isEmpty && myImages.isEmpty) || (uploading)) {
        print(uploading
            ? "GestFiles : Someone else is uploading ..."
            : "GestFiles : Waiting for upload");
        //   _wasUploading = myFiles.isNotEmpty || myImages.isNotEmpty;
      } else {
        // cancelUploadNotification();
        // _wasUploading = true;
        if (myFiles.isNotEmpty) {
          sendFile(myFiles[0]);
        } else {
          sendImage(myImages[0]);
        }
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  static Future sendFile(MyCours item) async {
    uploading = true;
    var dio = Dio();
    String serverDir = Data.getServerDirectory();
    final String url = "$serverDir/UPLOAD_COURS_FILES.php";
    Map<String, dynamic> body = {};
    body['ID_FORMATION'] = item.idFormation.toString();
    body['ID_USER'] = Data.currentUser!.idUser.toString();
    body['DESIGNATION'] = item.designation;
    body['DATA'] = item.base64Image;
    body['EXT'] = item.extension;
    try {
      //  Response? response = await dio.post(url, data: FormData.fromMap(body),
      sentItem = item;
      typeSent = 1;
      Response? response = await dio.post(url, data: FormData.fromMap(body),
          onSendProgress: (int psent, int ptotal) {
        sent = psent;
        total = ptotal;
        print("GestFiles : $sent $total");
      }).then((value) {
        print("GestFiles is terminated .........");
        isThereNewUploaded = true;
        sentItem = null;
        uploading = false;
      }).onError((error, stackTrace) {
        print("GestFiles : erreur : $error");
        print("GestFiles : Error Uploading Image");
      });
      myFiles.removeAt(0);
      print("GestFiles Response : " + response!.data.toString());
    } catch (e) {
      print("GestFiles : erreur : $e");
      print("GestFiles : Error Uploading Image");
    }
  }

  static Future sendImage(MyPhoto item) async {
    uploading = true;
    var dio = Dio();
    String serverDir = Data.getServerDirectory();
    final String url = "$serverDir/UPLOAD_ANNONCE_IMAGE.php";
    Map<String, dynamic> body = {};
    body['ID_ANNONCE'] = item.idAnnonce.toString();
    body['ID_USER'] = Data.currentUser!.idUser.toString();
    body['DATA'] = item.base64Image;
    body['EXT'] = item.extension;
    try {
      //  Response? response = await dio.post(url, data: FormData.fromMap(body),
      sentItem = item;
      typeSent = 2;
      Response? response = await dio.post(url, data: FormData.fromMap(body),
          onSendProgress: (int psent, int ptotal) {
        sent = psent;
        total = ptotal;
        print("GestFiles : $sent $total");
      }).then((value) {
        print("GestFiles is terminated .........");
        isThereNewUploaded = true;
        sentItem = null;
        uploading = false;
      }).onError((error, stackTrace) {
        print("GestFiles : erreur : $error");
        print("GestFiles : Error Uploading Image");
      });
      myImages.removeAt(0);
      print("GestFiles Response : " + response!.data.toString());
    } catch (e) {
      print("GestFiles : erreur : $e");
      print("GestFiles : Error Uploading Image");
    }
  }

  static void sendHttp(MyCours item) async {
    uploading = true;
    String serverDir = Data.getServerDirectory();
    final String url = "$serverDir/UPLOAD_COURS_FILES.php";
    print(url);
    Uri myUri = Uri.parse(url);
    var body = {};
    body['ID_FORMATION'] = item.idFormation.toString();
    body['ID_USER'] = Data.currentUser!.idUser.toString();
    body['DESIGNATION'] = item.designation;
    body['DATA'] = item.base64Image;
    body['EXT'] = item.extension;
    http.post(myUri, body: body).then((result) {
      if (result.statusCode == 200) {
        isThereNewUploaded = true;
      } else {
        print("GestFiles : Error Uploading Image");
      }
      uploading = false;
    }).catchError((error) {
      print("GestFiles : erreur : $error");
    });

    myFiles.removeAt(0);
  }

/*  static void _uploadDio(MyCours item) async {
    uploading = true;
    String serverDir = Data.getServerDirectory();
    final String uploadurl = "$serverDir/UPLOAD_FILE.php";
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(item.path,
          filename: p.basename(item.path))
    });
    try {
      sentItem = item;
      myFiles.removeAt(0);
      Dio dio = Dio();
      Response response = await dio.post(uploadurl,
          data: formdata,
          options: Options(headers: {
       //     "accept": "*",
            "Auhtorization": "Bearer accresstoken",
            "Content-Type": "multipart/form-data",
          }), onSendProgress: (int psent, int ptotal) {
        sent = psent;
        total = ptotal;
        print("GestFiles : $sent $total");
      });

      if (response.statusCode == 200) {
        print(response.toString());
        print("GestFiles is terminated .........");
        isThereNewUploaded = true;
        sentItem = null;
        uploading = false;
      } else {
        print("Error during connection to server.");
      }
    } catch (e) {
      print("GestFiles : erreur : $e");
      print("GestFiles : Error Uploading Image");
    }
  }*/
}
