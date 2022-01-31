// ignore_for_file: avoid_print
// ignore_for_file: empty_catches

import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mcorses/classes/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class FileReader extends StatefulWidget {
  final String file, name;
  const FileReader({Key? key, required this.file, required this.name})
      : super(key: key);

  @override
  _FileReaderState createState() => _FileReaderState();
}

class _FileReaderState extends State<FileReader> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late SharedPreferences prefs;
  late VideoPlayerController _controller;
  String file = "",
      name = "",
      localPath = "",
      filename = "",
      fileExtension = "";
  bool pdfFile = false,
      mediaFile = false,
      powerFile = false,
      downloading = false,
      loading = true,
      initComplete = false;
  int _total = 0, _received = 0;
  late http.StreamedResponse _response;
  final List<int> _bytes = [];

  init() async {
    prefs = await SharedPreferences.getInstance();
    file = Data.getFile(widget.file);
    filename = p.basenameWithoutExtension(file);
    fileExtension = p.extension(file).toUpperCase();
    getLocalFile();
  }

  @override
  void dispose() {
    if (mediaFile) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    name = widget.name;
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mediaFile = (fileExtension == ".MP4" || fileExtension == ".MP3");
    powerFile = (fileExtension == ".PPT" || fileExtension == ".PPTX");
    pdfFile = fileExtension == ".PDF";
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        if (Data.production) {
          secureScreen();
        } else {
          unsecureScreen();
        }
      }
    } catch (e) {
      print("error : $e");
    }
    Data.setSizeScreen(context);
    print("localPath=$localPath");
    if (localPath.isEmpty && initComplete && !downloading) {
      Navigator.pop(context);
    }
    return Scaffold(
        backgroundColor: mediaFile ? Colors.black : Colors.white,
        appBar: AppBar(
            title: Text(name),
            backgroundColor: mediaFile
                ? Colors.red
                : powerFile
                    ? Colors.orange
                    : Colors.blue,
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.refresh,
                      color: Colors.white, semanticLabel: 'Actualiser'),
                  onPressed: () {
                    AwesomeDialog(
                            context: context,
                            dialogType: DialogType.QUESTION,
                            showCloseIcon: true,
                            title: 'Confirmation',
                            btnOkText: "Oui",
                            btnCancelText: "Non",
                            btnOkOnPress: () {
                              setState(() {
                                loading = true;
                              });
                              _downloadPdfFile(file);
                            },
                            btnCancelOnPress: () {},
                            desc: 'Voulez vraiment re-télécharger ce fichier ?')
                        .show();
                  }),
              IconButton(
                  icon: const Icon(Icons.bookmark,
                      color: Colors.white, semanticLabel: 'Bookmark'),
                  onPressed: () {
                    _pdfViewerKey.currentState?.openBookmarkView();
                  })
            ]),
        body: loading || downloading || fileExtension.isEmpty
            ? waitWidget()
            : pdfFile
                ? SfPdfViewer.file(File(localPath), key: _pdfViewerKey)
                : mediaFile
                    ? openMediaPlayer()
                    //: powerFile
                    //  ? FileReaderView(filePath: localPath)
                    : const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: FittedBox(
                                child: Text("Format Inconnu !!!!",
                                    style: TextStyle(
                                        fontSize: 100, color: Colors.red))))));
    //: SfPdfViewer.network(file, key: _pdfViewerKey));
  }

  _downloadPdfFile(networkPath) async {
    setState(() {
      downloading = true;
    });
    _received = 0;
    _total = 0;
    _response =
        await http.Client().send(http.Request('GET', Uri.parse(networkPath)));
    _total = _response.contentLength ?? 0;
    _response.stream.listen((value) {
      print("received data = $_received/$_total");
      _bytes.addAll(value);
      _received += value.length;
      setState(() {});
    }).onDone(() async {
      var documentDirectory = await getTemporaryDirectory();
      var firstPath = documentDirectory.path + "/mf";
      int r = Random().nextInt(900) + 100;
      var filePathAndName = documentDirectory.path +
          '/mf/${p.basenameWithoutExtension(networkPath)}.${r.toString()}';
      await Directory(firstPath).create(recursive: true); // <-- 1
      File file2 = File(filePathAndName); // <-- 2
      await file2.writeAsBytes(_bytes);
      prefs.setString(filename, filePathAndName);
      localPath = filePathAndName;
      typeOfLocalPath();
      setState(() {
        downloading = false;
      });
    });
  }

  getLocalFile() async {
    localPath = prefs.getString(filename) ?? '';
    if (localPath.isEmpty) {
      _downloadPdfFile(file);
    } else {
      bool fileexist = await File(localPath).exists();
      if (!fileexist) {
        _downloadPdfFile(file);
      }
    }
    typeOfLocalPath();
    initComplete = true;
    loading = false;
    setState(() {});
  }

  typeOfLocalPath() {
    print("localPath=$localPath");
    mediaFile = (fileExtension == ".MP4" || fileExtension == ".MP3");
    powerFile = (fileExtension == ".PPT" || fileExtension == ".PPTX");
    pdfFile = fileExtension == ".PDF";

    if (mediaFile) {
      File media = File(localPath);
      _controller = VideoPlayerController.file(media) //'images/video.mp4')
        ..addListener(() => setState(() {}))
        ..setLooping(false)
        ..initialize().then((_) => _controller.play());
    }
  }

  secureScreen() async {
    // DISABLE SCREEN CAPTURE
    await FlutterWindowManager.addFlags(
        FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  unsecureScreen() async {
    // DISABLE SCREEN CAPTURE
    await FlutterWindowManager.addFlags(
        FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }

  openMediaPlayer() {
    return _controller.value.isInitialized
        ? MyMediaPlayer(controller: _controller)
        : const Center(child: CircularProgressIndicator());
  }

  waitWidget() {
    double pourc = _total == 0 ? 0 : _received / _total;
    int pourci = (pourc * 100).round();
    String pourcs = _total == 0
        ? ""
        : Data.formatBytes(_received, 2) + " / " + Data.formatBytes(_total, 2);
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Visibility(
          visible: _total > 0,
          child: Center(child: Text("$pourcs  ($pourci %)"))),
      Visibility(
          visible: _total > 0,
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Data.widthScreen / 6, vertical: 10),
              child: LinearProgressIndicator(value: pourc))),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(
            color: Data.darkColor[Random().nextInt(Data.darkColor.length)]),
        const SizedBox(width: 10),
        const Text("Télechargement en cours du fichier ...")
      ])
    ]));
  }
}

class MyMediaPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  const MyMediaPlayer({Key? key, required this.controller}) : super(key: key);

  @override
  _MyMediaPlayerState createState() => _MyMediaPlayerState();
}

class _MyMediaPlayerState extends State<MyMediaPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    _controller = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(alignment: Alignment.center, child: buildVideo()));
  }

  Widget buildVideo() {
    bool isMute = _controller.value.volume == 0;
    return Stack(children: [
      buildVideoPlayer(),
      Positioned.fill(child: BasicOverlayWidget(controller: _controller)),
      Positioned(
          top: 10,
          right: 10,
          child: CircleAvatar(
              radius: 15,
              backgroundColor: isMute ? Colors.grey : Colors.red,
              child: IconButton(
                  onPressed: () => _controller.setVolume(isMute ? 1 : 0),
                  icon: Icon(isMute ? Icons.volume_mute : Icons.volume_up,
                      size: 15))))
    ]);
  }

  Widget buildVideoPlayer() => AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller));
}

class BasicOverlayWidget extends StatelessWidget {
  final VideoPlayerController controller;
  const BasicOverlayWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          controller.value.isPlaying ? controller.pause() : controller.play(),
      child: Stack(children: [
        buildPlay(),
        Positioned(bottom: 0, left: 0, right: 0, child: buildIndicator())
      ]));

  Widget buildPlay() => controller.value.isPlaying
      ? Container()
      : Container(
          alignment: Alignment.center,
          color: Colors.black26,
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 80));

  Widget buildIndicator() =>
      VideoProgressIndicator(controller, allowScrubbing: true);
}
