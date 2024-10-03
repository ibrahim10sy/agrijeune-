import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/constants.dart';
import 'package:koumi/models/Continent.dart';
import 'package:koumi/models/SousRegion.dart';
import 'package:koumi/service/SousRegionService.dart';
import 'package:provider/provider.dart';

class updateSousRegions extends StatefulWidget {
  final SousRegion sousRegion;
  const updateSousRegions({super.key, required this.sousRegion});

  @override
  State<updateSousRegions> createState() => _updateSousRegionsState();
}

class _updateSousRegionsState extends State<updateSousRegions> {
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  late Continent continents;
  String? continentValue;
  late Future _continentList;
  @override
  void initState() {
    libelleController.text = widget.sousRegion.nomSousRegion;
    continents = widget.sousRegion.continent;
    continentValue = widget.sousRegion.continent.idContinent;
    _continentList = http.get(Uri.parse('$apiOnlineUrl/continent/read'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
     
      padding: const EdgeInsets.all(16),
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
                    labelText: "Nom de la sous-région",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                FutureBuilder(
                  future: _continentList,
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
                      final continentList = reponse
                          .map((e) => Continent.fromMap(e))
                          .where((con) => con.statutContinent == true)
                          .toList();

                      if (continentList.isEmpty) {
                        return Text('Aucun continent disponible');
                      }

                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        items: continentList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.idContinent,
                                child: Text(e.nomContinent),
                              ),
                            )
                            .toList(),
                        value: continentValue,
                        onChanged: (newValue) {
                          setState(() {
                            continentValue = newValue;
                            if (newValue != null) {
                              continents = continentList.firstWhere(
                                  (element) => element.idContinent == newValue);
                              debugPrint(
                                  "con select ${continents.idContinent.toString()}");
                              // typeSelected = true;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un continent',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                    return Text('Aucune donnée disponible');
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final String libelle = libelleController.text;
                    if (formkey.currentState!.validate()) {
                      try {
                        await SousRegionService()
                            .updateSousRegion(
                                idSousRegion: widget.sousRegion.idSousRegion!,
                                nomSousRegion: libelle,
                                continent: continents)
                            .then((value) => {
                                  Provider.of<SousRegionService>(context,
                                          listen: false)
                                      .applyChange(),
                                  libelleController.clear(),
                                  Navigator.of(context).pop()
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
    );
  }
}
