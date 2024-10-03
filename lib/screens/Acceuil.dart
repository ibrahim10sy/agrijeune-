import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:koumi/widgets/CustomAppBar.dart';
import 'package:koumi/widgets/Default_Acceuil.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:koumi/widgets/Carrousel.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

class _AccueilState extends State<Accueil> {
  late Acteur acteur = Acteur();

  String? email = "";
  bool isExist = false;

  String? detectedC;
  String? isoCountryCode;
  String? country;
  String? detectedCountryCode;
  String? detectedCountry;
  CountryProvider? countryProvider;
  late BuildContext _currentContext;

  void getLocationNew() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark placemark = placemarks.first;
      setState(() {
        detectedCountryCode = placemark.isoCountryCode!;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  var latitude = 'Getting Latitude..'.obs;
  var longitude = 'Getting Longitude..'.obs;
  var address = 'Getting Address..'.obs;
  StreamSubscription<Position>? streamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // verify();
    getLocation();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  getLocation() async {
    bool serviceEnabled;

    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    streamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10000,
      ),
    ).listen((Position position) {
      latitude.value = 'accueil Latitude : ${position.latitude}';
      longitude.value = 'accueil Longitude : ${position.longitude}';
      getAddressFromLatLang(position);
      streamSubscription?.cancel(); // Annule après la première mise à jour
    });
  }

  Future<void> getAddressFromLatLang(Position position) async {
    final detectorPays = Provider.of<DetectorPays>(context, listen: false);

    try {
      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemark.isNotEmpty) {
        Placemark place = placemark[0];

        debugPrint("Address ISO dans acceuil: $detectedC");
        address.value =
            'Address dans acceuil : ${place.locality}, ${place.country}, ${place.isoCountryCode}';

        // Comparez avec les valeurs existantes avant de mettre à jour
        String newDetectedCountryCode = place.isoCountryCode ?? "ML";
        String newDetectedCountry = place.country ?? "Mali";

        if (detectedCountryCode != newDetectedCountryCode ||
            detectedCountry != newDetectedCountry) {
          if (mounted) {
            setState(() {
              detectedC = place.isoCountryCode;
              detectedCountryCode = place.isoCountryCode ?? "ML";
              detectedCountry = place.country ?? "Mali";
              print(
                  "pays dans acceuil: ${detectedCountry} code: ${detectedCountryCode}");
              if (detectedCountry != null || detectedCountry!.isNotEmpty) {
                detectorPays.setDetectedCountryAndCode(
                    detectedCountry!, detectedCountryCode!);
                print(
                    "pays dans acceuil: $detectedCountry code: $detectedCountryCode");
              } else {
                detectorPays.setDetectedCountryAndCode("Mali", "ML");
                print("Le pays n'a pas pu être détecté dans acceuil.");
              }
            });
          }
        }

        String newAddress =
            'Address dans accueil : ${place.locality}, ${place.country}, ${place.isoCountryCode}';
        if (address.value != newAddress) {
          address.value = newAddress;
          debugPrint(newAddress);
        }
      } else {
        debugPrint(
            "Aucun emplacement trouvé dans accueil pour les coordonnées fournies.");
      }
    } catch (e) {
      debugPrint(
          "Une erreur est survenue lors de la récupération de l'adresse : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          SizedBox(height: 180, child: Carrousel()),
          const SizedBox(
            height: 10,
          ),
          DefautAcceuil(),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
