import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/ForgetPassScreen.dart';
import 'package:koumi/screens/LoginScreen.dart';
import 'package:koumi/screens/RegisterScreen.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/BottomNavBarAdmin.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _PinLoginScreenState extends State<PinLoginScreen> {
  String enteredPin = '';
  bool isPinVisible = false;
  bool isLoading = false;
  String? codeActeur;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadCodeActeur();
  }

  Future<void> _loadCodeActeur() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      codeActeur = prefs.getString('codeActeur');
    });
  }

  _handleButtonPress() async {
    setState(() {
      isLoading = true;
    });
    await loginUser().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> loginUser() async {
    const String baseUrl = '$apiOnlineUrl/acteur/pinLogin';

    ActeurProvider acteurProvider =
        Provider.of<ActeurProvider>(context, listen: false);

    // Assurez-vous que le code acteur est chargé
    if (codeActeur == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Connexion"),
          content: Text(
              "Veillez vous connectez d'abord avec votre email et le mot de passe puis réessayer plus tard",
              style: TextStyle(
                color: Colors.black87,
              )),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("connexion"),
              onPressed: () {
                Get.offAll(LoginScreen(),
                    duration: Duration(seconds: 1),
                    transition: Transition.leftToRight);
              },
            ),
          ],
        ),
      );

      return;
    }

    final Uri apiUrl =
        Uri.parse('$baseUrl?codeActeur=$codeActeur&password=$enteredPin');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));

        // Sauvegarder les données de l'utilisateur dans shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('codeActeur', codeActeur!);
        prefs.setString('password', enteredPin);

        final nomActeur = responseBody['nomActeur'];
        final idActeur = responseBody['idActeur'];
        final adresseActeur = responseBody['adresseActeur'];
        final telephoneActeur = responseBody['telephoneActeur'];
        final whatsAppActeur = responseBody['whatsAppActeur'];
        final niveau3PaysActeur = responseBody['niveau3PaysActeur'];
        final localiteActeur = responseBody['localiteActeur'];

        prefs.setString('nomActeur', nomActeur);
        prefs.setString('idActeur', idActeur);
        prefs.setString('codeActeur', responseBody['codeActeur']);
        prefs.setString('adresseActeur', adresseActeur);
        prefs.setString('telephoneActeur', telephoneActeur);
        prefs.setString('whatsAppActeur', whatsAppActeur);
        prefs.setString('niveau3PaysActeur', niveau3PaysActeur);
        prefs.setString('localiteActeur', localiteActeur);
        // Enregistrer la liste des types d'utilisateur dans SharedPreferences

        // Enregistrer la liste des types d'utilisateur dans SharedPreferences

        List<dynamic> typeActeurData = responseBody['typeActeur'];
        List<dynamic> speculationData = responseBody['speculation'];

        List<TypeActeur> typeActeurList =
            typeActeurData.map((data) => TypeActeur.fromMap(data)).toList();

        List<Speculation> speculationsList =
            speculationData.map((data) => Speculation.fromMap(data)).toList();

        // Extraire les libellés des types d'utilisateur et les ajouter à une nouvelle liste de chaînes
        List<String> userTypeLabels =
            typeActeurList.map((typeActeur) => typeActeur.libelle!).toList();

        List<String> speculationLabels =
            speculationsList.map((spec) => spec.nomSpeculation!).toList();

        // Convertir les listes en JSON pour les stocker
        String typeActeurJson = json.encode(
            typeActeurList.map((typeActeur) => typeActeur.toMap()).toList());
        String speculationsJson = json.encode(speculationsList
            .map((speculation) => speculation.toMap())
            .toList());

        // Sauvegarder les JSON dans SharedPreferences
        prefs.setString('typeActeurList', typeActeurJson);
        prefs.setString('speculationsList', speculationsJson);
