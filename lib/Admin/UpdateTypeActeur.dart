import 'package:flutter/material.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/service/TypeActeurService.dart';
import 'package:provider/provider.dart';

class UpdateTypeActeur extends StatefulWidget {
  final TypeActeur typeActeur;
  const UpdateTypeActeur({super.key, required this.typeActeur});

  @override
  State<UpdateTypeActeur> createState() => _UpdateTypeActeurState();
}

class _UpdateTypeActeurState extends State<UpdateTypeActeur> {
  List<TypeActeur> typeList = [];
  late TypeActeur type;
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    type = widget.typeActeur;
    libelleController.text = type.libelle!;
    descriptionController.text = type.descriptionTypeActeur!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
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
         
          const SizedBox(height: 10),
          Form(
            key: formkey,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Libellé',
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
                  controller: libelleController,
                  decoration: InputDecoration(
                    hintText: "Libellé",
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
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final String libelle = libelleController.text;
                    final String desc = descriptionController.text;
                    if (formkey.currentState!.validate()) {
                      try {
                        await TypeActeurService()
                            .updateTypeActeur(
                                idTypeActeur: type.idTypeActeur!,
                                libelle: libelle,
                                descriptionTypeActeur: desc)
                            .then((value) => {
                                  Provider.of<TypeActeurService>(context,
                                          listen: false)
                                      .applyChange(),
                                  libelleController.clear(),
                                  descriptionController.clear(),
                                  Navigator.of(context).pop()
                                });
                      } catch (e) {
                        final String errorMessage = e.toString();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const SizedBox(width: 10),
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
