import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/Admin/CodePays.dart';
import 'package:koumi/Admin/UpdateNiveau3.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:koumi/models/Niveau2Pays.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/Niveau2Service.dart';
import 'package:koumi/service/Niveau3Service.dart';
import 'package:provider/provider.dart';

class Niveau3Page extends StatefulWidget {
  // final Niveau2Pays niveau2pays;
  const Niveau3Page({super.key});

  @override
  State<Niveau3Page> createState() => _Niveau3PageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _Niveau3PageState extends State<Niveau3Page> {
  late TextEditingController _searchController;

  List<Niveau3Pays> niveau3Liste = [];
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isSearchMode = false;
  late Niveau2Pays niveau2;
  String? niveau2Value;
  late Acteur acteur;
  late Future _niveau2List;
  late ScrollController _scrollController;
  String? niveau1Value;
  late Niveau1Pays niveau1Pays = Niveau1Pays();

  @override
  void initState() {
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    super.initState();
  }

  Future<List<Niveau2Pays>> fetchList(String id) async {
    final response = await Niveau2Service().fetchNiveau2ByNiveau1(id);
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    return response;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
          "Niveau 3",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          // PopupMenuButton<String>(
          //   padding: EdgeInsets.zero,
          //   itemBuilder: (context) => <PopupMenuEntry<String>>[
          //     PopupMenuItem<String>(
          //       child: ListTile(
          //         leading: const Icon(
          //           Icons.add,
          //           color: Colors.green,
          //         ),
          //         title: Text(
          //           "Ajouter un niveau 3",
          //           style: TextStyle(
          //               color: Colors.green,
          //               fontWeight: FontWeight.bold,
          //               overflow: TextOverflow.ellipsis),
          //         ),
          //         onTap: () async {
          //           // _showDialog();
          //           Navigator.of(context).pop();
          //           bottomUpdatesheet(context);
          //         },
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
      body: Container(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                  child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // The PopupMenuButton is used here to display the menu when the button is pressed.
                          showMenu<String>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              0,
                              50, // Adjust this value based on the desired position of the menu
                              MediaQuery.of(context).size.width,
                              0,
                            ),
                            items: [
                              PopupMenuItem<String>(
                                value: 'add_store',
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.add,
                                    color: d_colorGreen,
                                  ),
                                  title: const Text(
                                    "Ajouter un niveau 3 ",
                                    style: TextStyle(
                                      color: d_colorGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            elevation: 8.0,
                          ).then((value) {
                            if (value != null) {
                              if (value == 'add_store') {
                                bottomUpdatesheet(context);
                              }
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: d_colorGreen,
                            ),
                            SizedBox(width: 8), // Space between icon and text
                            Text(
                              'Ajouter',
                              style: TextStyle(
                                color: d_colorGreen,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isSearchMode = !isSearchMode;
                            _searchController.clear();
                          });
                        },
                        icon: Icon(
                          isSearchMode ? Icons.close : Icons.search,
                          color: isSearchMode ? Colors.red : d_colorGreen,
                        ),
                        label: Text(
                          isSearchMode ? 'Fermer' : 'Rechercher...',
                          style: TextStyle(
                              color: isSearchMode ? Colors.red : d_colorGreen,
                              fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSearchMode)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.blueGrey[400]),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Rechercher',
                                border: InputBorder.none,
                                hintStyle:
                                    TextStyle(color: Colors.blueGrey[400]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ])),
            ];
          },
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                
                Consumer<Niveau3Service>(
                  builder: (context, niveau3Service, child) {
                    return FutureBuilder(
                        future: niveau3Service.fetchNiveau3Pays(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return Padding(
                              padding: EdgeInsets.all(10),
                              child:
                                  Center(child: Text("Aucun niveau 3 trouvé")),
                            );
                          } else {
                            niveau3Liste = snapshot.data!;
                            String searchText = "";
                            List<Niveau3Pays> filtereSearch =
                                niveau3Liste.where((search) {
                              String libelle = search.nomN3.toLowerCase();
                              searchText = _searchController.text.toLowerCase();
                              return libelle.contains(searchText);
                            }).toList();
                            return Column(
                                children: filtereSearch
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
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
                                                        e
                                                            .niveau2Pays!
                                                            .niveau1Pays
                                                            .pays!
                                                            .nomPays!),
                                                    title: Text(
                                                        e.nomN3.toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                                    subtitle: Text(
                                                        e.descriptionN3.trim(),
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ))),
                                                Container(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _buildEtat(e.statutN3),
                                                      PopupMenuButton<String>(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        itemBuilder:
                                                            (context) =>
                                                                <PopupMenuEntry<
                                                                    String>>[
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  e.statutN3 ==
                                                                          false
                                                                      ? Icon(
                                                                          Icons
                                                                              .check,
                                                                          color:
                                                                              Colors.green,
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .disabled_visible,
                                                                          color:
                                                                              Colors.orange[400],
                                                                        ),
                                                              title: Text(
                                                                e.statutN3 ==
                                                                        false
                                                                    ? "Activer"
                                                                    : "Desactiver",
                                                                style:
                                                                    TextStyle(
                                                                  color: e.statutN3 ==
                                                                          false
                                                                      ? Colors
                                                                          .green
                                                                      : Colors.orange[
                                                                          400],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                e.statutN3 ==
                                                                        false
                                                                    ? await Niveau3Service()
                                                                        .activerNiveau3(e
                                                                            .idNiveau3Pays!)
                                                                        .then((value) =>
                                                                            {
                                                                              Provider.of<Niveau3Service>(context, listen: false).applyChange(),
                                                                              // setState(
                                                                              //     () {
                                                                              //   _liste =
                                                                              //       Niveau3Service().fetchNiveau3ByNiveau2(widget.niveau2pays.idNiveau2Pays!);
                                                                              // }),
                                                                              Navigator.of(context).pop(),
                                                                              ScaffoldMessenger.of(context).showSnackBar(
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
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    const SnackBar(
                                                                                      content: Row(
                                                                                        children: [
                                                                                          Text("Une erreur s'est produit"),
                                                                                        ],
                                                                                      ),
                                                                                      duration: Duration(seconds: 5),
                                                                                    ),
                                                                                  ),
                                                                                  Navigator.of(context).pop(),
                                                                                })
                                                                    : await Niveau3Service()
                                                                        .desactiverNiveau3Pays(e
                                                                            .idNiveau3Pays!)
                                                                        .then((value) =>
                                                                            {
                                                                              Provider.of<Niveau3Service>(context, listen: false).applyChange(),
                                                                              Navigator.of(context).pop(),
                                                                            })
                                                                        .catchError((onError) =>
                                                                            {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(
                                                                                  content: Row(
                                                                                    children: [
                                                                                      Text("Une erreur s'est produit"),
                                                                                    ],
                                                                                  ),
                                                                                  duration: Duration(seconds: 5),
                                                                                ),
                                                                              ),
                                                                              Navigator.of(context).pop(),
                                                                            });

                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content:
                                                                        Row(
                                                                      children: [
                                                                        Text(
                                                                            "Désactiver avec succèss "),
                                                                      ],
                                                                    ),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            2),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  const Icon(
                                                                Icons.edit,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              title: const Text(
                                                                "Modifier",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                bottomUpdatesN3heet(
                                                                    context, e);
                                                              },
                                                            ),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              title: const Text(
                                                                "Supprimer",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                await Niveau3Service()
                                                                    .deleteNiveau3Pays(e
                                                                        .idNiveau3Pays!)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              Provider.of<Niveau3Service>(context, listen: false).applyChange(),
                                                                              Navigator.of(context).pop(),
                                                                            })
                                                                    .catchError(
                                                                        (onError) =>
                                                                            {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(
                                                                                  content: Row(
                                                                                    children: [
                                                                                      Text("Impossible de supprimer"),
                                                                                    ],
                                                                                  ),
                                                                                  duration: Duration(seconds: 2),
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
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> bottomUpdatesheet(BuildContext context) async {
    return await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: AddDialog()),
        );
      },
    );
  }

  Future<dynamic> bottomUpdatesN3heet(
      BuildContext context, Niveau3Pays? niveau3) async {
    return await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: UpdateNiveau3(niveau3pays: niveau3!)),
        );
      },
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

class AddDialog extends StatefulWidget {
  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  List<Niveau3Pays> niveau3Liste = [];
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  // late ParametreGeneraux para;
  // List<ParametreGeneraux> paraList = [];
  late Niveau2Pays niveau2;
  String? niveau2Value;
  late Future _niveau2List;
  late Acteur acteur;
  String? niveau1Value;
  late Future _niveau1List;
  late Niveau1Pays niveau1Pays = Niveau1Pays();

  @override
  void initState() {
    _niveau1List = http.get(Uri.parse('$apiOnlineUrl/niveau1Pays/read'));
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _niveau2List = http.get(Uri.parse(
        '$apiOnlineUrl/niveau2Pays/listeNiveau2PaysByIdNiveau1Pays/${niveau1Pays.idNiveau1Pays}'));

    super.initState();
  }

  @override
  void dispose() {
    libelleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ajouter un niveau 3",
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
            SizedBox(height: 16),
            Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez remplir ce champ";
                      }
                      return null;
                    },
                    controller: libelleController,
                    decoration: InputDecoration(
                      labelText: "Nom du niveau 3",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder(
                    future: _niveau1List,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return DropdownButtonFormField(
                          items: [],
                          onChanged: null,
                          decoration: InputDecoration(
                            labelText: 'Chargement...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        // final reponse = json.decode(snapshot.data.body);
                        dynamic jsonString =
                            utf8.decode(snapshot.data.bodyBytes);
                        dynamic reponse = json.decode(jsonString);
                        if (reponse is List) {
                          final niveau1List = reponse
                              .map((e) => Niveau1Pays.fromMap(e))
                              .where((con) => con.statutN1 == true)
                              .toList();

                          if (niveau1List.isEmpty) {
                            return DropdownButtonFormField(
                              items: [],
                              onChanged: null,
                              decoration: InputDecoration(
                                labelText: 'Aucun donnée trouvé',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            items: niveau1List
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.idNiveau1Pays,
                                    child: Text(e.nomN1!),
                                  ),
                                )
                                .toList(),
                            value: niveau1Value,
                            onChanged: (newValue) {
                              niveau2Value = null;
                              setState(() {
                                if (newValue != null) {
                                  niveau1Pays = niveau1List.firstWhere(
                                    (element) =>
                                        element.idNiveau1Pays == newValue,
                                  );
                                  _niveau2List = http.get(Uri.parse(
                                      '$apiOnlineUrl/niveau2Pays/listeNiveau2PaysByIdNiveau1Pays/${newValue}'));
                                  // Appel de la méthode pour mettre à jour _niveau2List
                                  // updateNiveau2List(newValue);
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Sélectionner un niveau 1',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      }
                      return DropdownButtonFormField(
                        items: [],
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: 'Aucun donnée trouvé',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  FutureBuilder(
                    future: _niveau2List,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return DropdownButtonFormField(
                          items: [],
                          onChanged: null,
                          decoration: InputDecoration(
                            labelText: 'Chargement...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        dynamic jsonString =
                            utf8.decode(snapshot.data.bodyBytes);
                        dynamic reponse = json.decode(jsonString);
                        if (reponse is List) {
                          final niveauList = reponse
                              .map((e) => Niveau2Pays.fromMap(e))
                              // .where((con) => con.statutN2 == true)
                              .toList();

                          if (niveauList.isEmpty) {
                            return DropdownButtonFormField(
                              items: [],
                              onChanged: null,
                              decoration: InputDecoration(
                                labelText: 'Aucun donnée trouvé',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            items: niveauList
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.idNiveau2Pays,
                                    child: Text(e.nomN2),
                                  ),
                                )
                                .toList(),
                            value: niveau2Value,
                            onChanged: (newValue) {
                              setState(() {
                                niveau2Value = newValue;
                                if (newValue != null) {
                                  niveau2 = niveauList.firstWhere((element) =>
                                      element.idNiveau2Pays == newValue);
                                  debugPrint(
                                      "niveau select :${niveau2.toString()}");
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Sélectionner un niveau 2',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      }
                      return DropdownButtonFormField(
                        items: [],
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: 'Aucun donnée trouvé',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final String libelle = libelleController.text;
                      final String description = descriptionController.text;
                      if (formkey.currentState!.validate()) {
                        try {
                          await Niveau3Service()
                              .addNiveau3Pays(
                                  nomN3: libelle,
                                  descriptionN3: description,
                                  niveau2Pays: niveau2)
                              .then((value) => {
                                    Provider.of<Niveau3Service>(context,
                                            listen: false)
                                        .applyChange(),
                                    Navigator.of(context).pop(),
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Text(
                                                "niveau 3 ajouté avec success"),
                                          ],
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    ),
                                    libelleController.clear(),
                                    descriptionController.clear(),
                                    setState(() {
                                      niveau2 == null;
                                      niveau1Pays == null;
                                    }),
                                  });
                        } catch (e) {
                          final String errorMessage = e.toString();
                          print(errorMessage);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Text("Cette niveau 3 existe déjà"),
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
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Ajouter",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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
