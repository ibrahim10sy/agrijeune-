import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:koumi/screens/CodeConfirmScreen.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen>
    with AutomaticKeepAliveClientMixin<ForgetPassScreen> {
  // Override wantKeepAlive to return true
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email = "";
  String whatsApp = "";
  String processedNumberWA = "";
  String selectedCountry = "";
  String detectedCountryCode = "";
  String _errorMessage = "";

  PhoneNumber locale =
      PhoneNumber(isoCode: Platform.localeName.split('_').last);
  // String detectedCountryCode = '';
  PhoneNumber number = PhoneNumber();

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(
        phoneNumber, Platform.localeName.split('_').last);

    setState(() {
      this.number = number;
    });
  }

  String removePlus(String phoneNumber) {
    if (phoneNumber.startsWith('+')) {
      return phoneNumber.substring(1); // Remove the first character
    } else {
      return phoneNumber; // No change if "+" is not present
    }
  }

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "Email ne doit pas être vide";
      });
    } else if (!EmailValidator.validate(val, true)) {
      setState(() {
        _errorMessage = "Email non valide";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  // Fonction pour vérifier la connectivité réseau
  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

// Fonction pour afficher un message d'erreur si la connexion Internet n'est pas disponible
  void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur de connexion'),
          content: const Text(
              'Veuillez vérifier votre connexion Internet et réessayer.'),
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

  void _handleClick(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    await handleSendButton(context).then((_) {
      // Cacher l'indicateur de chargement lorsque votre fonction est terminée
      setState(() {
        isLoading = false;
      });
    });
  }

  // Fonction pour gérer le bouton Envoyer
  handleSendButton(BuildContext context) async {
    bool isConnected = await checkInternetConnectivity();
    if (!isConnected) {
      showNoInternetDialog(context);
      return;
    }

    // Si la connexion Internet est disponible, poursuivez avec l'envoi du code
    // Affichez la boîte de dialogue de chargement

    try {
      final emailActeur = emailController.text;
      final whatsAppActeur = processedNumberWA;
      print("num : $whatsAppActeur");
      if (isVisible) {
        await ActeurService.sendOtpCodeEmail(emailActeur, context).then(
          (value) => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CodeConfirmScreen(
                        isVisible: isVisible,
                        emailActeur: emailController.text,
                        whatsAppActeur: processedNumberWA)))
          },
        );
        debugPrint("Code envoyé par mail");
      } else {
        await ActeurService.sendOtpCodeWhatsApp(whatsAppActeur, context).then(
          (value) => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CodeConfirmScreen(
                        isVisible: isVisible,
                        emailActeur: emailController.text,
                        whatsAppActeur: processedNumberWA)))
          },
        );
        debugPrint("Code envoyé par whatsApp");
      }

      // Fermez la boîte de dialogue de chargement après l'envoi du code
    } catch (e) {
      // En cas d'erreur, fermez également la boîte de dialogue de chargement
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: const Text("Une erreur s'est produite veuillez réessayer"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => CodeConfirmScreen(
                  //             isVisible: isVisible,
                  //             emailActeur: emailController.text,
                  //             whatsAppActeur: whatsAppController.text)));
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      // Gérez l'erreur ici
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController whatsAppController = TextEditingController();
  bool isVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    whatsAppController.addListener(() {
      setState(() {
        processedNumberWA = removePlus(whatsAppController.text);
      });
    });

    final paysProvider = Provider.of<DetectorPays>(context, listen: false);
    paysProvider.hasLocation
        ? detectedCountryCode =
            Provider.of<DetectorPays>(context, listen: false)
                .detectedCountryCode!
        : detectedCountryCode = "ML";
    paysProvider.hasLocation
        ? selectedCountry =
            Provider.of<DetectorPays>(context, listen: false).detectedCountry!
        : selectedCountry = "Mali";

    isVisible = !isVisible;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 250, 250, 250),
          appBar: AppBar(
            centerTitle: true,
            toolbarHeight: 100,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: IconButton(
              //     onPressed: () {
              //       // Fonction de retour
              //       Navigator.pop(context);
              //     },
              //     icon: const Icon(Icons.arrow_back_ios),
              //     iconSize: 30,
              //     splashRadius: 20,
              //     padding: EdgeInsets.zero,
              //     constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              //   ),
              // ),
              Center(child: Image.asset('assets/images/fg-pass.png')),
              // connexion
              const Text(
                " Mot de passe oublié  ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF2B6706)),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Bouton radio Email
                        Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Radio(
                          value: true,
                          groupValue: isVisible,
                          onChanged: (bool? value) {
                            setState(() {
                              isVisible = value!;
                            });
                          },
                        ),
                        // Espace
                        SizedBox(width: 4),
                        const SizedBox(
                          width: 10,
                        ),
                        Text('WhatsApp',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        // Bouton radio WhatsApp
                        Radio(
                          value: false,
                          groupValue: isVisible,
                          onChanged: (bool? value) {
                            setState(() {
                              isVisible = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(2),
                      child: Center(
                        child: Text(isVisible ? _errorMessage : ""),
                      ),
                    ),
                    Visibility(
                      visible: isVisible,
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Entrez votre adresse email",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez votre adresse email";
                          } else if (_errorMessage == "Email non valide" &&
                              isVisible == false) {
                            return "Veillez entrez une adresse email valide";
                          } else {
                            return null;
                          }
                        },
                        onChanged: (val) {
                          validateEmail(val);
                        },
                        onSaved: (val) => email = val!,
                      ),
                    ),
                    Visibility(
                      visible: !isVisible,
                      child: IntlPhoneField(
                        initialCountryCode: detectedCountryCode,
                        controller: whatsAppController,
                        disableLengthCheck: true,
                        invalidNumberMessage: "Numéro invalide",
                        searchText: "Chercher un pays",
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        languageCode: "fr",
                        onChanged: (phone) {
                          setState(() {
                            processedNumberWA =
                                removePlus(phone.completeNumber.toString());
                          });
                          print("num complet ${phone.completeNumber}");
                          print("wa selected $processedNumberWA");
                        },
                        onCountryChanged: (country) {
                          setState(() {
                            processedNumberWA =
                                removePlus(whatsAppController.text);
                                print("wa num $processedNumberWA");
                          });
                          print("wa change country $processedNumberWA");

                          // Obtenir le numéro actuel sans indicatif
                          String currentNumber = whatsAppController.text
                              .replaceAll(RegExp(r'^\+\d+\s'), '');

                          // Ajouter l'indicatif du nouveau pays au numéro actuel
                          String newCompleteNumber =
                              '+${country.dialCode}$currentNumber';
                          setState(() {
                            processedNumberWA = removePlus(newCompleteNumber);
                          });

                          print(
                              "wa updated with country change $processedNumberWA");
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 15,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _handleClick(context);
                    }
                  },
                  child: Text(
                    " Envoyer ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF8A00), // Orange color code
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: Size(250, 40),
                  ),
                ),
              ),
            ]),
          ))),
    );
  }
}
