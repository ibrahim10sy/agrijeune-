import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/screens/LoginSuccessScreen.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RegisterEndScreen extends StatefulWidget {
  String nomActeur, email, adresse, localistaion;
  String telephoneActeur, numeroWhatsApp, pays;
  // File? image1;
  late List<TypeActeur>? typeActeur;
  //  late List<TypeActeur> idTypeActeur;

  RegisterEndScreen(
      {super.key,
      required this.nomActeur,
      // this.image1,
      required this.email,
      required this.telephoneActeur,
      this.typeActeur,
      required this.adresse,
      required this.numeroWhatsApp,
      required this.localistaion,
      required this.pays});

  @override
  State<RegisterEndScreen> createState() => _RegisterEndScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

class _RegisterEndScreenState extends State<RegisterEndScreen> {
  bool isLoading = false;
  String errorMessage = "";
  String exception = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //  final MultiSelectController _controllerCategorie = MultiSelectController();
  TextEditingController imageController = TextEditingController();
  final MultiSelectController _controllerCategorie = MultiSelectController();
  final MultiSelectController _controllerSpeculation = MultiSelectController();
  TextEditingController typeController = TextEditingController();

  String password = "";
  String confirmPassword = "";

  String filiere = "";
  String idsJson = "";
  bool _obscureText = true;
  List<String> libelleCategorie = [];
  List<String> libelleSpeculation = [];
  List<String> typeLibelle = [];
  List<String> selectedCategoryIds = [];
  List<Speculation> listeSpeculations = [];

  List<Speculation> selectedSpec = [];
  String responses = "";
  late Future _typeList;
  List<String> idsCategorieProduit = [];
  String idsCategorieProduitAsString = "";
  late TextEditingController _searchController;
  String? image2Src;
  File? image2;

  String url = "";
  List<Speculation> options = [];

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  Future<File?> getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;
    imageController.text = image.name;
    return File(image.path);
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        this.image2 = image;
        image2Src = image.path;
        imageController.text = image.path;
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: Text("Photo du siège"),
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
          ),
        );
      },
    );
  }

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Fonction pour afficher la boîte de dialogue de chargement
  void _handleButtonPress(BuildContext context) async {
    // Afficher l'indicateur de chargement
    setState(() {
      isLoading = true;
    });
    await registerUser(context).then((_) {
      // Cacher l'indicateur de chargement lorsque votre fonction est terminée
      setState(() {
        isLoading = false;
      });
    });
  }

  void _saveUserToPrefs(String nomActeur, String codeActeur) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? acteurs = prefs.getStringList('acteur');

    // Si c'est la première fois que vous enregistrez des utilisateurs, initialisez la liste
    if (acteurs == null) {
      acteurs = [];
    }

    // Ajouter les informations de l'utilisateur actuel
    acteurs.add('$nomActeur|$codeActeur');
    prefs.setStringList('acteurs', acteurs);
  }

  void _showMultiSelectDialogt() async {
    final BuildContext context = this.context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (mounted) setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une spéculation...',
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              content: FutureBuilder(
                future: _typeList,
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erreur lors du chargement des données"),
                    );
                  }

                  if (snapshot.hasData) {
                    final responseData =
                        json.decode(utf8.decode(snapshot.data.bodyBytes));
                    if (responseData is List) {
                      List<Speculation> typeListe = responseData
                          .map((e) => Speculation.fromMap(e))
                          .where((con) => con.statutSpeculation == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucun type trouvé")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Speculation> filteredSearch = typeListe
                          .where((type) => type.nomSpeculation!
                              .toLowerCase()
                              .contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucune spéculation trouvé',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final type = filteredSearch[index];
                                  final isSelected =
                                      selectedSpec.contains(type);

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.nomSpeculation!,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 16,
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? const Icon(
                                                Icons.check_box_outlined,
                                                color: d_colorGreen,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            isSelected
                                                ? selectedSpec.remove(type)
                                                : selectedSpec.add(type);
                                          });
                                        },
                                      ),
                                      Divider()
                                    ],
                                  );
                                },
                              ),
                            );
                    }
                  }

                  return const SizedBox(height: 8);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: d_colorGreen, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorGreen, fontSize: 16),
                  ),
                  onPressed: () {
                    List<String> typeLibelle =
                        selectedSpec.map((e) => e.nomSpeculation!).toList();
                    typeController.text = typeLibelle.join(', ');
                    _searchController.clear();
                    print('Options sélectionnées : $selectedSpec');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> registerUser(BuildContext context) async {
    final nomActeur = widget.nomActeur;
    final emailActeur = widget.email;
    final adresse = widget.adresse;
    final localisation = widget.localistaion;
    final typeActeur = widget.typeActeur;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Vérification des mots de passe
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Les mots de passe ne correspondent pas',
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
          behavior: SnackBarBehavior.floating, // Flottant pour un style moderne
          margin: EdgeInsets.all(10), // Espace autour du SnackBar
        ),
      );
      return;
    }

    ActeurService acteurService = ActeurService();

    try {
      // Création de l'acteur
      await acteurService.creerActeur(
        nomActeur: nomActeur,
        adresseActeur: adresse,
        telephoneActeur: widget.telephoneActeur,
        whatsAppActeur: widget.numeroWhatsApp,
        niveau3PaysActeur: widget.pays,
        localiteActeur: localisation,
        emailActeur: emailActeur,
        typeActeur: typeActeur,
        password: password,
        speculation: selectedSpec,
      );

      // Affichage de la boîte de dialogue de succès
      showSuccessDialog(context, "Inscription réussie avec succès");
    } catch (error) {
      String errorMessage;
      if (error
          .toString()
          .contains('Un compte avec le même numéro de téléphone existe déjà')) {
        errorMessage = 'Un compte avec le même numéro de téléphone existe déjà';
      } else if (error
          .toString()
          .contains('Un compte avec le même email existe déjà')) {
        errorMessage = 'Un compte avec le même email existe déjà';
      } else if (error.toString().contains('https://api.greenapi.com')) {
        // Si une condition spécifique doit entraîner un succès malgré l'exception
        showSuccessDialog(context, "Inscription réussie avec succès ");
        return;
      } else {
        errorMessage =
            'Une erreur s\'est produite. Vérifiez les informations du compte puis réessayez';
      }
      // Affichage de la boîte de dialogue d'erreur
      showErrorDialog(context, errorMessage);
    }
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Succès')),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
                Get.offAll(LoginSuccessScreen());
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erreur lors de l'inscription"),
          content: Text(
            errorMessage,
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _searchController = TextEditingController();
    _typeList =
        http.get(Uri.parse('$apiOnlineUrl/Speculation/getAllSpeculation'));

    debugPrint("Adresse : " +
        widget.adresse +
        " Type : ${widget.typeActeur}" +
        " Tel : ${widget.telephoneActeur}" +
        "pays : ${widget.pays}" +
        " Localisation :  " +
        widget.localistaion +
        " Whats app : " +
        widget.numeroWhatsApp +
        "Email :" +
        widget.email);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios)),
            actions: [
              TextButton(
                onPressed: () {
                  Get.offAll(BottomNavigationPage(),
                      transition: Transition.leftToRight);
                  Provider.of<BottomNavigationService>(context, listen: false)
                      .changeIndex(0);
                },
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: d_colorGreen, fontSize: 17),
                ),
              )
            ]),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // SizedBox(
                //   height: 120,
                //   width: double.infinity,
                //   child: GestureDetector(
                //     onTap: _showImageSourceDialog,
                //     child: (image2 == null)
                //         ? Center(
                //             child: Image.asset('assets/images/logo-pr.png'))
                //         : ClipRRect(
                //             borderRadius: BorderRadius.circular(8),
                //             child: Image.file(
                //               image2!,
                //               height: 100,
                //               width: 200,
                //               fit: BoxFit.cover,
                //             ),
                //           ),
                //   ),
                // ),
                const SizedBox(
                  height: 75,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Spéculation (Multi-selection)",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: _showMultiSelectDialogt,
                          child: TextFormField(
                            onTap: _showMultiSelectDialogt,
                            controller: typeController,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Sélectionner une spéculation ",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Mot de passe (6 chiffres)",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: _obscureText,
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
                          onSaved: (val) => password = val!,
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Confirmer mot de passe",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            hintText:
                                "Entrez votre confirmer votre mot de passe",
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
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

                        // fin confirm password

                        const SizedBox(height: 35),
                        SizedBox(
                          height: 60,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (selectedSpec.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Veuillez sélectionner au moins une speculation.'),
                                    ));
                                  } else if (passwordController.text
                                              .toString()
                                              .trim() ==
                                          "123456" ||
                                      confirmPasswordController.text
                                              .toString()
                                              .trim() ==
                                          "123456") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Mot de passe faible, veuillez saisir un mot de passe sécurisé.',
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
                                        duration: Duration(seconds: 3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        behavior: SnackBarBehavior
                                            .floating, // Flottant pour un style moderne
                                        margin: EdgeInsets.all(
                                            10), // Espace autour du SnackBar
                                      ),
                                    );
                                  } else {
                                    _handleButtonPress(context);
                                  }
                                }
                                // Handle button press action here
                              },
                              child: Text(
                                " Enregister ",
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
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// registerUser(BuildContext context) async {
//     final nomActeur = widget.nomActeur;
//     final emailActeur = widget.email;
//     final adresse = widget.adresse;
//     final localisation = widget.localistaion;
//     final typeActeur = widget.typeActeur;
//     final password = passwordController.text;
//     final confirmPassword = confirmPasswordController.text;

//     if (password != confirmPassword) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         backgroundColor: Colors.red,
//         content: Text('Les mot de passe ne correspondent pas ',
//             style: TextStyle(color: Colors.white)),
//       ));
//       return;
//     }
//     // Utilize your backend service to send the request
//     ActeurService acteurService = ActeurService();
//     // Si widget.typeActeur est bien une liste de TypeActeur
//     try {
//       // String type = typeActeurList.toString();
//       if (widget.image1 != null && image2 != null) {
//         await acteurService
//             .creerActeur(
//                 logoActeur: widget.image1,
//                 photoSiegeActeur: image2,
//                 nomActeur: nomActeur,
//                 adresseActeur: adresse,
//                 telephoneActeur: widget.telephoneActeur,
//                 whatsAppActeur: widget.numeroWhatsApp,
//                 niveau3PaysActeur: widget.pays,
//                 localiteActeur: localisation,
//                 emailActeur: emailActeur,
//                 typeActeur: widget
//                     .typeActeur, // Convertir les IDs en chaînes de caractères
//                 password: password,
//                 speculation: selectedSpec)
//             .then((value) => showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Center(child: Text('Succès')),
//                       content: const Text("Inscription réussi avec succès"),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () {
//                             Get.back();
//                             Get.offAll(LoginSuccessScreen());
//                           },
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     );
//                   },
//                 ))
//             .catchError((error) => {
//                   if (error is Exception)
//                     {
//                       exception = error.toString(),
//                       if (exception.toString().contains(
//                           'Un compte avec le même numéro de téléphone existe déjà'))
//                         {
//                           setState(() {
//                             errorMessage =
//                                 'Un compte avec le même numéro de téléphone existe déjà';
//                           })
//                         }
//                       else if (exception
//                           .toString()
//                           .contains('https://api.greenapi.com'))
//                         {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Center(child: Text('Succès')),
//                                 content: const Text(
//                                     "Inscription réussi avec succès 1"),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     onPressed: () {
//                                       Get.back();
//                                       Get.offAll(LoginSuccessScreen());
//                                     },
//                                     child: const Text('OK'),
//                                   ),
//                                 ],
//                               );
//                             },
//                           )
//                         }
//                       else
//                         {
//                           setState(() {
//                             errorMessage =
//                                 'Un compte avec le même email et numéro de téléphone  existe déjà';
//                           })
//                         }
//                     },
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text("Erreur lors de l'inscription"),
//                         content: Text(errorMessage,
//                             style: TextStyle(
//                               color: Colors.black87,
//                             )),
//                         actions: [
//                           TextButton(
//                             child: Text("OK"),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       );
//                     },
//                   )
//                 });
//       } else if (widget.image1 != null) {
//         await acteurService
//             .creerActeur(
//                 logoActeur: widget.image1,
//                 nomActeur: nomActeur,
//                 adresseActeur: adresse,
//                 telephoneActeur: widget.telephoneActeur,
//                 whatsAppActeur: widget.numeroWhatsApp,
//                 niveau3PaysActeur: widget.pays,
//                 localiteActeur: localisation,
//                 emailActeur: emailActeur,
//                 typeActeur: widget
//                     .typeActeur, // Convertir les IDs en chaînes de caractères
//                 password: password,
//                 speculation: selectedSpec)
//             .then((value) => showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Center(child: Text('Succès')),
//                       content: const Text("Inscription réussi avec succès"),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () {
//                             Get.back();
//                             Get.offAll(LoginSuccessScreen());
//                           },
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     );
//                   },
//                 ))
//             .catchError((error) => {
//                   if (error is Exception)
//                     {
//                       exception = error.toString(),
//                       if (exception.toString().contains(
//                           'Un compte avec le même numéro de téléphone existe déjà'))
//                         {
//                           setState(() {
//                             errorMessage =
//                                 'Un compte avec le même numéro de téléphone existe déjà';
//                           })
//                         }
//                       else if (exception
//                           .toString()
//                           .contains('https://api.greenapi.com'))
//                         {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Center(child: Text('Succès')),
//                                 content: const Text(
//                                     "Inscription réussi avec succès 1"),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     onPressed: () {
//                                       Get.back();
//                                       Get.offAll(LoginSuccessScreen());
//                                     },
//                                     child: const Text('OK'),
//                                   ),
//                                 ],
//                               );
//                             },
//                           )
//                         }
//                       else
//                         {
//                           setState(() {
//                             errorMessage =
//                                 'Un compte avec le même email et numéro de téléphone  existe déjà';
//                           })
//                         }
//                     },
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text("Erreur lors de l'inscription"),
//                         content: Text(errorMessage,
//                             style: TextStyle(
//                               color: Colors.black87,
//                             )),
//                         actions: [
//                           TextButton(
//                             child: Text("OK"),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       );
//                     },
//                   )
//                 });
//       } else if (image2 != null) {
//         await acteurService
//             .creerActeur(
//                 photoSiegeActeur: image2,
//                 nomActeur: nomActeur,
//                 adresseActeur: adresse,
//                 telephoneActeur: widget.telephoneActeur,
//                 whatsAppActeur: widget.numeroWhatsApp,
//                 niveau3PaysActeur: widget.pays,
//                 localiteActeur: localisation,
//                 emailActeur: emailActeur,
//                 typeActeur: widget
//                     .typeActeur, // Convertir les IDs en chaînes de caractères
//                 password: password,
//                 speculation: selectedSpec)
//             .then((value) => showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Center(child: Text('Succès')),
//                       content: const Text("Inscription réussi avec succès"),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () {
//                             Get.back();
//                             Get.offAll(LoginSuccessScreen());
//                           },
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     );
//                   },
//                 ))
//             .catchError((error) => {
//                   if (error is Exception)
//                     {
//                       exception = error.toString(),
//                       if (exception.toString().contains(
//                           'Un compte avec le même numéro de téléphone existe déjà'))
//                         {
//                           setState(() {
//                             errorMessage =
//                                 'Un compte avec le même numéro de téléphone existe déjà';
//                           })
//                         }
//                       else if (exception
//                           .toString()
//                           .contains('https://api.greenapi.com'))
//                         {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Center(child: Text('Succès')),
//                                 content: const Text(
//                                     "Inscription réussi avec succès 1"),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     onPressed: () {
//                                       Get.back();
//                                       Get.offAll(LoginSuccessScreen());
//                                     },
//                                     child: const Text('OK'),
//                                   ),
//                                 ],
//                               );
//                             },
//                           )
//                         }
//                       else
//                         {
//                           setState(() {
//                             errorMessage =
//                                 'Un compte avec le même email et numéro de téléphone  existe déjà';
//                           })
//                         }
//                     },
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text("Erreur lors de l'inscription"),
//                         content: Text(errorMessage,
//                             style: TextStyle(
//                               color: Colors.black87,
//                             )),
//                         actions: [
//                           TextButton(
//                             child: Text("OK"),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       );
//                     },
//                   )
//                 });
//       } else {
//         await acteurService
//             .creerActeur(
//               nomActeur: nomActeur,
//               adresseActeur: adresse,
//               telephoneActeur: widget.telephoneActeur,
//               whatsAppActeur: widget.numeroWhatsApp,
//               niveau3PaysActeur: widget.pays,
//               localiteActeur: localisation,
//               emailActeur: emailActeur,
//               typeActeur: typeActeur,
//               password: password,
//               speculation: selectedSpec,
//             )
//             .then((value) => showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Center(child: Text('Succès')),
//                       content: const Text("Inscription réussi avec succès"),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       const LoginSuccessScreen()),
//                             );
//                           },
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     );
//                   },
//                 ))
//             .catchError((error) => {
//                   if (error is Exception)
//                     {
//                       exception = error.toString(),
//                       if (exception.toString().contains(
//                           'Un compte avec le même numéro de téléphone existe déjà'))
//                         {
//                           setState(() {
//                             errorMessage =
//                                 'Un compte avec le même numéro de téléphone existe déjà';
//                           })
//                         }
//                       else if (exception
//                           .toString()
//                           .contains('https://api.greenapi.com'))
//                         {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Center(child: Text('Succès')),
//                                 content: const Text(
//                                     "Inscription réussi avec succès 1"),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     onPressed: () {
//                                       Get.back();
//                                       Get.offAll(LoginSuccessScreen());
//                                     },
//                                     child: const Text('OK'),
//                                   ),
//                                 ],
//                               );
//                             },
//                           )
//                         }
//                       else
//                         {
//                           setState(() {
//                             errorMessage =
//                                 'Un compte avec le même email et numéro de téléphone  existe déjà';
//                           })
//                         }
//                     },
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text("Erreur lors de l'inscription"),
//                         content: Text(errorMessage,
//                             style: TextStyle(
//                               color: Colors.black87,
//                             )),
//                         actions: [
//                           TextButton(
//                             child: Text("OK"),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       );
//                     },
//                   )
//                 });
//       }
//       // print("Demande envoyée avec succès: ${updatedDemande.toString()}");
//       debugPrint("yes ");
//       // Navigate to the next page if necessary
//     } catch (error) {
//       String errorMessage = "";
//       if (error is Exception) {
//         final exception = error;
//         if (exception.toString().contains(
//             'Un compte avec le même numéro de téléphone existe déjà')) {
//           setState(() {
//             errorMessage =
//                 'Un compte avec le même numéro de téléphone existe déjà';
//           });
//         } else if (exception.toString().contains('https://api.greenapi.com')) {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Center(child: Text('Succès')),
//                 content: const Text("Inscription réussi avec succès 1"),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () {
//                       Get.back();
//                       Get.offAll(LoginSuccessScreen());
//                     },
//                     child: const Text('OK'),
//                   ),
//                 ],
//               );
//             },
//           );
//         } else {
//           setState(() {
//             errorMessage =
//                 'Une erreur s\'est produite. vérifier les informations du compte puis réessayer';
//           });
//         }
//         print(errorMessage);
//       }

//       debugPrint("no " + errorMessage);
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Erreur lors de l'inscription"),
//           content: Text(errorMessage,
//               style: TextStyle(
//                 color: Colors.black87,
//               )),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       );
//     }
//   }