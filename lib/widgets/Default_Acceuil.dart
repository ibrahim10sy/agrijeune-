import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:koumi/screens/ComplementAlimentaire.dart';
import 'package:koumi/screens/ConseilScreen.dart';
import 'package:koumi/screens/EngraisAndApport.dart';
import 'package:koumi/screens/FruitsAndLegumes.dart';
import 'package:koumi/screens/IntrantPage.dart';
import 'package:koumi/screens/Location.dart' as l;
import 'package:koumi/screens/MatereilAndEquipement.dart';
import 'package:koumi/screens/MesCommande.dart';
import 'package:koumi/screens/Products.dart';
import 'package:koumi/screens/ProduitElevage.dart';
import 'package:koumi/screens/ProduitPhytosanitaire.dart';
import 'package:koumi/screens/ProduitTransforme.dart';
import 'package:koumi/screens/SemenceAndPlant.dart';
import 'package:koumi/screens/Store.dart';
import 'package:koumi/screens/Transport.dart';
import 'package:koumi/screens/Weather.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/ActeurProvider.dart';

class DefautAcceuil extends StatefulWidget {
  const DefautAcceuil({super.key});

  @override
  State<DefautAcceuil> createState() => _DefautAcceuilState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _DefautAcceuilState extends State<DefautAcceuil> {
  String? detectedC;
  String? isoCountryCode;
  String? country;
  String? detectedCountryCode;
  String? detectedCountry;
  CountryProvider? countryProvider;
  late BuildContext _currentContext;
  late Acteur acteur = Acteur();

  String? email = "";
  bool isExist = false;

  void verify() async {
    await Provider.of<ActeurProvider>(context, listen: false)
        .initializeActeurFromSharedPreferences();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

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
  late StreamSubscription<Position> streamSubscription;

  getLocation() async {
    bool serviceEnabled;

    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      latitude.value = 'Latitude : ${position.latitude}';
      longitude.value = 'Longitude : ${position.longitude}';
      getAddressFromLatLang(position);
    });
  }

  Future<void> getAddressFromLatLang(Position position) async {
    try {
      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemark.isNotEmpty) {
        Placemark place = placemark[0];
        debugPrint("Address ISO: $detectedC");
        address.value =
            'Address : ${place.locality}, ${place.country}, ${place.isoCountryCode}';

        if (mounted) {
          setState(() {
            detectedC = place.isoCountryCode;
            detectedCountryCode = place.isoCountryCode!;
            detectedCountry = place.country!;
          });
        }

        debugPrint(
            "Address: ${place.locality}, ${place.country}, ${place.isoCountryCode}");
      } else {
        debugPrint(
            "Aucun emplacement trouvé dans defaut accueil pour les coordonnées fournies.");
      }
    } catch (e) {
      debugPrint(
          "Une erreur est survenue lors de la récupération de l'adresse : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    verify();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        childAspectRatio: 2,
        children: _buildCards(),
      ),
    );
  }

  List<Widget> _buildCards() {
    List<Widget> cards = [
      _buildAccueilCard("Semences et plants", "semence.png", 13),
      _buildAccueilCard("Produits phytosanitaires", "physo.png", 12),
      _buildAccueilCard("Engrais et apports", "engrais.png", 11),
      _buildAccueilCard("Fruits et légumes", "fruit&legume.png", 10),
      _buildAccueilCard("Compléments alimentaires", "compl.png", 5),
      _buildAccueilCard("Produits transformés", "transforme.png", 8),
      _buildAccueilCard("Produits d'élevages", "elevage.png", 7),
      _buildAccueilCard("Produits agricoles", "pro1.png", 9),
      _buildAccueilCard("Matériels et équipements", "equi.png", 16),
      _buildAccueilCard("Magasins", "shop1.png", 6),
      _buildAccueilCard("Moyens de transport", "transp.png", 3),
      _buildAccueilCard("Matériels de location", "loc.png", 4),
      _buildAccueilCard("Météo", "met1.png", 2),
      _buildAccueilCard("Conseils", "cons1.png", 1)
    ];

    if (isExist) {
      cards.insert(
        8,
        _buildAccueilCard("Intrants agricoles", "int1.png", 15),
      );
      // cards.insert(
      //   11,
      //   _buildAccueilCard("Commandes", "cm.png", 14),
      // );
    }

    return cards;
  }

  Widget _buildAccueilCard(String titre, String imgLocation, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: InkWell(
        onTap: () {
          if (index == 16) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MaterielAndEquipement()));
          } else if (index == 15) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => IntrantPage()));
          }
          // else if (index == 14) {
          //   Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => const MesCommande()));
          // }
          else if (index == 13) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SemenceAndPlant()));
          } else if (index == 12) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProduitPhytosanitaire()));
          } else if (index == 11) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EngraisAndApport()));
          } else if (index == 10) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FruitAndLegumes()));
          } else if (index == 9) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProductsScreen()));
          } else if (index == 8) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProduitTransforme()));
          } else if (index == 7) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProduitElevage()));
          } else if (index == 6) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => StoreScreen()));
          } else if (index == 5) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ComplementAlimentaire()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => l.Location()));
          } else if (index == 3) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Transport()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => WeatherScreen()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ConseilScreen()));
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 5.0,
                color: Color.fromRGBO(0, 0, 0, 0.20), // Opacité de 10%
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Image.asset(
                    "assets/images/$imgLocation",
                    fit: BoxFit.contain,
                    scale: 1,
                  ),
                ),
              ),
              // SizedBox(
              //   width: 10,
              // ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    titre,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
