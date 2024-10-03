import 'package:flutter/material.dart';

import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Unite.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/UniteService.dart';
import 'package:provider/provider.dart';

class UpdateUnite extends StatefulWidget {
  final Unite unite;
  const UpdateUnite({super.key, required this.unite});

  @override
  State<UpdateUnite> createState() => _UpdateUniteState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

class _UpdateUniteState extends State<UpdateUnite> {
  List<Unite> uniteList = [];
  late Acteur acteur;
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController sigleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;

    libelleController.text = widget.unite.nomUnite!;
    sigleController.text = widget.unite.sigleUnite!;
    descController.text = widget.unite.description!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                "Modification",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
              ),
              trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 30,
                  )),
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
                        return "Veuillez remplir les champs";
                      }
                      return null;
                    },
                    controller: libelleController,
                    decoration: InputDecoration(
                      hintText: "Nom unité",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez remplir les champs";
                      }
                      return null;
                    },
                    controller: sigleController,
                    decoration: InputDecoration(
                      hintText: "Sigle unité",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez remplir les champs";
                      }
                      return null;
                    },
                    controller: descController,
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
                      final String sigle = sigleController.text;
                      final String description = descController.text;
                      if (formkey.currentState!.validate()) {
                        try {
                          await UniteService()
                              .updateUnite(
                                  idUnite: widget.unite.idUnite!,
                                  nomUnite: libelle,
                                  sigleUnite: sigle,
                                  description: description,
                                  acteur: acteur,
                                  personneModif: acteur.nomActeur!)
                              .then((value) => {
                                    Provider.of<UniteService>(context,
                                            listen: false)
                                        .applyChange(),
                                    libelleController.clear(),
                                    descController.clear(),
                                    sigleController.clear(),
                                    Navigator.of(context).pop()
                                  });
                        } catch (e) {
                          final String errorMessage = e.toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Text(
                                      "Une erreur s'est produit : $errorMessage"),
                                ],
                              ),
                              duration: const Duration(seconds: 5),
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
                      "Modifer",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
