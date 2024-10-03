import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/AddZone.dart';
import 'package:koumi/Admin/Zone.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Filiere.dart';
import 'package:koumi/models/Magasin.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/Unite.dart';
import 'package:koumi/models/ZoneProduction.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddMagasinScreen.dart';
import 'package:koumi/screens/DetailProduits.dart';
import 'package:koumi/screens/MyStores.dart';
import 'package:koumi/service/StockService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAndUpdateProductEndSreen extends StatefulWidget {
  bool? isEditable;
  late Stock? stock;
  String? nomProduit, origine, forme, prix, quantite;
  File? image;
  Monnaie? monnaies;
  Unite? unite;

  AddAndUpdateProductEndSreen(
      {super.key,
      this.isEditable,
      this.stock,
      this.nomProduit,
      this.forme,
      this.origine,
      this.prix,
      this.quantite,
      this.image,
      this.unite,
      this.monnaies});

  @override
  State<AddAndUpdateProductEndSreen> createState() =>
      _AddAndUpdateProductEndSreenState();
}


const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
class _AddAndUpdateProductEndSreenState
    extends State<AddAndUpdateProductEndSreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController uniteController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController magasinController = TextEditingController();
  TextEditingController zoneController = TextEditingController();
  TextEditingController speculationController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  File? photos;
  String? speValue;
  String? catValue;
  String? filiereValue;
  late Future _speculationList;
  late Future _categorieList;
  late Future _filiereList;
  late Filiere filiere = Filiere();
  late Speculation speculation = Speculation();
  late CategorieProduit categorieProduit = CategorieProduit();
  String? uniteValue;
  Unite unite = Unite(); // Initialisez l'objet unite
  late Future uniteListe;
  String? magasinValue;
  Monnaie monnaies = Monnaie();
  late Magasin magasin = Magasin();
  late Future magasinListe;
  String? zoneValue;
  ZoneProduction zoneProduction = ZoneProduction();
  late Future zoneListe;
  late Acteur acteur = Acteur();
  String? id = "";
  String? email = "";
  bool isExist = false;
  late TextEditingController _searchController;

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      setState(() {
        id = acteur.idActeur;
        zoneListe = http.get(Uri.parse(
            '$apiOnlineUrl/ZoneProduction/getAllZonesByActeurs/${id}'));
        magasinListe = http.get(
            Uri.parse('$apiOnlineUrl/Magasin/getAllMagasinByActeur/${id}'));
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  void handleButtonPress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    if (widget.isEditable == false) {
      await ajouterStock().then((_) {
        _typeController.clear();
        _descriptionController.clear();
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context, true);
      });
    } else {
      await updateProduit().then((_) {
        _typeController.clear();
        _descriptionController.clear();

        Navigator.pop(context, true);
      });
      _typeController.clear();
      _descriptionController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fonction pour traiter les données du QR code scanné
  Future<void> processScannedQRCode(Stock scannedData) async {
    // Ici, vous pouvez décoder les données du QR code et effectuer les actions nécessaires
    // Par exemple, naviguer vers la page de détail du produit avec les données du produit
    // Veuillez remplacer DetailProduits avec le nom de votre widget de détail du produit
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailProduits(stock: scannedData),
      ),
    );
  }

  Future<void> ajouterStock() async {
    try {
      if (widget.image != null) {
        await StockService().creerStock(
            nomProduit: widget.nomProduit!,
            origineProduit: widget.origine!,
            prix: widget.prix!,
            formeProduit: widget.forme!,
            quantiteStock: widget.quantite!,
            photo: widget.image,
            typeProduit: _typeController.text,
            descriptionStock: _descriptionController.text,
            zoneProduction: zoneProduction,
            speculation: speculation,
            unite: unite,
            magasin: magasin,
            acteur: acteur,
            monnaie: widget.monnaies!);
      } else {
        await StockService().creerStock(
            nomProduit: widget.nomProduit!,
            origineProduit: widget.origine!,
            prix: widget.prix!,
            formeProduit: widget.forme!,
            quantiteStock: widget.quantite!,
            typeProduit: _typeController.text,
            descriptionStock: _descriptionController.text,
            zoneProduction: zoneProduction,
            speculation: speculation,
            unite: unite,
            magasin: magasin,
            acteur: acteur,
            monnaie: widget.monnaies!);
      }
    } catch (error) {
      // Handle any exceptions that might occur during the request
      final String errorMessage = error.toString();
      debugPrint("no " + errorMessage);
    }
  }

  Future<void> updateProduit() async {
    try {
      print("quantiteStock: ${widget.quantite!},");
      if (widget.image != null) {
        await StockService().updateStock(
            idStock: widget.stock!.idStock!,
            nomProduit: widget.nomProduit!,
            origineProduit: widget.origine!,
            prix: widget.prix!,
            formeProduit: widget.forme!,
            quantiteStock: widget.quantite!,
            photo: widget.image,
            dateProduction: widget.stock!.dateAjout!,
            typeProduit: _typeController.text,
            descriptionStock: _descriptionController.text,
            zoneProduction: zoneProduction,
            speculation: speculation,
            unite: unite,
            magasin: magasin,
            acteur: acteur,
            monnaie: widget.monnaies!);
      } else {
        await StockService().updateStock(
            idStock: widget.stock!.idStock!,
            nomProduit: widget.nomProduit!,
            origineProduit: widget.origine!,
            prix: widget.prix!,
            formeProduit: widget.forme!,
            quantiteStock: widget.quantite!,
            typeProduit: _typeController.text,
            descriptionStock: _descriptionController.text,
            zoneProduction: zoneProduction,
            dateProduction: widget.stock!.dateAjout!,
            speculation: speculation,
            unite: unite,
            magasin: magasin,
            acteur: acteur,
            monnaie: widget.monnaies!);
      }
    } catch (error) {
      // Handle any exceptions that might occur during the request
      final String errorMessage = error.toString();
      debugPrint("no update " + errorMessage);
    }
  }

  @override
  void initState() {
    verify();
    _searchController = TextEditingController();
    magasinListe = http.get(Uri.parse(
        '$apiOnlineUrl/Magasin/getAllMagasinByActeur/${acteur.idActeur}'));

    _speculationList =
        http.get(Uri.parse('$apiOnlineUrl/Speculation/getAllSpeculation'));

    uniteListe = http.get(Uri.parse('$apiOnlineUrl/Unite/getAllUnite'));
    zoneListe = http.get(Uri.parse(
        '$apiOnlineUrl/ZoneProduction/getAllZonesByActeurs/${acteur.idActeur}'));

    debugPrint(
        "nom : ${widget.nomProduit},   monnaie : ${widget.monnaies},  bool : ${widget.isEditable} ,image : ${widget.image.toString()} , forme: ${widget.forme}, origine : ${widget.origine}, qte : ${widget.quantite}, prix : ${widget.prix}");
    monnaies = widget.monnaies!;
    unite = widget.unite!;
    if (widget.isEditable! == true) {
      unite = widget.unite!;

      speculationController.text = widget.stock!.speculation!.nomSpeculation!;
      _typeController.text = widget.stock!.typeProduit!;
      _descriptionController.text = widget.stock!.descriptionStock!;
      magasinController.text = widget.stock!.magasin!.nomMagasin!;
      zoneController.text = widget.stock!.zoneProduction!.nomZoneProduction!;
      debugPrint("id : $id,  forme : ${widget.forme}");
      magasin = widget.stock!.magasin!;
      magasinValue = widget.stock!.magasin!.idMagasin;
      speculation = widget.stock!.speculation!;

      unite = widget.stock!.unite!;
      uniteValue = widget.stock!.unite!.idUnite;
      zoneProduction = widget.stock!.zoneProduction!;
      zoneValue = widget.stock!.zoneProduction!.idZoneProduction;
      super.initState();
    }
  }

  void _showZone() async {
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
                    hintText: 'Rechercher une zone ',
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
              contentPadding: EdgeInsets.all(20),
              content: FutureBuilder(
                future: zoneListe,
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
                      List<ZoneProduction> typeListe = responseData
                          .map((e) => ZoneProduction.fromMap(e))
                          .where((con) => con.statutZone == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            _showAddZoneDialog().then((value) {
                              zoneListe = http.get(Uri.parse(
                                  '$apiOnlineUrl/ZoneProduction/getAllZonesByActeurs/${acteur.idActeur}'));
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            backgroundColor:
                                d_colorGreen, // Style de fond personnalisé
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Bords arrondis
                            ),
                          ),
                          child: const Text(
                            "Ajouter une zone",
                            style: TextStyle(
                              color: Colors.white, // Couleur du texte
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<ZoneProduction> filteredSearch = typeListe
                          .where((type) => type.nomZoneProduction!
                              .toLowerCase()
                              .contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showAddZoneDialog().then((value) {
                                  zoneListe = http.get(Uri.parse(
                                      '$apiOnlineUrl/ZoneProduction/getAllZonesByActeurs/${acteur.idActeur}'));
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                backgroundColor:
                                    d_colorGreen, // Style de fond personnalisé
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Bords arrondis
                                ),
                              ),
                              child: const Text(
                                "Ajouter une zone",
                                style: TextStyle(
                                  color: Colors.white, // Couleur du texte
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final type = filteredSearch[index];
                                  final isSelected = zoneController.text ==
                                      type.nomZoneProduction;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.nomZoneProduction!,
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
                                            zoneProduction = type;
                                            zoneValue = type.idZoneProduction;
                                            zoneController.text =
                                                type.nomZoneProduction!;
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

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Aucune zone trouvée",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                            height: 20), // Ajout d'espace entre les éléments
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            _showAddZoneDialog().then((value) {
                              zoneListe = http.get(Uri.parse(
                                  '$apiOnlineUrl/ZoneProduction/getAllZonesByActeurs/${acteur.idActeur}'));
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            backgroundColor:
                                d_colorGreen, // Style de fond personnalisé
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Bords arrondis
                            ),
                          ),
                          child: const Text(
                            "Ajouter une zone",
                            style: TextStyle(
                              color: Colors.white, // Couleur du texte
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
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
                    _searchController.clear();
                    print('Options sélectionnées : $zoneProduction');
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

  void _showMagasin() async {
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
                    hintText: 'Rechercher un magasin ',
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
              contentPadding: EdgeInsets.all(20),
              content: FutureBuilder(
                future: magasinListe,
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
                      List<Magasin> typeListe = responseData
                          .map((e) => Magasin.fromMap(e))
                          .where((con) => con.statutMagasin == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            _showAddMagasinDialog().then((value) {
                              magasinListe = http.get(Uri.parse(
                                  '$apiOnlineUrl/Magasin/getAllMagasinByActeur/${acteur.idActeur}'));
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            backgroundColor:
                                d_colorGreen, // Style de fond personnalisé
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Bords arrondis
                            ),
                          ),
                          child: const Text(
                            "Ajouter un magasin",
                            style: TextStyle(
                              color: Colors.white, // Couleur du texte
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Magasin> filteredSearch = typeListe
                          .where((type) => type.nomMagasin!
                              .toLowerCase()
                              .contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();

                                _showAddMagasinDialog().then((value) {
                                  magasinListe = http.get(Uri.parse(
                                      '$apiOnlineUrl/Magasin/getAllMagasinByActeur/${acteur.idActeur}'));
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                backgroundColor:
                                    d_colorGreen, // Style de fond personnalisé
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Bords arrondis
                                ),
                              ),
                              child: const Text(
                                "Ajouter un magasin",
                                style: TextStyle(
                                  color: Colors.white, // Couleur du texte
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final type = filteredSearch[index];
                                  final isSelected =
                                      magasinController.text == type.nomMagasin;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.nomMagasin!,
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
                                            magasin = type;
                                            magasinValue = magasin.idMagasin;
                                            magasinController.text =
                                                type.nomMagasin!;
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

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Aucun magasin trouvée",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                            height: 20), // Ajout d'espace entre les éléments
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            _showAddMagasinDialog().then((value) {
                              magasinListe = http.get(Uri.parse(
                                  '$apiOnlineUrl/Magasin/getAllMagasinByActeur/${acteur.idActeur}'));
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            backgroundColor:
                                d_colorGreen, // Style de fond personnalisé
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Bords arrondis
                            ),
                          ),
                          child: const Text(
                            "Ajouter un magasin",
                            style: TextStyle(
                              color: Colors.white, // Couleur du texte
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
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
                    _searchController.clear();
                    print('Options sélectionnées : $magasin');
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

  void _showSpeculation() async {
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
                    hintText: 'Rechercher une speculation',
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
                future: _speculationList,
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
                          child:
                              Center(child: Text("Aucune speculation trouvée")),
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
                              'Aucune speculation trouvée',
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
                                      speculationController.text ==
                                          type.nomSpeculation;

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
                                            speculation = type;
                                            speculationController.text =
                                                type.nomSpeculation!;
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
                    _searchController.clear();
                    print('Options sélectionnées : $speculation');
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

  Future<void> _getResultFromZonePage(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Zone()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        zoneListe = http.get(Uri.parse(
            '$apiOnlineUrl/ZoneProduction/getAllZonesByActeurs/${acteur.idActeur}'));
      });
    }
  }

  Future<void> _getResultFromMagasinPage(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyStoresScreen()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        magasinListe = http.get(Uri.parse(
            '$apiOnlineUrl/Magasin/getAllMagasinByActeur/${acteur.idActeur}'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
          backgroundColor: d_colorGreen,
          centerTitle: true,
          toolbarHeight: 75,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
          title: Text(
            widget.isEditable == false ? "Ajouter produit" : "Modifier produit",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Choisir une spéculation ",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showSpeculation,
                          child: TextFormField(
                            onTap: _showSpeculation,
                            controller: speculationController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Sélectionner une speculation",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Magasin ",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showMagasin,
                          child: TextFormField(
                            onTap: _showMagasin,
                            controller: magasinController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Sélectionner un magasin",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Zone de production",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showZone,
                          child: TextFormField(
                            onTap: _showZone,
                            controller: zoneController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Sélectionner une zone",
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
                              horizontal: 10, vertical: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Type Produit  ",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez saisir le type du produit";
                            }
                            return null;
                          },
                          controller: _typeController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Type produit",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Description Produit ",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez saisir la description du produit";
                            }
                            return null;
                          },
                          enableSuggestions: true,
                          maxLines: null,
                          controller: _descriptionController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Description produit",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Handle button press action here
                              if (_formKey.currentState!.validate()) {
                                print('Form is valid');
                                print('magasinValue: $magasinValue');
                                print('zoneValue: $zoneValue');

                                if (magasinValue != null && zoneValue != null) {
                                  handleButtonPress();
                                } else if (magasinValue == null &&
                                    zoneValue == null) {
                                  _showMessageDialog();
                                } else if (magasinValue == null) {
                                  _showMagasinDialog();
                                } else if (zoneValue == null) {
                                  _showZoneDialog();
                                }
                              } else {
                                print('Form is not valid');
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
                              widget.isEditable == false
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
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }


  void _showMagasinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Aucun magasin disponible')),
          content: const Text("Veuillez au préalable créer un magasin"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Get.back();
                Navigator.of(context).pop();
                _getResultFromMagasinPage(context);
              },
              child: const Text('Créer un magasin'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic?> _showAddMagasinDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Ajouter un magasin')),
          content: AddMagasinScreen(
            isEditable: false,
            isRoute: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Fermer',
                style: TextStyle(color: d_colorGreen, fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic?> _showAddZoneDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Ajouter une zone')),
          content: AddZone(
            isRoute: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Fermer',
                style: TextStyle(color: d_colorGreen, fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showMessageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Center(child: Text('Aucun magasin et zone  sélectionner')),
          content: const Text(
              "Veuillez au préalable créer un magasin et une zone de production(Profil)"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _showZoneDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Aucune zone disponible')),
          content: const Text("Veuillez au préalable ajouter une zone"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Get.back();
                Navigator.of(context).pop();
                _getResultFromZonePage(context);
              },
              child: const Text('Ajouter une zone'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }
}
