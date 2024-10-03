import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Magasin.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/MagasinService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


class AddMagasinScreen extends StatefulWidget {
  bool? isRoute;
  bool? isEditable;
  final Magasin? magasin;
  // String? nomMagasin = "";
  // String? contactMagasin = "";
  // String? localiteMagasin = "";
  // String? idMagasin = "";
  // File? photo;
  // late Niveau1Pays? niveau1Pays;

  AddMagasinScreen(
      {super.key,
      this.isRoute,
      this.isEditable,
      this.magasin,
      // this.idMagasin,
      // this.nomMagasin,
      // this.contactMagasin,
      // this.localiteMagasin,
      // this.photo,
      // this.niveau1Pays
      });

  @override
  State<AddMagasinScreen> createState() => _AddMagasinScreenState();
}

const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AddMagasinScreenState extends State<AddMagasinScreen> {
  late Acteur acteur = Acteur();
  String nomMagasin = "";
  String contactMagasin = "";
  String localiteMagasin = "";

  File? photos;
  String? imageSrc;
  String? libelleNiveau1Pays;

  Niveau1Pays niveau1Pays = Niveau1Pays();

  List<String> regions = [];
  String? niveauPaysValue;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nomMagasinController = TextEditingController();
  TextEditingController contactMagasinController = TextEditingController();
  TextEditingController localiteMagasinController = TextEditingController();
  TextEditingController localiteController = TextEditingController();
  List<Map<String, dynamic>> regionsData = [];
  TextEditingController? _searchController;
  bool isLoading = false;
  bool isLoadingLibelle = true;

  late Future niveau1PaysList;
  final String message = "Encore quelques secondes";

  Set<String> loadedRegions =
      {}; // Ensemble pour garder une trace des régions pour lesquelles les magasins ont déjà été chargés

  Future<String> getLibelleNiveau1PaysByActor(String id) async {
    final response = await http
        .get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau1Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response
          .body; // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau1Pays');
    }
  }

  Future<void> fetchLibelleNiveau1Pays() async {
    try {
      String libelle = await getLibelleNiveau1PaysByActor(acteur.idActeur!);
      setState(() {
        libelleNiveau1Pays = libelle;
        isLoadingLibelle = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLibelle = false;
      });
      print('Error: $e');
    }
  }

  Future<void> updateMagasin() async {
    final nomMagasin = nomMagasinController.text;
    final contactMagasin = contactMagasinController.text;
    final localiteMagasin = localiteMagasinController.text;
    MagasinService magasinService = MagasinService();
    try {
      if (photos != null) {
        await magasinService
            .updateMagasin(
                idMagasin: widget.magasin!.idMagasin!,
                nomMagasin: nomMagasin,
                contactMagasin: contactMagasin,
                localiteMagasin: localiteMagasin,
                photo: photos,
                acteur: acteur,
                niveau1Pays: niveau1Pays)
            .then((value) {
          Provider.of<MagasinService>(context, listen: false).applyChange();
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Text(
                    "Magasin modifier avec succèss",
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              duration: Duration(seconds: 2),
            ),
          );
        });
      } else {
        await magasinService
            .updateMagasin(
                idMagasin: widget.magasin!.idMagasin!,
                nomMagasin: nomMagasin,
                contactMagasin: contactMagasin,
                localiteMagasin: localiteMagasin,
                acteur: acteur,
                niveau1Pays: niveau1Pays)
            .then((value) {
          Provider.of<MagasinService>(context, listen: false).applyChange();
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Text(
                    "Magasin modifier avec succèss",
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Erreur : $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Erreur')),
            content: Text("Une erreur s'est produite veuiller réessayer $e"),
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
    // Afficher l'indicateur de chargement
    setState(() {
      isLoading = true;
    });

    if (widget.isEditable! == false) {
      await addMagasin().then((_) {
        // Cacher l'indicateur de chargement lorsque votre fonction est terminée
        setState(() {
          isLoading = false;
        });
        // Provider.of<MagasinService>(context, listen: false).applyChange();
        //  Navigator.of(context).pop();
      });
    } else {
      await updateMagasin().then((_) {
        // Cacher l'indicateur de chargement lorsque votre fonction est terminée
        setState(() {
          isLoading = false;
        });
        // Navigator.of(context).pop();
      });
    }
  }

  Future<void> addMagasin() async {
    final nomMagasin = nomMagasinController.text;
    final contactMagasin = contactMagasinController.text;
    final localiteMagasin = localiteMagasinController.text;
    MagasinService magasinService = MagasinService();
    try {
      if (photos != null) {
        await magasinService
            .creerMagasin(
                nomMagasin: nomMagasin,
                contactMagasin: contactMagasin,
                localiteMagasin: localiteMagasin,
                pays: acteur.niveau3PaysActeur!,
                photo: photos,
                acteur: acteur,
                niveau1Pays: niveau1Pays)
            .then((value) => {
                  Provider.of<MagasinService>(context, listen: false)
                      .applyChange(),
                  Navigator.pop(context, true),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Text("Ajouté avec succèss "),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  ),
                  nomMagasinController.clear(),
                  contactMagasinController.clear(),
                  localiteMagasinController.clear(),
                  setState(() {
                    // niveau1Pays == null;
                    photos == null;
                  }),
                });
      } else {
        await magasinService
            .creerMagasin(
                nomMagasin: nomMagasin,
                contactMagasin: contactMagasin,
                localiteMagasin: localiteMagasin,
                pays: acteur.niveau3PaysActeur!,
                acteur: acteur,
                niveau1Pays: niveau1Pays)
            .then((value) => {
                  Provider.of<MagasinService>(context, listen: false)
                      .applyChange(),
                  Navigator.pop(context, true),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Text("Ajouté avec succèss "),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  ),
                  nomMagasinController.clear(),
                  contactMagasinController.clear(),
                  localiteMagasinController.clear(),
                  setState(() {
                    niveauPaysValue == "Sélectionner une région";
                  }),
                });
      }
    } catch (e) {
      debugPrint("Erreur : $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Erreur')),
            content: Text("Une erreur s'est produite veuiller réessayer "),
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

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  Future<File?> getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;

    return File(image.path);
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        this.photos = image;
        imageSrc = image.path;
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
            title: Text("Choisir une source"),
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

  @override
  void initState() {
    super.initState();
    if (widget.isEditable! == true) {
      nomMagasinController.text = widget.magasin!.nomMagasin!;
      contactMagasinController.text = widget.magasin!.contactMagasin!;
      localiteMagasinController.text = widget.magasin!.localiteMagasin!;
      localiteController.text =widget.magasin!.niveau1Pays!.nomN1!;
      // photos = widget.photo;
      // print("image : ${widget.photo}");
      niveau1Pays = widget.magasin!.niveau1Pays!;
      niveauPaysValue = widget.magasin!.niveau1Pays!.idNiveau1Pays;
      debugPrint("Id Magasin " +
          widget.magasin!.idMagasin! +
          "bool" +
          widget.isEditable!.toString());
    }
    _searchController = TextEditingController();
    debugPrint("bool" + widget.isEditable!.toString());
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    niveau1PaysList = http.get(Uri.parse(
        '$apiOnlineUrl/niveau1Pays/listeNiveau1PaysByNomPays/${acteur.niveau3PaysActeur}'));
    debugPrint(
        '$apiOnlineUrl/niveau1Pays/listeNiveau1PaysByNomPays/${acteur.niveau3PaysActeur}');
    fetchLibelleNiveau1Pays();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
  }

  void _showLocalite() async {
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
                    hintText: 'Rechercher une localité',
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
                future: niveau1PaysList,
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
                      List<Niveau1Pays> typeListe = responseData
                          .map((e) => Niveau1Pays.fromMap(e))
                          .where((con) => con.statutN1 == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucune localité trouvée")),
                        );
                      }

                      String searchText = _searchController!.text.toLowerCase();
                      List<Niveau1Pays> filteredSearch = typeListe
                          .where((type) =>
                              type.nomN1!.toLowerCase().contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucune localité trouvée',
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
                                      niveau1Pays.idNiveau1Pays ==
                                          type.idNiveau1Pays;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.nomN1!,
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
                                                color: d_colorOr,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            niveau1Pays = type;
                                            localiteController.text =
                                                type.nomN1!;
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
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController!.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController!.clear();

                    localiteController.text = niveau1Pays.nomN1!;
                    print('Options sélectionnées : $niveau1Pays');
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

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: !(widget.isRoute ?? false) ? isLoading : false,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: !(widget.isRoute ?? false)
            ? AppBar(
                backgroundColor: d_colorOr,
                centerTitle: true,
                toolbarHeight: 75,
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    icon:
                        const Icon(Icons.arrow_back_ios, color: Colors.white)),
                title: Text(
                  widget.isEditable! == false
                      ? "Ajouter magasin"
                      : "Modifier magasin",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )
            : null,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Nom Magasin",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),

                      TextFormField(
                        controller: nomMagasinController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Entrez le nom du magasin",
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez le nom du magasin";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => nomMagasin = val!,
                      ),
                      // fin  nom magasin
                      const SizedBox(height: 10),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Contact Magasin ",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),

                      TextFormField(
                        controller: contactMagasinController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Entrez le contact du magasin",
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez le contact du magasin";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => contactMagasin = val!,
                      ),
                      // fin contact magasin
                      const SizedBox(height: 10),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Localité Magasin ",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showLocalite,
                        child: TextFormField(
                          onTap: _showLocalite,
                          controller: localiteController,
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.arrow_drop_down,
                                color: Colors.blueGrey[400]),
                            hintText: "Sélectionner une localité",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Adresse Magasin ",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: localiteMagasinController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Adresse du magasin",
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez la localité du magasin";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => localiteMagasin = val!,
                      ),
                      // fin localite magasin

                      const SizedBox(
                        height: 10,
                      ),
                      Text("Choisir une photo"),
                      SizedBox(
                    child: photos != null
                        ? GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Image.file(
                              photos!,
                              fit: BoxFit.fitWidth,
                              height: 150,
                              width: 200,
                            ),
                          )
                        : widget.isEditable == false
                            ?
                            // :  widget.stock!.photo == null || widget.stock!.photo!.isEmpty ?
                            SizedBox(
                                child: IconButton(
                                  onPressed: _showImageSourceDialog,
                                  icon: const Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 60,
                                  ),
                                ),
                              )
                            : Center(
                                child: widget.magasin!.photo != null &&
                                        !widget.magasin!.photo!.isEmpty
                                    ? GestureDetector(
                                        onTap: _showImageSourceDialog,
                                        child: CachedNetworkImage(
                                          height: 120,
                                          width: 150,
                                          imageUrl:
                                              "https://koumi.ml/api-koumi/Magasin/${widget.magasin!.idMagasin}/image",
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            'assets/images/default_image.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        child: IconButton(
                                          onPressed: _showImageSourceDialog,
                                          icon: const Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 60,
                                          ),
                                        ),
                                      )),
                  ),

                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Handle button press action here
                            if (_formKey.currentState!.validate()) {
                              _handleButtonPress();
                              // debugPrint("n1 : ${niveau1Pays}");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF8A00), // Orange color code
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(250, 40),
                          ),
                          child: Text(
                            widget.isEditable! == false
                                ? " Ajouter "
                                : " Modifier ",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
