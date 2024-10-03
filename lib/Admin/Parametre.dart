import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/ContinentPage.dart';
import 'package:koumi/Admin/FormeProduit.dart';
import 'package:koumi/Admin/Niveau1Page.dart';
import 'package:koumi/Admin/Niveau2Page.dart';
import 'package:koumi/Admin/Niveau3Page.dart';
import 'package:koumi/Admin/PaysPage.dart';
import 'package:koumi/Admin/SousRegionPage.dart';
import 'package:koumi/Admin/TypeMaterielPage.dart';
import 'package:koumi/Admin/UnitePage.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/ParametreGeneraux.dart';
import 'package:koumi/screens/TypeVehicule.dart';
import 'package:provider/provider.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/providers/ActeurProvider.dart';

class Parametre extends StatefulWidget {
  const Parametre({super.key});

  @override
  State<Parametre> createState() => _ParametreState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

class _ParametreState extends State<Parametre> {
  late ParametreGeneraux params = ParametreGeneraux();
  List<ParametreGeneraux> paramList = [];
  late Acteur acteur;
  bool isLoadingLibelle = true;
  String? libelleNiveau1Pays;
  String? libelleNiveau2Pays;
  String? libelleNiveau3Pays;

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

  Future<String> getLibelleNiveau2PaysByActor(String id) async {
    final response = await http
        .get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau2Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response
          .body; // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau2Pays');
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
//   Future<String> getMonnaieByActor(String id) async {
//     final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/monnaie/$id'));

//     if (response.statusCode == 200) {
//       print("libelle : ${response.body}");
//       return response.body;  // Return the body directly since it's a plain string
//     } else {
//       throw Exception('Failed to load monnaie');
//     }
// }

//   Future<String> getTauxDollarByActor(String id) async {
//     final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/tauxDollar/$id'));

//     if (response.statusCode == 200) {
//       print("libelle : ${response.body}");
//       return response.body;  // Return the body directly since it's a plain string
//     } else {
//       throw Exception('Failed to load tauxDollar');
//     }
// }
//   Future<String> getTauxYuanByActor(String id) async {
//     final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/tauxYuan/$id'));

//     if (response.statusCode == 200) {
//       print("libelle : ${response.body}");
//       return response.body;  // Return the body directly since it's a plain string
//     } else {
//       throw Exception('Failed to load tauxYUAN');
//     }
// }

  Future<void> fetchPaysDataByActor() async {
    try {
      String libelle1 = await getLibelleNiveau1PaysByActor(acteur.idActeur!);
      String libelle2 = await getLibelleNiveau2PaysByActor(acteur.idActeur!);
      String libelle3 = await getLibelleNiveau3PaysByActor(acteur.idActeur!);
      // String monnaies = await getMonnaieByActor(acteur.idActeur!);
      // String tauxDollar = await getTauxDollarByActor(acteur.idActeur!);
      // String tauxYuan = await getTauxYuanByActor(acteur.idActeur!);
      setState(() {
        libelleNiveau1Pays = libelle1;
        libelleNiveau2Pays = libelle2;
        libelleNiveau3Pays = libelle3;
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
    // verifyParam();
    fetchPaysDataByActor();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
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
              Navigator.of(context).pop();
              // Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: const Text(
          "Paramètre Système",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Container(
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
                child: ListTile(
                  leading:
                      params.logoSysteme == null || params.logoSysteme!.isEmpty
                          ? SizedBox(
                              width: 110,
                              height: 150,
                              child: Image.asset(
                                "assets/images/fav.png",
                                scale: 1,
                                fit: BoxFit.fill,
                              ),
                            )
                          : SizedBox(
                              width: 110,
                              height: 150,
                              child: Image.network(
                                "https://koumi.ml/api-koumi/parametreGeneraux/${params.idParametreGeneraux!}/image",
                                // scale: 1,
                                scale: 1,
                                fit: BoxFit.fill,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Image.asset(
                                    'assets/images/default_image.png',
                                    // scale: 1,
                                    scale: 1,
                                    fit: BoxFit.fill,
                                  );
                                },
                              ),
                            ),
                  title: Text(
                    params.nomSysteme != null ? params.nomSysteme! : "Louma-BI",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    params.sloganSysteme != null
                        ? params.sloganSysteme!
                        : "Louma-BI",
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 17,
                      // overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
          Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Container(
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
                    getList(
                        "continent.png",
                        'Continent',
                        const ContinentPage(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                    const Divider(
                      color: Colors.grey,
                      height: 4,
                      thickness: 1,
                      indent: 50,
                      endIndent: 0,
                    ),
                    getList(
                        "sous.png",
                        'Sous région',
                        const SousRegionPage(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                    const Divider(
                      color: Colors.grey,
                      height: 4,
                      thickness: 1,
                      indent: 50,
                      endIndent: 0,
                    ),
                    getList(
                        "pays.png",
                        'Pays',
                        const PaysPage(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                    const Divider(
                      color: Colors.grey,
                      height: 4,
                      thickness: 1,
                      indent: 50,
                      endIndent: 0,
                    ),
                    getList(
                        "region.png",
                        libelleNiveau1Pays != null
                            ? libelleNiveau1Pays!
                            : "Niveau 1",
                        const Niveau1Page(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                    const Divider(
                      color: Colors.grey,
                      height: 4,
                      thickness: 1,
                      indent: 50,
                      endIndent: 0,
                    ),
                    getList(
                        "region.png",
                        libelleNiveau2Pays != null
                            ? libelleNiveau2Pays!
                            : "Niveau 2",
                        const Niveau2Page(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                    const Divider(
                      color: Colors.grey,
                      height: 4,
                      thickness: 1,
                      indent: 50,
                      endIndent: 0,
                    ),
                    getList(
                        "region.png",
                        libelleNiveau3Pays != null
                            ? libelleNiveau3Pays!
                            : "Niveau 3",
                        const Niveau3Page(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                    const Divider(
                      color: Colors.grey,
                      height: 4,
                      thickness: 1,
                      indent: 50,
                      endIndent: 0,
                    ),
                    getList(
                        "unite.png",
                        'Unité de mesure',
                        const UnitePage(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                    const Divider(
                      color: Colors.grey,
                      height: 4,
                      thickness: 1,
                      indent: 50,
                      endIndent: 0,
                    ),
                    getList(
                        "fruits.png",
                        'Forme produit',
                        const FormeProduit(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                    const Divider(
                      color: Colors.grey,
                      height: 4,
                      thickness: 1,
                      indent: 50,
                      endIndent: 0,
                    ),
                    getList(
                        "car.png",
                        'Type de véhicule',
                        TypeVehicule(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                    const Divider(
                      color: Colors.grey,
                      height: 4,
                      thickness: 1,
                      indent: 50,
                      endIndent: 0,
                    ),
                    getList(
                        "typeMateriel.png",
                        'Type de matériel',
                        const TypeMaterielPage(),
                        const Icon(
                          Icons.chevron_right_sharp,
                          size: 30,
                        )),
                  ],
                ),
              )),
          // Padding(
          //     padding: EdgeInsets.symmetric(
          //       vertical: MediaQuery.of(context).size.height * 0.02,
          //       horizontal: MediaQuery.of(context).size.width * 0.05,
          //     ),
          //     child: Container(
          //       width: MediaQuery.of(context).size.width * 0.9,
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(15),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.grey.withOpacity(0.2),
          //             offset: const Offset(0, 2),
          //             blurRadius: 5,
          //             spreadRadius: 2,
          //           ),
          //         ],
          //       ),
          //       child: Column(
          //         children: [
          //           getList(
          //               "settings.png",
          //               'Paramètre fiche donnée',
          //               const ParametreFichePage(),
          //               const Icon(
          //                 Icons.chevron_right_sharp,
          //                 size: 30,
          //               )),
          //           const Divider(
          //             color: Colors.grey,
          //             height: 4,
          //             thickness: 1,
          //             indent: 50,
          //             endIndent: 0,
          //           ),
          //           getList(
          //              "settings.png",
          //               'Paramètre regroupée',
          //               const ParametreRegroupePage(),
          //               const Icon(
          //                 Icons.chevron_right_sharp,
          //                 size: 30,
          //               )),
          //           const Divider(
          //             color: Colors.grey,
          //             height: 4,
          //             thickness: 1,
          //             indent: 50,
          //             endIndent: 0,
          //           ),
          //           getList(
          //               "settings.png",
          //               'Renvoie donnée',
          //               const ParametreRenvoiePage(),
          //               const Icon(
          //                 Icons.chevron_right_sharp,
          //                 size: 30,
          //               )),
          //         ],
          //       ),
          //     ))
        ]),
      ),
    );
  }

  Widget getList(String imgLocation, String text, Widget page, Icon icon2) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
                  child: Image.asset("assets/images/$imgLocation",
                      height: 40, width: 42, fit: BoxFit.contain),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            icon2
          ],
        ),
      ),
    );
  }
}
