import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/models/SousRegion.dart';
import 'package:koumi/service/PaysService.dart';
import 'package:provider/provider.dart';

class UpdatesPays extends StatefulWidget {
  final Pays pays;
  const UpdatesPays({super.key, required this.pays});

  @override
  State<UpdatesPays> createState() => _UpdatesPaysState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _UpdatesPaysState extends State<UpdatesPays> {
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController niveau1PaysController = TextEditingController();
  TextEditingController niveau2PaysController = TextEditingController();
  TextEditingController niveau3PaysController = TextEditingController();
  TextEditingController monnaieController = TextEditingController();
  TextEditingController numController = TextEditingController();
  late SousRegion sousRegion;
  String? sousValue;
  late Future _sousRegionList;
  late Pays payss;

  @override
  void initState() {
    super.initState();
    _sousRegionList = http.get(Uri.parse('$apiOnlineUrl/sousRegion/read'));
    payss = widget.pays;
    sousValue = payss.sousRegion!.idSousRegion;
    libelleController.text = payss.nomPays!;
    descriptionController.text = payss.descriptionPays!;
    niveau1PaysController.text = payss.libelleNiveau1Pays!;
    niveau2PaysController.text = payss.libelleNiveau2Pays!;
    niveau3PaysController.text = payss.libelleNiveau3Pays!;
    monnaieController.text = payss.monnaie!;
    numController.text = payss.whattsAppPays!;
    sousRegion = payss.sousRegion!;
    // if (payss.monnaie != null) {
    //   monnaieController.text = payss.monnaie!;
    // } else {
    //   monnaieController.text = "";
    // }
    // if (payss.tauxDollar != null) {
    // tauxDollarController.text = payss.tauxDollar!;
    // } else {
    //     tauxDollarController.text = "";

    // }
    // if (payss.tauxYuan != null) {
    // tauxYuanController.text = payss.tauxYuan!;
    // } else {
    //     tauxYuanController.text = "";

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: d_colorGreen,
        centerTitle: true,
        toolbarHeight: 75,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
        title: const Text(
          "Modification",
          style: TextStyle(
              color: d_colorGreen, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Nom du pays",
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
                          return "Veuillez remplir ce champ";
                        }
                        return null;
                      },
                      controller: libelleController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Sous région",
                        style: TextStyle(color: (Colors.black), fontSize: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: FutureBuilder(
                      future: _sousRegionList,
                      builder: (_, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return DropdownButtonFormField(
                            items: [],
                            onChanged: null,
                            decoration: InputDecoration(
                              labelText: 'Chargement...',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          final reponse =
                              json.decode((snapshot.data.body)) as List;
                          final sousList = reponse
                              .map((e) => SousRegion.fromMap(e))
                              .where((con) => con.statutSousRegion == true)
                              .toList();

                          if (sousList.isEmpty) {
                            return Text(
                              'Aucun sous region disponible',
                              style: TextStyle(overflow: TextOverflow.ellipsis),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            items: sousList
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.idSousRegion,
                                    child: Text(e.nomSousRegion),
                                  ),
                                )
                                .toList(),
                            value: sousValue,
                            onChanged: (newValue) {
                              setState(() {
                                // sousValue = newValue;
                                // if (newValue != null) {
                                //   sousRegion = sousList.firstWhere((element) =>
                                //       element.idSousRegion == newValue);
                                //   debugPrint(
                                //       "con select ${sousRegion.idSousRegion.toString()}");
                                //   // typeSelected = true;
                                // }
                                sousValue = newValue;
                                if (newValue != null) {
                                  sousRegion = sousList.firstWhere(
                                    (sousRegion) =>
                                        sousRegion.idSousRegion == newValue,
                                  );
                                  print("niveau 1 : ${sousRegion}");
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Sélectionner un sous région',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
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
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Description",
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
                          return "Veuillez remplir ce champ";
                        }
                        return null;
                      },
                      controller: descriptionController,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: "Description",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Numéro whathsApp",
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
                          return "Veuillez remplir ce champ";
                        }
                        return null;
                      },
                      controller: numController,
                      maxLines: null,
                      decoration: InputDecoration(
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
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Libellé niveau 1",
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
                          return "Veuillez remplir ce champ";
                        }
                        return null;
                      },
                      controller: niveau1PaysController,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Libellé niveau 2",
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
                          return "Veuillez remplir ce champ";
                        }
                        return null;
                      },
                      controller: niveau2PaysController,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Libellé niveau 3",
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
                          return "Veuillez remplir ce champ";
                        }
                        return null;
                      },
                      controller: niveau3PaysController,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Monnaie",
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
                          return "Veuillez remplir ce champ";
                        }
                        return null;
                      },
                      controller: monnaieController,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final String libelle = libelleController.text;
                        final String description = descriptionController.text;
                        if (formkey.currentState!.validate()) {
                          try {
                            await PaysService()
                                .updatePays(
                                    idPays: payss.idPays!,
                                    nomPays: libelle,
                                    descriptionPays: description,
                                    libelleNiveau1Pays:
                                        niveau1PaysController.text,
                                    libelleNiveau2Pays:
                                        niveau2PaysController.text,
                                    libelleNiveau3Pays:
                                        niveau3PaysController.text,
                                    monnaie: monnaieController.text,
                                    whattsAppPays: numController.text,
                                    sousRegion: sousRegion)
                                .then((value) => {
                                      Provider.of<PaysService>(context,
                                              listen: false)
                                          .applyChange(),
                                      Provider.of<PaysService>(context,
                                              listen: false)
                                          .applyChange(),
                                      numController.clear(),
                                      libelleController.clear(),
                                      niveau1PaysController.clear(),
                                      niveau2PaysController.clear(),
                                      niveau3PaysController.clear(),
                                      descriptionController.clear(),
                                      setState(() {
                                        sousRegion == null;
                                      }),
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
                          debugPrint("sous region $sousRegion");
                          debugPrint("l1 ${niveau1PaysController.text}");
                          debugPrint("l2 ${niveau2PaysController.text}");
                          debugPrint("l3 ${niveau3PaysController.text}");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Orange color code
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
