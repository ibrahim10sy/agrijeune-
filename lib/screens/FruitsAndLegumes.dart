import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/Zone.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddAndUpdateProductScreen.dart';
import 'package:koumi/screens/DetailProduits.dart';
import 'package:koumi/screens/MyStores.dart';
import 'package:koumi/service/StockService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class FruitAndLegumes extends StatefulWidget {
  FruitAndLegumes({super.key});

  @override
  State<FruitAndLegumes> createState() => _FruitAndLegumesState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _FruitAndLegumesState extends State<FruitAndLegumes> {
  late TextEditingController _searchController;
  List<Stock> stockListe = [];
  List<Stock> stockList = [];
  late Future<List<Stock>> stockListeFuture;
  late Future<List<Stock>> stockListeFuture1;
  CategorieProduit? selectedCat;
  String? typeValue;
  late Future _catList;
  String? detectedCountry;
  ScrollController scrollableController = ScrollController();
  ScrollController scrollableController1 = ScrollController();
  String? nomP;
  late Future _paysList;
  String libelle = "Végétales";
  // List<String> libelles = ["Végétale", "Vegetale", "vegetale", "végétale","Végétales"];

  // String? monnaie;
  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;
  bool isExist = false;
  String? email = "";
  bool isSearchMode = false;
  bool isFilterMode = false;
  late String type;
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];

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
        // stockListeFuture = fetchAllStock();
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  // void _scrollListener() {
  //   if (scrollableController.position.pixels >=
  //           scrollableController.position.maxScrollExtent - 200 &&
  //       hasMore &&
  //       !isLoading) {
  //     // if (selectedCat != null) {
  //     // Incrementez la page et récupérez les stocks par catégorie
  //     debugPrint("yes - fetch by category");
  //     setState(() {
  //       // Rafraîchir les données ici
  //       page++;
  //     });

  //     fetchStock(detectedCountry != null ? detectedCountry! : "Mali")
  //         .then((value) {
  //       setState(() {
  //         // Rafraîchir les données ici
  //         debugPrint("page inc all ${page}");
  //       });
  //     });
  //   }
  //   debugPrint("no");
  // }
  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading) {
      // if (selectedCat != null) {
      // Incrementez la page et récupérez les stocks par catégorie
      debugPrint("yes - fetch by category");
      setState(() {
        // Rafraîchir les données ici
        page++;
      });

      fetchStock().then((value) {
        setState(() {
          // Rafraîchir les données ici
          debugPrint("page inc all ${page}");
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

      fetchStockByCategorie(
              // detectedCountry != null ? detectedCountry! : "Mali"
              )
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

      fetchStockByPays().then((value) {
        setState(() {
          debugPrint("page pour pays ${nomP} inc all ${page}");
        });
      });
    }
    debugPrint("no");
  }

  Future<List<Stock>> getAllStock() async {
    if (selectedCat != null) {
      stockListe = await StockService().fetchStockByCategorieAndFiliere(
        selectedCat!.idCategorieProduit!,
        libelle,
        // detectedCountry != null ? detectedCountry! : "mali"
      );
    } else if (nomP != null && nomP!.isNotEmpty) {
      stockListe =
          await StockService().fetchStockByPaysAndFiliere(libelle, nomP!);
    }

    return stockListe;
  }

  Future<List<Stock>> fetchStockByPays({bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        stockListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllByFiliereAndPays?libelle=${libelle}&nomPays=${nomP}&page=$page&size=$size'));
      print(
          "page : $apiOnlineUrl/Stock/getAllByFiliereAndPays?libelle=${libelle}&nomPays=${nomP}&page=$page&size=$size");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          setState(() {
            stockListe.addAll(newStocks.where((newStock) => !stockListe
                .any((existStock) => existStock.idStock == newStock.idStock)));
          });
        }

        debugPrint(
            "response body all stock by categorie and pays with pagination ${page} par défilement soit ${stockListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return stockListe;
  }

  Future<List<Stock>> fetchStockByCategorie({bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        stockListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllStocksByCategorieAndFiliere?idCategorie=${selectedCat!.idCategorieProduit}&libelleFiliere=$libelle&page=$page&size=$size'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          setState(() {
            stockListe.addAll(newStocks.where((newStock) => !stockListe
                .any((existStock) => existStock.idStock == newStock.idStock)));
          });
        }

        debugPrint(
            "response body all stock by categorie and pays with pagination ${page} par défilement soit ${stockListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return stockListe;
  }

  Future<List<Stock>> fetchStock({bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        stockListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      // List<Stock> tempStockListe = [];
      // for (String libelle in libelles) {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?libelle=$libelle&page=$page&size=$size'));
      // '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?pays=$pays&libelle=$libelle&page=$page&size=$size'));
      debugPrint(
          '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?libelle=$libelle&page=$page&size=$size');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          setState(() {
            stockListe.addAll(newStocks.where((newStock) => !stockListe
                .any((existStock) => existStock.idStock == newStock.idStock)));
          });
        }

        debugPrint(
            "response body all stock by categorie with pagination ${page} par défilement soit ${stockListe.length}");
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
    return stockListe;
  }
  // Future<List<Stock>> fetchStock(String pays, {bool refresh = false}) async {
  //   if (isLoading == true) return [];

  //   setState(() {
  //     isLoading = true;
  //   });

  //   if (refresh) {
  //     setState(() {
  //       stockListe.clear();
  //       page = 0;
  //       hasMore = true;
  //     });
  //   }

  //   try {
  //     // List<Stock> tempStockListe = [];
  //     // for (String libelle in libelles) {
  //     final response = await http.get(Uri.parse(
  //         '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size'));
  //     // '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?pays=$pays&libelle=$libelle&page=$page&size=$size'));
  //     debugPrint(
  //         '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size');
  //     // debugPrint( '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size');
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
  //       final List<dynamic> body = jsonData['content'];

  //       if (body.isEmpty) {
  //         setState(() {
  //           hasMore = false;
  //         });
  //       } else {
  //         List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
  //         setState(() {
  //           stockListe.addAll(newStocks.where((newStock) => !stockListe
  //               .any((existStock) => existStock.idStock == newStock.idStock)));
  //         });
  //       }

  //       debugPrint(
  //           "response body all stock by categorie with pagination ${page} par défilement soit ${stockListe.length}");
  //     } else {
  //       print(
  //           'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
  //     }
  //   } catch (e) {
  //     print(
  //         'Une erreur s\'est produite lors de la récupération des intrants: $e');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  //   return stockListe;
  // }

  @override
  void initState() {
    super.initState();

    final paysProvider = Provider.of<DetectorPays>(context, listen: false);
    paysProvider.hasLocation
        ? detectedCountry =
            Provider.of<DetectorPays>(context, listen: false).detectedCountry!
        : detectedCountry = "Mali";
    verify();
    _paysList = http.get(Uri.parse('$apiOnlineUrl/pays/read'));
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController1.addListener(_scrollListener1);
    });
    _catList = http.get(Uri.parse(
        '$apiOnlineUrl/Categorie/allCategorieByLibelleFiliere/$libelle'));
    stockListeFuture1 = getAllStock();
    stockListeFuture = fetchStock();
    // stockListeFuture =
    //     fetchStock(detectedCountry != null ? detectedCountry! : "Mali");
  }

  Future<void> _getResultFromNextScreen1(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddAndUpdateProductScreen(
                  isEditable: false,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        stockListeFuture = fetchStock();
        // stockListeFuture =
        //     fetchStock(detectedCountry != null ? detectedCountry! : "Mali");
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollableController.dispose();
    scrollableController1.dispose();
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

  Future<void> _getResultFromMagasinPage(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyStoresScreen()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
    }
  }

  Future<void> _getResultFromZonePage(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Zone()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
    }
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
              "Fruits & légumes",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions:
                // !isExist
                //     ?
                [
              IconButton(
                  onPressed: () {
                    stockListeFuture = fetchStock();
                    // stockListeFuture = fetchStock(
                    //     detectedCountry != null ? detectedCountry! : "Mali");
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white)),
            ]
            // : [
            //     IconButton(
            //         onPressed: () {
            //           stockListeFuture = fetchStock(detectedCountry != null
            //               ? detectedCountry!
            //               : "Mali");
            //         },
            //         icon: const Icon(Icons.refresh, color: Colors.white)),
            //     (typeActeurData
            //                 .map((e) => e.libelle!.toLowerCase())
            //                 .contains("commercant") ||
            //             typeActeurData
            //                 .map((e) => e.libelle!.toLowerCase())
            //                 .contains("commerçant") ||
            //             typeActeurData
            //                 .map((e) => e.libelle!.toLowerCase())
            //                 .contains("admin") ||
            //             typeActeurData
            //                 .map((e) => e.libelle!.toLowerCase())
            //                 .contains("producteur"))
            //         ? PopupMenuButton<String>(
            //             padding: EdgeInsets.zero,
            //             itemBuilder: (context) {
            //               return <PopupMenuEntry<String>>[
            //                 PopupMenuItem<String>(
            //                   child: ListTile(
            //                     leading: const Icon(
            //                       Icons.add,
            //                       color: Colors.green,
            //                     ),
            //                     title: const Text(
            //                       "Ajouter produit",
            //                       style: TextStyle(
            //                         color: Colors.green,
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                     onTap: () async {
            //                       Navigator.of(context).pop();
            //                       _getResultFromNextScreen1(context);
            //                     },
            //                   ),
            //                 ),
            //               ];
            //             },
            //           )
            //         : Container()
            //   ],
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
                                                .contains("commercant") ||
                                            typeActeurData
                                                .map((e) =>
                                                    e.libelle!.toLowerCase())
                                                .contains("commerçant") ||
                                            typeActeurData
                                                .map((e) =>
                                                    e.libelle!.toLowerCase())
                                                .contains("transformateur") ||
                                            typeActeurData
                                                .map((e) =>
                                                    e.libelle!.toLowerCase())
                                                .contains("admin") ||
                                            typeActeurData
                                                .map((e) =>
                                                    e.libelle!.toLowerCase())
                                                .contains("producteur") ||
                                            typeActeurData
                                                .map((e) =>
                                                    e.libelle!.toLowerCase())
                                                .contains(
                                                    "partenaires de développement") ||
                                            typeActeurData
                                                .map((e) =>
                                                    e.libelle!.toLowerCase())
                                                .contains(
                                                    "partenaire de developpement"))
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
                                                    value: 'add_product',
                                                    child: ListTile(
                                                      leading: const Icon(
                                                        Icons.list_alt_sharp,
                                                        color: d_colorGreen,
                                                      ),
                                                      title: const Text(
                                                        "Ajouter un produit",
                                                        style: TextStyle(
                                                          color: d_colorGreen,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'add_store',
                                                    child: ListTile(
                                                      leading: const Icon(
                                                        Icons.store,
                                                        color: d_colorGreen,
                                                      ),
                                                      title: const Text(
                                                        "Ajouter un magasin",
                                                        style: TextStyle(
                                                          color: d_colorGreen,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'add_zone',
                                                    child: ListTile(
                                                      leading: const Icon(
                                                        Icons.zoom_in_outlined,
                                                        color: d_colorGreen,
                                                      ),
                                                      title: const Text(
                                                        "Ajouter une zone de production",
                                                        style: TextStyle(
                                                          color: d_colorGreen,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                elevation: 8.0,
                                              ).then((value) {
                                                if (value != null) {
                                                  if (value == 'add_product') {
                                                    _getResultFromNextScreen1(
                                                        context);
                                                  } else if (value ==
                                                      'add_store') {
                                                    _getResultFromMagasinPage(
                                                        context);
                                                  } else if (value ==
                                                      'add_zone') {
                                                    _getResultFromZonePage(
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
                                          stockListeFuture = fetchStock();
                                          // stockListeFuture = fetchStock(
                                          //     detectedCountry != null
                                          //         ? detectedCountry!
                                          //         : "Mali");
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
                                                fetchStockByPays(refresh: true);
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
                                    future: _catList,
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
                                                fetchStockByCategorie(
                                                    // detectedCountry != null
                                                    //     ? detectedCountry!
                                                    //     : "Mali",
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
                              suggestions: AutoComplet.getFruitsAndVegetables,
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
                                    ? stockListeFuture1 = StockService()
                                        .fetchStockByCategorieAndFiliere(
                                        selectedCat!.idCategorieProduit!,
                                        libelle,
                                        // detectedCountry != null
                                        //     ? detectedCountry!
                                        //     : "Mali"
                                      )
                                    : stockListeFuture1 = StockService()
                                        .fetchStockByPaysAndFiliere(
                                            libelle, nomP!);
                              })
                            : setState(() {
                                stockListeFuture = fetchStock();
                                // : setState(() {
                                //     stockListeFuture = fetchStock(
                                //         detectedCountry != null
                                //             ? detectedCountry!
                                //             : "Mali");
                              });
                        debugPrint("refresh page ${page}");
                      },
                      child: selectedCat == null && nomP == null
                          ? SingleChildScrollView(
                              controller: scrollableController,
                              child: Consumer<StockService>(
                                  builder: (context, intrantService, child) {
                                return FutureBuilder(
                                    future: stockListeFuture,
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
                                        stockList = snapshot.data!;
                                        String searchText = "";

                                        List<Stock> produitsLocaux = stockList
                                            .where((stock) =>
                                                stock.acteur!
                                                    .niveau3PaysActeur! ==
                                                detectedCountry)
                                            .where((cate) {
                                          String nomCat =
                                              cate.nomProduit!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Stock> produitsEtrangers =
                                            stockList
                                                .where((stock) =>
                                                    stock.acteur!
                                                        .niveau3PaysActeur! !=
                                                    detectedCountry)
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomProduit!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Stock> filteredSearch =
                                            stockList.where((cate) {
                                          String nomCat =
                                              cate.nomProduit!.toLowerCase();
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
                                                      // itemCount: stockListe.length + (isLoading ? 1 : 0),
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
                                                                            DetailProduits(
                                                                      stock: produitsLocaux[
                                                                          index],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Card(
                                                                margin:
                                                                    EdgeInsets
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
                                                                          Container(
                                                                        height:
                                                                            85,
                                                                        child: produitsLocaux[index].photo == null ||
                                                                                produitsLocaux[index].photo!.isEmpty
                                                                            ? Image.asset(
                                                                                "assets/images/default_image.png",
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                imageUrl: "https://koumi.ml/api-koumi/Stock/${produitsLocaux[index].idStock}/image",
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
                                                                      title:
                                                                          Text(
                                                                        produitsLocaux[index]
                                                                            .nomProduit!,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        "${produitsLocaux[index].quantiteStock!.toString()} ${produitsLocaux[index].unite!.nomUnite} ",
                                                                        style:
                                                                            TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        produitsLocaux[index].monnaie !=
                                                                                null
                                                                            ? "${produitsLocaux[index].prix.toString()} ${produitsLocaux[index].monnaie!.libelle}"
                                                                            : "${produitsLocaux[index].prix.toString()} FCFA",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
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
                                                      // itemCount: stockListe.length + (isLoading ? 1 : 0),
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
                                                                            DetailProduits(
                                                                      stock: produitsEtrangers[
                                                                          index],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Card(
                                                                margin:
                                                                    EdgeInsets
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
                                                                          Container(
                                                                        height:
                                                                            85,
                                                                        child: produitsEtrangers[index].photo == null ||
                                                                                produitsEtrangers[index].photo!.isEmpty
                                                                            ? Image.asset(
                                                                                "assets/images/default_image.png",
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                imageUrl: "https://koumi.ml/api-koumi/Stock/${produitsEtrangers[index].idStock}/image",
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
                                                                      title:
                                                                          Text(
                                                                        produitsEtrangers[index]
                                                                            .nomProduit!,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        "${produitsEtrangers[index].quantiteStock!.toString()} ${produitsEtrangers[index].unite!.nomUnite} ",
                                                                        style:
                                                                            TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        produitsEtrangers[index].monnaie !=
                                                                                null
                                                                            ? "${produitsEtrangers[index].prix.toString()} ${produitsEtrangers[index].monnaie!.libelle}"
                                                                            : "${produitsEtrangers[index].prix.toString()} FCFA",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
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
                              child: FutureBuilder(
                                  future: stockListeFuture1,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _buildShimmerEffect();
                                    }

                                    if (!snapshot.hasData) {
                                      return const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                            child: Text("Aucun donné trouvé")),
                                      );
                                    } else {
                                      stockList = snapshot.data!;
                                      String searchText = "";

                                      List<Stock> produitsLocaux = stockList
                                          .where((stock) =>
                                              stock
                                                  .acteur!.niveau3PaysActeur! ==
                                              detectedCountry)
                                          .where((cate) {
                                        String nomCat =
                                            cate.nomProduit!.toLowerCase();
                                        searchText = _searchController.text
                                            .toLowerCase();
                                        return nomCat.contains(searchText);
                                      }).toList();

                                      List<Stock> produitsEtrangers = stockList
                                          .where((stock) =>
                                              stock
                                                  .acteur!.niveau3PaysActeur! !=
                                              detectedCountry)
                                          .where((cate) {
                                        String nomCat =
                                            cate.nomProduit!.toLowerCase();
                                        searchText = _searchController.text
                                            .toLowerCase();
                                        return nomCat.contains(searchText);
                                      }).toList();

                                      List<Stock> filteredSearch =
                                          stockList.where((cate) {
                                        String nomCat =
                                            cate.nomProduit!.toLowerCase();
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
                                                          overflow: TextOverflow
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      "Produits locaux",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: d_colorGreen,
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
                                                        produitsLocaux.length,
                                                    // itemCount: stockListe.length + (isLoading ? 1 : 0),
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
                                                                          DetailProduits(
                                                                    stock: produitsLocaux[
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
                                                                        Container(
                                                                      height:
                                                                          85,
                                                                      child: produitsLocaux[index].photo == null ||
                                                                              produitsLocaux[index].photo!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/Stock/${produitsLocaux[index].idStock}/image",
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
                                                                          .nomProduit!,
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
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      "${produitsLocaux[index].quantiteStock!.toString()} ${produitsLocaux[index].unite!.nomUnite} ",
                                                                      style:
                                                                          TextStyle(
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
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
                                                                          ? "${produitsLocaux[index].prix.toString()} ${produitsLocaux[index].monnaie!.libelle}"
                                                                          : "${produitsLocaux[index].prix.toString()} FCFA",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ));
                                                      } else {
                                                        return isLoading == true
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
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
                                                    itemCount: produitsEtrangers
                                                        .length,
                                                    // itemCount: stockListe.length + (isLoading ? 1 : 0),
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
                                                                          DetailProduits(
                                                                    stock: produitsEtrangers[
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
                                                                        Container(
                                                                      height:
                                                                          85,
                                                                      child: produitsEtrangers[index].photo == null ||
                                                                              produitsEtrangers[index].photo!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/Stock/${produitsEtrangers[index].idStock}/image",
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
                                                                          .nomProduit!,
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
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      "${produitsEtrangers[index].quantiteStock!.toString()} ${produitsEtrangers[index].unite!.nomUnite} ",
                                                                      style:
                                                                          TextStyle(
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
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
                                                                          ? "${produitsEtrangers[index].prix.toString()} ${produitsEtrangers[index].monnaie!.libelle}"
                                                                          : "${produitsEtrangers[index].prix.toString()} FCFA",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ));
                                                      } else {
                                                        return isLoading == true
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
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
        itemCount: 6, // Number of shimmer items to display
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

  DropdownButtonFormField<String> buildDropdown(
      List<CategorieProduit> typeList) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      items: typeList
          .map((e) => DropdownMenuItem(
                value: e.idCategorieProduit,
                child: Text(e.libelleCategorie!),
              ))
          .toList(),
      hint: Text("-- Filtre par categorie --"),
      value: typeValue,
      onChanged: (newValue) {
        setState(() {
          typeValue = newValue;
          if (newValue != null) {
            selectedCat = typeList.firstWhere(
              (element) => element.idCategorieProduit == newValue,
            );
          }
          page = 0;
          hasMore = true;
          fetchStockByCategorie(
              // detectedCountry != null ? detectedCountry! : "Mali",
              refresh: true);
          if (page == 0 && isLoading == true) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              scrollableController1.jumpTo(0.0);
            });
          }
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
        labelText: '-- Aucun categorie trouvé --',
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
