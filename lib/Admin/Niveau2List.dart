import 'package:flutter/material.dart';

import 'package:koumi/Admin/CodePays.dart';
import 'package:koumi/Admin/Niveau2List.dart';
import 'package:koumi/Admin/UpdateNiveau1.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:koumi/models/Niveau2Pays.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/Niveau1Service.dart';
import 'package:koumi/service/Niveau2Service.dart';
import 'package:koumi/service/PaysService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Niveau2List extends StatefulWidget {
  final Niveau1Pays niveau1pays;
  const Niveau2List({super.key, required this.niveau1pays});

  @override
  State<Niveau2List> createState() => _Niveau2ListState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _Niveau2ListState extends State<Niveau2List> {
  // late ParametreGeneraux para;
  // List<ParametreGeneraux> paraList = [];
  List<Niveau2Pays> niveauList = [];
  late Future<List<Niveau2Pays>> _liste;
  late TextEditingController _searchController;
  late Acteur acteur;

  bool isLoadingLibelle = true;
  String? libelleNiveau2Pays;

  Future<String> getLibelleNiveau2PaysByActor(String id) async {
    final response = await http
        .get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau2Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response
          .body; // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau2Pays');
    }
  }

  Future<void> fetchPaysDataByActor() async {
    try {
      String libelle2 = await getLibelleNiveau2PaysByActor(acteur.idActeur!);

      setState(() {
        libelleNiveau2Pays = libelle2;
        isLoadingLibelle = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLibelle = false;
      });
      print('Error: $e');
    }
  }

  Future<List<Niveau2Pays>> getNiveauListe() async {
    final response = await Niveau2Service()
        .fetchNiveau2ByNiveau1(widget.niveau1pays.idNiveau1Pays!);
    return response;
  }

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    fetchPaysDataByActor();
    _searchController = TextEditingController();
    // paraList = Provider.of<ParametreGenerauxProvider>(context, listen: false)
    //     .parametreList!;
    // para = paraList[0];
    _liste = getNiveauListe();
  }

  @override
  void dispose() {
    _searchController
        .dispose(); // Disposez le TextEditingController lorsque vous n'en avez plus besoin
    super.dispose();
  }

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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: Text(
          widget.niveau1pays.nomN1!.toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50], // Couleur d'arrière-plan
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: Colors.blueGrey[400]), // Couleur de l'icône
                  SizedBox(
                      width:
                          10), // Espacement entre l'icône et le champ de recherche
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: Colors
                                .blueGrey[400]), // Couleur du texte d'aide
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Consumer<Niveau2Service>(builder: (context, niveau2Service, child) {
            return FutureBuilder(
                future: _liste,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(
                          child: Text("Aucun ${libelleNiveau2Pays} trouvé")),
                    );
                  } else {
                    niveauList = snapshot.data!;
                    String searchText = "";
                    List<Niveau2Pays> filtereSearch =
                        niveauList.where((search) {
                      String libelle = search.nomN2.toLowerCase();
                      searchText = _searchController.text.toLowerCase();
                      return libelle.contains(searchText);
                    }).toList();
                    return Column(
                        children: filtereSearch
                            .map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          offset: const Offset(0, 2),
                                          blurRadius: 5,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: CodePays().getFlag(
                                              e.niveau1Pays.pays!.nomPays!),
                                          title: Text(e.nomN2.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                          subtitle: Text(e.descriptionN2.trim(),
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              )),
                                        ),
                                        Container(
                                          alignment: Alignment.bottomRight,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildEtat(e.statutN2),
                                              PopupMenuButton<String>(
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context) =>
                                                    <PopupMenuEntry<String>>[
                                                  PopupMenuItem<String>(
                                                    child: ListTile(
                                                      leading: e.statutN2 ==
                                                              false
                                                          ? Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : Icon(
                                                              Icons
                                                                  .disabled_visible,
                                                              color: Colors
                                                                  .orange[400]),
                                                      title: Text(
                                                        e.statutN2 == false
                                                            ? "Activer"
                                                            : "Desactiver",
                                                        style: TextStyle(
                                                          color: e.statutN2 ==
                                                                  false
                                                              ? Colors.green
                                                              : Colors
                                                                  .orange[400],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        e.statutN2 == false
                                                            ? await Niveau2Service()
                                                                .activerNiveau2(e
                                                                    .idNiveau2Pays!)
                                                                .then(
                                                                    (value) => {
                                                                          Provider.of<Niveau2Service>(context, listen: false)
                                                                              .applyChange(),
                                                                          setState(
                                                                              () {
                                                                            _liste =
                                                                                Niveau2Service().fetchNiveau2ByNiveau1(widget.niveau1pays.idNiveau1Pays!);
                                                                          }),
                                                                          Navigator.of(context)
                                                                              .pop(),
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            const SnackBar(
                                                                              content: Row(
                                                                                children: [
                                                                                  Text("Activer avec succèss "),
                                                                                ],
                                                                              ),
                                                                              duration: Duration(seconds: 2),
                                                                            ),
                                                                          )
                                                                        })
                                                                .catchError(
                                                                    (onError) =>
                                                                        {
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            const SnackBar(
                                                                              content: Row(
                                                                                children: [
                                                                                  Text("Une erreur s'est produit"),
                                                                                ],
                                                                              ),
                                                                              duration: Duration(seconds: 5),
                                                                            ),
                                                                          ),
                                                                          Navigator.of(context)
                                                                              .pop(),
                                                                        })
                                                            : await Niveau2Service()
                                                                .desactiverNiveau2Pays(e
                                                                    .idNiveau2Pays!)
                                                                .then(
                                                                    (value) => {
                                                                          Provider.of<Niveau2Service>(context, listen: false)
                                                                              .applyChange(),
                                                                          setState(
                                                                              () {
                                                                            _liste =
                                                                                Niveau2Service().fetchNiveau2ByNiveau1(widget.niveau1pays.idNiveau1Pays!);
                                                                          }),
                                                                          Navigator.of(context)
                                                                              .pop(),
                                                                        })
                                                                .catchError(
                                                                    (onError) =>
                                                                        {
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            const SnackBar(
                                                                              content: Row(
                                                                                children: [
                                                                                  Text("Une erreur s'est produit"),
                                                                                ],
                                                                              ),
                                                                              duration: Duration(seconds: 5),
                                                                            ),
                                                                          ),
                                                                          Navigator.of(context)
                                                                              .pop(),
                                                                        });

                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Row(
                                                              children: [
                                                                Text(
                                                                    "Désactiver avec succèss "),
                                                              ],
                                                            ),
                                                            duration: Duration(
                                                                seconds: 2),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    child: ListTile(
                                                      leading: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      title: const Text(
                                                        "Supprimer",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        await Niveau2Service()
                                                            .deleteNiveau2Pays(e
                                                                .idNiveau2Pays!)
                                                            .then((value) => {
                                                                  Provider.of<Niveau2Service>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .applyChange(),
                                                                  setState(() {
                                                                    _liste = Niveau2Service().fetchNiveau2ByNiveau1(widget
                                                                        .niveau1pays
                                                                        .idNiveau1Pays!);
                                                                  }),
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                                })
                                                            .catchError(
                                                                (onError) => {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        const SnackBar(
                                                                          content:
                                                                              Row(
                                                                            children: [
                                                                              Text("Impossible de supprimer"),
                                                                            ],
                                                                          ),
                                                                          duration:
                                                                              Duration(seconds: 2),
                                                                        ),
                                                                      )
                                                                    });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ))
                            .toList());
                  }
                });
          })
        ]),
      ),
    );
  }

  Widget _buildEtat(bool isState) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isState ? Colors.green : Colors.red,
      ),
    );
  }
}
