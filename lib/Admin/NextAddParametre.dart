import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koumi/Admin/ParametreFichePage.dart';
import 'package:koumi/service/ParametreFicheService.dart';
import 'package:provider/provider.dart';

class NextAddParametre extends StatefulWidget {
  final String libelle;
  final String classe;
  final String champ;
  final String type;
  final List<String> liste;

  NextAddParametre(
      {super.key,
      required this.libelle,
      required this.classe,
      required this.champ,
      required this.type,
      required this.liste});

  @override
  State<NextAddParametre> createState() => _NextAddParametreState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _NextAddParametreState extends State<NextAddParametre> {
  TextEditingController _valeurMaxController = TextEditingController();
  TextEditingController _valeurMinController = TextEditingController();
  TextEditingController _valeurObligatoireController = TextEditingController();
  TextEditingController _critereController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
          backgroundColor: d_colorOr,
          centerTitle: true,
          toolbarHeight: 75,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
          title: const Text(
            "Suite",
            style: TextStyle(color: d_colorGreen, fontWeight: FontWeight.bold),
          )),
      body: SingleChildScrollView(
        child: Column(children: [
          Form(
              key: formkey,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Valeur max",
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
                          return "Veuillez remplir les champs";
                        }
                        return null;
                      },
                      controller: _valeurMaxController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: "valeur max",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Valeur min",
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
                          return "Veuillez remplir les champs";
                        }
                        return null;
                      },
                      controller: _valeurMinController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: "valeur min",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Valeur obligatoire",
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
                          return "Veuillez remplir les champs";
                        }
                        return null;
                      },
                      controller: _valeurObligatoireController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: "valeur obligatoire",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Critère champ paramètre",
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
                          return "Veuillez remplir les champs";
                        }
                        return null;
                      },
                      controller: _critereController,
                      decoration: InputDecoration(
                        hintText: "Critère champ paramètre",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        final String valeurMin = _valeurMinController.text;
                        final String valeurMax = _valeurMaxController.text;
                        final String valeurObligatoire =
                            _valeurObligatoireController.text;
                        final String critere = _critereController.text;
                        if (formkey.currentState!.validate()) {
                          try {
                            await ParametreFicheService()
                                .addParametre(
                                    classeParametre: widget.classe,
                                    champParametre: widget.champ,
                                    libelleParametre: widget.libelle,
                                    typeDonneeParametre: widget.type,
                                    listeDonneeParametre: widget.liste,
                                    valeurMax: valeurMax,
                                    valeurMin: valeurMin,
                                    valeurObligatoire: valeurObligatoire,
                                    critereChampParametre: critere)
                                .then((value) => {
                                      Provider.of<ParametreFicheService>(
                                              context,
                                              listen: false)
                                          .applyChange(),
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ParametreFichePage())),
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Row(
                                            children: [
                                              Text("Ajouter avec succèss "),
                                            ],
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      )
                                    })
                                .catchError(
                                    (onError) => {print(onError.toString())});
                          } catch (e) {
                            print(e.toString());
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: d_colorGreen, // Orange color code
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: const Size(290, 45),
                      ),
                      child: Text(
                        "Ajouter",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              ))
        ]),
      ),
    );
  }
}
