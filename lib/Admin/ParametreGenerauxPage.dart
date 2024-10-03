import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/models/ParametreGeneraux.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/ParametreGenerauxProvider.dart';
import 'package:koumi/service/ParametreGenerauxService.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:koumi/models/Acteur.dart';

class ParametreGenerauxPage extends StatefulWidget {
  const ParametreGenerauxPage({Key? key}) : super(key: key);

  @override
  State<ParametreGenerauxPage> createState() => _ParametreGenerauxPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _ParametreGenerauxPageState extends State<ParametreGenerauxPage> {
  List<ParametreGeneraux> paramList = [];
  TextEditingController sigleStructureController = TextEditingController();
  TextEditingController nomStructureController = TextEditingController();
  TextEditingController sigleSystemeController = TextEditingController();
  TextEditingController nomSystemeController = TextEditingController();
  TextEditingController descriptionSystemeController = TextEditingController();
  TextEditingController sloganSystemeController = TextEditingController();
  TextEditingController adresseStructureController = TextEditingController();
  TextEditingController emailStructureController = TextEditingController();
  TextEditingController telephoneStructureController = TextEditingController();
  TextEditingController whattsAppStructureController = TextEditingController();
  TextEditingController localiteStructureController = TextEditingController();
  bool isEditing = false;
  late ParametreGeneraux param;
  String? imageSrc;
  File? photo;
  late Acteur acteur;
  late List<TypeActeur> typeActeurData = [];
  late String type;

  late ParametreGenerauxProvider parProvider;

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

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing; // Inverse l'état d'édition
    });
  }

  @override
  void initState() {
    super.initState();
    parProvider =
        Provider.of<ParametreGenerauxProvider>(context, listen: false);
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    typeActeurData = acteur.typeActeur!;
    type = typeActeurData.map((data) => data.libelle).join(', ');
    // fetchPaysDataByActor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
          backgroundColor: d_colorOr,
          centerTitle: true,
          toolbarHeight: 75,
          leading: isEditing
              ? Container()
              : IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
          title: typeActeurData
                  .map((e) => e.libelle!.toLowerCase())
                  .contains("admin")
              ? Text(
                  "Paramètre généraux",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )
              : Text(
                  "Information sur la structure",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
          actions: typeActeurData
                  .map((e) => e.libelle!.toLowerCase())
                  .contains("admin")
              ? [
                  isEditing
                      ? IconButton(
                          onPressed: () async {
                            setState(() {
                              isEditing = false;
                            });
                            try {
                              if (photo == null) {
                                await ParametreGenerauxService()
                                    .updateParametre(
                                        idParametreGeneraux:
                                            param.idParametreGeneraux!,
                                        sigleStructure: param.sigleStructure!,
                                        nomStructure: param.nomStructure!,
                                        sigleSysteme: param.sigleSysteme!,
                                        nomSysteme: param.nomSysteme!,
                                        descriptionSysteme:
                                            param.descriptionSysteme!,
                                        sloganSysteme: param.sloganSysteme!,
                                        adresseStructure:
                                            param.adresseStructure!,
                                        emailStructure: param.emailStructure!,
                                        telephoneStructure:
                                            param.telephoneStructure!,
                                        // monnaie: monnaie!,
                                        // tauxDollar: tauxDollar!,
                                        // tauxYuan: tauxYuan!,
                                        whattsAppStructure:
                                            param.whattsAppStructure!,
                                        // libelleNiveau1Pays:
                                        //     libelleNiveau1Pays!,
                                        // libelleNiveau2Pays:
                                        //     libelleNiveau2Pays!,
                                        // libelleNiveau3Pays:
                                        //     libelleNiveau3Pays!,
                                        localiteStructure:
                                            param.localiteStructure!)
                                    .then((value) => {
                                          print("Modifier avec succèss"),
                                          Provider.of<ParametreGenerauxService>(
                                                  context,
                                                  listen: false)
                                              .applyChange(),
                                        })
                                    .catchError((onError) =>
                                        {print(onError.toString())});
                              } else {
                                await ParametreGenerauxService()
                                    .updateParametre(
                                        idParametreGeneraux:
                                            param.idParametreGeneraux!,
                                        nomStructure: param.nomStructure!,
                                        sigleStructure: param.sigleStructure!,
                                        sigleSysteme: param.sigleSysteme!,
                                        nomSysteme: param.nomSysteme!,
                                        logoSysteme: photo,
                                        // monnaie: monnaie!,
                                        // tauxDollar: tauxDollar!,
                                        // tauxYuan: tauxYuan!,
                                        descriptionSysteme:
                                            param.descriptionSysteme!,
                                        sloganSysteme: param.sloganSysteme!,
                                        adresseStructure:
                                            param.adresseStructure!,
                                        emailStructure: param.emailStructure!,
                                        telephoneStructure:
                                            param.telephoneStructure!,
                                        whattsAppStructure:
                                            param.whattsAppStructure!,
                                        // libelleNiveau1Pays:
                                        //     libelleNiveau1Pays!,
                                        // libelleNiveau2Pays:
                                        //     libelleNiveau2Pays!,
                                        // libelleNiveau3Pays:
                                        //     libelleNiveau3Pays!,
                                        localiteStructure:
                                            param.localiteStructure!)
                                    .then((value) => {
                                          print("Modifier avec succèss"),
                                          Provider.of<ParametreGenerauxService>(
                                                  context,
                                                  listen: false)
                                              .applyChange(),
                                        })
                                    .catchError((onError) =>
                                        {print(onError.toString())});
                              }
                            } catch (e) {}
                          },
                          icon: const Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              isEditing = true; // Activer le mode édition
                            });
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                ]
              : null),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<ParametreGenerauxService>(
              builder: (context, paramService, child) {
                return FutureBuilder(
                  future: paramService.fetchParametre(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return buildShimmerEffect();
                    }
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Une erreur s'est produite"),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Aucun donnée trouvé"),
                      );
                    } else {
                      paramList = snapshot.data!;
                      param = paramList[0];
                      // parProvider.setParametre(param);
                      //  parProvider.setParametreList(paramList);
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05,
                            ),
                            child: Container(
                              // height: isEditing ? 290 : 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    offset: const Offset(0, 2),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: isEditing
                                        ? SizedBox(
                                            width: 150,
                                            height: 80,
                                            child: Column(
                                              children: [
                                                Flexible(
                                                  child: FadeInImage(
                                                    image: NetworkImage(
                                                      "https://koumi.ml/api-koumi/parametreGeneraux/${param.idParametreGeneraux!}/image",
                                                    ),
                                                    placeholder: AssetImage(
                                                        "assets/images/logo.png"),
                                                    placeholderFit:
                                                        BoxFit.cover,
                                                    width: 90,
                                                    height: 90,
                                                    fit: BoxFit.cover,
                                                    imageErrorBuilder: (context,
                                                        error, stackTrace) {
                                                      // Widget affiché en cas d'erreur
                                                      return Image.asset(
                                                        'assets/images/default_image.png',
                                                        fit: BoxFit.contain,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      50, // ou une autre valeur selon vos besoins
                                                  child: TextButton(
                                                    onPressed:
                                                        _showImageSourceDialog,
                                                    child: const Text(
                                                      'Modifier',
                                                      style: TextStyle(
                                                          color: d_colorGreen),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : FadeInImage(
                                                    image: NetworkImage(
                                                      "https://koumi.ml/api-koumi/parametreGeneraux/${param.idParametreGeneraux!}/image",
                                                    ),
                                                    placeholder: AssetImage(
                                                        "assets/images/logo.png"),
                                                    placeholderFit:
                                                        BoxFit.cover,
                                                    width: 90,
                                                    height: 90,
                                                    fit: BoxFit.cover,
                                                    imageErrorBuilder: (context,
                                                        error, stackTrace) {
                                                      // Widget affiché en cas d'erreur
                                                      return Image.asset(
                                                        'assets/images/default_image.png',
                                                        fit: BoxFit.contain,
                                                      );
                                                    },
                                                  ),
                                                
                                    title: isEditing
                                        ? TextFormField(
                                            initialValue: param.nomSysteme,
                                            onChanged: (value) {
                                              param.nomSysteme = value;
                                            })
                                        : Text(
                                            param.nomSysteme!,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                    subtitle: isEditing
                                        ? TextFormField(
                                            initialValue: param.sloganSysteme,
                                            onChanged: (value) {
                                              param.sloganSysteme = value;
                                            },
                                          )
                                        : Text(
                                            param.sloganSysteme!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              // overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Divider(
                                      height: 2,
                                      color: d_colorGreen,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  isEditing
                                      ? TextFormField(
                                          initialValue:
                                              param.descriptionSysteme,
                                          onChanged: (value) {
                                            param.descriptionSysteme = value;
                                          },
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            param.descriptionSysteme!,
                                            textAlign: TextAlign.justify,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05),
                              child: Container(
                                // height: isEditing ? 150 : 110,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      offset: const Offset(0, 2),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text("Nom structure",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              )),
                                        ),
                                        isEditing
                                            ? Expanded(
                                                child: TextFormField(
                                                  initialValue:
                                                      param.nomStructure,
                                                  onChanged: (value) {
                                                    param.nomStructure = value;
                                                  },
                                                  // controller:
                                                  //     nomStructureController
                                                ),
                                              )
                                            : Text(param.nomStructure!,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ))
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Divider(
                                      height: 2,
                                      color: d_colorGreen,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text("Sigle Structure",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              )),
                                        ),
                                        isEditing
                                            ? Expanded(
                                                child: TextFormField(
                                                  initialValue:
                                                      param.sigleStructure,
                                                  onChanged: (value) {
                                                    param.sigleStructure =
                                                        value;
                                                  },
                                                  // controller:
                                                  //     sigleStructureController,
                                                ),
                                              )
                                            : Text(param.sigleStructure!,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ))
                                      ],
                                    ),
                                  )
                                ]),
                              )),
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text("Autres informations"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.02,
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05),
                            child: Container(
                              height: isEditing ? 340 : 250,
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    offset: const Offset(0, 2),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text("Adresse",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              )),
                                        ),
                                        isEditing
                                            ? Expanded(
                                                child: TextFormField(
                                                  initialValue:
                                                      param.adresseStructure,
                                                  onChanged: (value) {
                                                    param.adresseStructure =
                                                        value;
                                                  },
                                                  // controller:
                                                  //     adresseStructureController,
                                                ),
                                              )
                                            : Text(param.adresseStructure!,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ))
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Divider(
                                      height: 1,
                                      color: d_colorGreen,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text("Téléphone",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              )),
                                        ),
                                        isEditing
                                            ? Expanded(
                                                child: TextFormField(
                                                  initialValue:
                                                      param.telephoneStructure,
                                                  onChanged: (value) {
                                                    param.telephoneStructure =
                                                        value;
                                                  },
                                                  // controller:
                                                  //     telephoneStructureController,
                                                ),
                                              )
                                            : Text(param.telephoneStructure!,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ))
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Divider(
                                      height: 1,
                                      color: d_colorGreen,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text("whatsApp",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              )),
                                        ),
                                        isEditing
                                            ? Expanded(
                                                child: TextFormField(
                                                  initialValue:
                                                      param.whattsAppStructure,
                                                  onChanged: (value) {
                                                    param.whattsAppStructure =
                                                        value;
                                                  },
                                                  // controller:
                                                  //     whattsAppStructureController,
                                                ),
                                              )
                                            : Text(param.whattsAppStructure!,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ))
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Divider(
                                      height: 1,
                                      color: d_colorGreen,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text("Localité",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              )),
                                        ),
                                        isEditing
                                            ? Expanded(
                                                child: TextFormField(
                                                  initialValue:
                                                      param.localiteStructure,
                                                  onChanged: (value) {
                                                    param.localiteStructure =
                                                        value;
                                                  },
                                                  // controller:
                                                  //     localiteStructureController,
                                                ),
                                              )
                                            : Text(param.localiteStructure!,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerEffect() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 110,
                      height: 150,
                      color: Colors.white,
                    ),
                    title: Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    subtitle: Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Divider(height: 2, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 80,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 110,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 20,
                          color: Colors.white,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Divider(height: 2, color: Colors.green),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 20,
                          color: Colors.white,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text("Autre information"),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 400,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 20,
                          color: Colors.white,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Divider(height: 1, color: Colors.green),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 20,
                          color: Colors.white,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfil(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                overflow: TextOverflow.ellipsis),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
