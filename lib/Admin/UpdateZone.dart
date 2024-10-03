import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/ZoneProduction.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/ZoneProductionService.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class UpdateZone extends StatefulWidget {
  final ZoneProduction zone;
  const UpdateZone({super.key, required this.zone});

  @override
  State<UpdateZone> createState() => _UpdateZoneState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _UpdateZoneState extends State<UpdateZone> {
  final formkey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  String? imageSrc;
  File? photo;
  late Acteur acteur;
  late ZoneProduction zoneProd;

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    zoneProd = widget.zone;
    nomController.text = zoneProd.nomZoneProduction!;
    latitudeController.text = zoneProd.latitude!;
    longitudeController.text = zoneProd.longitude!;

    super.initState();
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(imagePath);
    final image = File('${directory.path}/$name');
    return image;
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        photo = image;
        imageSrc = image.path;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
       appBar: AppBar(
             backgroundColor: d_colorGreen,
            centerTitle: true,
            toolbarHeight: 75,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: const Text(
          "Modification",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              overflow: TextOverflow.ellipsis),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(
            height: 150,
            child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: photo != null
                    ? Image.file(
                        photo!,
                        fit: BoxFit.fill,
                        width: 150,
                        height: 150,
                      )
                    
                        : 
                        Image.network(
                           "https://koumi.ml/api-koumi/ZoneProduction/${zoneProd.idZoneProduction}/image",
                           fit: BoxFit.fitWidth,
                        height: 150,
                        width: double.infinity,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/default_image.png',
                            fit: BoxFit.cover,
                          );
                        },
                          )),
          ),
          const SizedBox(height: 10),
          Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      "Nom de la zone",
                      style: TextStyle(color: (Colors.black), fontSize: 18),
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
                      controller: nomController,
                      decoration: InputDecoration(
                        hintText: "Nom de la zone",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 10),
                  const Text(
                    "Latitude",
                    style: TextStyle(color: (Colors.black), fontSize: 18),
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
                      controller: latitudeController,
                      decoration: InputDecoration(
                        hintText: "Latitude",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 10),
                  const Text(
                    "Longitude",
                    style: TextStyle(color: (Colors.black), fontSize: 18),
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
                      controller: longitudeController,
                      decoration: InputDecoration(
                        hintText: "Longitude",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: IconButton(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(
                          Icons.add_a_photo_rounded,
                          size: 100,
                        )),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                      onPressed: () async {
                        final String nom = nomController.text;
                        final String latitude = latitudeController.text;
                        final String longitude = longitudeController.text;
                        print("acteur : ${acteur.toString()}");

                        try {
                          if (photo == null) {
                            await ZoneProductionService()
                                .updateZone(
                                    idZoneProduction:
                                        zoneProd.idZoneProduction!,
                                    nomZoneProduction: nom,
                                    latitude: latitude,
                                    longitude: longitude,
                                    personneModif: acteur.nomActeur!)
                                .then((value) => {
                                      Provider.of<ZoneProductionService>(
                                              context,
                                              listen: false)
                                          .applyChange(),
                                      nomController.clear(),
                                      latitudeController.clear(),
                                      longitudeController.clear(),
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Row(
                                            children: [
                                              Text("Modifier avec succèss"),
                                            ],
                                          ),
                                          // duration: const Duration(seconds: 5),
                                        ),
                                      ),
                                      Navigator.of(context).pop(),
                                    })
                                .catchError((onError) {
                              print(onError.message);
                            });
                          } else {
                            await ZoneProductionService()
                                .updateZone(
                                    idZoneProduction:
                                        zoneProd.idZoneProduction!,
                                    nomZoneProduction: nom,
                                    latitude: latitude,
                                    longitude: longitude,
                                    personneModif: acteur.nomActeur!)
                                .then((value) => {
                                      Provider.of<ZoneProductionService>(
                                              context,
                                              listen: false)
                                          .applyChange(),
                                      nomController.clear(),
                                      latitudeController.clear(),
                                      longitudeController.clear(),
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Row(
                                            children: [
                                              Text("Modifier avec succèss"),
                                            ],
                                          ),
                                          // duration: const Duration(seconds: 5),
                                        ),
                                      ),
                                      Navigator.of(context).pop(),
                                    })
                                .catchError((onError) {
                              print(onError.message);
                            });
                          }
                        } catch (e) {
                          print(e.toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Text("Cette zone est existe déjà"),
                                ],
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: d_colorGreen, // Orange color code
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: const Size(290, 45),
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        "Modifier",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              ))
        ]),
      ),
    );
  }
}
