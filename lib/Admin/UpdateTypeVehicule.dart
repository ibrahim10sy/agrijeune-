import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/TypeVoiture.dart';
import 'package:koumi/models/Vehicule.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/TypeVoitureService.dart';
import 'package:provider/provider.dart';

class UpdateTypeVehicule extends StatefulWidget {
  final TypeVoiture typeVoiture;
  const UpdateTypeVehicule({super.key, required this.typeVoiture});

  @override
  State<UpdateTypeVehicule> createState() => _UpdateTypeVehiculeState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _UpdateTypeVehiculeState extends State<UpdateTypeVehicule> {
  late Acteur acteur;
  List<TypeVoiture> typeListe = [];
  late List<Vehicule> vehiculeList = [];
  final formkey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController nombreSiegesController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    nomController.text = widget.typeVoiture.nom!;
    // Ensure nombreSieges and description are not null
    if (widget.typeVoiture.nombreSieges != null) {
      nombreSiegesController.text = widget.typeVoiture.nombreSieges!.toString();
    }

    if (widget.typeVoiture.description != null) {
      descController.text = widget.typeVoiture.description!;
    }

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
                        return "Veuillez remplir les champs";
                      }
                      return null;
                    },
                    controller: nomController,
                    decoration: InputDecoration(
                      hintText: "Nom type vehicule",
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
                    controller: nombreSiegesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: "nombre siège facultatif",
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
                      final String nom = nomController.text;
                      final String siege = nombreSiegesController.text;
                      final String description = descController.text;
                      // if (formkey.currentState!.validate()) {
                      try {
                        await TypeVoitureService()
                            .updateTypeVoiture(
                                idTypeVoiture:
                                    widget.typeVoiture.idTypeVoiture!,
                                nom: nom,
                                nombreSieges: siege,
                                description: description,
                                acteur: acteur)
                            .then((value) => {
                                  Provider.of<TypeVoitureService>(context,
                                          listen: false)
                                      .applyChange(),
                                  nomController.clear(),
                                  descController.clear(),
                                  nombreSiegesController.clear(),
                                  Navigator.of(context).pop(),
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Text("Modifier avec succèss"),
                                        ],
                                      ),
                                      duration: Duration(seconds: 5),
                                    ),
                                  )
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
                      // }
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
