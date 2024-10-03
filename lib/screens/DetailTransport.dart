import 'dart:convert';
import 'dart:io';

import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/Admin/CodePays.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Device.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/models/TypeVoiture.dart';
import 'package:koumi/models/Vehicule.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/DeviceService.dart';
import 'package:koumi/service/VehiculeService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTransport extends StatefulWidget {
  final Vehicule vehicule;
  const DetailTransport({super.key, required this.vehicule});

  @override
  State<DetailTransport> createState() => _DetailTransportState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _DetailTransportState extends State<DetailTransport> {
  late Vehicule vehicules;
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  late String type;
  String? imageSrc;
  File? photo;
  late TypeVoiture typeVoiture;
  late Map<String, int> prixParDestinations;
  String? monnaieValue;
  late Future _monnaieList;
  late Monnaie monnaie = Monnaie();
  int nbVue = 0;
  // List<ParametreGeneraux> paraList = [];
  // late ParametreGeneraux para = ParametreGeneraux();
  late ValueNotifier<bool> isDialOpenNotifier;
  TextEditingController _prixController = TextEditingController();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _nbKiloController = TextEditingController();
  TextEditingController _capaciteController = TextEditingController();
  TextEditingController _etatController = TextEditingController();
  TextEditingController _localiteController = TextEditingController();
  TextEditingController _monnaieController = TextEditingController();
  List<TextEditingController> _destinationControllers = [];
  List<TextEditingController> _prixControllers = [];
  List<TextEditingController> destinationControllers = [];
  List<TextEditingController> prixControllers = [];
  List<Widget> destinationPrixFields = [];
  bool _isEditing = false;
  bool _isLoading = false;
  bool active = false;
  String? typeValue;
  late Future _niveau3List;
  String? n3Value;
  String niveau3 = '';
  List<String> selectedDestinations = [];
  Map<String, int> newPrixParDestinations = {};
  List<String?> selectedDestinationsList = [];
  late Future<Map<String, Map<String, String>>> rates;
  late TextEditingController _searchController;
  bool isExist = false;
  String? email = "";
  bool isLoadingLibelle = true;
  String? libelleNiveau3Pays;

  Future<List<Device>> getDeviceListe(String id) async {
    try {
      return await DeviceService().fetchDeviceByIdMonnaie(id);
    } catch (e) {
      print('Failed to fetch devices: $e');
      return [];
    }
  }

  Future<Map<String, Map<String, String>>> fetchConvert(
      Vehicule vehicule) async {
    Monnaie monnaie = vehicule.monnaie!;
    Map<String, Map<String, String>> result = {};

    try {
      List<Device> devices = await getDeviceListe(monnaie.idMonnaie!);

      vehicule.prixParDestination.forEach((destination, prix) {
        Map<String, String> convertedPrices = {};
        for (var device in devices) {
          double convertedAmount = prix * device.taux!;
          String amountSubString = convertedAmount.toStringAsFixed(2);
          print(amountSubString);

          switch (device.nomDevice!.toLowerCase()) {
            case 'dollar':
            case 'euro':
            case 'yuan':
              convertedPrices[device.sigle!] = amountSubString;
              break;
            default:
              print('Aucune devise trouvée pour ${device.nomDevice}');
          }
        }
        result[destination] = convertedPrices;
      });
    } catch (e) {
      print('Error: $e');
    }

    print("Conversion : ${result.toString()}");
    return result;
  }

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur.typeActeur!;
      type = typeActeurData.map((data) => data.libelle).join(', ');
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

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

  void ajouterPrixDestination() {
    for (int i = 0; i < selectedDestinationsList.length; i++) {
      String destination = selectedDestinations[i];
      int prix = int.tryParse(prixControllers[i].text) ?? 0;

      // Ajouter la destination et le prix à la nouvelle map
      if (destination.isNotEmpty && prix > 0) {
        newPrixParDestinations.addAll({destination: prix});
      }
    }
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
    verify();

    _niveau3List = http.get(Uri.parse('$apiOnlineUrl/nivveau3Pays/read'));

    vehicules = widget.vehicule;
    _loadNbVue();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await updateViews(vehicules);
      setState(() {
        vehicules.nbreView = nbVue;
      });
    });
    rates = fetchConvert(vehicules);
    print("rates ${rates.toString()}");
    typeVoiture = vehicules.typeVoiture;
    prixParDestinations = vehicules.prixParDestination;
    _nomController.text = vehicules.nomVehicule;
    _capaciteController.text = vehicules.capaciteVehicule;
    _etatController.text = vehicules.etatVehicule.toString();
    _localiteController.text = vehicules.localisation;
    _descriptionController.text = vehicules.description!;
    _monnaieController.text = vehicules.monnaie!.libelle!;
    _nbKiloController.text = vehicules.nbKilometrage.toString();
    _searchController = TextEditingController();
    vehicules.prixParDestination.forEach((destination, prix) {
      TextEditingController destinationController =
          TextEditingController(text: destination);
      TextEditingController prixController =
          TextEditingController(text: prix.toString());

      _destinationControllers.add(destinationController);
      _prixControllers.add(prixController);
    });
    monnaie = vehicules.monnaie!;
    monnaieValue = vehicules.monnaie!.idMonnaie;
    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
    isDialOpenNotifier = ValueNotifier<bool>(false);
    fetchLibelleNiveau3Pays();
    super.initState();
  }

  Future<void> _loadNbVue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nbVue = prefs.getInt('nbVue_${vehicules.idVehicule}') ??
          vehicules.nbreView ??
          0;
    });
  }

  updateViews(Vehicule i) async {
    if (acteur.idActeur != i.acteur.idActeur) {
      final response = await http.put(
        Uri.parse('$apiOnlineUrl/vehicule/updateView/${i.idVehicule}'),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          nbVue++;
          i.nbreView = nbVue;
          print('Nombre de vues mis à jour : ${i.nbreView}');
          // Sauvegarder la nouvelle valeur de nbVue
          _saveNbVue();
        });
      } else {
        print('Échec de la mise à jour du nombre de vues');
      }
    }
  }

  Future<void> _saveNbVue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nbVue_${vehicules.idVehicule}', nbVue);
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

  Future<void> updateMethode() async {
    setState(() {
      // Afficher l'indicateur de chargement pendant l'opération
      _isLoading = true;
    });

    try {
      // Récupération des nouvelles valeurs des champs
      final String nom = _nomController.text;
      final String capacite = _capaciteController.text;
      final String etat = _etatController.text;
      final String localite = _localiteController.text;
      final String description = _descriptionController.text;
      final String nbKil = _nbKiloController.text;
      final int? nb = int.tryParse(nbKil);

      setState(() {
        // Parcourir les destinations et les prix modifiés simultanément
        for (int i = 0; i < _destinationControllers.length; i++) {
          String destination = _destinationControllers[i].text;
          int prix = int.tryParse(_prixControllers[i].text) ?? 0;

          // Ajouter la destination et le prix à la nouvelle map
          if (destination.isNotEmpty && prix > 0) {
            newPrixParDestinations[destination] = prix;
          }
        }

        // Parcourir pour ajouter les nouvelles destinations
        for (int i = 0; i < selectedDestinationsList.length; i++) {
          String destination = selectedDestinations[i];
          int prix = int.tryParse(prixControllers[i].text) ?? 0;

          // Ajouter la destination et le prix à la nouvelle map
          if (destination.isNotEmpty && prix > 0) {
            // Si la destination n'existe pas déjà dans la nouvelle map, l'ajouter
            if (!newPrixParDestinations.containsKey(destination)) {
              newPrixParDestinations[destination] = prix;
            } else {
              // Si la destination existe déjà, mettre à jour le prix
              newPrixParDestinations[destination] = prix;
              // Réinitialiser les contrôleurs de destination et de prix
            }
          }
        }
        // Réinitialiser les listes de destinations sélectionnées
        selectedDestinationsList.clear();
        selectedDestinations.clear();
      });

      if (photo != null) {
        await VehiculeService()
            .updateVehicule(
                idVehicule: vehicules.idVehicule,
                nomVehicule: nom,
                capaciteVehicule: capacite,
                prixParDestination: newPrixParDestinations,
                etatVehicule: etat,
                photoVehicule: photo,
                localisation: localite,
                description: description,
                nbKilometrage: nb.toString(),
                typeVoiture: typeVoiture,
                acteur: acteur,
                monnaie: monnaie)
            .then((value) => {
                  setState(() {
                    vehicules = Vehicule(
                      idVehicule: vehicules.idVehicule,
                      nomVehicule: nom,
                      photoVehicule: vehicules.photoVehicule,
                      capaciteVehicule: capacite,
                      prixParDestination: newPrixParDestinations,
                      etatVehicule: etat,
                      codeVehicule: vehicules.codeVehicule,
                      description: description,
                      nbKilometrage: nb,
                      localisation: localite,
                      typeVoiture: typeVoiture,
                      acteur: acteur,
                      statutVehicule: vehicules.statutVehicule,
                      monnaie: monnaie,
                    );

                    _isLoading = false;
                  }),
                  Provider.of<VehiculeService>(context, listen: false)
                      .applyChange(),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Text(
                            "vehicule modifier avec succèss",
                            style: TextStyle(overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      duration: Duration(seconds: 5),
                    ),
                  )
                })
            .catchError((onError) => {print(onError.toString())});
      } else {
        await VehiculeService()
            .updateVehicule(
                idVehicule: vehicules.idVehicule,
                nomVehicule: nom,
                capaciteVehicule: capacite,
                prixParDestination: newPrixParDestinations,
                etatVehicule: etat,
                localisation: localite,
                description: description,
                nbKilometrage: nb.toString(),
                typeVoiture: typeVoiture,
                acteur: acteur,
                monnaie: monnaie)
            .then((value) => {
                  setState(() {
                    vehicules = Vehicule(
                      idVehicule: vehicules.idVehicule,
                      nomVehicule: nom,
                      capaciteVehicule: capacite,
                      prixParDestination: newPrixParDestinations,
                      etatVehicule: etat,
                      photoVehicule: vehicules.photoVehicule,
                      codeVehicule: vehicules.codeVehicule,
                      description: description,
                      nbKilometrage: nb,
                      localisation: localite,
                      typeVoiture: typeVoiture,
                      acteur: acteur,
                      statutVehicule: vehicules.statutVehicule,
                      monnaie: monnaie,
                    );
                    _isLoading = false;
                  }),
                  Provider.of<VehiculeService>(context, listen: false)
                      .applyChange(),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Text(
                            "vehicule modifier avec succèss",
                            style: TextStyle(overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      duration: Duration(seconds: 5),
                    ),
                  )
                })
            .catchError((onError) => {print(onError.toString())});
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleButtonPress() async {
    // Afficher l'indicateur de chargement
    setState(() {
      _isLoading = true;
    });
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
              leading: _isEditing
                  ? IconButton(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        // size: 60,
                      ),
                    )
                  : acteur.idActeur == vehicules.acteur.idActeur
                      ? IconButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                        )
                      : IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                        ),
              title: _isEditing
                  ? Text(
                      'Modification',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )
                  : Text(
                      'Transport',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
              actions: acteur.idActeur == vehicules.acteur.idActeur
                  ? [
                      _isEditing
                          ? IconButton(
                              onPressed: () async {
                                setState(() {
                                  _isEditing = false;
                                  vehicules = widget.vehicule;
                                });
                                updateMethode();
                              },
                              icon: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            )
                          : IconButton(
                              onPressed: () async {
                                setState(() {
                                  _isEditing = true;
                                  vehicules = widget.vehicule;
                                });
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                    ]
                  : [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CodePays()
                            .getFlagsApp(vehicules.acteur.niveau3PaysActeur!),
                      )
                    ]),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                photo != null
                    ? Center(
                        child: Image.file(
                        photo!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ))
                    : Center(
                        child: vehicules.photoVehicule != null &&
                                !vehicules.photoVehicule!.isEmpty
                            ? CachedNetworkImage(
                                imageUrl:
                                    "https://koumi.ml/api-koumi/vehicule/${vehicules.idVehicule}/image",
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/default_image.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                "assets/images/default_image.png",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                      ),
                SizedBox(height: 20),
                _isEditing ? _buildEditing() : _buildData(),
              ],
            ),
          ),
          floatingActionButton: acteur.idActeur != vehicules.acteur.idActeur
              ? SpeedDial(
                  // animatedIcon: AnimatedIcons.close_menu,
                  backgroundColor: d_colorGreen,
                  foregroundColor: Colors.white,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.4,
                  spacing: 12,
                  icon: Icons.phone,

                  children: [
                    SpeedDialChild(
                      child: FaIcon(FontAwesomeIcons.whatsapp),
                      label: 'Par whatsApp',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () {
                        final String whatsappNumber =
                            vehicules.acteur.whatsAppActeur!;
                        _makePhoneWa(whatsappNumber);
                      },
                    ),
                    SpeedDialChild(
                      child: Icon(Icons.phone),
                      label: 'Par téléphone ',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () {
                        final String numberPhone =
                            vehicules.acteur.telephoneActeur!;
                        _makePhoneCall(numberPhone);
                      },
                    )
                  ],
                  // État du Speed Dial (ouvert ou fermé)
                  openCloseDial: isDialOpenNotifier,
                  // Fonction appelée lorsque le bouton principal est pressé
                  onPress: () {
                    isDialOpenNotifier.value = !isDialOpenNotifier
                        .value; // Inverser la valeur du ValueNotifier
                  },
                )
              : Container()),
    );
  }

  Future<void> _makePhoneWa(String whatsappNumber) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: whatsappNumber,
    );
    print(Uri);
    await launchUrl(launchUri);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Widget _buildEditing() {
    return Column(
      children: [
        _buildEditableDetailItem('Nom du véhicule : ', _nomController),
        _buildEditableDetailItem('Capacité : ', _capaciteController),
        _buildEditableDetailItem('Etat du véhicule : ', _etatController),
        _buildEditableDetailItem('Description : ', _descriptionController),
        _buildEditableDetailItem('Nombre kilometrage : ', _nbKiloController),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Localité",
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 18),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: GestureDetector(
                  onTap: _showLocalite,
                  child: TextFormField(
                    onTap: _showLocalite,
                    controller: _localiteController,
                    maxLines: null,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: Colors.blueGrey[400]),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black54,
                    ),
                    enabled: _isEditing,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Monnaie",
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 18),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: GestureDetector(
                  onTap: _showMonnaie,
                  child: TextFormField(
                    onTap: _showMonnaie,
                    controller: _monnaieController,
                    maxLines: null,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: Colors.blueGrey[400]),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black54,
                    ),
                    enabled: _isEditing,
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildDestinationPriceFields(),
        SizedBox(
          height: 15,
        ),
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
                    "Ajouter d'autres prix",
                    style: TextStyle(color: d_colorGreen, fontSize: 17),
                  ),
                  IconButton(
                    onPressed: () {
                      // Appeler la méthode pour ajouter une destination et un prix
                      addDestinationAndPrix();
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                children: destinationPrixFields,
              ),
              Column(
                children: List.generate(
                  destinationControllers.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _showLocalites(index), // Pass the index here
                            child: TextFormField(
                              onTap: () =>
                                  _showLocalites(index), // Pass the index here
                              controller: destinationControllers[index],
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400],
                                ),
                                hintText: "Destination",
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
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
      ],
    );
  }

  Widget _buildData() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: d_colorGreen,
            ),
            child: Center(
              child: Text(
                vehicules.nomVehicule.toUpperCase(),
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        _buildItem('Nom du véhicule: ', vehicules.nomVehicule),
        _buildItem('Type de véhicule : ', vehicules.typeVoiture.nom!),
        vehicules.typeVoiture.nombreSieges != 0
            ? _buildItem('Nombre de siège : ',
                vehicules.typeVoiture.nombreSieges.toString())
            : Container(),
        _buildItem('Capacité : ', vehicules.capaciteVehicule),
        _buildItem('Localisation : ', vehicules.localisation),
        _buildItem('Nombre de kilometrage : ',
            "${vehicules.nbKilometrage.toString()} Km"),
        _buildItem('Statut: : ',
            '${vehicules.statutVehicule ? 'Disponible' : 'Non disponible'}'),
        SizedBox(height: 10),
        _buildPanel(),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: d_colorGreen,
            ),
            child: Center(
              child: Text(
                "Description",
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: ReadMoreText(
            colorClickableText: d_colorGreen,
            trimLines: 2,
            trimMode: TrimMode.Line,
            trimCollapsedText: "Lire plus",
            trimExpandedText: "Lire moins",
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            vehicules.description! == null ? "" : vehicules.description!,
          ),
        ),
        // _buildDescription('Description : ', vehicules.description!),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: d_colorGreen,
                ),
                child: Center(
                  child: Text(
                    "Autres informations",
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            _getPays(vehicules),
            _buildItem('Nombre de vue  ', vehicules.nbreView.toString()),
            _buildItem('Propriètaire : ', vehicules.acteur.nomActeur!),
            _buildItem('Téléphone : ', vehicules.acteur.whatsAppActeur!),
            _buildItem('Adresse : ', vehicules.acteur.adresseActeur!),
            _buildItem('Localité : ', vehicules.acteur.niveau3PaysActeur!),
          ],
        )

        // _buildItem('Description : ', vehicules.description!),
      ],
    );
  }

  Widget _buildDestinationPriceFields() {
    List<Widget> fields = [];

    for (int i = 0; i < _destinationControllers.length; i++) {
      fields.add(
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _destinationControllers[i],
                decoration: InputDecoration(
                  hintText: 'Destination',
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _prixControllers[i],
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Prix',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: fields,
    );
  }

  Widget _buildEditableDetailItem(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 18),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black54,
                  ),
                  enabled: _isEditing,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDescription(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 18),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: ReadMoreText(
                  colorClickableText: Colors.orange,
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: "Lire plus",
                  trimExpandedText: "Lire moins",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              // softWrap: true,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getPays(Vehicule v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "Pays",
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16),
            ),
          ),
          CodePays().getFlags(v.acteur.niveau3PaysActeur!)
        ],
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          active = !active;
        });
      },
      children: <ExpansionPanel>[
        ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                "Voir les prix par destination",
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 17,
                ),
              ),
            );
          },
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: List.generate(vehicules.prixParDestination.length,
                      (index) {
                    String destination =
                        vehicules.prixParDestination.keys.elementAt(index);
                    int prix =
                        vehicules.prixParDestination.values.elementAt(index);
                    return Column(
                      children: [
                        _buildItem(destination,
                            "${prix.toString()} ${vehicules.monnaie!.libelle!}"),
                        FutureBuilder<Map<String, Map<String, String>>>(
                          future: rates,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              Map<String, String>? convertedPrices =
                                  snapshot.data?[destination];
                              if (convertedPrices != null) {
                                return Column(
                                  children:
                                      convertedPrices.entries.map((entry) {
                                    return _buildItem("Prix en ${entry.key}",
                                        "${entry.value}");
                                  }).toList(),
                                );
                              } else {
                                return Text('');
                              }
                            }
                          },
                        )
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          isExpanded: active,
          canTapOnHeader: true,
        )
      ],
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
                                      _localiteController.text == type;

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
                                            _localiteController.text = type;
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

  void _showLocalites(int index) async {
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
                                                color: d_colorGreen,
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
                    style: TextStyle(color: d_colorGreen, fontSize: 16),
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
                    style: TextStyle(color: d_colorGreen, fontSize: 16),
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
