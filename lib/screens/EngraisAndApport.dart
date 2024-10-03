import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Intrant.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddIntrant.dart';
import 'package:koumi/screens/DetailIntrant.dart';
import 'package:koumi/screens/ListeIntrantByActeur.dart';
import 'package:koumi/service/IntrantService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class EngraisAndApport extends StatefulWidget {
  EngraisAndApport({super.key});

  @override
  State<EngraisAndApport> createState() => _EngraisAndApportState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _EngraisAndApportState extends State<EngraisAndApport> {
  int page = 0;
  bool isLoading = false;
  late TextEditingController _searchController;
  ScrollController scrollableController = ScrollController();
  int size = sized;
  bool hasMore = true;
  bool isExist = false;
  late Acteur acteur = Acteur();
  String? email = "";
  String? detectedCountry;
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late Future<List<Intrant>> intrantListeFuture;
  late Future<List<Intrant>> intrantListeFuture1;
  List<Intrant> intrantListe = [];
  List<Intrant> intrantList = [];
  String? nomP;
  late Future _paysList;
  ScrollController scrollableController1 = ScrollController();
  String libelle = "Engrais et apports";
  String? catValue;
  late Future _typeList;
  bool isSearchMode = false;
  bool isFilterMode = false;
  CategorieProduit? selectedCat;

  void _scrollListener() {
    debugPrint("Scroll position: ${scrollableController.position.pixels}");
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading) {
      setState(() {
        page++;
      });

      fetchIntrantByCategorie(
              // detectedCountry != null ? detectedCountry! : "Mali"
              )
          .then((value) {
        setState(() {
          debugPrint("page inc all $page");
        });
      });
    }
    debugPrint("no");
  }

  void _scrollListener1() {
    if (scrollableController1.position.pixels >=
            scrollableController1.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedCat != null) {
      // if (selectedCat != null) {
      // Incrementez la page et récupérez les stocks par catégorie
      debugPrint("yes - fetch by category and pays");
      if (mounted)
        setState(() {
          // Rafraîchir les données ici
          page++;
        });

      fetchIntrantByCategorieAndFiliere(
              detectedCountry != null ? detectedCountry! : "Mali")
          .then((value) {
        setState(() {
          // Rafraîchir les données ici
          debugPrint("page inc all ${page}");
        });
      });
    } else if (nomP != null && nomP!.isNotEmpty) {
      debugPrint("yes - fetch by country");
      if (mounted)
        setState(() {
          page++;
        });

      fetchAllIntrantByPays().then((value) {
        setState(() {
          debugPrint("page pour pays ${nomP} inc all ${page}");
        });
      });
    }
    debugPrint("no");
  }

  Future<List<Intrant>> fetchAllIntrantByPays({bool refresh = false}) async {
    if (isLoading) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        intrantListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleAndPays?libelle=${libelle}&nomPays=$nomP&page=$page&size=$size'));
      debugPrint(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleAndPays?libelle=${libelle}&nomPays=$nomP&page=$page&size=$size');
      if (response.statusCode == 200) {
        print("pays end point $nomP");
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Intrant> newIntrants =
              body.map((e) => Intrant.fromMap(e)).toList();

          setState(() {
            // Ajouter uniquement les nouveaux intrants qui ne sont pas déjà dans la liste
            intrantListe.addAll(newIntrants.where((newIntrant) =>
                !intrantListe.any((existingIntrant) =>
                    existingIntrant.idIntrant == newIntrant.idIntrant)));
          });
        }

        debugPrint(
            "response body all intrant by pays with pagination $page par défilement soit ${intrantListe.length}");
        return intrantListe;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des intrants: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return intrantListe;
  }

  Future<List<Intrant>> fetchIntrantByCategorieAndFiliere(String pays,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        intrantListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      // for (String libelle in libelles) {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleFiliereAndIcategorie?idCategorie=${selectedCat!.idCategorieProduit}&libelle=$libelle&pays=$pays&page=$page&size=$size'));
      debugPrint(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleFiliereAndIcategorie?idCategorie=${selectedCat!.idCategorieProduit}&libelle=$libelle&pays=$pays&page=$page&size=$size');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Intrant> newIntrants =
              body.map((e) => Intrant.fromMap(e)).toList();

          setState(() {
            // Ajouter uniquement les nouveaux intrants qui ne sont pas déjà dans la liste
            intrantListe.addAll(newIntrants.where((newIntrant) =>
                !intrantListe.any((existingIntrant) =>
                    existingIntrant.idIntrant == newIntrant.idIntrant)));
          });
        }

        debugPrint(
            "response body all intrants by categorie with pagination ${page} par défilement soit ${intrantListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des intrants: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return intrantListe;
  }

  Future<List<Intrant>> getAllIntrant() async {
    if (selectedCat != null) {
      intrantListe = await IntrantService().fetchIntrantByCategorieAndFilieres(
          selectedCat!.idCategorieProduit!,
          libelle,
          detectedCountry != null ? detectedCountry! : "Mali");
    } else if (nomP != null && nomP!.isNotEmpty) {
      intrantListe =
          await IntrantService().fetchAllByPaysAndFiliere(libelle, nomP!);
    }
    return intrantListe;
  }

  Future<List<Intrant>> fetchIntrantByCategorie({bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        intrantListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      // for (String libelle in libelles) {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleCategorie?libelle=$libelle&page=$page&size=$size'));
      debugPrint(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleCategorie?libelle=$libelle&page=$page&size=$size');
      //     '$apiOnlineUrl/intrant/listeIntrantByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size'));
      // debugPrint(
      //     '$apiOnlineUrl/intrant/listeIntrantByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Intrant> newIntrants =
              body.map((e) => Intrant.fromMap(e)).toList();

          setState(() {
            // Ajouter uniquement les nouveaux intrants qui ne sont pas déjà dans la liste
            intrantListe.addAll(newIntrants.where((newIntrant) =>
                !intrantListe.any((existingIntrant) =>
                    existingIntrant.idIntrant == newIntrant.idIntrant)));
          });
        }

        debugPrint(
            "response body all intrants by categorie with pagination ${page} par défilement soit ${intrantListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des intrants: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return intrantListe;
  }

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur.typeActeur!;
      type = typeActeurData.map((data) => data.libelle).join(', ');
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final paysProvider = Provider.of<DetectorPays>(context, listen: false);
    paysProvider.hasLocation
        ? detectedCountry =
            Provider.of<DetectorPays>(context, listen: false).detectedCountry!
        : detectedCountry = "Mali";

    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController1.addListener(_scrollListener1);
    });
    _paysList = http.get(Uri.parse('$apiOnlineUrl/pays/read'));
    _typeList = http.get(Uri.parse(
        '$apiOnlineUrl/Categorie/allCategorieByLibelleFiliere/$libelle'));
    intrantListeFuture1 = getAllIntrant();
    verify();
    intrantListeFuture = fetchIntrantByCategorie(
        // detectedCountry != null ? detectedCountry! : "Mali"
        );
  }

  Future<void> _getResultFromNextScreen1(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddIntrant()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        intrantListeFuture = IntrantService().fetchIntrantByPays(
            // detectedCountry != null ? detectedCountry! : "Mali"
            );
      });
    }
  }

  Future<void> _getResultFromNextScreen2(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListeIntrantByActeur(
                  isRoute: true,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        intrantListeFuture = IntrantService().fetchIntrantByPays(
            // detectedCountry != null ? detectedCountry! : "Mali"
            );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollableController.dispose();
    scrollableController1.dispose();
    super.dispose();
  }

  void _updateMode(int index) {
    if (mounted) {
      setState(() {
        isSearchMode = index == 0;
        if (!isSearchMode) {
          _searchController.clear();
          _searchController.dispose();
          _searchController = TextEditingController();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
            backgroundColor: d_colorOr,
            centerTitle: true,
            toolbarHeight: 75,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                )),
            title: const Text(
              "Engrais et apports ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions:
                //  !isExist
                //     ?
                [
              IconButton(
                  onPressed: () {
                    intrantListeFuture = fetchIntrantByCategorie(
                        // detectedCountry != null ? detectedCountry! : "Mali"
                        );
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  )),
            ]
          
            ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
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
                                isExist
                                    ? (typeActeurData
                                                .map((e) =>
                                                    e.libelle!.toLowerCase())
                                                .contains("fournisseur") ||
                                            typeActeurData
                                                .map((e) =>
                                                    e.libelle!.toLowerCase())
                                                .contains("admin") ||
                                            typeActeurData
                                                .map((e) =>
                                                    e.libelle!.toLowerCase())
                                                .contains("fournisseurs"))
                                        ? TextButton(
                                            onPressed: () {
                                              // The PopupMenuButton is used here to display the menu when the button is pressed.
                                              showMenu<String>(
                                                context: context,
                                                position: RelativeRect.fromLTRB(
                                                  0,
                                                  50, // Adjust this value based on the desired position of the menu
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  0,
                                                ),
                                                items: [
                                                  PopupMenuItem<String>(
                                                    value: 'add_intrant',
                                                    child: ListTile(
                                                      leading: const Icon(
                                                        Icons.add,
                                                        color: d_colorGreen,
                                                      ),
                                                      title: const Text(
                                                        "Ajouter un intrant",
                                                        style: TextStyle(
                                                          color: d_colorGreen,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // PopupMenuItem<String>(
                                                  //   value: 'mesIntrant',
                                                  //   child: ListTile(
                                                  //     leading: const Icon(
                                                  //       Icons.remove_red_eye,
                                                  //       color: d_colorGreen,
                                                  //     ),
                                                  //     title: const Text(
                                                  //       "Mes intrants",
                                                  //       style: TextStyle(
                                                  //         color: d_colorGreen,
                                                  //         fontWeight:
                                                  //             FontWeight.bold,
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                ],
                                                elevation: 8.0,
                                              ).then((value) {
                                                if (value != null) {
                                                  if (value == 'add_intrant') {
                                                    _getResultFromNextScreen1(
                                                        context);
                                                  } else if (value ==
                                                      'mesIntrant') {
                                                    _getResultFromNextScreen2(
                                                        context);
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
                                                SizedBox(
                                                    width:
                                                        8), // Space between icon and text
                                                Text(
                                                  'Ajouter',
                                                  style: TextStyle(
                                                    color: d_colorGreen,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container()
                                    : Container(),
                                if (!isSearchMode)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        isSearchMode = true;
                                        isFilterMode = true;
                                      });
                                      debugPrint(
                                          "rechercher mode value : ${isSearchMode}");
                                    },
                                    icon: Icon(
                                      Icons.search,
                                      color: d_colorGreen,
                                    ),
                                    label: Text(
                                      'Rechercher...',
                                      style: TextStyle(
                                          color: d_colorGreen, fontSize: 17),
                                    ),
                                  ),
                                if (isSearchMode)
                                  TextButton.icon(
                                    onPressed: () {
                                      if (mounted) {
                                        setState(() {
                                          isSearchMode = false;
                                          isFilterMode = false;
                                          _searchController.clear();
                                          _searchController =
                                              TextEditingController();
                                          nomP =
                                              null; // Réinitialiser le pays sélectionné
                                          selectedCat =
                                              null; // Réinitialiser la catégorie sélectionnée
                                          intrantListeFuture =
                                              fetchIntrantByCategorie(
                                                  // detectedCountry != null
                                                  //     ? detectedCountry!
                                                  //     : "Mali"
                                                  ); // Recharger les stocks
                                        });
                                        debugPrint(
                                            "Rechercher mode désactivé : $isSearchMode");
                                      }
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    label: Text(
                                      'Fermer',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 17),
                                    ),
                                  )
                              ]),
                        ),
                        Visibility(
                          visible: isSearchMode,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FutureBuilder(
                                    future: _paysList,
                                    builder: (_, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return TextDropdownFormField(
                                          options: [],
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 0),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                              ),
                                              suffixIcon:
                                                  Icon(Icons.search, size: 19),
                                              labelText: "Chargement..."),
                                          cursorColor: Colors.green,
                                        );
                                      }

                                      if (snapshot.hasData) {
                                        dynamic jsonString = utf8
                                            .decode(snapshot.data.bodyBytes);
                                        dynamic responseData =
                                            json.decode(jsonString);

                                        if (responseData is List) {
                                          final paysList = responseData
                                              .map((e) => Pays.fromMap(e))
                                              .where((con) =>
                                                  con.statutPays == true)
                                              .toList();
                                          if (paysList.isEmpty) {
                                            return TextDropdownFormField(
                                              options: [],
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10,
                                                          horizontal: 0),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  suffixIcon: Icon(Icons.search,
                                                      size: 19),
                                                  labelText:
                                                      "  Aucun pays trouvé"),
                                              cursorColor: Colors.green,
                                            );
                                          }

                                          return DropdownFormField<Pays>(
                                            onEmptyActionPressed:
                                                (String str) async {},
                                            dropdownHeight: 200,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 0),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                ),
                                                suffixIcon: Icon(Icons.search,
                                                    size: 19),
                                                labelText:
                                                    "  Filtrer par pays"),
                                            onSaved: (dynamic pays) {
                                              print("onSaved : $nomP");
                                            },
                                            onChanged: (dynamic pays) {
                                              nomP = pays?.nomPays;
                                              setState(() {
                                                nomP = pays?.nomPays;
                                                page = 0;
                                                hasMore = true;
                                                fetchAllIntrantByPays(
                                                    refresh: true);
                                                if (page == 0 &&
                                                    isLoading == true) {
                                                  SchedulerBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    scrollableController1
                                                        .jumpTo(0.0);
                                                  });
                                                }
                                              });
                                              print("selected : $nomP");
                                            },
                                            displayItemFn: (dynamic item) =>
                                                Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: Text(
                                                item?.nomPays ?? '',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            findFn: (String str) async =>
                                                paysList,
                                            selectedFn:
                                                (dynamic item1, dynamic item2) {
                                              if (item1 != null &&
                                                  item2 != null) {
                                                return item1.idPays ==
                                                    item2.idPays;
                                              }
                                              return false;
                                            },
                                            filterFn:
                                                (dynamic item, String str) =>
                                                    item.nomPays!
                                                        .toLowerCase()
                                                        .contains(
                                                            str.toLowerCase()),
                                            dropdownItemFn: (dynamic item,
                                                    int position,
                                                    bool focused,
                                                    bool selected,
                                                    Function() onTap) =>
                                                ListTile(
                                              title: Text(item.nomPays!),
                                              tileColor: focused
                                                  ? Color.fromARGB(20, 0, 0, 0)
                                                  : Colors.transparent,
                                              onTap: onTap,
                                            ),
                                          );
                                        }
                                      }
                                      return TextDropdownFormField(
                                        options: [],
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 0),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            suffixIcon:
                                                Icon(Icons.search, size: 19),
                                            labelText: " Aucun pays trouvé"),
                                        cursorColor: Colors.green,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: FutureBuilder(
                                    future: _typeList,
                                    builder: (_, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return TextDropdownFormField(
                                          options: [],
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 0),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                              ),
                                              suffixIcon:
                                                  Icon(Icons.search, size: 19),
                                              labelText: "Chargement..."),
                                          cursorColor: Colors.green,
                                        );
                                      }

                                      if (snapshot.hasData) {
                                        dynamic jsonString = utf8
                                            .decode(snapshot.data.bodyBytes);
                                        dynamic responseData =
                                            json.decode(jsonString);

                                        if (responseData is List) {
                                          final paysList = responseData
                                              .map((e) =>
                                                  CategorieProduit.fromMap(e))
                                              .where((con) =>
                                                  con.statutCategorie == true)
                                              .toList();
                                          if (paysList.isEmpty) {
                                            return TextDropdownFormField(
                                              options: [],
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10,
                                                          horizontal: 0),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  suffixIcon: Icon(Icons.search,
                                                      size: 19),
                                                  labelText:
                                                      " Aucune catégorie trouvé"),
                                              cursorColor: Colors.green,
                                            );
                                          }

                                          return DropdownFormField<
                                              CategorieProduit>(
                                            onEmptyActionPressed:
                                                (String str) async {},
                                            dropdownHeight: 200,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                ),
                                                suffixIcon: Icon(Icons.search,
                                                    size: 19),
                                                labelText:
                                                    "Filtrer par catégorie"),
                                            onSaved: (dynamic cat) {
                                              selectedCat = cat;
                                              print("onSaved : $cat");
                                            },
                                            onChanged: (dynamic cat) {
                                              setState(() {
                                                selectedCat = cat;
                                                page = 0;
                                                hasMore = true;
                                                fetchIntrantByCategorieAndFiliere(
                                                    detectedCountry != null
                                                        ? detectedCountry!
                                                        : "Mali",
                                                    refresh: true);
                                                if (page == 0 &&
                                                    isLoading == true) {
                                                  SchedulerBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    scrollableController1
                                                        .jumpTo(0.0);
                                                  });
                                                }
                                              });
                                            },
                                            displayItemFn: (dynamic item) =>
                                                Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 0),
                                              child: Text(
                                                item?.libelleCategorie ?? '',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            findFn: (String str) async =>
                                                paysList,
                                            selectedFn:
                                                (dynamic item1, dynamic item2) {
                                              if (item1 != null &&
                                                  item2 != null) {
                                                return item1
                                                        .idCategorieProduit ==
                                                    item2.idCategorieProduit;
                                              }
                                              return false;
                                            },
                                            filterFn:
                                                (dynamic item, String str) =>
                                                    item.libelleCategorie!
                                                        .toLowerCase()
                                                        .contains(
                                                            str.toLowerCase()),
                                            dropdownItemFn: (dynamic item,
                                                    int position,
                                                    bool focused,
                                                    bool selected,
                                                    Function() onTap) =>
                                                ListTile(
                                              title:
                                                  Text(item.libelleCategorie!),
                                              tileColor: focused
                                                  ? Color.fromARGB(20, 0, 0, 0)
                                                  : Colors.transparent,
                                              onTap: onTap,
                                            ),
                                          );
                                        }
                                      }
                                      return TextDropdownFormField(
                                        options: [],
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 0),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            suffixIcon:
                                                Icon(Icons.search, size: 19),
                                            labelText:
                                                "Aucune catégorie trouvé"),
                                        cursorColor: Colors.green,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isSearchMode,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            child: SearchFieldAutoComplete<String>(
                              controller: _searchController,
                              placeholder: 'Rechercher un produit ...',
                              placeholderStyle:
                                  TextStyle(fontStyle: FontStyle.italic),
                              suggestions: AutoComplet.getAgriculturalInputs,
                              suggestionsDecoration: SuggestionDecoration(
                                marginSuggestions: const EdgeInsets.all(8.0),
                                color: const Color.fromARGB(255, 236, 234, 234),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              onSuggestionSelected: (selectedItem) {
                                if (mounted) {
                                  _searchController.text =
                                      selectedItem.searchKey;
                                }
                              },
                              suggestionItemBuilder:
                                  (context, searchFieldItem) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    searchFieldItem.searchKey,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ])),
                    ];
                  },
                  body: RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          page = 0;
                          // Rafraîchir les données ici
                        });
                        debugPrint("refresh page ${page}");
                        selectedCat != null || nomP != null
                            ? setState(() {
                                nomP == null
                                    ? intrantListeFuture1 = IntrantService()
                                        .fetchIntrantByCategorieAndFilieres(
                                            selectedCat!.idCategorieProduit!,
                                            libelle,
                                            detectedCountry != null
                                                ? detectedCountry!
                                                : "Mali")
                                    : intrantListeFuture1 = IntrantService()
                                        .fetchAllByPaysAndFiliere(
                                            libelle, nomP!);
                              })
                            : setState(() {
                                intrantListeFuture = fetchIntrantByCategorie(
                                    // detectedCountry != null
                                    //     ? detectedCountry!
                                    //     : "Mali"
                                    );
                              });
                        debugPrint("refresh page ${page}");
                      },
                      child: selectedCat == null && nomP == null
                          ? SingleChildScrollView(
                              controller: scrollableController,
                              child: Consumer<IntrantService>(
                                  builder: (context, intrantService, child) {
                                return FutureBuilder(
                                    future: intrantListeFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return _buildShimmerEffect();
                                      }

                                      if (!snapshot.hasData) {
                                        return const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                              child:
                                                  Text("Aucun donné trouvé")),
                                        );
                                      } else {
                                        intrantList = snapshot.data!;
                                        String searchText = "";

                                        List<Intrant> produitsLocaux =
                                            intrantList
                                                .where(
                                          (element) =>
                                              element
                                                  .acteur!.niveau3PaysActeur! ==
                                              detectedCountry!,
                                        )
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Intrant> produitsEtrangers =
                                            intrantList
                                                .where(
                                          (element) =>
                                              element
                                                  .acteur!.niveau3PaysActeur! !=
                                              detectedCountry,
                                        )
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Intrant> filteredSearch =
                                            intrantList.where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();
                                        return filteredSearch.isEmpty &&
                                                isLoading == false
                                            ? SingleChildScrollView(
                                                child:  Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        Image.asset(
                                                            'assets/images/notif.jpg'),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      const  Text(
                                                          'Aucun produit trouvé',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 17,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                children: [
                                                  if (produitsLocaux
                                                      .isNotEmpty) ...[
                                                    GridView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        mainAxisSpacing: 5,
                                                        crossAxisSpacing: 5,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsLocaux.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index <
                                                            produitsLocaux
                                                                .length) {
                                                          return  GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DetailIntrant(
                                                                    intrant:
                                                                        produitsLocaux[
                                                                            index],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Card(
                                                              margin: EdgeInsets
                                                                  .all(8),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          85,
                                                                      child: produitsLocaux[index].photoIntrant == null ||
                                                                              produitsLocaux[index].photoIntrant!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/intrant/${produitsLocaux[index].idIntrant}/image",
                                                                              fit: BoxFit.cover,
                                                                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                'assets/images/default_image.png',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  // SizedBox(height: 8),
                                                                  ListTile(
                                                                    title:  Text(
                                                                      produitsLocaux[
                                                                              index]
                                                                          .nomIntrant!,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      "${produitsLocaux[index].quantiteIntrant.toString()} ${produitsLocaux[index].unite}",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            15),
                                                                    child: Text(
                                                                      produitsLocaux[index].monnaie !=
                                                                              null
                                                                          ? "${produitsLocaux[index].prixIntrant.toString()} ${produitsLocaux[index].monnaie!.libelle}"
                                                                          : "${produitsLocaux[index].prixIntrant.toString()} FCFA ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          32),
                                                                  child: Center(
                                                                      child:
                                                                          const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: Colors
                                                                          .orange,
                                                                    ),
                                                                  )),
                                                                )
                                                              : Container();
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                  // Section des produits étrangers
                                                  if (produitsEtrangers
                                                      .isNotEmpty) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Produits autre pays",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                    GridView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        mainAxisSpacing: 5,
                                                        crossAxisSpacing: 5,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsEtrangers
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index <
                                                            produitsEtrangers
                                                                .length) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DetailIntrant(
                                                                    intrant:
                                                                        produitsEtrangers[
                                                                            index],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Card(
                                                              margin: EdgeInsets
                                                                  .all(8),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          85,
                                                                      child: produitsEtrangers[index].photoIntrant == null ||
                                                                              produitsEtrangers[index].photoIntrant!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/intrant/${produitsEtrangers[index].idIntrant}/image",
                                                                              fit: BoxFit.cover,
                                                                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                'assets/images/default_image.png',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  // SizedBox(height: 8),
                                                                  ListTile(
                                                                    title: Text(
                                                                      produitsEtrangers[
                                                                              index]
                                                                          .nomIntrant!,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      "${produitsEtrangers[index].quantiteIntrant.toString()} ${produitsEtrangers[index].unite}",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            15),
                                                                    child: Text(
                                                                      produitsEtrangers[index].monnaie !=
                                                                              null
                                                                          ? "${produitsEtrangers[index].prixIntrant.toString()} ${produitsEtrangers[index].monnaie!.libelle}"
                                                                          : "${produitsEtrangers[index].prixIntrant.toString()} FCFA ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          32),
                                                                  child: Center(
                                                                      child:
                                                                          const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: Colors
                                                                          .orange,
                                                                    ),
                                                                  )),
                                                                )
                                                              : Container();
                                                        }
                                                      },
                                                    ),
                                                  ]
                                                ],
                                              );
                                      }
                                    });
                              }),
                            )
                          : SingleChildScrollView(
                              controller: scrollableController1,
                              child: Consumer<IntrantService>(
                                  builder: (context, intrantService, child) {
                                return FutureBuilder(
                                    future: intrantListeFuture1,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return _buildShimmerEffect();
                                      }

                                      if (!snapshot.hasData) {
                                        return const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                              child:
                                                  Text("Aucun donné trouvé")),
                                        );
                                      } else {
                                        intrantList = snapshot.data!;
                                        String searchText = "";

                                        List<Intrant> produitsLocaux =
                                            intrantList
                                                .where(
                                          (element) =>
                                              element
                                                  .acteur!.niveau3PaysActeur! ==
                                              detectedCountry!,
                                        )
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Intrant> produitsEtrangers =
                                            intrantList
                                                .where(
                                          (element) =>
                                              element
                                                  .acteur!.niveau3PaysActeur! !=
                                              detectedCountry,
                                        )
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Intrant> filteredSearch =
                                            intrantList.where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();
                                        return filteredSearch
                                                    // .where((element) => element.statutIntrant == true)
                                                    .isEmpty &&
                                                isLoading == false
                                            ? SingleChildScrollView(
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        Image.asset(
                                                            'assets/images/notif.jpg'),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          'Aucun produit trouvé',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 17,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                children: [
                                                  if (produitsLocaux
                                                      .isNotEmpty) ...[
                                                    // Padding(
                                                    //   padding:
                                                    //       const EdgeInsets.all(
                                                    //           8.0),
                                                    //   child: Text(
                                                    //     "Produits locaux",
                                                    //     style: TextStyle(
                                                    //         fontWeight:
                                                    //             FontWeight.bold,
                                                    //         color: d_colorGreen,
                                                    //         fontSize: 16),
                                                    //   ),
                                                    // ),
                                                    GridView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        mainAxisSpacing: 5,
                                                        crossAxisSpacing: 5,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsLocaux.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index <
                                                            produitsLocaux
                                                                .length) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DetailIntrant(
                                                                    intrant:
                                                                        produitsLocaux[
                                                                            index],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Card(
                                                              margin: EdgeInsets
                                                                  .all(8),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          85,
                                                                      child: produitsLocaux[index].photoIntrant == null ||
                                                                              produitsLocaux[index].photoIntrant!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/intrant/${produitsLocaux[index].idIntrant}/image",
                                                                              fit: BoxFit.cover,
                                                                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                'assets/images/default_image.png',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  // SizedBox(height: 8),
                                                                  ListTile(
                                                                    title: Text(
                                                                      produitsLocaux[
                                                                              index]
                                                                          .nomIntrant!,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      "${produitsLocaux[index].quantiteIntrant.toString()} ${produitsLocaux[index].unite}",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            15),
                                                                    child: Text(
                                                                      produitsLocaux[index].monnaie !=
                                                                              null
                                                                          ? "${produitsLocaux[index].prixIntrant.toString()} ${produitsLocaux[index].monnaie!.libelle}"
                                                                          : "${produitsLocaux[index].prixIntrant.toString()} FCFA ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          32),
                                                                  child: Center(
                                                                      child:
                                                                          const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: Colors
                                                                          .orange,
                                                                    ),
                                                                  )),
                                                                )
                                                              : Container();
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                  // Section des produits étrangers
                                                  if (produitsEtrangers
                                                      .isNotEmpty) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Produits autre pays",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                    GridView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        mainAxisSpacing: 5,
                                                        crossAxisSpacing: 5,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsEtrangers
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index <
                                                            produitsEtrangers
                                                                .length) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DetailIntrant(
                                                                    intrant:
                                                                        produitsEtrangers[
                                                                            index],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Card(
                                                              margin: EdgeInsets
                                                                  .all(8),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          85,
                                                                      child: produitsEtrangers[index].photoIntrant == null ||
                                                                              produitsEtrangers[index].photoIntrant!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/intrant/${produitsEtrangers[index].idIntrant}/image",
                                                                              fit: BoxFit.cover,
                                                                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                'assets/images/default_image.png',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  // SizedBox(height: 8),
                                                                  ListTile(
                                                                    title: Text(
                                                                      produitsEtrangers[
                                                                              index]
                                                                          .nomIntrant!,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      "${produitsEtrangers[index].quantiteIntrant.toString()} ${produitsEtrangers[index].unite}",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            15),
                                                                    child: Text(
                                                                      produitsEtrangers[index].monnaie !=
                                                                              null
                                                                          ? "${produitsEtrangers[index].prixIntrant.toString()} ${produitsEtrangers[index].monnaie!.libelle}"
                                                                          : "${produitsEtrangers[index].prixIntrant.toString()} FCFA ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          32),
                                                                  child: Center(
                                                                      child:
                                                                          const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: Colors
                                                                          .orange,
                                                                    ),
                                                                  )),
                                                                )
                                                              : Container();
                                                        }
                                                      },
                                                    ),
                                                  ]
                                                ],
                                              );
                                      }
                                    });
                              }),
                            )))),
        ));
  }

  Widget _buildShimmerEffect() {
    return Center(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 85,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  title: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 16,
                      color: Colors.grey,
                    ),
                  ),
                  subtitle: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 15,
                      color: Colors.grey,
                      margin: EdgeInsets.only(top: 4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 15,
                      color: Colors.grey,
                      margin: EdgeInsets.only(top: 4),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  
}
