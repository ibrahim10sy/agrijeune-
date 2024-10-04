import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfil extends StatefulWidget {
  // Acteur? acteurs;
  EditProfil({super.key});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

const d_colorPage = Color.fromRGBO(255, 255, 255, 1);

class _EditProfilState extends State<EditProfil> {
  TextEditingController nomActeurController = TextEditingController();
  TextEditingController whatsAppController = TextEditingController();
  TextEditingController telephoneActeurController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController localisationController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  MultiSelectController _controllerTypeActeur = MultiSelectController();
  late TextEditingController _searchController;
  TextEditingController typeSController = TextEditingController();
  TextEditingController typeController = TextEditingController();

  MultiSelectController _controllerSpeculation = MultiSelectController();
  List<TypeActeur> typeActeur = [];
  final _tokenTextController = TextEditingController();
  List<Speculation> optionS = [];
  bool isEditing = false;
  bool _isLoading = false;
  bool _obscureText = true;
  Acteur? acteur;
  String? imageSrc;
  String? id;
  File? photo;
  File? image1;
  String? image1Src;
  late List<TypeActeur> typeActeurData = [];
  late String type;
  List<TypeActeur> selectedTypes = [];
  List<Speculation> selectedSpec = [];
  List<String> specu = [];
  List<String> typeLibelle = [];
  List<String> libelleSpeculation = [];
  List<Speculation> listeSpeculations = [];
  late Future _typeListe;
  late Future _typeList;
  String niveau3 = '';
  late Future _niveau3List;

  Future<File> saveImagePermanently(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final name = path.basename(imagePath);
      final image = File('${directory.path}/$name');
      return File(imagePath).copy(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sauvegarde de l\'image : $e');
      rethrow;
    }
  }

  Future<File?> getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sélection de l\'image : $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        photo = image;
        imageSrc = image.path;
      });
      await saveImagePermanently(image.path);
    }
  }

  Future<File> saveImagePermanently1(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final name = path.basename(imagePath);
      final image = File('${directory.path}/$name');
      return File(imagePath).copy(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sauvegarde de l\'image : $e');
      rethrow;
    }
  }

  Future<File?> getImage1(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sélection de l\'image : $e');
      return null;
    }
  }

  Future<void> _pickImage1(ImageSource source) async {
    final image = await getImage1(source);
    if (image != null) {
      setState(() {
        image1 = image;
        image1Src = image.path;
      });
      await saveImagePermanently(image.path);
    }
  }

  Future<void> _showImageSourceDialog1() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Photo du siège"),
          content: Wrap(
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Fermer le dialogue
                  _pickImage1(ImageSource.camera);
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
                  Navigator.pop(context);
                  _pickImage1(ImageSource.gallery);
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
        );
      },
    );
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Photo de profil"),
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
        );
      },
    );
  }

  // Méthode pour récupérer les données depuis SharedPreferences
  Future<void> retrieveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Récupérer les chaînes JSON depuis SharedPreferences
    String? typeActeurJson = prefs.getString('typeActeurList');
    String? speculationsJson = prefs.getString('speculationsList');

    // Vérifier si les données sont présentes
    if (typeActeurJson != null && speculationsJson != null) {
      // Décoder les JSON pour obtenir des listes de Map
      List<dynamic> typeActeurData = json.decode(typeActeurJson);
      List<dynamic> speculationData = json.decode(speculationsJson);

      // Convertir chaque élément en instance de TypeActeur et Speculation
      List<TypeActeur> liste1 =
          typeActeurData.map((data) => TypeActeur.fromMap(data)).toList();
      print("share Type acteur ${liste1.toString()}");

      List<Speculation> liste2 =
          speculationData.map((data) => Speculation.fromMap(data)).toList();
      print("share speculation acteur ${liste2.toString()}");
      selectedSpec = liste2;
      libelleSpeculation = selectedSpec.map((e) => e.nomSpeculation!).toList();
      typeSController.text = libelleSpeculation.map((e) => e).join(',');
      print("speculation acteur selected Spec share: ${selectedSpec}");

      selectedTypes = liste1;
      typeLibelle = selectedTypes.map((e) => e.libelle!).toList();
      typeController.text = typeLibelle.map((e) => e).join(',');
      print("type acteur selected Types share : ${selectedTypes}");
      print("type libelle share: ${typeLibelle}");
      // Utilisez typeActeurList et speculationsList comme nécessaire
    } else {
      print("Aucune donnée trouvée pour TypeActeur et Speculation");
    }
  }

  @override
  void initState() {
    super.initState();
    // acteur = widget.acteurs!;
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _niveau3List = http.get(Uri.parse(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${acteur!.niveau3PaysActeur}'));

    id = acteur!.idActeur!;
    debugPrint("init  id $id ${acteur.toString()}");
    nomActeurController.text = acteur!.nomActeur!;
    whatsAppController.text = acteur!.whatsAppActeur!;
    telephoneActeurController.text = acteur!.telephoneActeur!;
    localisationController.text = acteur!.localiteActeur!;
    adresseController.text = acteur!.adresseActeur!;

    if (acteur!.emailActeur != null) {
      emailController.text = acteur!.emailActeur!;
      print("email : ${acteur!.emailActeur}");
    }
    print("logo acteur : ${acteur!.logoActeur}");
    print("siege  photoSiegeActeur: ${acteur!.photoSiegeActeur}");
    _searchController = TextEditingController();
    _typeListe =
        http.get(Uri.parse('$apiOnlineUrl/Speculation/getAllSpeculation'));
    _typeList = http.get(Uri.parse('$apiOnlineUrl/typeActeur/read'));

    print("niveau 3 : ${acteur!.niveau3PaysActeur!}");

    retrieveData();
  }

  @override
  void dispose() {
    _controllerTypeActeur.dispose();
    _controllerSpeculation.dispose();
    _searchController.dispose();
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
                                      localisationController.text == type;

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
                                            localisationController.text = type;
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

  void _showMultiSelectDialogS() async {
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
                future: _typeListe,
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

                                  return ListTile(
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
                    typeSController.text = typeLibelle.join(', ');
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
                    hintText: 'Rechercher un type...',
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
                      List<TypeActeur> typeListe = responseData
                          .map((e) => TypeActeur.fromMap(e))
                          .where((con) => con.statutTypeActeur == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucun type trouvé")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<TypeActeur> filteredSearch = typeListe
                          .where((typeActeur) =>
                              typeActeur.libelle!
                                  .toLowerCase()
                                  .contains(searchText) &&
                              typeActeur.libelle!.toLowerCase() != 'admin')
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucun type trouvé',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final typeActeur = filteredSearch[index];
                                  final isSelected =
                                      selectedTypes.contains(typeActeur);

                                  return ListTile(
                                    title: Text(
                                      typeActeur.libelle!,
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
                                            ? selectedTypes.remove(typeActeur)
                                            : selectedTypes.add(typeActeur);
                                      });
                                    },
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
                        selectedTypes.map((e) => e.libelle!).toList();
                    typeController.text = typeLibelle.join(', ');
                    _searchController.clear();
                    print('Options sélectionnées : $selectedTypes');
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
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
          backgroundColor: d_colorGreen,
          centerTitle: true,
          toolbarHeight: 75,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title: const Text(
            "Modifier le Profil",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    photo != null
                        ? Image.file(
                            photo!,
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          )
                        : FadeInImage(
                            image: NetworkImage(
                              "$apiOnlineUrl/acteur/${acteur!.idActeur}/image",
                            ),
                            placeholder:
                                AssetImage('assets/images/default_image.png'),
                            placeholderFit: BoxFit.cover,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) {
                              // Widget affiché en cas d'erreur
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                height: 90,
                                width: 90,
                                child: IconButton(
                                  onPressed: () {
                                    _showImageSourceDialog();
                                  },
                                  icon: Icon(
                                    Icons.camera_enhance_outlined,
                                    size: 40, // Taille de l'icône augmentée
                                    color: Colors.blueGrey[
                                        700], // Couleur de l'icône ajustée
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: Offset(0, 3), // Effet d'ombre
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    SizedBox(width: 50),
                    image1 != null
                        ? Image.file(
                            image1!,
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          )
                        : FadeInImage(
                            image: NetworkImage(
                              "$apiOnlineUrl/acteur/${acteur!.idActeur}/siege",
                            ),
                            placeholder:
                                AssetImage('assets/images/default_image.png'),
                            placeholderFit: BoxFit.cover,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) {
                              // Widget affiché en cas d'erreur
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                height: 90,
                                width: 90,
                                child: IconButton(
                                  onPressed: () {
                                    _showImageSourceDialog1();
                                  },
                                  icon: Icon(
                                    Icons.camera_enhance_outlined,
                                    size: 40, // Taille de l'icône augmentée
                                    color: Colors.blueGrey[
                                        700], // Couleur de l'icône ajustée
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: Offset(0, 3), // Effet d'ombre
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _showImageSourceDialog();
                    },
                    child: Text(
                      "Photo de profil",
                      style: TextStyle(
                        fontSize: 16,
                        color: d_colorGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      // backgroundColor: d_colorGreen, // Couleur au survol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side:
                            BorderSide(color: d_colorGreen), // Bordure colorée
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      _showImageSourceDialog1();
                    },
                    child: Text(
                      "Photo du siège",
                      style: TextStyle(
                        fontSize: 16,
                        color: d_colorGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      // backgroundColor: d_colorGreen, // Couleur au survol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side:
                            BorderSide(color: d_colorGreen), // Bordure colorée
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: nomActeurController,
                  decoration: InputDecoration(
                    labelText: "Nom complet",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: _showMultiSelectDialogt,
                  child: TextFormField(
                    onTap: _showMultiSelectDialogt,
                    controller: typeController,
                    decoration: InputDecoration(
                      labelText: "Type acteur",
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: Colors.blueGrey[400]),
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
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: _showMultiSelectDialogS,
                  child: TextFormField(
                    onTap: _showMultiSelectDialogS,
                    controller: typeSController,
                    decoration: InputDecoration(
                      labelText: "Spéculation",
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: Colors.blueGrey[400]),
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
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: whatsAppController,
                  decoration: InputDecoration(
                    labelText: "Numéro whatsApp",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: telephoneActeurController,
                  decoration: InputDecoration(
                    labelText: "Numéro",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: _showLocalite,
                  child: TextFormField(
                    onTap: _showLocalite,
                    controller: localisationController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: Colors.blueGrey[400]),
                      labelText: "Localité",
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
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: adresseController,
                  decoration: InputDecoration(
                    labelText: "Adresse",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final idActeur = acteur?.idActeur;
                    final nomActeur = nomActeurController.text;
                    final emailActeur = emailController.text;
                    final adresse = adresseController.text;
                    final localisation = localisationController.text;
                    final typeActeur = selectedTypes;
                    final speculation = selectedSpec;
                    final whatsApp = whatsAppController.text;
                    final tel = telephoneActeurController.text;
                    final niveau3PaysActeur = acteur?.niveau3PaysActeur;

                    print("Spec envoie  : ${selectedSpec}");
                    print("Type envoie  : ${selectedTypes}");
                    debugPrint(
                      "acteur edit  nom: $nomActeur, email: $emailActeur, adresse: $adresse, loc: $localisation, type: ${typeActeur.toList()}, speculation: ${speculation.toList()}, wa: $whatsApp, tel: $tel, emailActeur: $emailActeur, pays: $niveau3PaysActeur",
                    );
                    Acteur a = Acteur();
                    a = Provider.of<ActeurProvider>(context, listen: false)
                        .acteur!;
                    typeActeurData = a.typeActeur!;
                    print("acteur pro  : ${typeActeurData}");

                    if (idActeur == null || idActeur.isEmpty) {
                      debugPrint("ID est null ou vide");

                      return;
                    }

                    try {
                      setState(() {
                        _isLoading = true;
                      });

                      final response = await ActeurService()
                          .updateActeur(
                        context: context,
                        idActeur: idActeur,
                        nomActeur: nomActeur,
                        adresseActeur: adresse,
                        telephoneActeur: tel,
                        whatsAppActeur: whatsApp,
                        localiteActeur: localisation,
                        emailActeur: emailActeur,
                        niveau3PaysActeur: niveau3PaysActeur,
                        typeActeur: selectedTypes,
                        speculation: selectedSpec,
                        photoSiegeActeur: image1,
                        logoActeur: photo,
                      )
                          .then((_) {
                        debugPrint("profil modifier avec succèss");

                        setState(() {
                          _isLoading = false;
                        });
                        // Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profil modifié avec succès"),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      });
                    } catch (e) {
                      debugPrint(
                          "Erreur lors de la mise à jour de l'acteur: ${e.toString()}");

                      setState(() {
                        _isLoading = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Une erreur s'est produite"),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: Text(
                    "Modifier",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: d_colorGreen, // Code couleur orange
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: Size(250, 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
