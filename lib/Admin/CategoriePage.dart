import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/SpeculationPage.dart';
import 'package:koumi/Admin/UpdatesCategorie.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Filiere.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/CategorieService.dart';
import 'package:koumi/service/FiliereService.dart';
import 'package:koumi/service/SpeculationService.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';

class CategoriPage extends StatefulWidget {
  const CategoriPage({super.key});

  @override
  State<CategoriPage> createState() => _CategoriPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _CategoriPageState extends State<CategoriPage> {
  Future<List<CategorieProduit>> getCatListe(String id) async {
    return await CategorieService().fetchCategorieByFiliere(id);
  }

  List<CategorieProduit> categorieList = [];
  List<Speculation> speculationList = [];
  bool isSearchMode = false;
  bool isFilterMode = false;
  late Acteur acteur;
  final formkey = GlobalKey<FormState>();
  ScrollController scrollableController = ScrollController();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? filiereValue;
  late Future _filiereList;
  late Filiere filiere = Filiere();
  String? catValue;
  late List<CategorieProduit> _categorieProduitList;
  late Future<List<CategorieProduit>> _categorieProduitListe;

  Filiere? selectedType;
  late Future<List<CategorieProduit>> _liste;
  late CategorieProduit categorieProduit;
  late TextEditingController _searchController;

  Future<List<CategorieProduit>> getCat() async {
    return await CategorieService().fetchCategorie();
  }

  Future<List<CategorieProduit>> getAllCatBySearch() async {
    _categorieProduitList = await CategorieService().fetchSearchItems();
    return _categorieProduitList;
  }

  @override
  void initState() {
    super.initState();
    _liste = getCat();
    _categorieProduitListe = getAllCatBySearch();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _filiereList = http.get(Uri.parse('$apiOnlineUrl/Filiere/getAllFiliere/'));
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (isSearchMode) {
      _searchController = TextEditingController();
    } else {
      _searchController.dispose();
    }
    scrollableController.dispose();
    super.dispose();
  }

  void _selectMode(String mode) {
    setState(() {
      if (mode == 'Rechercher') {
        isSearchMode = true;
        isFilterMode = false;
      } else if (mode == 'Filtrer') {
        isSearchMode = false;
        isFilterMode = true;
      } else if (mode == 'Fermer') {
        isSearchMode = false;
        isFilterMode = false;
      }
    });
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
        title: const Text(
          "Catégories de produits",
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
          //           "Ajouter une spéculation",
          //           style: TextStyle(
          //             color: Colors.green,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         onTap: () async {
          //           Navigator.of(context).pop();
          //           afficherBottomSheet(context);

          //         },
          //       ),
          //     ),
          //     PopupMenuItem<String>(
          //       child: ListTile(
          //         leading: Icon(
          //           Icons.add,
          //           color: Colors.orange[400],
          //         ),
          //         title: Text(
          //           "Ajouter catégorie",
          //           style: TextStyle(
          //             color: Colors.orange[400],
          //             fontWeight: FontWeight.bold,
          //           ),
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
                                value: 'add_fil',
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.add,
                                    color: d_colorGreen,
                                  ),
                                  title: const Text(
                                    "Ajouter une spéculation",
                                    style: TextStyle(
                                      color: d_colorGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'add_cat',
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.add,
                                    color: d_colorGreen,
                                  ),
                                  title: const Text(
                                    "Ajouter une catégorie",
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
                              if (value == 'add_fil') {
                                afficherBottomSheet(context);
                              } else if (value == 'add_cat') {
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

                Visibility(
                    visible: isSearchMode,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      child: FutureBuilder(
                        future: _filiereList,
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return buildLoadingDropdown();
                          }

                          if (snapshot.hasData) {
                            dynamic jsonString =
                                utf8.decode(snapshot.data.bodyBytes);
                            dynamic responseData = json.decode(jsonString);

                            if (responseData is List) {
                              final reponse = responseData;
                              final typeList = reponse
                                  .map((e) => Filiere.fromMap(e))
                                  .where((con) => con.statutFiliere == true)
                                  .toList();

                              if (typeList.isEmpty) {
                                return buildEmptyDropdown();
                              }

                              return buildDropdown(typeList);
                            } else {
                              return buildEmptyDropdown();
                            }
                          }

                          return buildEmptyDropdown();
                        },
                      ),
                    )),
                Visibility(
                  visible: isSearchMode,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color:
                                  Colors.blueGrey[400]), // Couleur de l'icône
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
                                    color: Colors.blueGrey[
                                        400]), // Couleur du texte d'aide
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Visibility(
                //     visible: isSearchMode,
                //     child: Padding(
                //       padding:
                //           EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                //       child: FutureBuilder<List<CategorieProduit>>(
                //         future: _categorieProduitListe,
                //         builder: (context, snapshot) {
                //           if (snapshot.connectionState ==
                //               ConnectionState.waiting) {
                //             return SearchFieldAutoComplete<String>(
                //               placeholder: 'Rechercher...',
                //               suggestions: [],
                //             );
                //           } else {
                //             return SearchFieldAutoComplete<String>(
                //               controller: _searchController,
                //               placeholder: 'Rechercher...',
                //               placeholderStyle:
                //                   TextStyle(fontStyle: FontStyle.italic),
                //               suggestions: snapshot.data!
                //                   .map((item) =>
                //                       SearchFieldAutoCompleteItem<String>(
                //                         searchKey: item.libelleCategorie!,
                //                         value: item.libelleCategorie!,
                //                       ))
                //                   .toList(),
                //               suggestionsDecoration: SuggestionDecoration(
                //                 marginSuggestions: const EdgeInsets.all(8.0),
                //                 color: const Color.fromARGB(255, 236, 234, 234),
                //                 borderRadius: BorderRadius.circular(16.0),
                //               ),
                //               onSuggestionSelected: (selectedItem) {
                //                 if (mounted) {
                //                   _searchController.text =
                //                       selectedItem.searchKey;
                //                   print(_searchController.text);
                //                 }
                //               },
                //               suggestionItemBuilder:
                //                   (context, searchFieldItem) {
                //                 return Padding(
                //                   padding: const EdgeInsets.all(8.0),
                //                   child: Text(
                //                     searchFieldItem.searchKey,
                //                     style: TextStyle(color: Colors.black),
                //                   ),
                //                 );
                //               },
                //             );
                //           }
                //         },
                //       ),
                //     )),

                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: ToggleButtons(
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //         child: Text('Rechercher'),
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //         child: Text('Filtrer'),
                //       ),
                //     ],
                //     isSelected: [isSearchMode, !isSearchMode],
                //      onPressed: _updateMode,
                //   ),
                // ),
                // if (isSearchMode)
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 10),
                //     decoration: BoxDecoration(
                //       color: Colors.blueGrey[50], // Couleur d'arrière-plan
                //       borderRadius: BorderRadius.circular(25),
                //     ),
                //     child: Row(
                //       children: [
                //         Icon(Icons.search,
                //             color:
                //                 Colors.blueGrey[400]), // Couleur de l'icône
                //         SizedBox(
                //             width:
                //                 10), // Espacement entre l'icône et le champ de recherche
                //         Expanded(
                //           child: TextField(
                //             controller: _searchController,
                //             onChanged: (value) {
                //               setState(() {});
                //             },
                //             decoration: InputDecoration(
                //               hintText: 'Rechercher',
                //               border: InputBorder.none,
                //               hintStyle: TextStyle(
                //                   color: Colors.blueGrey[
                //                       400]), // Couleur du texte d'aide
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // if (!isSearchMode)
                //   Padding(
                //     padding: const EdgeInsets.symmetric(
                //         vertical: 3, horizontal: 10),
                //     child: FutureBuilder(
                //       future: _filiereList,
                //       builder: (_, snapshot) {
                //         if (snapshot.connectionState ==
                //             ConnectionState.waiting) {
                //           return buildLoadingDropdown();
                //         }

                //         if (snapshot.hasData) {
                //           dynamic jsonString =
                //               utf8.decode(snapshot.data.bodyBytes);
                //           dynamic responseData = json.decode(jsonString);

                //           if (responseData is List) {
                //             final reponse = responseData;
                //             final typeList = reponse
                //                 .map((e) => Filiere.fromMap(e))
                //                 .where((con) => con.statutFiliere == true)
                //                 .toList();

                //             if (typeList.isEmpty) {
                //               return buildEmptyDropdown();
                //             }

                //             return buildDropdown(typeList);
                //           } else {
                //             return buildEmptyDropdown();
                //           }
                //         }

                //         return buildEmptyDropdown();
                //       },
                //     ),
                //   ),
              ])),
            ];
          },
          body: SingleChildScrollView(
            controller: scrollableController,
            child: Column(
              children: [
                Consumer<CategorieService>(
                  builder: (context, categorieService, child) {
                    return FutureBuilder(
                        future: selectedType == null
                            ? categorieService.fetchCategorie()
                            : categorieService.fetchCategorieByFiliere(
                                selectedType!.idFiliere!),
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
                              child: Center(
                                child: Column(
                                  children: [
                                    Image.asset('assets/images/notif.jpg'),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Aucune catégorie touvée ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          overflow: TextOverflow.ellipsis,
                                        ))
                                  ],
                                ),
                              ),
                            );
                          } else {
                            categorieList = snapshot.data!;
                            String searchText = "";
                            List<CategorieProduit> filteredSearch =
                                categorieList.where((cate) {
                              String nomCat =
                                  cate.libelleCategorie!.toLowerCase();
                              searchText = _searchController.text.toLowerCase();
                              return nomCat.contains(searchText);
                            }).toList();

                            return Column(
                                children: filteredSearch.isEmpty
                                    ? [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                    'assets/images/notif.jpg'),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Aucune catégorie trouvé ',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))
                                              ],
                                            ),
                                          ),
                                        )
                                      ]
                                    : filteredSearch
                                        .map((e) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 15),
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
                                                      offset:
                                                          const Offset(0, 2),
                                                      blurRadius: 5,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    SpeculationPage(
                                                                        categorieProduit:
                                                                            e)));
                                                      },
                                                      child: ListTile(
                                                          leading:
                                                              _getIconForFiliere(e
                                                                  .filiere!
                                                                  .libelleFiliere!),
                                                          title: Text(
                                                              e.libelleCategorie!
                                                                  .toUpperCase(),
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                          subtitle: Text(
                                                              e.descriptionCategorie!
                                                                  .trim(),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ))),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text("Filière : ",
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
                                                            e.filiere!
                                                                .libelleFiliere!,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    FutureBuilder(
                                                        future: SpeculationService()
                                                            .fetchSpeculationByCategorie(e
                                                                .idCategorieProduit!),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .orange,
                                                              ),
                                                            );
                                                          }

                                                          if (!snapshot
                                                              .hasData) {
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
                                                                      "Nombre de spéculation:",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontSize:
                                                                            17,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle:
                                                                            FontStyle.italic,
                                                                      )),
                                                                  Text("0",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ))
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            speculationList =
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
                                                                      "Nombres de spéculation",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontSize:
                                                                            17,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle:
                                                                            FontStyle.italic,
                                                                      )),
                                                                  Text(
                                                                      speculationList
                                                                          .length
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black87,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ))
                                                                ],
                                                              ),
                                                            );
                                                          }
                                                        }),
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
                                                          _buildEtat(e
                                                              .statutCategorie!),
                                                          PopupMenuButton<
                                                              String>(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            itemBuilder: (context) =>
                                                                <PopupMenuEntry<
                                                                    String>>[
                                                              PopupMenuItem<
                                                                  String>(
                                                                child: ListTile(
                                                                  leading: e.statutCategorie ==
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
                                                                              Colors.orange[400]),
                                                                  title: Text(
                                                                    e.statutCategorie ==
                                                                            false
                                                                        ? "Activer"
                                                                        : "Desactiver",
                                                                    style:
                                                                        TextStyle(
                                                                      color: e.statutCategorie ==
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
                                                                    e.statutCategorie ==
                                                                            false
                                                                        ? await CategorieService()
                                                                            .activerCategorie(e
                                                                                .idCategorieProduit!)
                                                                            .then((value) =>
                                                                                {
                                                                                  Provider.of<CategorieService>(context, listen: false).applyChange(),
                                                                                  // setState(
                                                                                  //     () {
                                                                                  //   _liste =
                                                                                  //       CategorieService().fetchCategorieByFiliere(filiere.idFiliere!);
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
                                                                        : await CategorieService()
                                                                            .desactiverCategorie(e
                                                                                .idCategorieProduit!)
                                                                            .then((value) =>
                                                                                {
                                                                                  Provider.of<CategorieService>(context, listen: false).applyChange(),
                                                                                  Navigator.of(context).pop(),
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    const SnackBar(
                                                                                      content: Row(
                                                                                        children: [
                                                                                          Text("Désactiver avec succèss "),
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
                                                                                });
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

                                                                    Provider.of<CategorieService>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .applyChange();
                                                                    // setState(() {
                                                                    //   _liste = CategorieService()
                                                                    //       .fetchCategorieByFiliere(
                                                                    //           filiere
                                                                    //               .idFiliere!);
                                                                    // });
                                                                  },
                                                                ),
                                                              ),
                                                              PopupMenuItem<
                                                                  String>(
                                                                child: ListTile(
                                                                  leading:
                                                                      const Icon(
                                                                    Icons
                                                                        .delete,
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
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    await CategorieService()
                                                                        .deleteCategorie(e
                                                                            .idCategorieProduit!)
                                                                        .then((value) =>
                                                                            {
                                                                              Provider.of<CategorieService>(context, listen: false).applyChange(),
                                                                             
                                                                            })
                                                                        .catchError((onError) =>
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Méthode pour afficher la feuille inférieure (bottom sheet)
  void bottomUpdatesheet(
      BuildContext context, CategorieProduit? categorieProduit) {
    showModalBottomSheet(
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
              child: UpdatesCategorie(categorieProduit: categorieProduit!)),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ajouter une catégorie",
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
                            labelText: "Nom de la catégorie",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Consumer<FiliereService>(
                            builder: (context, filiereService, child) {
                          return FutureBuilder(
                            future: _filiereList,
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
                                dynamic jsonString =
                                    utf8.decode(snapshot.data.bodyBytes);
                                dynamic responseData = json.decode(jsonString);

                                if (responseData is List) {
                                  final reponse = responseData;
                                  final filiereList = reponse
                                      .map((e) => Filiere.fromMap(e))
                                      .where((con) => con.statutFiliere == true)
                                      .toList();

                                  if (filiereList.isEmpty) {
                                    return DropdownButtonFormField(
                                      items: [],
                                      onChanged: null,
                                      decoration: InputDecoration(
                                        labelText: 'Aucune filière trouvée',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }

                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    items: filiereList
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.idFiliere,
                                            child: Text(e.libelleFiliere!),
                                          ),
                                        )
                                        .toList(),
                                    value: filiereValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        filiereValue = newValue;
                                        if (newValue != null) {
                                          filiere = filiereList.firstWhere(
                                            (element) =>
                                                element.idFiliere == newValue,
                                          );
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Sélectionnez une filière',
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
                                      labelText: 'Aucune filière trouvée',
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
                                  labelText: 'Aucune filière trouvée',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
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
                            final String description =
                                descriptionController.text;
                            if (formkey.currentState!.validate()) {
                              try {
                                await CategorieService()
                                    .addCategorie(
                                      libelleCategorie: libelle,
                                      descriptionCategorie: description,
                                      filiere: filiere,
                                    )
                                    .then((value) => {
                                          Provider.of<CategorieService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          Navigator.of(context).pop(),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Text(
                                                      "Catégorie ajouté avec succès"),
                                                ],
                                              ),
                                              duration: Duration(seconds: 3),
                                            ),
                                          ),
                                          setState(() {
                                            filiereValue = null;
                                          }),
                                          libelleController.clear(),
                                          descriptionController.clear(),
                                        });
                              } catch (e) {
                                final String errorMessage = e.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Text("Cette catégorie existe déjà"),
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

  Widget _getIconForFiliere(String libelle) {
    switch (libelle.toLowerCase()) {
      case 'céréale':
      case 'céréales':
      case 'cereale':
      case 'cereales':
        return Image.asset(
          "assets/images/cereale.png",
          width: 80,
          height: 80,
        );
      case 'fruits':
      case 'fruit':
        return Image.asset(
          "assets/images/fruits.png",
          width: 80,
          height: 80,
        );
      case 'bétails':
      case 'bétail':
      case 'betails':
      case 'betail':
      case 'animale':
        return Image.asset(
          "assets/images/betail.png",
          width: 80,
          height: 80,
        );
      case 'légumes':
      case 'légume':
      case 'legumes':
      case 'legume':
      case 'végétale':
        return Image.asset(
          "assets/images/legumes.png",
          width: 80,
          height: 80,
        );
      default:
        return Image.asset(
          "assets/images/default.png",
          width: 80,
          height: 80,
        );
    }
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

  DropdownButtonFormField<String> buildDropdown(List<Filiere> typeList) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      items: typeList
          .map((e) => DropdownMenuItem(
                value: e.idFiliere,
                child: Text(e.libelleFiliere!),
              ))
          .toList(),
      hint: Text("-- Filtre par filière --"),
      value: filiereValue,
      onChanged: (newValue) {
        setState(() {
          filiereValue = newValue;
          if (newValue != null) {
            selectedType = typeList.firstWhere(
              (element) => element.idFiliere == newValue,
            );
          }
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }

  DropdownButtonFormField buildEmptyDropdown() {
    return DropdownButtonFormField(
      items: [],
      onChanged: null,
      decoration: InputDecoration(
        labelText: '-- Aucune filière trouvé --',
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }

  DropdownButtonFormField buildLoadingDropdown() {
    return DropdownButtonFormField(
      items: [],
      onChanged: null,
      decoration: InputDecoration(
        labelText: 'Chargement...',
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }

  void afficherBottomSheet(BuildContext context) {
    showModalBottomSheet(
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
            child: AddSpeculations(),
          ),
        );
      },
    );
  }
}

class AddSpeculations extends StatefulWidget {
  const AddSpeculations({super.key});

  @override
  State<AddSpeculations> createState() => _AddSpeculationsState();
}

class _AddSpeculationsState extends State<AddSpeculations> {
  late Future _categorieList;
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  String? filiereValue;
  String? catValue;
  late Future _filiereList;
  late Filiere filiere = Filiere();
  late CategorieProduit categorie;
  String? id = "";
  late Acteur acteur;

  @override
  void initState() {
    super.initState();

    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _filiereList = http.get(Uri.parse('$apiOnlineUrl/Filiere/getAllFiliere/'));

    _categorieList = http.get(Uri.parse(
        '$apiOnlineUrl/Categorie/allCategorieByFiliere/${filiere.idFiliere}'));
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
                  "Ajouter une spéculation",
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
                      labelText: "Nom de la speculation",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder(
                    future: _filiereList,
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
                        dynamic responseData = json.decode(jsonString);

                        // Vérifier si responseData est une liste
                        if (responseData is List) {
                          final reponse = responseData;
                          final filiereList = reponse
                              .map((e) => Filiere.fromMap(e))
                              .where((con) => con.statutFiliere == true)
                              .toList();

                          if (filiereList.isEmpty) {
                            return DropdownButtonFormField(
                              items: [],
                              onChanged: null,
                              decoration: InputDecoration(
                                labelText: 'Aucun filière trouvé',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            items: filiereList
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.idFiliere,
                                    child: Text(e.libelleFiliere!),
                                  ),
                                )
                                .toList(),
                            value: filiereValue,
                            onChanged: (newValue) {
                              setState(() {
                                catValue = null;
                                filiereValue = newValue;
                                if (newValue != null) {
                                  filiere = filiereList.firstWhere(
                                    (element) => element.idFiliere == newValue,
                                  );
                                  debugPrint("valeur : $newValue");
                                  _categorieList = http.get(Uri.parse(
                                      '$apiOnlineUrl/Categorie/allCategorieByFiliere/${newValue}'));
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Choisir une filière",
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
                              labelText: 'Aucun filière trouvé',
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
                          labelText: 'Aucun filière trouvé',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  FutureBuilder(
                    future: _categorieList,
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
                        dynamic responseData = json.decode(jsonString);

                        // Vérifier si responseData est une liste
                        if (responseData is List) {
                          final reponse = responseData;
                          final catList = reponse
                              .map((e) => CategorieProduit.fromMap(e))
                              .where((con) => con.statutCategorie == true)
                              .toList();

                          if (catList.isEmpty) {
                            return DropdownButtonFormField(
                              items: [],
                              onChanged: null,
                              decoration: InputDecoration(
                                labelText: 'Aucune categorie trouvé',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            items: catList
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.idCategorieProduit,
                                    child: Text(e.libelleCategorie!),
                                  ),
                                )
                                .toList(),
                            value: catValue,
                            onChanged: (newValue) {
                              setState(() {
                                catValue = newValue;
                                if (newValue != null) {
                                  categorie = catList.firstWhere(
                                    (element) =>
                                        element.idCategorieProduit == newValue,
                                  );
                                  debugPrint("cat valeur : $categorie");
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Selectionner une catégorie',
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
                              labelText: 'Aucune catégorie trouvé',
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
                          labelText: 'Aucune catégorie trouvé',
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
                          await SpeculationService()
                              .addSpeculation(
                                nomSpeculation: libelle,
                                descriptionSpeculation: description,
                                categorieProduit: categorie,
                              )
                              .then((value) => {
                                    Provider.of<SpeculationService>(context,
                                            listen: false)
                                        .applyChange(),
                                    libelleController.clear(),
                                    descriptionController.clear(),
                                    Navigator.of(context).pop(),
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Text(
                                                "Spéculation ajouter avec success"),
                                          ],
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    )
                                  });
                        } catch (e) {
                          final String errorMessage = e.toString();
                          print(errorMessage);
                          Navigator.of(context).pop();
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
