import 'dart:convert';
import 'dart:io';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Filiere.dart';
import 'package:koumi/models/Forme.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/models/Unite.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddAndUpdateProductEndScreen.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';

class AddAndUpdateProductScreen extends StatefulWidget {
  bool? isEditable;
  final Stock? stock;
  AddAndUpdateProductScreen({super.key, this.isEditable, this.stock});

  @override
  State<AddAndUpdateProductScreen> createState() =>
      _AddAndUpdateProductScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _AddAndUpdateProductScreenState extends State<AddAndUpdateProductScreen> {
  final formkey = GlobalKey<FormState>();
  TextEditingController _prixController = TextEditingController();
  TextEditingController _quantiteController = TextEditingController();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _formController = TextEditingController();
  TextEditingController _origineController = TextEditingController();
  TextEditingController _monnaieController = TextEditingController();
  TextEditingController _uniteController = TextEditingController();

  late Acteur acteur;
  Unite unite = Unite();

  late Stock stock = Stock();
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late TextEditingController _searchController;
  List<Filiere> filiereListe = [];
  String? imageSrc;
  File? photo;
  String? formeValue;
  late Future _formeList;
  late Future _niveau3List;
  String? n3Value;
  String niveau3 = '';
  String forme = '';
  bool isLoadingLibelle = true;
  String? libelleNiveau3Pays;
  String? monnaieValue;
  late Future _monnaieList;
  late Future _uniteListe;
  late Monnaie monnaie = Monnaie();

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
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    // typeActeurData = acteur.typeActeur!;
    // type = typeActeurData.map((data) => data.libelle).join(', ');
    _searchController = TextEditingController();
    if (widget.isEditable! == true) {
      _nomController.text = widget.stock!.nomProduit!;
      _formController.text = widget.stock!.formeProduit!;
      // _origineController.text = widget.stock!.origineProduit!;
      _prixController.text = widget.stock!.prix!.toString();
      _quantiteController.text = widget.stock!.quantiteStock!.toString();
      forme = widget.stock!.formeProduit!;
      niveau3 = widget.stock!.origineProduit!;
      _origineController.text = widget.stock!.origineProduit!;
      monnaie = widget.stock!.monnaie!;
      unite = widget.stock!.unite!;
      _uniteController.text = widget.stock!.unite!.nomUnite!;
      monnaieValue = widget.stock!.monnaie!.idMonnaie;
      _monnaieController.text = widget.stock!.monnaie!.libelle!;
    }
    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
    _uniteListe = http.get(Uri.parse('$apiOnlineUrl/Unite/getAllUnite'));

    _formeList = http.get(Uri.parse('$apiOnlineUrl/formeproduit/getAllForme/'));
    _niveau3List = http.get(Uri.parse(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${acteur.niveau3PaysActeur}'));
    // verifyParam();
    fetchLibelleNiveau3Pays();
    // fetchPaysDataByActor();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
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
            widget.isEditable! ? 'Modifier de produit' : 'Ajout de produit',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Column(children: [
            SizedBox(
              height: 10,
            ),
            Form(
                key: formkey,
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Nom produit",
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
                      controller: _nomController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Nom produit",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Forme produit",
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
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Origine du produit",
                        style: TextStyle(color: (Colors.black), fontSize: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: GestureDetector(
                      onTap: _showLocalite,
                      child: TextFormField(
                        onTap: _showLocalite,
                        controller: _origineController,
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
                  ),
                  SizedBox(
                    height: 10,
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
                            "Prix du produit",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
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
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Veuillez saisir le prix du produit";
                              }
                              return null;
                            },
                            controller: _prixController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ThousandsFormatter(),
                            ],
                            decoration: InputDecoration(
                              hintText: "Prix du produit",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: GestureDetector(
                          onTap: _showMonnaie,
                          child: TextFormField(
                            onTap: _showMonnaie,
                            controller: _monnaieController,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Monnaie",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
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
                            "Quantité disponible",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
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
                            "Choisir l'unité",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez saisir la quantité du produit";
                                }
                                return null;
                              },
                              controller: _quantiteController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: "Quantite produit",
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                              child: GestureDetector(
                            onTap: _showUnite,
                            child: TextFormField(
                              onTap: _showUnite,
                              controller: _uniteController,
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.arrow_drop_down,
                                    color: Colors.blueGrey[400]),
                                hintText: "Unite",
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          )),
                        ],
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Choisir une photo"),
                  SizedBox(
                    child: photo != null
                        ? GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Image.file(
                              photo!,
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
                                child: widget.stock!.photo != null &&
                                        !widget.stock!.photo!.isEmpty
                                    ? GestureDetector(
                                        onTap: _showImageSourceDialog,
                                        child: CachedNetworkImage(
                                          height: 120,
                                          width: 150,
                                          imageUrl:
                                              "https://koumi.ml/api-koumi/Stock/${widget.stock!.idStock}/image",
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () async {
                        String formattedMontant =
                            _prixController.text.replaceAll(',', '');

                        final int prix = int.tryParse(formattedMontant) ?? 0;
                        print("prix formated $prix");

                        // if (formkey.currentState!.validate()) {
                        debugPrint(
                            "forme: ${forme} , formeValue : ${formeValue}, origin : ${niveau3} , value : ${n3Value},  quantite: ${_quantiteController.text}");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    (AddAndUpdateProductEndSreen(
                                      monnaies: monnaie,
                                      isEditable: widget.isEditable!,
                                      nomProduit: _nomController.text,
                                      forme: forme,
                                      unite: unite,
                                      origine: niveau3,
                                      prix: prix.toString(),
                                      image: photo,
                                      quantite: _quantiteController.text,
                                      stock: widget.stock,
                                    )))).then((value) => {
                              if (widget.isEditable! == false)
                                {
                                  _nomController.clear(),
                                  _prixController.clear(),
                                  _quantiteController.clear(),
                                  _monnaieController.clear(),
                                  _uniteController.clear(),
                                  _origineController.clear(),
                                  _formController.clear(),

                                  setState(() {
                                    niveau3 == null;
                                    unite == null;
                                    monnaie == null;
                                    n3Value = null;
                                    monnaieValue = null;
                                    formeValue = null;
                                  })
                                }
                            });
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: d_colorGreen, // Orange color code
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: const Size(290, 45),
                      ),
                      child: Text(
                        "Suivant",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                ]))
          ])
        ])));
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                overflow: TextOverflow.ellipsis,
                fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
                fontSize: 16),
          )
        ],
      ),
    );
  }

  void _showUnite() async {
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
                    hintText: 'Rechercher une unité ',
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
                future: _uniteListe,
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
                      List<Unite> typeListe = responseData
                          .map((e) => Unite.fromMap(e))
                          .where((con) => con.statutUnite == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucune unité trouvée")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Unite> filteredSearch = typeListe
                          .where((type) =>
                              type.nomUnite!.toLowerCase().contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucune unité trouvée',
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
                                      unite.idUnite == type.idUnite;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.nomUnite!,
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
                                            unite = type;
                                            _uniteController.text =
                                                type.nomUnite!;
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
                    _uniteController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorGreen, fontSize: 16),
                  ),
                  onPressed: () {
                    _uniteController.clear();
                    _uniteController.text = unite.nomUnite!;
                    print('Options sélectionnées : $unite');
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
                                                color: d_colorGreen,
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
                    style: TextStyle(color: d_colorGreen, fontSize: 16),
                  ),
                  onPressed: () {
                    _monnaieController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorGreen, fontSize: 16),
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
                                  final type =
                                      filteredSearch[index].libelleForme;
                                  final isSelected =
                                      _formController.text == type;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type!,
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
                                            forme = type;
                                            _formController.text = forme;
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
                    _formController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorGreen, fontSize: 16),
                  ),
                  onPressed: () {
                    _formController.clear();
                    _formController.text = forme;
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
                                itemBuilder: (context, index) {
                                  final type = filteredSearch[index].nomN3;
                                  final isSelected =
                                      _origineController.text == type;

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
                                                color: d_colorGreen,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            niveau3 = type;
                                            _origineController.text = type;
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
                    _origineController.text = niveau3;
                    print('Options sélectionnées : $niveau3');
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
