import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/constants.dart';

import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Niveau2Pays.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/ParametreGeneraux.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/Niveau3Service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class UpdateNiveau3 extends StatefulWidget {
  final Niveau3Pays niveau3pays;
  const UpdateNiveau3({super.key, required this.niveau3pays});

  @override
  State<UpdateNiveau3> createState() => _UpdateNiveau3State();
}

class _UpdateNiveau3State extends State<UpdateNiveau3> {
  late ParametreGeneraux para;
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<ParametreGeneraux> paraList = [];
  late Niveau2Pays niveau2;
  late Future _paysList;
  late Acteur acteur;
  String? niveau2Value;
  late Future _niveauList;


   bool isLoadingLibelle = true;
    String? libelleNiveau3Pays;
 
  Future<String> getLibelleNiveau3PaysByActor(String id) async {
    final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau3Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response.body;  // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau3Pays');
    }
 }

     Future<void> fetchPaysDataByActor() async {
    try {
      String libelle3 = await getLibelleNiveau3PaysByActor(acteur.idActeur!);

      setState(() { 
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
  
    fetchPaysDataByActor();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _niveauList =
        http.get(Uri.parse('$apiOnlineUrl/niveau2Pays/read'));
    libelleController.text = widget.niveau3pays.nomN3;
    descriptionController.text = widget.niveau3pays.descriptionN3;
    niveau2 = widget.niveau3pays.niveau2Pays!;
    niveau2Value = widget.niveau3pays.niveau2Pays!.idNiveau2Pays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Modification",
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Fermer",
                      style: TextStyle(color: Colors.red, fontSize: 18)),
                )
              ],
            ),
           
            SizedBox(height: 16),
            Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez remplir ce champ";
                      }
                      return null;
                    },
                    controller: libelleController,
                    decoration: InputDecoration(
                      labelText: "Nom du ${libelleNiveau3Pays}",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 6),
                    ),
                  ),
                  // SizedBox(height: 16),
                  // FutureBuilder(
                  //   future: _paysList,
                  //   builder: (_, snapshot) {
                  //     if (snapshot.connectionState ==
                  //         ConnectionState.waiting) {
                  //       return CircularProgressIndicator();
                  //     }
                  //     if (snapshot.hasError) {
                  //       return Text("${snapshot.error}");
                  //     }
                  //     if (snapshot.hasData) {
                  //       final reponse =
                  //           json.decode((snapshot.data.body)) as List;
                  //       final paysList = reponse
                  //           .map((e) => Pays.fromMap(e))
                  //           .where((con) => con.statutPays == true)
                  //           .toList();

                  //       if (paysList.isEmpty) {
                  //         return Text(
                  //           'Aucun donné disponible',
                  //           style:
                  //               TextStyle(overflow: TextOverflow.ellipsis),
                  //         );
                  //       }

                  //       return DropdownButtonFormField<String>(
                  //         items: paysList
                  //             .map(
                  //               (e) => DropdownMenuItem(
                  //                 value: e.idPays,
                  //                 child: Text(e.nomPays),
                  //               ),
                  //             )
                  //             .toList(),
                  //         value: paysValue,
                  //         onChanged: (newValue) {
                  //           setState(() {
                  //             paysValue = newValue;
                  //             if (newValue != null) {
                  //               pays = paysList.firstWhere((element) =>
                  //                   element.idPays == newValue);

                  //               // typeSelected = true;
                  //             }
                  //           });
                  //         },
                  //         decoration: InputDecoration(
                  //           labelText: 'Sélectionner un pays',
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //     return Text(
                  //       'Aucune donnée disponible',
                  //       style: TextStyle(overflow: TextOverflow.ellipsis),
                  //     );
                  //   },
                  // ),
                  SizedBox(height: 16),
                 FutureBuilder(
  future: _niveauList,
  builder: (_, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return DropdownButtonFormField(
                                  items: [],
                                  onChanged: null,
                                  decoration: InputDecoration(
                                    labelText: 'Chargement ...',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
    }
    if (snapshot.hasError) {
      return Text("${snapshot.error}");
    }
    if (snapshot.hasData) {
      final reponse = json.decode((snapshot.data.body)) as List;
      final niveauList = reponse
          .map((e) => Niveau2Pays.fromMap(e))
          .where((con) => con.statutN2 == true)
          .toList();

      if (niveauList.isEmpty) {
        return Text(
          'Aucun donné disponible',
          style: TextStyle(overflow: TextOverflow.ellipsis),
        );
      }

      return IntrinsicWidth(
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          items: niveauList
              .map(
                (e) => DropdownMenuItem(
                  value: e.idNiveau2Pays,
                  child: Text(
                    e.nomN2,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
              .toList(),
          value: niveau2Value,
          onChanged: (newValue) {
            setState(() {
              niveau2Value = newValue;
              if (newValue != null) {
                niveau2 = niveauList.firstWhere(
                    (element) => element.idNiveau2Pays == newValue);
                debugPrint("niveau select :${niveau2.toString()}");
              }
            });
          },
          decoration: InputDecoration(
            labelText: 'Sélectionner un niveau 2',
            labelStyle: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 6), // Ajouter un padding horizontal
          ),
        ),
      );
    }
    return Text(
      'Aucune donnée disponible',
      style: TextStyle(overflow: TextOverflow.ellipsis),
    );
  },
),

                  SizedBox(height: 16),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez remplir ce champ";
                      }
                      return null;
                    },
                    controller: descriptionController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 6),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final String libelle = libelleController.text;
                      final String description = descriptionController.text;
                      if (formkey.currentState!.validate()) {
                        try {
                          await Niveau3Service()
                              .updateNiveau3Pays(idNiveau3Pays: widget.niveau3pays.idNiveau3Pays! , nomN3: libelle, descriptionN3: description, niveau2Pays: niveau2)
                              .then((value) => {
                                    Provider.of<Niveau3Service>(context,
                                            listen: false)
                                        .applyChange(),
                                    libelleController.clear(),
                                    descriptionController.clear(),
                                    Navigator.of(context).pop(),
                                    setState(() {
                                      niveau2 == null;
                                    }),
                                  });
                        } catch (e) {
                          final String errorMessage = e.toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Text("Une erreur s'est produit"),
                                ],
                              ),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Orange color code
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(290, 45),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Modifier",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