// Enregistrer la liste des libellés des types d'utilisateur dans SharedPreferences
        prefs.setStringList('userType', userTypeLabels);
        prefs.setStringList('specType', speculationLabels);
        // prefs.setStringList('speculations', speculationLabels);
        Acteur acteurs = Acteur(
          idActeur: responseBody['idActeur'],
          resetToken: responseBody['resetToken'],
          tokenCreationDate: responseBody['tokenCreationDate'],
          codeActeur: codeActeur,
          nomActeur: responseBody['nomActeur'],
          adresseActeur: responseBody['adresseActeur'],
          telephoneActeur: responseBody['telephoneActeur'],
          whatsAppActeur: responseBody['whatsAppActeur'],
          latitude: responseBody['latitude'],
          longitude: responseBody['longitude'],
          // photoSiegeActeur: responseBody['photoSiegeActeur'],
          // logoActeur: responseBody['logoActeur'],
          niveau3PaysActeur: responseBody['niveau3PaysActeur'],
          password: responseBody['password'],
          dateAjout: responseBody['dateAjout'],
          dateModif: responseBody['dateModif'],
          personneModif: responseBody['personneModif'],
          localiteActeur: responseBody['localiteActeur'],
          emailActeur: responseBody['emailActeur'],
          statutActeur: responseBody['statutActeur'],
          isConnected: responseBody['isConnected'],
          pays: null,
          typeActeur: typeActeurList,
          speculation: speculationsList,
        );
        print('Pays acteur : ${responseBody['pays']}');
        acteurProvider.setActeur(acteurs);

        final List<String> type =
            acteurs.typeActeur!.map((e) => e.libelle!).toList();
        if (type.contains('admin') || type.contains('Admin')) {
          Get.offAll(BottomNavBarAdmin(),
              duration: Duration(seconds: 1),
              transition: Transition.leftToRight);
        } else if (acteurs.typeActeur!.any((type) =>
            type.libelle!.toLowerCase() == 'producteur' ||
            type.libelle!.toLowerCase() == 'commercant' ||
            type.libelle!.toLowerCase() == 'commerçant' ||
            type.libelle!.toLowerCase() == 'transformeur' ||
            type.libelle!.toLowerCase() == 'transformateur' ||
            type.libelle!.toLowerCase() == 'partenaires de développement')) {
          // Index pour les intrants
          Timer(const Duration(seconds: 1), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        } else if (acteurs.typeActeur!
            .any((type) => type.libelle!.toLowerCase() == 'fournisseur')) {
          Timer(const Duration(seconds: 1), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        } else if (acteurs.typeActeur!
            .any((type) => type.libelle!.toLowerCase() == 'transporteur')) {
          // Index pour les véhicules
          // Mise à jour de l'index de navigation
          Timer(const Duration(seconds: 1), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        } else if (acteurs.typeActeur!
            .any((type) => type.libelle!.toLowerCase() == 'prestataire')) {
          Timer(const Duration(seconds: 1), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        } else {
          Get.offAll(BottomNavigationPage(),
              duration: Duration(seconds: 1),
              transition: Transition.leftToRight);
          Provider.of<BottomNavigationService>(context, listen: false)
              .changeIndex(0);
        }
      } else {
        print('$baseUrl?codeActeur=$codeActeur&password=$enteredPin');
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        String errorMessage = responseBody['message'];
        print('Erreur if : $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "votre compte est désactivé. Veuillez contacter l\'administrateur au numéro suivant +223 51554851 pour la procédure d\'activation de votre compte !",
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.error_outline, color: Colors.white),
              ],
            ),
            backgroundColor: Colors.redAccent, // Couleur de fond du SnackBar
            duration: Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior:
                SnackBarBehavior.floating, // Flottant pour un style moderne
            margin: EdgeInsets.all(10), // Espace autour du SnackBar
          ),
        );

        print("if : $errorMessage");
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('$baseUrl?codeActeur=$codeActeur&password=$enteredPin');

      String errorMessage = e.toString();
      print("Erreur catch : ${errorMessage}");
      if (errorMessage.contains('Code Pin incorrect')) {
        errorMessage = 'Code Pin incorrect';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    errorMessage,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.error_outline, color: Colors.white),
              ],
            ),
            backgroundColor: Colors.redAccent, // Couleur de fond du SnackBar
            duration: Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior:
                SnackBarBehavior.floating, // Flottant pour un style moderne
            margin: EdgeInsets.all(10), // Espace autour du SnackBar
          ),
        );
      } else if (errorMessage.contains(' is not a subtype of type')) {
      
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Code Pin incorrect ou compte non validée',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.error_outline, color: Colors.white),
              ],
            ),
            backgroundColor: Colors.redAccent, // Couleur de fond du SnackBar
            duration: Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior:
                SnackBarBehavior.floating, // Flottant pour un style moderne
            margin: EdgeInsets.all(10), // Espace autour du SnackBar
          ),
        );
      }
    }
  }

  /// this widget will be use for each digit
  Widget numButton(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (enteredPin.length < 6) {
              enteredPin += number.toString();
            }

            debugPrint("Pin : $enteredPin");
          });
          if (enteredPin.length == 6) {
            _handleButtonPress();
          }
        },
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
            centerTitle: true,
            toolbarHeight: 75,
            leading: IconButton(
              onPressed: () {
                Get.offAll(BottomNavigationPage(),
                    transition: Transition.leftToRight);
                Provider.of<BottomNavigationService>(context, listen: false)
                    .changeIndex(0);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
            ),
            actions: [
              // TextButton(
              //   onPressed: () {
              //     Future.microtask(() {
              //       Provider.of<BottomNavigationService>(context, listen: false)
              //           .changeIndex(0);
              //     });
              //     Get.to(LoginScreen(),
              //         duration: Duration(seconds: 1),
              //         transition: Transition.leftToRight);
              //   },
              //   child: const Text(
              //     "connexion avec email",
              //     style: TextStyle(
              //         fontSize: 16,
              //         // decoration: TextDecoration.underline,
              //         color: d_colorOr),
              //   ),
              // ),
              // PopupMenuButton<String>(
              //   padding: EdgeInsets.zero,
              //   itemBuilder: (context) {
              //     return <PopupMenuEntry<String>>[
              //       PopupMenuItem<String>(
              //         child: ListTile(
              //           leading: const Icon(
              //             Icons.login,
              //           ),
              //           title: const Text(
              //             "S'authentifier",
              //             style: TextStyle(
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           onTap: () async {
              //             Navigator.of(context).pop();
              //   Future.microtask(() {
              //     Provider.of<BottomNavigationService>(context,
              //             listen: false)
              //         .changeIndex(0);
              //   });
              //   Get.to(LoginScreen(),
              //       duration: Duration(seconds: 1),
              //       transition: Transition.leftToRight);
              // },
              //         ),
              //       ),
              //     ];
              //   },
              // )
            ]),
        body: SafeArea(
          minimum: EdgeInsets.only(top: 10),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(
                height: 30,
              ),
              const Center(
                child: Text(
                  'Entrer votre code pin',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (index) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      width: isPinVisible ? 40 : 18,
                      height: isPinVisible ? 40 : 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: index < enteredPin.length
                            ? isPinVisible
                                ? Colors.green
                                : CupertinoColors.activeBlue
                            : CupertinoColors.activeBlue.withOpacity(0.1),
                      ),
                      child: isPinVisible && index < enteredPin.length
                          ? Center(
                              child: Text(
                                enteredPin[index],
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),

              /// visiblity toggle button
              IconButton(
                onPressed: () {
                  setState(() {
                    isPinVisible = !isPinVisible;
                  });
                },
                icon: Icon(
                  isPinVisible ? Icons.visibility_off : Icons.visibility,
                ),
              ),

              SizedBox(height: isPinVisible ? 50.0 : 8.0),

              /// digits
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                      (index) => numButton(1 + 3 * i + index),
                    ).toList(),
                  ),
                ),

              /// 0 digit with back remove
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextButton(onPressed: null, child: SizedBox()),
                    numButton(0),
                    TextButton(
                      onPressed: () {
                        setState(
                          () {
                            if (enteredPin.isNotEmpty) {
                              enteredPin = enteredPin.substring(
                                  0, enteredPin.length - 1);
                            }
                            debugPrint("Pin : $enteredPin");
                          },
                        );
                      },
                      child: const Icon(
                        Icons.backspace,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              /// reset button
              TextButton(
                onPressed: () {
                  Get.to(ForgetPassScreen(),
                      duration: Duration(seconds: 1),
                      transition: Transition.leftToRight);
                },
                child: const Text(
                  "Mot de passe oublié ",
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(
                height: 35,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Pas de compte ?.",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(RegisterScreen(),
                              duration: Duration(seconds: 1),
                              transition: Transition.leftToRight);
                        },
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
