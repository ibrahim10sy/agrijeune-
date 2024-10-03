import 'package:flutter/material.dart';
import 'package:koumi/models/TypeMateriel.dart';
import 'package:koumi/service/TypeMaterielService.dart';
import 'package:provider/provider.dart';

class UpdateTypeMateriel extends StatefulWidget {
  final TypeMateriel typeMateriel;
  const UpdateTypeMateriel({
    super.key,
    required this.typeMateriel,
  });

  @override
  State<UpdateTypeMateriel> createState() => _UpdateTypeMaterielState();
}

class _UpdateTypeMaterielState extends State<UpdateTypeMateriel> {
  final formkey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    nomController.text = widget.typeMateriel.nom!;
    descController.text = widget.typeMateriel.description!;
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
                      hintText: "Nom type matériel",
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
                      final String description = descController.text;

                      if (formkey.currentState!.validate()) {
                        try {
                          await TypeMaterielService()
                              .updateTypeVoiture(
                                idTypeMateriel: widget.typeMateriel.idTypeMateriel! ,
                                  nom: nom, description: description)
                              .then((value) => {
                                    Provider.of<TypeMaterielService>(context,
                                            listen: false)
                                        .applyChange(),
                                    nomController.clear(),
                                    descController.clear(),
                                    Navigator.of(context).pop()
                                  })
                              .catchError((onError) => {
                                    print(onError.toString()),
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Text(
                                                "Ce type de matériel existe déjà"),
                                          ],
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    )
                                  });
                        } catch (e) {
                          final String errorMessage = e.toString();
                          print(errorMessage);
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
                      Icons.add,
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
