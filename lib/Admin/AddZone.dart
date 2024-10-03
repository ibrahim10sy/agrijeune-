import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/ZoneProductionService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class AddZone extends StatefulWidget {
   bool? isRoute;
   AddZone({super.key, this.isRoute});

  @override
  State<AddZone> createState() => _AddZoneState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _AddZoneState extends State<AddZone> {
  final formkey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  String? imageSrc;
  // late ValueNotifier<bool> isDialOpenNotifier;
  bool _isLoading = false;

  File? photo;
  late Acteur acteur;
  String? _currentAddress;
  Position? _currentPosition;

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          //  print(" Pos" + placemarks.toString());
          _currentAddress =
              "${place.street}, ${place.subLocality}, ${place.subAdministrativeArea!}, ${place.postalCode!}";
        });
      } else {
        setState(() {
          _currentAddress = "Adresse non disponible";
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération de l'adresse: $e");
      setState(() {
        _currentAddress = "Erreur lors de la récupération de l'adresse";
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    // isDialOpenNotifier = ValueNotifier<bool>(false);
    _getCurrentPosition();
    latitudeController.text = _currentPosition?.latitude.toString() ?? "";
    longitudeController.text = _currentPosition?.longitude.toString() ?? "";
    super.initState();
  }

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  Future<File> saveImagePermanently(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final name = path.basename(imagePath);
      final image = File('${directory.path}/$name');
      return File(imagePath).copy(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sauvegarde de l\'image : $e');
      rethrow;
    }
  }

  Future<File?> getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sélection de l\'image : $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        photo = image;
        imageSrc = image.path;
      });
      await saveImagePermanently(image.path);
    }
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Photo d'identité"),
          content: Wrap(
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Fermer le dialogue
                  _pickImage(ImageSource.camera);
                },
                child: Column(
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
                child: Column(
                  children: [
                    Icon(Icons.image, size: 40),
                    Text('Galerie photo'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: !(widget.isRoute ?? false)
              ? _isLoading : false,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: !(widget.isRoute ?? false)
              ? AppBar(
          backgroundColor: d_colorGreen,
          centerTitle: true,
          toolbarHeight: 75,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
          title: const Text(
            "Ajouter une Zone",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                overflow: TextOverflow.ellipsis),
          ),
        ) : null,
        body: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: photo != null
                    ? Image.file(
                        photo!,
                        fit: BoxFit.fitWidth,
                        height: 130,
                        width: 300,
                      )
                    : Container()),
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
                   
                    const SizedBox(height: 10),
                   !(widget.isRoute ?? false)
              ? SizedBox(
                      height: 60,
                      child: IconButton(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(
                          Icons.add_a_photo_rounded,
                          size: 60,
                        ),
                      ),
                    ) : Container(),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                        onPressed: () async {
                          final String nom = nomController.text;
                          final String latitude = latitudeController.text;
                          final String longitude = longitudeController.text;
                          print("acteur : ${acteur.toString()}");

                          try {
                            setState(() {
                              _isLoading = true;
                            });
                            if (photo == null) {
                              await ZoneProductionService()
                                  .addZone(
                                      nomZoneProduction: nom,
                                      latitude: latitude,
                                      longitude: longitude,
                                      acteur: acteur)
                                  .then((value) => {
                                        Provider.of<ZoneProductionService>(
                                                context,
                                                listen: false)
                                            .applyChange(),
                                        setState(() {
                                          _isLoading = false;
                                        }),
                                        nomController.clear(),
                                        latitudeController.clear(),
                                        longitudeController.clear(),
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Row(
                                              children: [
                                                Text("Ajouter avec succèss"),
                                              ],
                                            ),
                                            // duration: const Duration(seconds: 5),
                                          ),
                                        ),
                                        Navigator.pop(context, true),
                                      })
                                  .catchError((onError) {
                                print(onError.message);
                                setState(() {
                                  _isLoading = false;
                                });
                              });
                            } else {
                              await ZoneProductionService()
                                  .addZone(
                                      nomZoneProduction: nom,
                                      latitude: latitude,
                                      longitude: longitude,
                                      photoZone: photo,
                                      acteur: acteur)
                                  .then((value) => {
                                        Provider.of<ZoneProductionService>(
                                                context,
                                                listen: false)
                                            .applyChange(),
                                        setState(() {
                                          _isLoading = false;
                                        }),
                                        nomController.clear(),
                                        latitudeController.clear(),
                                        longitudeController.clear(),
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Row(
                                              children: [
                                                Text("Ajouter avec succèss"),
                                              ],
                                            ),
                                            // duration: const Duration(seconds: 5),
                                          ),
                                        ),
                                        Navigator.pop(context, true),
                                      })
                                  .catchError((onError) {
                                print(
                                  onError.toString(),
                                );
                              });
                            }
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            print(e.toString());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Text("Une erreur est survenu"),
                                  ],
                                ),
                                duration: Duration(seconds: 5),
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
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Ajouter",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ],
                )),
            const SizedBox(height: 32)
          ]),
        ),
        // floatingActionButton: SpeedDial(
        //   backgroundColor: Colors.green,
        //   foregroundColor: Colors.white,
        //   overlayColor: Colors.black,
        //   overlayOpacity: 0.4,
        //   spacing: 12,
        //   icon: Icons.location_searching,
        //   openCloseDial: isDialOpenNotifier,
        //   onPress: () {
        //     showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return AlertDialog(
        //           title: Text("Confirmation"),
        //           content: Text(
        //               "Voulez-vous vraiment récupérer la position actuelle ?"),
        //           actions: <Widget>[
        //             TextButton(
        //               onPressed: () {
        //                 Navigator.of(context).pop();
        //               },
        //               child: Text("Annuler"),
        //             ),
        //             TextButton(
        //               onPressed: () {
        //                 Navigator.of(context).pop();
        //                 _getCurrentPosition();
        //                 latitudeController.text =
        //                     _currentPosition?.latitude.toString() ?? "";
        //                 longitudeController.text =
        //                     _currentPosition?.longitude.toString() ?? "";
        //               },
        //               child: Text("Confirmer"),
        //             ),
        //           ],
        //         );
        //       },
        //     );
        //   },
        // )
      ),
    );
  }
}
