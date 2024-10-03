import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/Admin/CodePays.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Device.dart';
import 'package:koumi/models/Forme.dart';
import 'package:koumi/models/Intrant.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CartProvider.dart';
import 'package:koumi/service/DeviceService.dart';
import 'package:koumi/service/IntrantService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:koumi/widgets/SnackBar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailIntrant extends StatefulWidget {
  final Intrant intrant;
  const DetailIntrant({super.key, required this.intrant});

  @override
  State<DetailIntrant> createState() => _DetailIntrantState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _DetailIntrantState extends State<DetailIntrant> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _quantiteController = TextEditingController();
  TextEditingController _prixController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _uniteController = TextEditingController();
  TextEditingController _monnaieController = TextEditingController();
  TextEditingController _formController = TextEditingController();

  String? monnaieValue;
  late Future _monnaieList;
  late Monnaie monnaie = Monnaie();
  bool _isEditing = false;
  bool _isLoading = false;
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  late String type;
  String? imageSrc;
  File? photo;
  late ValueNotifier<bool> isDialOpenNotifier;
  late Intrant intrants;
  bool isExist = false;
  String? email = "";
  bool isLoadingLibelle = true;
  late Future<Map<String, String>> rates;
  late Future _formeList;
  late Forme forme;
  late TextEditingController _searchController;

  Future<List<Device>> getDeviceListe(String id) async {
    return await DeviceService().fetchDeviceByIdMonnaie(id);
  }

  Future<Map<String, String>> fetchConvert(Intrant intrant) async {
    Monnaie monnaie = intrant.monnaie!;
    int? amount = intrant.prixIntrant;
    Map<String, String> result = {};

    try {
      List<Device> devices = await getDeviceListe(monnaie.idMonnaie!);

      for (var device in devices) {
        double convertedAmount = amount! * device.taux!;
        String amountSubString = convertedAmount.toStringAsFixed(2);
        print(amountSubString);
        switch (device.nomDevice!.toLowerCase()) {
          case 'dollar':
            result[device.sigle!] = amountSubString;
            break;
          case 'euro':
            result[device.sigle!] = amountSubString;
            break;
          case 'yuan':
            result[device.sigle!] = amountSubString;
            break;
          default:
            print('Aucune devise trouvée pour ${device.nomDevice}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    print("conversion : ${result.toString()}");
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

  int nbVue = 0;

  @override
  void initState() {
    super.initState();
    verify();
    _formeList = http.get(Uri.parse('$apiOnlineUrl/formeproduit/getAllForme/'));
    _searchController = TextEditingController();
    intrants = widget.intrant;
    _loadNbVue();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await updateViews(intrants);
      setState(() {
        intrants.nbreView = nbVue;
      });
    });
    rates = fetchConvert(intrants);
    print("rates ${rates.toString()}");
    _nomController.text = intrants.nomIntrant!;
    _descriptionController.text = intrants.descriptionIntrant!;
    _quantiteController.text = intrants.quantiteIntrant.toString();
    _prixController.text = intrants.prixIntrant.toString();
    _dateController.text = intrants.dateExpiration!;
    _uniteController.text = intrants.unite!;
    _monnaieController.text = intrants.monnaie!.libelle!;
    _formController.text = intrants.forme!.libelleForme!;
    forme = intrants.forme!;
    monnaie = intrants.monnaie!;
    monnaieValue = intrants.monnaie!.idMonnaie;
    isDialOpenNotifier = ValueNotifier<bool>(false);
    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNbVue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nbVue =
          prefs.getInt('nbVue_${intrants.idIntrant}') ?? intrants.nbreView ?? 0;
    });
  }

  updateViews(Intrant i) async {
    if (acteur.idActeur != i.acteur!.idActeur) {
      final response = await http.put(
        Uri.parse('$apiOnlineUrl/intrant/updateView/${i.idIntrant}'),
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
    await prefs.setInt('nbVue_${intrants.idIntrant}', nbVue);
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
      final String nom = _nomController.text;
      final String description = _descriptionController.text;
      final double quantite = double.tryParse(_quantiteController.text) ?? 0.0;
      final int prix = int.tryParse(_prixController.text) ?? 0;
      final String date = _dateController.text;
      final String unite = _uniteController.text;

      if (quantite > intrants.quantiteIntrant!) {
        setState(() {
          // Afficher l'indicateur de chargement pendant l'opération
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Non autorisé"),
            content: Text(
                "Toute augmentation de quantité neccessite une nouvelle ajout de produits",
                style: TextStyle(
                  color: Colors.black87,
                )),
            actions: [
              TextButton(
                child: Text("Fermer"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );

        return;
      }

      if (photo != null) {
        await IntrantService()
            .updateIntrant(
                idIntrant: intrants.idIntrant!,
                nomIntrant: nom,
                quantiteIntrant: quantite,
                descriptionIntrant: description,
                prixIntrant: prix,
                dateExpiration: date,
                photoIntrant: photo,
                unite: unite,
                acteur: acteur,
                forme: forme,
                monnaie: monnaie)
            .then((value) => {
                  Provider.of<IntrantService>(context, listen: false)
                      .applyChange(),
                  setState(() {
                    intrants = Intrant(
                        idIntrant: intrants.idIntrant,
                        nomIntrant: nom,
                        quantiteIntrant: quantite,
                        prixIntrant: prix,
                        descriptionIntrant: description,
                        statutIntrant: intrants.statutIntrant,
                        dateAjout: intrants.dateAjout,
                        dateExpiration: date,
                        categorieProduit: intrants.categorieProduit,
                        forme: forme,
                        unite: unite,
                        acteur: acteur,
                        monnaie: monnaie);
                    _isLoading = false;
                  }),
                })
            .catchError((onError) => {
                  print(onError.toString()),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Text(
                            "Une erreur est survenu lors de la modification",
                            style: TextStyle(overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      duration: Duration(seconds: 5),
                    ),
                  )
                });
      } else {
        await IntrantService()
            .updateIntrant(
                idIntrant: intrants.idIntrant!,
                nomIntrant: nom,
                quantiteIntrant: quantite,
                descriptionIntrant: description,
                prixIntrant: prix,
                dateExpiration: date,
                unite: unite,
                acteur: acteur,
                forme: forme,
                monnaie: monnaie)
            .then((value) => {
                  Provider.of<IntrantService>(context, listen: false)
                      .applyChange(),
                  setState(() {
                    intrants = Intrant(
                        idIntrant: intrants.idIntrant,
                        nomIntrant: nom,
                        quantiteIntrant: quantite,
                        prixIntrant: prix,
                        descriptionIntrant: description,
                        statutIntrant: intrants.statutIntrant,
                        dateAjout: intrants.dateAjout,
                        dateExpiration: date,
                        categorieProduit: intrants.categorieProduit,
                        forme: forme,
                        unite: unite,
                        photoIntrant: intrants.photoIntrant,
                        acteur: acteur,
                        monnaie: monnaie);
                    _isLoading = false;
                  }),
                })
            .catchError((onError) => {
                  print(onError.toString()),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Text(
                            "Erreur lors de la modification",
                            style: TextStyle(overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      duration: Duration(seconds: 5),
                    ),
                  )
                });
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Text(
                "Erreur lors de la modification",
                style: TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
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
                leading: _isEditing
                    ? IconButton(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          // size: 60,
                        ),
                      )
                    :  acteur.idActeur != intrants.acteur!.idActeur ?
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        )): IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        )),
                title: _isEditing
                    ? Text(
                        'Modification',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    : Text(
                        'Détail intrant',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                actions: acteur.idActeur == intrants.acteur!.idActeur
                    ? [
                        _isEditing
                            ? IconButton(
                                onPressed: () async {
                                  setState(() {
                                    _isEditing = false;
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
                              .getFlagsApp(intrants.acteur!.niveau3PaysActeur!),
                        )
                      ]),
            body: SingleChildScrollView(
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
                          child: intrants.photoIntrant != null &&
                                  !intrants.photoIntrant!.isEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      "https://koumi.ml/api-koumi/intrant/${intrants.idIntrant}/image",
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
                  SizedBox(height: 30),
                  !_isEditing ? viewData() : _buildEditing(),
                  
                  const SizedBox(height: 10),
                ],
              ),
            ),
            floatingActionButton: acteur.idActeur != intrants.acteur!.idActeur
                ? SpeedDial(
                    // animatedIcon: AnimatedIcons.close_menu,
                    backgroundColor: d_colorGreen,
                    foregroundColor: Colors.white,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.7,
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
                              intrants.acteur!.whatsAppActeur!;
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
                              intrants.acteur!.telephoneActeur!;
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
                : Container()));
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

  Widget viewData() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: d_colorOr,
            ),
            child: Center(
              child: Text(
                intrants.nomIntrant!.toUpperCase(),
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        _buildData(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: d_colorOr,
            ),
            child: Center(
              child: Text(
                'Description',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        // _buildDescription(intrants.descriptionIntrant!),
        Padding(
          padding: EdgeInsets.all(8),
          child: ReadMoreText(
            colorClickableText: d_colorOr,
            trimLines: 2,
            trimMode: TrimMode.Line,
            trimCollapsedText: "Lire plus",
            trimExpandedText: "Lire moins",
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            intrants.descriptionIntrant == null
                ? ""
                : intrants.descriptionIntrant!,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: d_colorOr,
            ),
            child: Center(
              child: Text(
                'Autres informations',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        // _buildItem('Spéculation ', intrants.speculation!.nomSpeculation!),
        _getPays(intrants),
        _buildItem('Nombre de vue  ', intrants.nbreView.toString()),
        _buildItem('Catégorie  ', intrants.categorieProduit!.libelleCategorie!),
        _buildItem(
            'Filière  ', intrants.categorieProduit!.filiere!.libelleFiliere!),
        _buildItem('Date d\'ajout ', '${intrants.dateAjout}' ?? 'N/A'),
        acteur.idActeur != intrants.acteur!.idActeur
            ? _buildFournissuer()
            : Container(),
      ],
    );
  }

  _buildEditing() {
    return Column(children: [
      _buildEditableDetailItem('Nom intrant ', _nomController),
      _buildEditableDetailItem('Description', _descriptionController),
      _buildEditableDetailItem('Date péremption ', _dateController),
      _buildEditableDetailItem('Quantité ', _quantiteController),
      _buildEditableDetailItem('Unité ', _uniteController),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "Forme",
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: GestureDetector(
                onTap: _showForme,
                child: TextFormField(
                  onTap: _showForme,
                  controller: _formController,
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
      _buildEditableDetailItem('Prix intrant ', _prixController),
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
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
    ]);
  }

  _buildData() {
    return Column(
      children: [
        _buildItem('Nom intrant ', intrants.nomIntrant!),
        _buildItem('Quantité ', intrants.quantiteIntrant.toString()),
        _buildItem('Date péremption ', intrants.dateExpiration!),
        monnaie != null
            ? _buildItem('Prix ',
                '${intrants.prixIntrant.toString()} ${intrants.monnaie!.libelle}')
            : _buildItem('Prix ', '${intrants.prixIntrant.toString()} '),
        FutureBuilder<Map<String, String>>(
          future: rates,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              return Column(
                children: snapshot.data!.entries.map((entry) {
                  return _buildItem("Prix en ${entry.key}", "${entry.value}");
                }).toList(),
              );
            }
          },
        ),
        _buildItem('Unité ', '${intrants.unite}'),
        _buildItem('Forme ', '${intrants.forme!.libelleForme}'),
        _buildItem('Statut ',
            '${intrants.statutIntrant! ? 'Disponible' : 'Non disponible'}'),
      ],
    );
  }

  _buildFournissuer() {
    return Column(
      children: [
        _buildItem('Nom du fournisseur ', intrants.acteur!.nomActeur!),
        _buildItem('Contact ', intrants.acteur!.telephoneActeur!),
      ],
    );
  }

  Widget _buildDescription(String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Text(
          value,
          textAlign: TextAlign.justify,
          softWrap: true,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            // overflow: TextOverflow.ellipsis,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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

  Widget _getPays(Intrant intrant) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
          CodePays().getFlags(intrants.acteur!.niveau3PaysActeur!)
        ],
      ),
    );
  }

  Widget _buildEditableDetailItem(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
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
                  maxLines: null,
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
