import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/screens/ResetPassScreen.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';

class CodeConfirmScreen extends StatefulWidget {
  final bool? isVisible;
  final String? emailActeur;
  final String? whatsAppActeur;
  CodeConfirmScreen(
      {super.key, this.isVisible, this.emailActeur, this.whatsAppActeur});

  @override
  State<CodeConfirmScreen> createState() => _CodeConfirmScreenState();
}

class _CodeConfirmScreenState extends State<CodeConfirmScreen> {
  bool _isMounted = false;
  bool _isLoading = false;

  String email = "";
  String otpCode = "";

  int _time = 120;
  late Timer timere;
  // String pinCode = '';

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
      _isLoading = true;
    });

    await handleSendButton(context).then(() {
      setState(() {
        _isLoading = false;
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
  }

  void startTimer() {
    timere = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_time > 0) {
          _time--;
        } else {
          timere.cancel();
        }
      });
    });
  }

  // Fonction pour imprimer le code PIN saisi dans la console
  // void printPinCode() {
  //   for (var controller in otpControllers) {
  //     pinCode += controller.text;
  //   }
  //   print('Code saisi: $pinCode');
  // }

  String get timerText {
    int minutes = _time ~/ 60;
    int seconds = _time % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timere.cancel();
    super.dispose();
  }

  @override
  void initState() {
    startTimer();
    super.initState();
    _isMounted = false;
  }

  void _safeSetState(Function() fn) {
    if (_isMounted) {
      setState(fn);
    }
  }

  TextEditingController codeController = TextEditingController();
  // TextEditingController Controller = TextEditingController();

  @override
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
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              child: Column(
                children: [
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: GestureDetector(
                  //     onTap: () => Navigator.pop(context),
                  //     child: Icon(
                  //       Icons.arrow_back,
                  //       size: 32,
                  //       color: Colors.black54,
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 18,
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo-pr.png',
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.isVisible!
                        ? "Entrer le code envoyer à votre email"
                        : "Entrer le code envoyer par whatsApp",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Container(
                    padding: EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: _textFieldOTP(
                                    first: true, last: false, index: 0)),
                            Expanded(
                                child: _textFieldOTP(
                                    first: false, last: false, index: 1)),
                            Expanded(
                                child: _textFieldOTP(
                                    first: false, last: false, index: 2)),
                            Expanded(
                                child: _textFieldOTP(
                                    first: false, last: true, index: 3)),
                          ],
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              String pinCode = otpControllers
                                  .map((controller) => controller.text)
                                  .join();
                              print('Code saisi: $pinCode');

                              try {
                                setState(() {
                                  _isLoading = true;
                                });

                                if (widget.isVisible!) {
                                  await ActeurService()
                                      .verifyOtpCodeEmail(
                                          widget.emailActeur!, pinCode, context)
                                      .then((value) {
                                    setState(() {
                                      _isLoading = false;
                                      pinCode = '';
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResetPassScreen(
                                          isVisible: widget.isVisible!,
                                          emailActeur: widget.emailActeur!,
                                          whatsAppActeur:
                                              widget.whatsAppActeur!,
                                        ),
                                      ),
                                    );
                                    debugPrint("Code vérifié par email");
                                  }).catchError((onError) {
                                    setState(() {
                                      _isLoading = false;
                                      pinCode = '';
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'Erreur de vérification'),
                                          content: const Text(
                                              'Le code saisi est incorrect.'),
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
                                  });
                                } else {
                                  await ActeurService()
                                      .verifyOtpCodeWhatsApp(
                                          widget.whatsAppActeur!,
                                          pinCode,
                                          context)
                                      .then((value) {
                                    setState(() {
                                      _isLoading = false;
                                      pinCode = '';
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResetPassScreen(
                                          isVisible: widget.isVisible!,
                                          emailActeur: widget.emailActeur!,
                                          whatsAppActeur:
                                              widget.whatsAppActeur!,
                                        ),
                                      ),
                                    );
                                    debugPrint("Code vérifié par WhatsApp");
                                  }).catchError((onError) {
                                    print(
                                        'Code saisi: $pinCode, error: $onError');
                                    setState(() {
                                      _isLoading = false;
                                      pinCode = '';
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'Erreur de vérification'),
                                          content: const Text(
                                              'Le code saisi est incorrect.'),
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
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                  pinCode = '';
                                });
                                print(
                                    'Code saisi: $pinCode, error catch: ${e.toString()}');
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Erreur'),
                                      content: const Text(
                                          'Une erreur s\'est produite, veuillez réessayer.'),
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
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.orange),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                'Verifier',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),

                  Center(
                      child: Text(
                    "Expire dans " + "$timerText",
                    style: TextStyle(fontSize: 15),
                  )),
                  SizedBox(
                    width: 10,
                  ),

                  Text(
                    "Vous n'avez pas reçu code?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  TextButton(
                      onPressed: () async {
                        try {
                          setState(() {
                            _isLoading = true;
                          });
                          final emailActeur = widget.emailActeur!;
                          final whatsAppActeur = widget.whatsAppActeur!;

                          if (widget.isVisible!) {
                            await ActeurService.sendOtpCodeEmail(
                                    emailActeur, context)
                                .then((value) => {
                                      setState(() {
                                        _isLoading = false;
                                      }),
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Envoie du code'),
                                            content: const Text(
                                                'Le code a été renvoyé à nouveau'),
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
                                      )
                                    })
                                .catchError((onError) {
                              print(onError.toString());
                              setState(() {
                                _isLoading = false;
                              });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Erreur '),
                                    content: const Text('Code non renvoyé'),
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
                            });
                            debugPrint("Code envoyé par mail");
                          } else {
                            await ActeurService.sendOtpCodeWhatsApp(
                                    whatsAppActeur, context)
                                .then((value) => {
                                      setState(() {
                                        _isLoading = false;
                                      }),
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Envoie du code'),
                                            content: const Text(
                                                'Le code a été renvoyé à nouveau'),
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
                                      )
                                    })
                                .catchError((onError) {
                              print(onError.toString());
                              setState(() {
                                _isLoading = false;
                              });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Erreur '),
                                    content: const Text('Code non renvoyé'),
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
                            });
                            debugPrint("Code envoyé par whatsApp");
                          }
                        } catch (e) {
                          print(e.toString());
                          setState(() {
                            _isLoading = false;
                          });
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Erreur '),
                                content: const Text('Code non renvoyé'),
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
                      },
                      child: Text(
                        "Envoyer à nouveau",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fonction pour construire un champ de texte OTP
// Déclarer une liste de contrôleurs de texte pour chaque champ de texte OTP
  List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());

// Fonction pour construire un champ de texte OTP
  Widget _textFieldOTP({required bool first, bool? last, required int index}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        height: 70,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: TextField(
            controller: otpControllers[
                index], // Utiliser le contrôleur de texte correspondant
            onChanged: (value) {
              // Mettre à jour la valeur dans le contrôleur de texte
              otpControllers[index].text = value;
              otpControllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: value.length),
              );

              // Vérifier si la longueur du code saisie est de 1
              if (value.length == 1 && last == false) {
                FocusScope.of(context).nextFocus();
              }
              if (value.length == 0 && first == false) {
                FocusScope.of(context).previousFocus();
              }
            },
            showCursor: false,
            readOnly: false,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counter: Offstage(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.black12),
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.orange),
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
