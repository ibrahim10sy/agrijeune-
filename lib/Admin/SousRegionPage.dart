import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/PaysList.dart';
import 'package:koumi/Admin/UpdateSousRegions.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Continent.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/models/SousRegion.dart';
import 'package:koumi/service/ContinentService.dart';
import 'package:koumi/service/PaysService.dart';
import 'package:koumi/service/SousRegionService.dart';
import 'package:provider/provider.dart';

class SousRegionPage extends StatefulWidget {
  // final Continent continent;
  const SousRegionPage({super.key});

  @override
  State<SousRegionPage> createState() => _SousRegionPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _SousRegionPageState extends State<SousRegionPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  late Continent continents;
  String? continentValue;
  List<SousRegion> regionList = [];
  late Future<List<SousRegion>> _liste;
  late Future<List<Pays>> _paysListe;
  late Future _continentList;
  late TextEditingController _searchController;
  List<Pays> paysList = [];
  bool isSearchMode = false;
  late ScrollController _scrollController;

  Future<List<Pays>> getPaysListe(String id) async {
    return await PaysService().fetchPaysBySousRegion(id);
  }

  @override
  void initState() {
    _continentList = http.get(Uri.parse('$apiOnlineUrl/continent/read'));
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
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
          title: const Text(
            "Sous regions",
            style: TextStyle(
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
            //         title: const Text(
            //           "Ajouter une sous région ",
            //           style: TextStyle(
            //               color: Colors.green,
            //               fontWeight: FontWeight.bold,
            //               overflow: TextOverflow.ellipsis),
            //         ),
            //         onTap: () async {
            //           Navigator.of(context).pop();
            //           _showBottomSheet();
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
                                      "Ajouter une sous région ",
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
                                  _showBottomSheet();
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
                Consumer<SousRegionService>(
                  builder: (context, sousService, child) {
                    return FutureBuilder(
                        future: sousService.fetchSousRegion(),
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
                            return const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: Text("Aucun sous region trouvé")),
                            );
                          } else {
                            regionList = snapshot.data!;
                            String searchText = "";
                            List<SousRegion> filtereSearch =
                                regionList.where((search) {
                              String libelle =
                                  search.nomSousRegion.toLowerCase();
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
                                                          PaysList(
                                                              sousRegion: e)));
                                            },
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
                                                      leading: Image.asset(
                                                        "assets/images/sous.png",
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                      title: Text(
                                                          e.nomSousRegion
                                                              .toUpperCase(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
                                                      subtitle: Text(
                                                          e.continent
                                                              .nomContinent
                                                              .trim(),
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ))),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text("Continent :",
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
                                                            e.continent
                                                                .nomContinent,
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
                                                  ),
                                                  FutureBuilder(
                                                      future: PaysService()
                                                          .fetchPaysBySousRegion(
                                                              e.idSousRegion!),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                          );
                                                        }

                                                        if (!snapshot.hasData) {
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombre pays :",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    )),
                                                                Text("0",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ))
                                                              ],
                                                            ),
                                                          );
                                                        } else {
                                                          paysList =
                                                              snapshot.data!;
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombre pays :",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    )),
                                                                Text(
                                                                    paysList
                                                                        .length
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ))
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      }),
                                                  // const Padding(
                                                  //   padding: EdgeInsets.symmetric(
                                                  //       horizontal: 15),
                                                  //   child: Row(
                                                  //     mainAxisAlignment:
                                                  //         MainAxisAlignment
                                                  //             .spaceBetween,
                                                  //     children: [
                                                  //       Text("Nombre pays :",
                                                  //           style: TextStyle(
                                                  //             color: Colors.black87,
                                                  //             fontSize: 17,
                                                  //             fontWeight:
                                                  //                 FontWeight.w500,
                                                  //             fontStyle:
                                                  //                 FontStyle.italic,
                                                  //           )),
                                                  //       Text(_paysListe.,
                                                  //           style: TextStyle(
                                                  //             color: Colors.black87,
                                                  //             fontSize: 18,
                                                  //             fontWeight:
                                                  //                 FontWeight.w800,
                                                  //           ))
                                                  //     ],
                                                  //   ),
                                                  // ),
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
                                                        _buildEtat(
                                                            e.statutSousRegion),
                                                        PopupMenuButton<String>(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          itemBuilder:
                                                              (context) =>
                                                                  <PopupMenuEntry<
                                                                      String>>[
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    e.statutSousRegion ==
                                                                            false
                                                                        ? Icon(
                                                                            Icons.check,
                                                                            color:
                                                                                Colors.green,
                                                                          )
                                                                        : Icon(
                                                                            Icons.disabled_visible,
                                                                            color:
                                                                                Colors.orange[400],
                                                                          ),
                                                                title: Text(
                                                                  e.statutSousRegion ==
                                                                          false
                                                                      ? "Activer"
                                                                      : "Desactiver",
                                                                  style:
                                                                      TextStyle(
                                                                    color: e.statutSousRegion ==
                                                                            false
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .orange[400],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                onTap:
                                                                    () async {
                                                                  e.statutSousRegion ==
                                                                          false
                                                                      ? await SousRegionService()
                                                                          .activerSousRegion(e
                                                                              .idSousRegion!)
                                                                          .then((value) =>
                                                                              {
                                                                                Provider.of<SousRegionService>(context, listen: false).applyChange(),
                                                                                // setState(() {
                                                                                //   _liste = SousRegionService().fetchSousRegionByContinent(continents.idContinent!);
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
                                                                              })
                                                                      : await SousRegionService()
                                                                          .desactiverSousRegion(e
                                                                              .idSousRegion!)
                                                                          .then((value) =>
                                                                              {
                                                                                Provider.of<SousRegionService>(context, listen: false).applyChange(),
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
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons.edit,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                title:
                                                                    const Text(
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
                                                                onTap:
                                                                    () async {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  bottomUpdatesheet(
                                                                      context,
                                                                      e);
                                                                },
                                                              ),
                                                            ),
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                title:
                                                                    const Text(
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
                                                                onTap:
                                                                    () async {
                                                                  await SousRegionService()
                                                                      .deleteSousRegion(e
                                                                          .idSousRegion!)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<SousRegionService>(context, listen: false).applyChange(),
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
                                          ),
                                        ))
                                    .toList());
                          }
                        });
                  },
                ),
              ]),
            ),
          ),
        ));
  }

  Future<dynamic> bottomUpdatesheet(
      BuildContext context, SousRegion? sousRegion) async {
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
              child: updateSousRegions(sousRegion: sousRegion!)),
        );
      },
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ajouter une sous-région",
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
                  SizedBox(height: 10),
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
                            labelText: "Nom de la sous-région",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Consumer<ContinentService>(
                          builder: (context, conService, child) {
                            return FutureBuilder(
                              future: _continentList,
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
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
                                    final continentList = reponse
                                        .map((e) => Continent.fromMap(e))
                                        .where((con) =>
                                            con.statutContinent == true)
                                        .toList();

                                    if (continentList.isEmpty) {
                                      return DropdownButtonFormField(
                                        items: [],
                                        onChanged: null,
                                        decoration: InputDecoration(
                                          labelText: 'Aucun continent trouvé',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                    }

                                    return DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      items: continentList
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.idContinent,
                                              child: Text(e.nomContinent),
                                            ),
                                          )
                                          .toList(),
                                      value: continentValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          continentValue = newValue;
                                          if (newValue != null) {
                                            continents = continentList
                                                .firstWhere((element) =>
                                                    element.idContinent ==
                                                    newValue);
                                            debugPrint(
                                                "con select ${continents.idContinent.toString()}");
                                            // typeSelected = true;
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Sélectionner un continent',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                }
                                return DropdownButtonFormField(
                                  items: [],
                                  onChanged: null,
                                  decoration: InputDecoration(
                                    labelText: 'Aucun continent trouvé',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final String libelle = libelleController.text;
                            if (formkey.currentState!.validate()) {
                              try {
                                await SousRegionService()
                                    .addSousRegion(
                                        nomSousRegion: libelle,
                                        continent: continents)
                                    .then((value) => {
                                          Provider.of<SousRegionService>(
                                                  context,
                                                  listen: false)
                                              .applyChange(),
                                          libelleController.clear(),
                                          setState(() {
                                            continents == null;
                                          }),
                                          Navigator.of(context).pop()
                                        });
                              } catch (e) {
                                final String errorMessage = e.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Text("Une erreur s'est produit"),
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
            ));
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
