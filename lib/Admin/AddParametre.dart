import 'package:flutter/material.dart';
import 'package:koumi/Admin/NextAddParametre.dart';

class AddParametre extends StatefulWidget {
  const AddParametre({super.key});

  @override
  State<AddParametre> createState() => _AddParametreState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _AddParametreState extends State<AddParametre> {
  bool _isEditing = false;
  TextEditingController _libelleController = TextEditingController();
  TextEditingController _classeController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  TextEditingController _listeController = TextEditingController();
  TextEditingController _champController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
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
            "Ajout de parametre",
            style: TextStyle(color: d_colorGreen, fontWeight: FontWeight.bold),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                          "Libelle paramètre",
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
                        controller: _libelleController,
                        decoration: InputDecoration(
                          hintText: "libelle",
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
                          "Classe paramètre",
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
                        controller: _classeController,
                        decoration: InputDecoration(
                          hintText: "Classe ",
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
                          "Champ paramètre",
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
                        controller: _champController,
                        decoration: InputDecoration(
                          hintText: "Champ paramètre",
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
                          "Type donnée paramètre",
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
                        controller: _typeController,
                        decoration: InputDecoration(
                          hintText: "Type donnée paramètre",
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
                          "Liste donnée paramètre",
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
                        controller: _listeController,
                        decoration: InputDecoration(
                          hintText: "Liste donnée paramètre",
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
                          final String libelle = _libelleController.text;
                          final String classe = _classeController.text;
                          final String champ = _champController.text;
                          final String type = _typeController.text;
                          final List<String> liste = _listeController.text
                              .split(',')
                              .map((e) => e.trim())
                              .toList();
                          ;
                          if (formkey.currentState!.validate()) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NextAddParametre(
                                        libelle: libelle,
                                        classe: classe,
                                        champ: champ,
                                        type: type,
                                        liste: liste)));
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
                          "Suivant",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
