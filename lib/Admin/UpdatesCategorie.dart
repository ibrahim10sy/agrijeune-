import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/constants.dart';

import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Filiere.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/CategorieService.dart';
import 'package:provider/provider.dart';

class UpdatesCategorie extends StatefulWidget {
  final CategorieProduit categorieProduit;
  const UpdatesCategorie({super.key, required this.categorieProduit});

  @override
  State<UpdatesCategorie> createState() => _UpdatesCategorieState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

class _UpdatesCategorieState extends State<UpdatesCategorie> {
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late CategorieProduit cat;
  late Acteur acteur;
  late Filiere filiere;
  late Future _filiereList;
  late String? filiereValue;

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    cat = widget.categorieProduit;
    libelleController.text = cat.libelleCategorie!;
    descriptionController.text = cat.descriptionCategorie!;
    filiere = cat.filiere!;
    filiereValue = cat.filiere!.idFiliere;
    _filiereList = http.get(Uri.parse('$apiOnlineUrl/Filiere/getAllFiliere/'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 5),
            Form(
              key: formkey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez remplir ce champ";
                      }
                      return null;
                    },
                    controller: libelleController,
                    decoration: InputDecoration(
                      labelText: "Nom du categorie",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder(
                    future: _filiereList,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return DropdownButtonFormField(
                          items: [],
                          onChanged: null,
                          decoration: InputDecoration(
                            labelText: 'Chargement...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        dynamic jsonString =
                            utf8.decode(snapshot.data.bodyBytes);
                        dynamic responseData = json.decode(jsonString);

                        if (responseData is List) {
                          final reponse = responseData;
                          final filiereList = reponse
                              .map((e) => Filiere.fromMap(e))
                              .where((con) => con.statutFiliere == true)
                              .toList();

                          if (filiereList.isEmpty) {
                            return DropdownButtonFormField(
                              items: [],
                              onChanged: null,
                              decoration: InputDecoration(
                                labelText: 'Aucune filière trouvée',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            items: filiereList
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.idFiliere,
                                    child: Text(e.libelleFiliere!),
                                  ),
                                )
                                .toList(),
                            value: filiereValue,
                            onChanged: (newValue) {
                              setState(() {
                                filiereValue = newValue;
                                if (newValue != null) {
                                  filiere = filiereList.firstWhere(
                                    (element) => element.idFiliere == newValue,
                                  );
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Sélectionnez une filière',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        } else {
                          return DropdownButtonFormField(
                            items: [],
                            onChanged: null,
                            decoration: InputDecoration(
                              labelText: 'Aucune filière trouvée',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      }
                      return DropdownButtonFormField(
                        items: [],
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: 'Aucune filière trouvée',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final String libelle = libelleController.text;
                      final String description = descriptionController.text;
                      if (formkey.currentState!.validate()) {
                        try {
                          await CategorieService()
                              .updateCategorie(
                                  idCategorieProduit: cat.idCategorieProduit!,
                                  libelleCategorie: libelle,
                                  descriptionCategorie: description,
                                  personneModif: acteur.nomActeur!,
                                  filiere: filiere)
                              .then((value) => {
                                    Provider.of<CategorieService>(context,
                                            listen: false)
                                        .applyChange(),
                                    libelleController.clear(),
                                    descriptionController.clear(),
                                    Navigator.of(context).pop(),
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Text(
                                                "Catégorie modifier avec success"),
                                          ],
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    )
                                  });
                        } catch (e) {
                          final String errorMessage = e.toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Text("Une erreur s'est produite"),
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
            )
          ],
        ),
      ),
    );
  }
}
