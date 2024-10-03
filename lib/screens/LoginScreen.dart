import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/ForgetPassScreen.dart';
import 'package:koumi/screens/ListeIntrantByActeur.dart';
import 'package:koumi/screens/RegisterScreen.dart';
import 'package:koumi/screens/VehiculesActeur.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/BottomNavBarAdmin.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:koumi/widgets/connection_verify.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late ConnectionVerify connectionVerify;

  String password = "";
  String email = "";
  bool _obscureText = true;
  bool isActive = true;
  // late Acteur acteur;
  bool _isLoading = false;
  final String message = "Encore quelques secondes";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? _currentAddress;
  Position? _currentPosition;

  Future<void> loginUser() async {
    final String emailActeur = emailController.text;
    final String password = passwordController.text;

    const String baseUrl = '$apiOnlineUrl/acteur/login';

    const String defaultProfileImage = 'assets/images/profil.jpg';

    ActeurProvider acteurProvider =
        Provider.of<ActeurProvider>(context, listen: false);

    if (emailActeur.isEmpty || password.isEmpty) {
      const String errorMessage = "Veuillez remplir tous les champs ";
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Erreur')),
            content: const Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final Uri apiUrl =
        Uri.parse('$baseUrl?emailActeur=$emailActeur&password=$password');
      print('$baseUrl?emailActeur=$emailActeur&password=$password');
    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        emailController.clear();
        passwordController.clear();

        // Sauvegarder les données de l'utilisateur dans shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('emailActeur', emailActeur);
        prefs.setString('password', password);
       
        final nomActeur = responseBody['nomActeur'];
        final idActeur = responseBody['idActeur'];
        final adresseActeur = responseBody['adresseActeur'];
        final telephoneActeur = responseBody['telephoneActeur'];
        final whatsAppActeur = responseBody['whatsAppActeur'];

        final niveau3PaysActeur = responseBody['niveau3PaysActeur'];
        final localiteActeur = responseBody['localiteActeur'];
      //  final photoSiegeActeur = responseBody['photoSiegeActeur'];
      //   final logoActeur = responseBody['logoActeur'];
      //   prefs.setString('photoSiegeActeur', photoSiegeActeur);
      //   prefs.setString('logoActeur', logoActeur);
        prefs.setString('nomActeur', nomActeur);
        prefs.setString('idActeur', idActeur);
        //  prefs.setString('resetToken', responseBody['resetToken']);
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
      String speculationsJson = json.encode(
          speculationsList.map((speculation) => speculation.toMap()).toList());

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
          codeActeur: emailActeur,
          nomActeur: responseBody['nomActeur'],
          adresseActeur: responseBody['adresseActeur'],
          telephoneActeur: responseBody['telephoneActeur'],
          whatsAppActeur: responseBody['whatsAppActeur'],
          latitude: responseBody['latitude'],
          longitude: responseBody['longitude'],
          // photoSiegeActeur: responseBody['photoSiegeActeur'],
          // logoActeur: responseBody['logoActeur'],
          niveau3PaysActeur: responseBody['niveau3PaysActeur'],
          password: password,
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
        }  else if (acteurs.typeActeur!
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
        // Traitement en cas d'échec
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        final errorMessage = responseBody['message'];
        print(errorMessage);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Center(child: Text('Connexion échouée !')),
              content: Text(
                'Email ou mot de passe incorrect',
                // errorMessage,
                textAlign: TextAlign.justify,
                style: const TextStyle(color: Colors.black, fontSize: 20),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Gérer les exceptionn
      debugPrint(e.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Erreur')),
            content: const Text(
              "Une erreur s'est produite veuillez vérifier votre connexion internet", // Afficher l'exception
              textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleButtonPress() async {
    // Vérifier si le widget est toujours monté avant de continuer
    if (!mounted) return;

    // Afficher l'indicateur de chargement
    setState(() {
      _isLoading = true;
    });

    if (isActive) {
      await loginUser().then((_) {
        // Vérifier à nouveau si le widget est toujours monté
        if (!mounted) return;

        // Cacher l'indicateur de chargement lorsque votre fonction est terminée
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      await loginUserWithoutSavedData().then((_) {
        // Vérifier à nouveau si le widget est toujours monté
        if (!mounted) return;

        // Cacher l'indicateur de chargement lorsque votre fonction est terminée
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future<void> loginUserWithoutSavedData() async {
    final String emailActeur = emailController.text;
    final String password = passwordController.text;

    const String baseUrl = '$apiOnlineUrl/acteur/login';

    ActeurProvider acteurProvider =
        Provider.of<ActeurProvider>(context, listen: false);

    if (emailActeur.isEmpty || password.isEmpty) {
      const String errorMessage = "Veuillez remplir tous les champs ";
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Erreur')),
            content: const Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final Uri apiUrl =
        Uri.parse('$baseUrl?emailActeur=$emailActeur&password=$password');
      print('$baseUrl?emailActeur=$emailActeur&password=$password');
    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        emailController.clear();
        passwordController.clear();

  SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('emailActeur', emailActeur);
        prefs.setString('password', password);
       
        final nomActeur = responseBody['nomActeur'];
        final idActeur = responseBody['idActeur'];
        final adresseActeur = responseBody['adresseActeur'];
        final telephoneActeur = responseBody['telephoneActeur'];
        final whatsAppActeur = responseBody['whatsAppActeur'];

        final niveau3PaysActeur = responseBody['niveau3PaysActeur'];
        final localiteActeur = responseBody['localiteActeur'];
        // final photoSiegeActeur = responseBody['photoSiegeActeur'];
        // final logoActeur = responseBody['logoActeur'];
        // prefs.setString('photoSiegeActeur', photoSiegeActeur);
        // prefs.setString('logoActeur', logoActeur);
        prefs.setString('nomActeur', nomActeur);
        prefs.setString('idActeur', idActeur);
        //  prefs.setString('resetToken', responseBody['resetToken']);
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
      String speculationsJson = json.encode(
          speculationsList.map((speculation) => speculation.toMap()).toList());

      // Sauvegarder les JSON dans SharedPreferences
      prefs.setString('typeActeurList', typeActeurJson);
      prefs.setString('speculationsList', speculationsJson);
// Enregistrer la liste des libellés des types d'utilisateur dans SharedPreferences
        prefs.setStringList('userType', userTypeLabels);
        prefs.setStringList('specType', speculationLabels);
       

        Acteur acteurs = Acteur(
          idActeur: responseBody['idActeur'],
          resetToken: responseBody['resetToken'],
          tokenCreationDate: responseBody['tokenCreationDate'],
          codeActeur: emailActeur,
          nomActeur: responseBody['nomActeur'],
          adresseActeur: responseBody['adresseActeur'],
          telephoneActeur: responseBody['telephoneActeur'],
          whatsAppActeur: responseBody['whatsAppActeur'],
          latitude: responseBody['latitude'],
          longitude: responseBody['longitude'],
          // photoSiegeActeur: responseBody['photoSiegeActeur'],
          // logoActeur: responseBody['logoActeur'],
          niveau3PaysActeur: responseBody['niveau3PaysActeur'],
          password: password,
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
        }
         else {
          Get.offAll(BottomNavigationPage(),
              duration: Duration(seconds: 1),
              transition: Transition.leftToRight);
        }
      } else {
        // Traitement en cas d'échec
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        final errorMessage = responseBody['message'];
        print(errorMessage);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Center(child: Text('Connexion échouée !')),
              content: Text(
                'Email ou mot de passe incorrect',
                // errorMessage,
                textAlign: TextAlign.justify,
                style: const TextStyle(color: Colors.black, fontSize: 20),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Gérer les exceptionn
      print(e.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Erreur')),
            content: const Text(
              "Une erreur s'est produite veuillez vérifier votre connexion internet", // Afficher l'exception
              textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    connectionVerify = Get.put(ConnectionVerify(), permanent: true);
  }
  // login methode end

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Get.offAll(BottomNavigationPage(),
                      transition: Transition.leftToRight);
                  Provider.of<BottomNavigationService>(context, listen: false)
                      .changeIndex(0);
                },
                icon: const Icon(Icons.arrow_back_ios))),
        backgroundColor: const Color(0xFFFFFFFF),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  width: 150,
                  child: Center(
                      child: Image.asset(
                    'assets/images/logo.png',
                    // height: MediaQuery.sizeOf(context).height * 0.45,
                  )),
                ),
                const Text(
                  " Connexion ",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff2b6706)),
                ),
                // connexion
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //       Text('LAT: ${_currentPosition?.latitude ?? ""}'),
                      // Text('LNG: ${_currentPosition?.longitude ?? ""}'),
                      // Text('ADDRESS: ${_currentAddress ?? ""}'),
                      // const SizedBox(height: 32),
                      // ElevatedButton(
                      //   onPressed: _getCurrentPosition,
                      //   child: const Text("Get Current Location"),
                      // ),
                      const SizedBox(
                        height: 10,
                      ),
                      // debut fullname
                      const Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Email *",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          hintText: "Entrez votre adresse email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez votre adresse email";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => email = val!,
                      ),
                      // fin  adresse email

                      const SizedBox(
                        height: 10,
                      ),

                      const Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Mot de passe *",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                      // debut  mot de pass
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Entrez votre mot de passe",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText =
                                    !_obscureText; // Inverser l'état du texte masqué
                              });
                            },
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons
                                      .visibility, // Choisir l'icône basée sur l'état du texte masqué
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: _obscureText,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez votre  mot de passe";
                          }
                          if (val.length < 4) {
                            return 'Le mot de passe doit contenir au moins 4 caractères';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => password = val!,
                      ),
                      // fin mot de pass

                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 50,
                                height: 30,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Switch(
                                    value: isActive,
                                    activeColor: Colors.orange,
                                    onChanged: (bool value) {
                                      setState(() {
                                        isActive = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                "Se souvenir de moi",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              print("ho");

                              Get.to(ForgetPassScreen(),
                                  duration: Duration(seconds: 1),
                                  transition: Transition.leftToRight);
                            },
                            child: const Text(
                              "Mot de passe oublié ",
                              style: TextStyle(
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                           
                            _handleButtonPress();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF8A00), // Orange color code
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(250, 40),
                          ),
                          child: const Text(
                            " Se connecter ",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 240, 178, 107),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Pas de compte ?.",
                                style: TextStyle(
                                    color: Colors.white,
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
                                      color: Colors.blue,
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
