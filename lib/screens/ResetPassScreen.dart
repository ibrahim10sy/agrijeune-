import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/screens/PinLoginScreen.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';

class ResetPassScreen extends StatefulWidget {
  final bool? isVisible;
  final String? emailActeur;
  final String? whatsAppActeur;
  ResetPassScreen(
      {super.key, this.isVisible, this.emailActeur, this.whatsAppActeur});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}
const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
class _ResetPassScreenState extends State<ResetPassScreen> {
  String password = "";
  bool _obscureText = true;
  String confirmPassword = "";
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Fonction pour afficher la boîte de dialogue de chargement
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Empêche de fermer la boîte de dialogue en cliquant en dehors
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Center(child: Text('Envoi en cours')),
          content: CupertinoActivityIndicator(
            color: Colors.orange,
            radius: 22,
          ),
          actions: <Widget>[
            // Pas besoin de bouton ici
          ],
        );
      },
    );
  }

// Fonction pour fermer la boîte de dialogue de chargement
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop(); // Ferme la boîte de dialogue
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

  // Fonction pour gérer le bouton Envoyer
  void handleSendButton(BuildContext context) async {
    bool isConnected = await checkInternetConnectivity();
    if (!isConnected) {
      showNoInternetDialog(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isVisible!) {
        debugPrint("Code envoyé par mail");
        await ActeurService.resetPasswordEmail(
                widget.emailActeur!, passwordController.text)
            .then((value) => {
                  setState(() {
                    _isLoading = false;
                  }),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mot de passe modifier avec succès"),
                      duration: Duration(seconds: 1),
                    ),
                  ),
                  Get.offAll(PinLoginScreen(),
                      transition: Transition.leftToRight),
                  Provider.of<BottomNavigationService>(context, listen: false)
                      .changeIndex(0),
                });
      } else {
        await ActeurService.resetPasswordWhatsApp(
                widget.whatsAppActeur!, passwordController.text)
            .then((value) => {
                  setState(() {
                    _isLoading = false;
                  }),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mot de passe modifier avec succès"),
                      duration: Duration(seconds: 1),
                    ),
                  ),
                  Get.offAll(PinLoginScreen(),
                      transition: Transition.leftToRight),
                  Provider.of<BottomNavigationService>(context, listen: false)
                      .changeIndex(0),
                });
        debugPrint("Code envoyé par whats app");
      }

      // Fermez la boîte de dialogue de chargement après l'envoi du code
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mot de passe non modifier"),
          duration: Duration(seconds: 5),
        ),
      );
      // En cas d'erreur, fermez également la boîte de dialogue de chargement
      // hideLoadingDialog(context);
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Center(child: Text('Erreur')),
      //       content: Text("Erreur : $e"),
      //       actions: <Widget>[
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //           child: const Text('OK'),
      //         ),
      //       ],
      //     );
      //   },
      // );
      // Gérez l'erreur ici
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 250, 250, 250),
          appBar: AppBar(
            // leading: null,
            automaticallyImplyLeading: false,
            centerTitle: true,
            toolbarHeight: 100,
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Get.offAll(BottomNavigationPage(),
                      transition: Transition.leftToRight);
                  Provider.of<BottomNavigationService>(context, listen: false)
                      .changeIndex(0);
                },
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: Colors.orange, fontSize: 17),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              Center(child: Image.asset('assets/images/fg-pass.png')),
              // connexion
              const Text(
                " Saisissez votre nouveau mot de passe  ",
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
                    // debut mot de passe
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Nouveau mot de passe",
                        style: TextStyle(color: (Colors.black), fontSize: 18),
                      ),
                    ),
                    // debut  mot de pass
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // labelText: "Nouveau mot de passe",
                        hintText: "Entrez votre nouveau mot de passe",
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
                      keyboardType: TextInputType.phone,
                      obscureText: _obscureText,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Veillez entrez votre  mot de passe à nouveau";
                        }
                        if (val.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        } else if (val.length > 6) {
                          return 'Le mot de passe ne doit pas dépassé 6 caractères';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => password = val!,
                    ),
                    // fin mot de pass

                    // confirm password
                    const SizedBox(
                      height: 10,
                    ),
                    // debut mot de passe
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Confirm mot de passe",
                        style: TextStyle(color: (Colors.black), fontSize: 18),
                      ),
                    ),
                    // debut  mot de pass
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // labelText: "Confirmer mot de passe",
                        hintText: "Entrez votre confirmer votre mot de passe",
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
                      keyboardType: TextInputType.phone,
                      obscureText: _obscureText,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Veillez entrez votre  mot de passe à nouveau";
                        }
                        if (val.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        } else if (val.length > 6) {
                          return 'Le mot de passe ne doit pas dépassé 6 caractères';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => password = val!,
                    ),
                    // fin confirm password
                  ],
                ),
              ),

              const SizedBox(
                height: 15,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Handle button press action here
                      final password = passwordController.text;
                      final confirmPassword = confirmPasswordController.text;
                      if (password != confirmPassword) {
                        // Gérez le cas où l'email ou le mot de passe est vide.
                        const String errorMessage =
                            "Les mot de passe ne correspondent pas ";
                        // Gérez le cas où l'email ou le mot de passe est vide.
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Vérifie les mots de passe'),
                        ));
                        return;
                      } else if (passwordController.text.toString().trim() ==
                              "123456" ||
                          confirmPasswordController.text.toString().trim() ==
                              "123456") {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Mot de passe faible, veuillez saisir un mot de passe sécurisé.'),
                        ));
                      }
                      handleSendButton(context);
                    }
                  },
                  child: Text(
                    " Modifier ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        d_colorGreen, // Orange color code
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
