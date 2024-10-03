// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:intl/intl.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Forme.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/FormeService.dart';
import 'package:koumi/service/IntrantService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

class NextAddIntrat extends StatefulWidget {
  final String nom;
  final String description;
  final double quantite;
  final String unite;
  final CategorieProduit categorieProduit;
  const NextAddIntrat({
    Key? key,
    required this.nom,
    required this.description,
    required this.quantite,
    required this.unite,
    required this.categorieProduit,
  }) : super(key: key);

  @override
  State<NextAddIntrat> createState() => _NextAddIntratState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _NextAddIntratState extends State<NextAddIntrat> {
  TextEditingController _prixController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  late Speculation speculation;
  TextEditingController _formController = TextEditingController();

  TextEditingController _monnaieController = TextEditingController();
  late CategorieProduit categorieProduit = CategorieProduit();
  String? monnaieValue;
  late Future _monnaieList;
  late Monnaie monnaie = Monnaie();
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();
  late Acteur acteur;
  late TextEditingController _searchController;
  String? imageSrc;
  File? photo;
  String? formeValue;
  late Future _formeList;
  late Forme forme;

  bool isLoadingLibelle = true;

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(imagePath);
    final image = File('${directory.path}/$name');
    return image;
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        photo = image;
        imageSrc = image.path;
      });
    }
  }

  Future<File?> getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;

    return File(image.path);
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: const Text('Choisir une source'),
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    _pickImage(ImageSource.camera);
                  },
                  child: const Column(
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
                  child: const Column(
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

  void _handleButtonPress() async {
    // Afficher l'indicateur de chargement
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _searchController = TextEditingController();
    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
    _formeList = http.get(Uri.parse('$apiOnlineUrl/formeproduit/getAllForme/'));
  }

@override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Forme>> fetchList() async {
    final response = await FormeService().fetchForme();
    return response;
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
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
            title: Text(
              'Etape 2 ',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: formkey,
                  child: Column(children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Choisir la forme",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: GestureDetector(
                          onTap: _showForme,
                          child: TextFormField(
                            onTap: _showForme,
                            controller: _formController,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Sélectionner une forme",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Date de péremption",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez remplir les champs";
                          }
                          return null;
                        },
                        controller: _dateController,
                        decoration: InputDecoration(
                          hintText: 'Sélectionner la date',
                          prefixIcon: const Icon(
                            Icons.date_range,
                            color: d_colorGreen,
                            size: 30.0,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100));
                          if (pickedDate != null) {
                            print(pickedDate);
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            print(formattedDate);
                            setState(() {
                              _dateController.text = formattedDate;
                            });
                          } else {}
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 22,
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Prix intrant",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 22,
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Choisir la monnaie",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Veuillez remplir les champs";
                                    }
                                    return null;
                                  },
                                  controller: _prixController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    ThousandsFormatter(),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "Prix intrant",
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                )),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: GestureDetector(
                                  onTap: _showMonnaie,
                                  child: TextFormField(
                                    onTap: _showMonnaie,
                                    controller: _monnaieController,
                                    decoration: InputDecoration(
                                      suffixIcon: Icon(Icons.arrow_drop_down,
                                          color: Colors.blueGrey[400]),
                                      hintText: "Monnaie",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Choisir une photo"),
                    SizedBox(
                      child: photo != null
                          ? GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Image.file(
                                photo!,
                                fit: BoxFit.fitWidth,
                                height: 150,
                                width: 300,
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
                            ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () async {
                          final String nom = widget.nom;
                          final String description = widget.description;
                          final double quantite = widget.quantite;
                          final CategorieProduit categorieProduit =
                              widget.categorieProduit;
                          final String unite = widget.unite;
                          String formattedMontant =
                              _prixController.text.replaceAll(',', '');

                          final int prix = int.tryParse(formattedMontant) ?? 0;
                          print("prix formated $prix");
                          final String date = _dateController.text;

                          if (formkey.currentState!.validate()) {
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              if (photo != null) {
                                await IntrantService()
                                    .creerIntrant(
                                        nomIntrant: nom,
                                        quantiteIntrant: quantite,
                                        descriptionIntrant: description,
                                        prixIntrant: prix,
                                        photoIntrant: photo,
                                        dateExpiration: date,
                                        forme: forme,
                                        unite: unite,
                                        categorieProduit: categorieProduit,
                                        acteur: acteur,
                                        monnaie: monnaie)
                                    .then((value) => {
                                          Provider.of<IntrantService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          _prixController.clear(),
                                          setState(() {
                                            _isLoading = false;
                                          }),
                                          Navigator.pop(context, true),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Text(
                                                    "Intant ajouté avec succèss",
                                                    style: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                              duration: Duration(seconds: 5),
                                            ),
                                          )
                                        })
                                    .catchError((onError) => {
                                          setState(() {
                                            _isLoading = false;
                                          }),
                                          print('Erreur :${onError.message}'),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Text(
                                                    "Une erreur s'est produite",
                                                    style: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                              duration: Duration(seconds: 5),
                                            ),
                                          )
                                        });
                              } else {
                                await IntrantService()
                                    .creerIntrant(
                                        nomIntrant: nom,
                                        quantiteIntrant: quantite,
                                        descriptionIntrant: description,
                                        prixIntrant: prix,
                                        dateExpiration: date,
                                        categorieProduit: categorieProduit,
                                        forme: forme,
                                        unite: unite,
                                        acteur: acteur,
                                        monnaie: monnaie)
                                    .then((value) => {
                                          Provider.of<IntrantService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          _prixController.clear(),
                                          setState(() {
                                            _isLoading = false;
                                          }),
                                          Navigator.pop(context, true),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Text(
                                                    "Intant ajouté avec succèss",
                                                    style: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                              duration: Duration(seconds: 5),
                                            ),
                                          )
                                        })
                                    .catchError((onError) => {
                                          print('Erreur :${onError.message}'),
                                          setState(() {
                                            _isLoading = false;
                                          }),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Text(
                                                    "Une erreur s'est produite",
                                                    style: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                              duration: Duration(seconds: 5),
                                            ),
                                          )
                                        });
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              print('Erreur :${e.toString()}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Text(
                                        "Erreur de connexion !",
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: d_colorOr, // Orange color code
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize: const Size(290, 45),
                        ),
                        child: Text(
                          "Ajouter",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ]),
                )
              ],
            ),
          ),
        ));
  }

  void _showMonnaie() async {
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
                    hintText: 'Rechercher un monnaie ',
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
                future: _monnaieList,
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
                      List<Monnaie> typeListe = responseData
                          .map((e) => Monnaie.fromMap(e))
                          .where((con) => con.statut == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucune monnaie trouvée")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Monnaie> filteredSearch = typeListe
                          .where((type) =>
                              type.libelle!.toLowerCase().contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucune monnaie trouvée',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final type = filteredSearch[index];
                                  final isSelected = monnaie == type;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.libelle!,
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
                                            monnaie = type;
                                            _monnaieController.text =
                                                type.libelle!;
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
                    _monnaieController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _monnaieController.clear();
                    _monnaieController.text = monnaie.libelle!;
                    print('Options sélectionnées : $monnaie');
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

  void _showForme() async {
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
                    hintText: 'Rechercher une forme',
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
                future: _formeList,
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
                      List<Forme> typeListe = responseData
                          .map((e) => Forme.fromMap(e))
                          .where((con) => con.statutForme == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucune forme trouvée")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Forme> filteredSearch = typeListe
                          .where((type) => type.libelleForme!
                              .toLowerCase()
                              .contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucune forme trouvée',
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
                                      _formController.text == type.libelleForme;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.libelleForme!,
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
                                            forme = type;
                                            _formController.text =
                                                forme.libelleForme!;
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
                    _formController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _formController.clear();
                    _formController.text = forme.libelleForme!;
                    print('Options sélectionnées : $forme');
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
}
