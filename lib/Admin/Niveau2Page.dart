import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/Admin/CodePays.dart';
import 'package:koumi/Admin/Niveau2List.dart';
import 'package:koumi/Admin/UpdateNiveau1.dart';
import 'package:koumi/Admin/UpdatesNiveau2.dart';
import 'package:koumi/Admin/niveau3Liste.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:koumi/models/Niveau2Pays.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/ParametreGeneraux.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/Niveau1Service.dart';
import 'package:koumi/service/Niveau2Service.dart';
import 'package:koumi/service/Niveau3Service.dart';
import 'package:koumi/service/PaysService.dart';
import 'package:provider/provider.dart';

class Niveau2Page extends StatefulWidget {
  // final Niveau1Pays niveau1pays;
  const Niveau2Page({super.key});

  @override
  State<Niveau2Page> createState() => _Niveau2PageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _Niveau2PageState extends State<Niveau2Page> {
  // late ParametreGeneraux para;
  late Acteur acteur;
  List<Niveau2Pays> niveauList = [];
  List<Niveau3Pays> niveau3List = [];

  // late Future<List<Niveau2Pays>> _liste;
  List<ParametreGeneraux> paraList = [];

  late TextEditingController _searchController;
 bool isSearchMode = false;

  late ScrollController _scrollController;
  Future<List<Niveau2Pays>> getNiveauListe(String id) async {
    final response = await Niveau2Service().fetchNiveau2ByNiveau1(id);
    return response;
  }

  @override
  void initState() {
    super.initState();
   _searchController = TextEditingController();
    _scrollController = ScrollController();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
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
        backgroundColor: d_colorGreen,
        centerTitle: true,
        toolbarHeight: 75,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: Text(
          "Niveau 2",
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
          //           "Ajouter un niveau 2",
          //           style: TextStyle(
          //               color: Colors.green,
          //               fontWeight: FontWeight.bold,
          //               overflow: TextOverflow.ellipsis),
          //         ),
          //         onTap: () async {
          //           Navigator.of(context).pop();
          //           bottomAddsheet(context);
          //         },
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
      body: Container(
        child: NestedScrollView(
         headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
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
                                      "Ajouter un niveau 2 ",
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
                                bottomAddsheet(context);
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
            child: Column(children: [
              
              Consumer<Niveau2Service>(builder: (context, niveau2Service, child) {
                return FutureBuilder(
                    future: niveau2Service.fetchNiveau2Pays(),
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
                          child: Center(child: Text("Aucun niveau 2 trouvé")),
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
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Niveau3Liste(
                                                          niveau2pays: e)));
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width *
                                              0.9,
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                subtitle: Text(
                                                    e.descriptionN2.trim(),
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w500,
                                                      fontStyle: FontStyle.italic,
                                                    )),
                                              ),
                                              Consumer<Niveau1Service>(builder:
                                                  (context, niveauSer, child) {
                                                return FutureBuilder(
                                                    future: Niveau3Service()
                                                        .fetchNiveau3ByNiveau2(
                                                            e.idNiveau2Pays!),
                                                    builder: (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState.waiting) {
                                                        return const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.orange,
                                                          ),
                                                        );
                                                      }
          
                                                      if (!snapshot.hasData) {
                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 15),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  "Nombres niveau 3 :",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black87,
                                                                    fontSize: 17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                  )),
                                                              Text("0",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black87,
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                  ))
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        niveau3List =
                                                            snapshot.data!;
                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 15),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  "Nombres niveau 3 :",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black87,
                                                                    fontSize: 17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                  )),
                                                              Text(
                                                                  niveau3List.length
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black87,
                                                                    fontSize: 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                  ))
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                    });
                                              }),
                                              Container(
                                                alignment: Alignment.bottomRight,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                                                    color: Colors
                                                                        .green,
                                                                  )
                                                                : Icon(
                                                                    Icons
                                                                        .disabled_visible,
                                                                    color: Colors
                                                                            .orange[
                                                                        400]),
                                                            title: Text(
                                                              e.statutN2 == false
                                                                  ? "Activer"
                                                                  : "Desactiver",
                                                              style: TextStyle(
                                                                color: e.statutN2 ==
                                                                        false
                                                                    ? Colors.green
                                                                    : Colors.orange[
                                                                        400],
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
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<Niveau2Service>(context, listen: false).applyChange(),
                                                                                // setState(
                                                                                //     () {
                                                                                //   _liste = Niveau2Service().fetchNiveau2ByNiveau1(widget
                                                                                //       .niveau1pays
                                                                                //       .idNiveau1Pays!);
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
                                                                  : await Niveau2Service()
                                                                      .desactiverNiveau2Pays(e
                                                                          .idNiveau2Pays!)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<Niveau2Service>(context, listen: false).applyChange(),
                                                                                // setState(
                                                                                //     () {
                                                                                //   _liste = Niveau2Service().fetchNiveau2ByNiveau1(widget
                                                                                //       .niveau1pays
                                                                                //       .idNiveau1Pays!);
                                                                                // }),
                                                                                Navigator.of(context).pop(),
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
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        PopupMenuItem<String>(
                                                          child: ListTile(
                                                            leading: const Icon(
                                                              Icons.edit,
                                                              color: Colors.green,
                                                            ),
                                                            title: const Text(
                                                              "Modifier",
                                                              style: TextStyle(
                                                                color: Colors.green,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                            ),
                                                            onTap: () async {
                                                              Navigator.of(context)
                                                                  .pop();
                                                              bottomUpdatesheet(
                                                                  context, e);
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
                                                                        Navigator.of(
                                                                                context)
                                                                            .pop(),
                                                                      })
                                                                  .catchError(
                                                                      (onError) => {
                                                                            ScaffoldMessenger.of(context)
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
                                      ),
                                    ))
                                .toList());
                      }
                    });
              })
            ]),
          ),
        ),
      ),
    );
  }

  Future<dynamic> bottomUpdatesheet(
      BuildContext context, Niveau2Pays? niveau2pays) async {
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
              child: UpdatesNiveau2(niveau2pays: niveau2pays!)),
        );
      },
    );
  }

  Future<dynamic> bottomAddsheet(BuildContext context) async {
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
              child: addNiveau2()),
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

