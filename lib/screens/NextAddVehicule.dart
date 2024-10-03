import 'dart:convert';
import 'dart:io';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/TypeVoiture.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/VehiculeService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

class NextAddVehicule extends StatefulWidget {
  final TypeVoiture typeVoiture;
  final String nomV;
  final String localite;
  final String description;
  final String nbKilo;
  final String capacite;

  const NextAddVehicule({
    super.key,
    required this.typeVoiture,
    required this.nomV,
    required this.localite,
    required this.description,
    required this.nbKilo,
    required this.capacite,
  });

  @override
  State<NextAddVehicule> createState() => _NextAddVehiculeState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _NextAddVehiculeState extends State<NextAddVehicule> {
  TextEditingController _etatController = TextEditingController();
  TextEditingController _prixController = TextEditingController();
  TextEditingController newDestinationController = TextEditingController();
  TextEditingController newPrixController = TextEditingController();
  TextEditingController _monnaieController = TextEditingController();
  List<Widget> destinationPrixFields = [];
  List<TextEditingController> destinationControllers = [];
  List<TextEditingController> prixControllers = [];
  late TextEditingController _searchController;
  late Map<String, int> prixParDestinations;
  final formkey = GlobalKey<FormState>();
  String? imageSrc;
  File? photo;
  late Acteur acteur;
  bool _isLoading = false;
  late Future _niveau3List;
  String? n3Value;
  // List<String>? n3Value = [];
  String niveau3 = '';
  List<String> selectedDestinations = [];
  bool isLoadingLibelle = true;
  String? libelleNiveau3Pays;
  String? monnaieValue;
  late Future _monnaieList;
  late Monnaie monnaie = Monnaie();

  List<String?> selectedDestinationsList = [];

  // Méthode pour ajouter une nouvelle destination et prix
  void addDestinationAndPrix() {
    // Créer un nouveau contrôleur pour chaque champ
    TextEditingController newDestinationController = TextEditingController();
    TextEditingController newPrixController = TextEditingController();

    setState(() {
      // Ajouter les nouveaux contrôleurs aux listes
      destinationControllers.add(newDestinationController);
      prixControllers.add(newPrixController);

      // Ajouter une valeur nulle à la liste des destinations sélectionnées
      selectedDestinationsList.add(null);
    });
  }

  void _handleButtonPress() async {
    // Afficher l'indicateur de chargement
    setState(() {
      _isLoading = true;
    });
  }

  Future<String> getLibelleNiveau3PaysByActor(String id) async {
    final response = await http
        .get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau3Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response
          .body; // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau3Pays');
    }
  }

