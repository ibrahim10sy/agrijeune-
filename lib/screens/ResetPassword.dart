import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';

class ResetPassword extends StatefulWidget {
  Acteur? acteurs;
  ResetPassword({super.key, this.acteurs});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _ResetPasswordState extends State<ResetPassword> {
  late Acteur acteur;
  bool _obscureText = true;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController initialPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String enteredPin = '';
  String? codeActeur = '';
  String? erroMessage = '';

  @override
  void initState() {
    //  acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    acteur = widget.acteurs!;
    emailController.text = acteur.emailActeur!;
    codeActeur = acteur.codeActeur;
    print("code acteur init : ${codeActeur}");
    super.initState();
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
          title: Text(
            "Modification du mot de passe",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/fg-pass.png',
                    height: 210,
                  ),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: initialPasswordController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              labelText: "Entrez votre mot de passe actuel",
                              labelStyle: const TextStyle(color: d_colorGreen),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                            obscureText: _obscureText,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Veillez entrez votre adresse mot de passe actuel";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (val) => enteredPin = val!,
                          ),
                        ),
                        erroMessage!.isNotEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(erroMessage!,
                                    style: TextStyle(color: Colors.red)))
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              labelText: "Nouveau mot de passe",
                              labelStyle: const TextStyle(color: d_colorGreen),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                            obscureText: _obscureText,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Veillez entrez votre  mot de passe ";
                              }
                              if (val.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              } else if (val.length > 6) {
                                return 'Le mot de passe ne doit pas dépassé 6 caractères';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: "Confirmer",
                              labelStyle: const TextStyle(color: d_colorGreen),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                            obscureText: _obscureText,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Veillez entrez votre  mot de passe ";
                              }
                              if (val.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              } else if (val.length > 6) {
                                return 'Le mot de passe ne doit pas dépassé 6 caractères';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final password = passwordController.text;
                            final confirmer = confirmPasswordController.text;
                            final code = acteur.codeActeur;
                            final codePin = initialPasswordController.text;

                            if (password != confirmer) {
                             
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Les mots de passe ne sont pas identiques",
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.error_outline,
                                          color: Colors.white),
                                    ],
                                  ),
                                  backgroundColor: Colors
                                      .redAccent, // Couleur de fond du SnackBar
                                  duration: Duration(seconds: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  behavior: SnackBarBehavior
                                      .floating, // Flottant pour un style moderne
                                  margin: EdgeInsets.all(
                                      10), // Espace autour du SnackBar
                                ),
                              );
                              return;
                            }
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              await ActeurService()
                                  .verifyPassword(
                                      codeActeur: acteur.codeActeur!,
                                      password: codePin)
                                  .then((value) async => {
                                        setState(() {
                                          _isLoading = false;
                                          erroMessage = "";
                                        }),
                                        await ActeurService()
                                            .updatePassword(
                                                id: acteur.idActeur!,
                                                newPassword: password)
                                            .then((value) => {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Votre mot de passe  a été modifier avec succèss"),
                                                      duration:
                                                          Duration(seconds: 5),
                                                    ),
                                                  ),
                                                  passwordController.clear(),
                                                  confirmPasswordController
                                                      .clear()
                                                })
                                            .catchError((onError) {
                                          setState(() {
                                            _isLoading = false;
                                            erroMessage =
                                                "Le mot de passe saisi est incorrect";
                                          });
                                          print(
                                              "Une erreur s'est produite: ${onError.toString()}");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "Une erreur s'est produite ! réessayer plus tard"),
                                              duration: Duration(seconds: 5),
                                            ),
                                          );
                                        }),
                                        initialPasswordController.clear()
                                      });
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                                erroMessage =
                                    "Le mot de passe saisi est incorrect";
                              });
                              print(e.toString());
                              print(
                                  "code acteur : ${acteur.codeActeur} et password : ${codePin}");
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text(
                              //         "Le mot de passe initial est incorrect "),
                              //     duration: Duration(seconds: 5),
                              //   ),
                              // );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: d_colorOr,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(250, 50),
                          ),
                          child: const Text(
                            "Confirmer",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
