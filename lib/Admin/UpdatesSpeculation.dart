import 'package:flutter/material.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/service/SpeculationService.dart';
import 'package:provider/provider.dart';

class UpdatesSpeculation extends StatefulWidget {
  final Speculation speculation;
  const UpdatesSpeculation({super.key, required this.speculation});

  @override
  State<UpdatesSpeculation> createState() => _UpdatesSpeculationState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

class _UpdatesSpeculationState extends State<UpdatesSpeculation> {
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late Speculation speculations;

  @override
  void initState() {
    super.initState();
    speculations = widget.speculation;
    libelleController.text = speculations.nomSpeculation!;
    descriptionController.text = speculations.descriptionSpeculation!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez remplir les champs";
                      }
                      return null;
                    },
                    controller: libelleController,
                    decoration: InputDecoration(
                      hintText: "Nom de la spéculation",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez remplir les champs";
                      }
                      return null;
                    },
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: "Description",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                        await SpeculationService()
                            .updateSpeculation(
                                idSpeculation: speculations.idSpeculation!,
                                nomSpeculation: libelle,
                                descriptionSpeculation: description)
                            .then((value) => {
                                  Provider.of<SpeculationService>(context,
                                          listen: false)
                                      .applyChange(),
                                  libelleController.clear(),
                                  descriptionController.clear(),
                                  Navigator.of(context).pop()
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
    );
  }
}