class addNiveau2 extends StatefulWidget {
  const addNiveau2({super.key});

  @override
  State<addNiveau2> createState() => _addNiveau2State();
}

class _addNiveau2State extends State<addNiveau2> {
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late Pays pays;
  String? paysValue;
  late Future _paysList;
  String? n1Value;
  late Future _niveauList;
  String? id = '';
  late Niveau1Pays niveau1;

  @override
  void initState() {
    super.initState();

    _paysList = http.get(Uri.parse('$apiOnlineUrl/pays/read'));

    _niveauList = http.get(
        Uri.parse('$apiOnlineUrl/niveau1Pays/listeNiveau1PaysByIdPays/${id!}'));
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
                  "Ajouter un niveau 2",
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
                      labelText: "Nom du niveau 2",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder(
                    future: _paysList,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return DropdownButtonFormField(
                          items: [],
                          onChanged: null,
                          decoration: InputDecoration(
                            labelText: 'Chargement ...',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        dynamic jsonString =
                            utf8.decode(snapshot.data.bodyBytes);
                        dynamic responseData = json.decode(jsonString);
                        if (responseData is List) {
                          final reponse = responseData;
                          final paysList = reponse
                              .map((e) => Pays.fromMap(e))
                              .where((con) => con.statutPays == true)
                              .toList();

                          if (paysList.isEmpty) {
                            return DropdownButtonFormField(
                              items: [],
                              onChanged: null,
                              decoration: InputDecoration(
                                labelText: 'Aucun pays trouvé',
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            items: paysList
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.idPays,
                                    child: Text(e.nomPays!),
                                  ),
                                )
                                .toList(),
                            value: paysValue,
                            onChanged: (newValue) {
                              setState(() {
                                n1Value = null;
                                paysValue = newValue;
                                if (newValue != null) {
                                  pays = paysList.firstWhere(
                                      (element) => element.idPays == newValue);
                                  _niveauList = http.get(Uri.parse(
                                      '$apiOnlineUrl/niveau1Pays/listeNiveau1PaysByIdPays/${newValue}'));
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Sélectionner un pays',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        } else {
                          return DropdownButtonFormField(
                            items: [],
                            onChanged: null,
                            decoration: InputDecoration(
                              labelText: 'Aucun pays trouvé',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
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
                          labelText: 'Aucun pays trouvé',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  FutureBuilder(
                    future: _niveauList,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return DropdownButtonFormField(
                          items: [],
                          onChanged: null,
                          decoration: InputDecoration(
                            labelText: 'Chargement ...',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        dynamic jsonString =
                            utf8.decode(snapshot.data.bodyBytes);
                        dynamic responseData = json.decode(jsonString);

                        if (responseData is List) {
                          final reponse = responseData;
                          final niveauList = reponse
                              .map((e) => Niveau1Pays.fromMap(e))
                              .where((con) => con.statutN1 == true)
                              .toList();

                          if (niveauList.isEmpty) {
                            return DropdownButtonFormField(
                              items: [],
                              onChanged: null,
                              decoration: InputDecoration(
                                labelText: 'Aucun niveau 1 trouvé',
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
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
                                    value: e.idNiveau1Pays,
                                    child: Text(e.nomN1!),
                                  ),
                                )
                                .toList(),
                            value: n1Value,
                            onChanged: (newValue) {
                              setState(() {
                                n1Value = newValue;
                                if (newValue != null) {
                                  niveau1 = niveauList.firstWhere((element) =>
                                      element.idNiveau1Pays == newValue);
                                  debugPrint(
                                      "niveau select :${niveau1.toString()}");
                                  // typeSelected = true;
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
                          labelText: 'Aucun niveau 1 trouvé',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
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
                          await Niveau2Service()
                              .addNiveau2Pays(
                                nomN2: libelle,
                                descriptionN2: description,
                                niveau1Pays: niveau1,
                              )
                              .then((value) => {
                                    Provider.of<Niveau2Service>(context,
                                            listen: false)
                                        .applyChange(),
                                    Navigator.of(context).pop(),
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Text(
                                                "niveau 2 ajouté avec success"),
                                          ],
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    ),
                                    libelleController.clear(),
                                    descriptionController.clear(),
                                    setState(() {
                                      niveau1 == null;
                                    }),
                                  });
                        } catch (e) {
                          final String errorMessage = e.toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Text("niveau 2 existe déjà"),
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
