// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Campagne.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/CampagneService.dart';

class UpdateCampagne extends StatefulWidget {
  final Campagne campagnes;
  const UpdateCampagne({
    Key? key,
    required this.campagnes,
  }) : super(key: key);

  @override
  State<UpdateCampagne> createState() => _UpdateCampagneState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

class _UpdateCampagneState extends State<UpdateCampagne> {
  TextEditingController nomController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late Campagne campagne;
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    campagne = widget.campagnes;
    nomController.text = campagne.nomCampagne;
    descriptionController.text = campagne.description;
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
              leading: Image.asset(
                "assets/images/zone.png",
                width: 50,
                height: 50,
              ),
              title: Text(
                "Modication ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
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

            // const SizedBox(height: 10),
            Form(
              key: formkey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Nom campagne',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez remplir les champs";
                      }
                      return null;
                    },
                    controller: nomController,
                    decoration: InputDecoration(
                      hintText: "Nom campagne",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez remplir les champs";
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
                      )),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final String nom = nomController.text;
                      final String desc = descriptionController.text;
                      if (formkey.currentState!.validate()) {
                        try {
                          await CampagneService()
                              .updateCampagne(
                                idCampagne: campagne.idCampagne!,
                                nomCampagne: nom,
                                description: desc,
                              )
                              .then((value) => {
                                    Provider.of<CampagneService>(context,
                                            listen: false)
                                        .applyChange(),
                                    nomController.clear(),
                                    descriptionController.clear(),
                                    Navigator.of(context).pop()
                                  });
                        } catch (e) {
                          final String errorMessage = e.toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Text("Une erreur s'est produit"),
                                ],
                              ),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