  Future<void> fetchLibelleNiveau3Pays() async {
    try {
      String libelle = await getLibelleNiveau3PaysByActor(acteur.idActeur!);
      setState(() {
        libelleNiveau3Pays = libelle;
        isLoadingLibelle = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLibelle = false;
      });
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
     _searchController = TextEditingController();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    prixParDestinations = {};
    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
    _niveau3List = http.get(Uri.parse(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${acteur.niveau3PaysActeur}'));
    fetchLibelleNiveau3Pays();
  }

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

 @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
          title: Text(
            'Etape 2',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                  key: formkey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Etat du véhicule",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
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
                          controller: _etatController,
                          decoration: InputDecoration(
                            hintText: "Etat du véhicule",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                       Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: GestureDetector(
                            onTap: _showMonnaie,
                            child: TextFormField(
                              onTap: _showMonnaie,
                              controller: _monnaieController,
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.arrow_drop_down,
                                    color: Colors.blueGrey[400]),
                                hintText: "Sélectionner une monnaie",
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Destination et prix",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    // Appeler la méthode pour ajouter une destination et un prix
                                    addDestinationAndPrix();
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: d_colorOr,
                                  ),
                                  label: Text(
                                    'Ajouter les  prix',
                                    style: TextStyle(
                                        color: d_colorOr, fontSize: 17,  decoration: TextDecoration.underline ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                           Column(
                              children: List.generate(
                                destinationControllers.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _showLocalite(
                                              index), // Pass the index here
                                          child: TextFormField(
                                            onTap: () => _showLocalite(
                                                index), // Pass the index here
                                            controller:
                                                destinationControllers[index],
                                            decoration: InputDecoration(
                                              suffixIcon: Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.blueGrey[400],
                                              ),
                                              hintText: "Destination",
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 20,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          controller: prixControllers[index],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            ThousandsFormatter(),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: "Prix",
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 20,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: destinationPrixFields,
                      ),
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
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
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () async {
                            final String nom = widget.nomV;
                            final String description = widget.description;
                            // final String prix = _prixController.text;
                            final String capacite = widget.capacite;
                            final String etat = _etatController.text;
                            final String localite = widget.localite;
                            final String nbKilometrage = widget.nbKilo;
                            final TypeVoiture type = widget.typeVoiture;

                            setState(() {
                              for (int i = 0;
                                  i < selectedDestinationsList.length;
                                  i++) {
                                String destination = selectedDestinations[i];
                                String formattedMontant =
                                    prixControllers[i].text.replaceAll(',', '');
                                int prix = int.tryParse(formattedMontant) ?? 0;
                                print("prix : $prix");
                                // Ajouter la destination et le prix à la nouvelle map
                                if (destination.isNotEmpty && prix > 0) {
                                  prixParDestinations
                                      .addAll({destination: prix});
                                }
                              }
                            });

                            if (formkey.currentState!.validate()) {
                              try {
                                setState(() {
                                  _isLoading = true;
                                });
                                if (photo != null) {
                                  await VehiculeService()
                                      .addVehicule(
                                          nomVehicule: nom,
                                          capaciteVehicule: capacite,
                                          localisation: localite,
                                          description: description,
                                          nbKilometrage: nbKilometrage,
                                          prixParDestination:
                                              prixParDestinations,
                                          photoVehicule: photo,
                                          etatVehicule: etat,
                                          typeVoiture: type,
                                          acteur: acteur,
                                          monnaie: monnaie)
                                      .then((value) => {
                                            Provider.of<VehiculeService>(
                                                    context,
                                                    listen: false)
                                                .applyChange(),
                                            _etatController.clear(),
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
                                                      "vehicule ajouté avec succèss",
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
                                            print(onError.toString())
                                          });
                                } else {
                                  await VehiculeService()
                                      .addVehicule(
                                          nomVehicule: nom,
                                          capaciteVehicule: capacite,
                                          prixParDestination:
                                              prixParDestinations,
                                          description: description,
                                          nbKilometrage: nbKilometrage,
                                          localisation: localite,
                                          etatVehicule: etat,
                                          typeVoiture: type,
                                          acteur: acteur,
                                          monnaie: monnaie)
                                      .then((value) => {
                                            Provider.of<VehiculeService>(
                                                    context,
                                                    listen: false)
                                                .applyChange(),
                                            // _nomController.clear(),
                                            // _descriptionController.clear(),
                                            // _prixController.clear(),
                                            // _capaciteController.clear(),
                                            _etatController.clear(),
                                            setState(() {
                                              _isLoading = false;
                                              // typeVoiture == null;
                                            }),
                                            Navigator.pop(context, true),
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Row(
                                                  children: [
                                                    Text(
                                                      "vehicule ajouté avec succèss",
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
                                            print(onError.toString()),
                                            setState(() {
                                              _isLoading = false;
                                            }),
                                          });
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                final String errorMessage = e.toString();
                                print(errorMessage);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Text(
                                          "Une erreur s'est produit",
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
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
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

  void _showLocalite(int index) async {
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
                future: _niveau3List,
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
                      List<Niveau3Pays> typeListe = responseData
                          .map((e) => Niveau3Pays.fromMap(e))
                          .where((con) => con.statutN3 == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucune localité trouvée")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Niveau3Pays> filteredSearch = typeListe
                          .where((type) =>
                              type.nomN3.toLowerCase().contains(searchText))
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
                                itemBuilder: (context, i) {
                                  final type = filteredSearch[i].nomN3;
                                  final isSelected =
                                      selectedDestinations.contains(type);

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type,
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
                                            niveau3 = type;

                                            if (index >= 0 &&
                                                index <
                                                    destinationControllers
                                                        .length) {
                                              isSelected
                                                  ? selectedDestinations
                                                      .remove(type)
                                                  : selectedDestinations
                                                      .add(type);
                                              destinationControllers[index]
                                                  .text = type;
                                            } else {
                                              print(
                                                  'Index hors limites : $index');
                                            }
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
                    // selectedDestinations.remove(niveau3);
                    _searchController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    // selectedDestinations.add(niveau3);
                    print('Options sélectionnées : $selectedDestinations');
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
