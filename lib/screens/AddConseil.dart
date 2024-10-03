import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/ConseilService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

class AddConseil extends StatefulWidget {
  const AddConseil({super.key});

  @override
  State<AddConseil> createState() => _AddConseilState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AddConseilState extends State<AddConseil> {
  TextEditingController _titreController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool isRecorderReady = false;
  late Acteur acteur = Acteur();
  bool _isLoading = false;
  String? imageSrc;
  File? photoUploaded;
  File? _videoUploaded;
  late String videoSrc;
  File? audiosUploaded;
  final _tokenTextController = TextEditingController();
  final _tokenAudioController = TextEditingController();
  final _tokenImageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  double _progressValue = 0;
  bool _hasUploadStarted = false;
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isRecording = false, isPlaying = false;
  String? recordingPath;
  Timer? _timer;
  int _elapsedSeconds = 0;

  void setProgress(double value) async {
    setState(() {
      _progressValue = value;
    });
  }

  void _startTimer() {
    _elapsedSeconds = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (!isRecording) {
        timer.cancel();
      } else {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(imagePath);
    final images = File('${directory.path}/$name');
    return images;
  }

  Future<void> _pickVideo(ImageSource source) async {
    final video = await ImagePicker().pickVideo(source: source);
    if (video == null) return;

    final videoFile = File(video.path);
    setState(() {
      _videoUploaded = videoFile;
      _tokenTextController.text = _videoUploaded!.path.toString();
      videoSrc = videoFile.path;
      _hasUploadStarted = true;
    });

    // Mocking upload progress
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(Duration(milliseconds: 40));
      setProgress(i / 100);
    }

    setState(() {
      _hasUploadStarted = false;
    });
  }

  Future<void> _showVideoSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: const Text('Choisir une source'),
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    _pickVideo(ImageSource.camera);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.videocam, size: 40),
                      Text('Camera'),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    _pickVideo(ImageSource.gallery);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.video_library, size: 40),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final images = await getImage(source);
    if (images != null) {
      setState(() {
        photoUploaded = images;
        _tokenImageController.text = photoUploaded!.path.toString();

        imageSrc = images.path;
      });
    }
  }

  Future<File?> getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;

    return File(image.path);
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: const Text('Choisir une source'),
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    _pickImage(ImageSource.camera);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.camera_alt, size: 40),
                      Text('Camera'),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    _pickImage(ImageSource.gallery);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.image, size: 40),
                      Text('Galerie photo'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
  }

  @override
  void dispose() {
    super.dispose();
     _timer?.cancel();
    _tokenTextController.dispose();
    _tokenAudioController.dispose();
    _tokenImageController.dispose();
  }

 
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
            backgroundColor: d_colorOr,
            centerTitle: true,
            toolbarHeight: 75,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
            title: const Text(
              "Ajout conseil ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               SizedBox(
                height: 10,
              ),
              Form(
                key: formkey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Titre conseil",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez remplir les champs";
                          }
                          return null;
                        },
                        controller: _titreController,
                        decoration: InputDecoration(
                          hintText: "titre conseil",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Description",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez remplir les champs";
                          }
                          return null;
                        },
                        controller: _descriptionController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Description",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _tokenTextController.text.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Video Source",
                                style: TextStyle(
                                    color: (Colors.black), fontSize: 18),
                              ),
                            ),
                          )
                        : Container(),
                    _tokenTextController.text.isNotEmpty
                        ? _videoUploade()
                        : Container(),
                    _tokenImageController.text.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Image Source",
                                style: TextStyle(
                                    color: (Colors.black), fontSize: 18),
                              ),
                            ),
                          )
                        : Container(),
                    _tokenImageController.text.isNotEmpty
                        ? _imageUploade()
                        : Container(),
                    _tokenAudioController.text.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Audio Source",
                                style: TextStyle(
                                    color: (Colors.black), fontSize: 18),
                              ),
                            ),
                          )
                        : Container(),
                    _tokenAudioController.text.isNotEmpty
                        ? _audioUploade()
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                      // _buildUi(),
                          isRecording
                              ? Text(
                                  'Durée: ${_elapsedSeconds}s',
                                  style: TextStyle(fontSize: 20),
                                )
                              : Container(),
                          _hasUploadStarted
                              ? LinearProgressIndicator(
                                  color: d_colorGreen,
                                  backgroundColor: d_colorOr,
                                  value: _progressValue,
                                )
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.camera,
                                  size: 30,
                                ),
                                onPressed: _showImageSourceDialog,
                              ),
                              IconButton(
                                  onPressed: _showVideoSourceDialog,
                                  icon: Icon(
                                    Icons.video_camera_front_rounded,
                                    size: 30,
                                  )),
                                   _recordingButton()
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (formkey.currentState!.validate()) {
                            final String titre = _titreController.text;
                            final String description =
                                _descriptionController.text;
                            final String videoFile = _tokenTextController.text;
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              if (_videoUploaded != null ||
                                  photoUploaded != null ||
                                  audiosUploaded != null) {
                                await ConseilService()
                                    .creerConseil(
                                        titreConseil: titre,
                                        descriptionConseil: description,
                                        videoConseil: _videoUploaded,
                                        photoConseil: photoUploaded,
                                        audioConseil: audiosUploaded,
                                        acteur: acteur)
                                    .then((value) => {
                                          // FirebaseApi()
                                          //     .sendPushNotificationToTopic(
                                          //         'Nouveau conseil', titre),
                                          _titreController.clear(),
                                          _descriptionController.clear(),
                                          _tokenTextController.clear(),
                                          _tokenAudioController.clear(),
                                          _tokenImageController.clear(),
                                          setState(() {
                                            _videoUploaded = null;
                                            photoUploaded = null;
                                            audiosUploaded = null;
                                            _isLoading = false;
                                          }),
                                          Provider.of<ConseilService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          Navigator.of(context).pop()
                                        })
                                    .catchError((onError) => {
                                          print("Error: " + onError.toString()),
                                          setState(() {
                                            _isLoading = false;
                                          }),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Text(
                                                    "Une erreur est survenu lors de l'ajout",
                                                    style: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                              duration: Duration(seconds: 5),
                                            ),
                                          )
                                        });
                              } else {
                                await ConseilService()
                                    .creerConseil(
                                        titreConseil: titre,
                                        descriptionConseil: description,
                                        acteur: acteur)
                                    .then((value) => {
                                          // FirebaseApi()
                                          //     .sendPushNotificationToTopic(
                                          //         'Nouveau conseil', titre),
                                          _titreController.clear(),
                                          _descriptionController.clear(),
                                          _tokenTextController.clear(),
                                          setState(() {
                                            _isLoading = false;
                                          }),
                                          Provider.of<ConseilService>(context,
                                                  listen: false)
                                              .applyChange(),

                                          Navigator.of(context).pop()
                                        })
                                    .catchError((onError) => {
                                          print("Error: " + onError.toString()),
                                          setState(() {
                                            _isLoading = false;
                                          }),
                                          //              ScaffoldMessenger.of(context).showSnackBar(
                                          //   const SnackBar(
                                          //     content: Row(
                                          //       children: [
                                          //         Text(
                                          //           "La taille des fichiers ne doit pas depassé 25 MB",
                                          //           style: TextStyle(
                                          //               overflow: TextOverflow.ellipsis),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //     duration: Duration(seconds: 5),
                                          //   ),
                                          // )
                                        });
                              }
                            } catch (e) {
                              print("Error: " + e.toString());
                              setState(() {
                                _isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Text(
                                        "Une erreur est survenu lors de l'ajout",
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // Orange color code
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize: const Size(290, 45),
                        ),
                        child: Text(
                          "Ajouter",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _recordingButton() {
    return IconButton(
      icon: Icon(
        isRecording ? Icons.stop : Icons.mic,
        size: 30,
      ),
      onPressed: () async {
        if (isRecording) {
          String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filePath;
              audiosUploaded = File(filePath);
              print("My Audio path : ${audiosUploaded}");
              _tokenAudioController.text = filePath;
            });
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocumentsDir =
                await getApplicationDocumentsDirectory();
            final String filePath =
                path.join(appDocumentsDir.path, "recording.wav");
            await audioRecorder.start(const RecordConfig(), path: filePath);
            setState(() {
              isRecording = true;
              recordingPath = null;
            });
            _startTimer();
          }
        }
      },
    );
  }

  Widget _videoUploade() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        cursorColor: d_colorGreen,
        decoration: InputDecoration(
          hintText: "video upload",
          enabled: false,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        controller: _tokenTextController,
      ),
    );
  }

  Widget _imageUploade() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        cursorColor: d_colorGreen,
        enabled: false,
        decoration: InputDecoration(
          hintText: "Image upload",
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        controller: _tokenImageController,
      ),
    );
  }

  Widget _audioUploade() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        cursorColor: d_colorGreen,
        enabled: false,
        decoration: InputDecoration(
          hintText: "Audio upload",
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        controller: _tokenAudioController,
      ),
    );
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 60),
        showCloseIcon: true);
  }

  void showSnackBar(BuildContext context, String message,
      {Color? backgroundColor,
      Duration duration = const Duration(seconds: 4),
      bool showCloseIcon = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        showCloseIcon: showCloseIcon,
      ),
    );
  }
}

// _hasUploadStarted
//     ? LinearProgressIndicator(
//         color: d_colorGreen,
//         backgroundColor: d_colorGreen,
//         value: _progressValue,
//       )
//     : Container(),
// _hasUploadStarted
//     ? MaterialButton(
//         color: d_colorGreen,
//         child: const Text(
//           "Cancel",
//           style: TextStyle(
//               color: Colors.white70, fontWeight: FontWeight.bold),
//         ),
//         onPressed: () async {
//           try {
//             await ApiVideoUploader.cancelAll();
//           } catch (e) {
//             log("Failed to cancel video: $e");
//           }
//         },
//       )
//     : Container(),
// photoUploaded != null
//     ? Center(
//         child: Image.file(
//         photoUploaded!,
//         width: double.infinity,
//         height: 200,
//         fit: BoxFit.cover,
//       ))
//     : Text("aucun image"),
extension ErrorExtension on Exception {
  String get message {
    if (this is PlatformException) {
      return (this as PlatformException).message ?? "Unknown error";
    }
    return toString();
  }
}
