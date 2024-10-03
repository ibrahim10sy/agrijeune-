import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/Zone.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddAndUpdateProductScreen.dart';
import 'package:koumi/screens/DetailProduits.dart';
import 'package:koumi/screens/MyStores.dart';
import 'package:koumi/screens/PinLoginScreen.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/service/StockService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'LoginScreen.dart';

class MyProductScreen extends StatefulWidget {
  bool? isRoute;
  MyProductScreen({super.key, this.isRoute});

  @override
  State<MyProductScreen> createState() => _MyProductScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _MyProductScreenState extends State<MyProductScreen> {
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  final FocusNode _focusNode = FocusNode();
  late String type;
  late TextEditingController _searchController;
  List<Stock> stockListe = [];
  CategorieProduit? selectedCat;
  String? typeValue;
  late Future _catList;

  bool isSearchMode = false;
  bool isFilterMode = false;
  bool isExist = false;
  String? email = "";
  late Future<List<Stock>> stockListeFuture;
  late Future<List<Stock>> stockListeFuture1;

  ScrollController scrollableController = ScrollController();
  ScrollController scrollableController1 = ScrollController();

  int page = 0;
  bool isLoading = false;
  int size = 100;
  // int size = sized;
  bool hasMore = true;

  bool isLoadingLibelle = true;

  Future<List<Stock>> fetchStockByActeur(String idActeur,
      {bool refresh = false}) async {
    // if (_stockService.isLoading == true) return [];

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
          '$apiOnlineUrl/Stock/getAllStocksByActeurWithPagination?idActeur=$idActeur&page=${page}&size=${size}'));
      debugPrint(
          '$apiOnlineUrl/Stock/getAllStocksByActeurWithPagination?idActeur=$idActeur&page=${page}&size=${size}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          setState(() {
            List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
            stockListe.addAll(newStocks);
          });
        }

        debugPrint(
            "response body all stocks by acteur with pagination ${page} par défilement soit ${stockListe.length}");
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

  Future<List<Stock>> fetchAllStockByCate() async {
    if (selectedCat != null) {
      stockListe = await StockService().fetchStockByIdActeurAndIdCategorie(
          selectedCat!.idCategorieProduit!, acteur.idActeur!);
    }
    return stockListe;
  }

  Future<List<Stock>> fetchStockByCategorieAndActeur(String idActeur,
      {bool refresh = false}) async {
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
          '$apiOnlineUrl/Stock/getStocksByCategorieAndActeur?idCategorie=${selectedCat!.idCategorieProduit}&idActeur=$idActeur&page=$page&size=$sized'));

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

  void verify() async {
    await Provider.of<ActeurProvider>(context, listen: false)
        .initializeActeurFromSharedPreferences();
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

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading) {
      debugPrint("yes - fetch stock by acteur");
      setState(() {
        page++;
      });
      fetchStockByActeur(acteur.idActeur!).then((value) {
        setState(() {});
      });
    }
  }

  void _scrollListener1() {
    if (scrollableController1.position.pixels >=
            scrollableController1.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading) {
      debugPrint("yes - fetch stock by acteur");
      setState(() {
        page++;
      });
      fetchStockByCategorieAndActeur(acteur.idActeur!).then((value) {
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController.addListener(_scrollListener);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController1.addListener(_scrollListener1);
    });

    // verify();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    typeActeurData = acteur.typeActeur!;
    type = typeActeurData.map((data) => data.libelle).join(', ');
    stockListeFuture1 = fetchAllStockByCate();
    stockListeFuture = fetchAllStock();
    _searchController = TextEditingController();
    _catList = http.get(Uri.parse('$apiOnlineUrl/Categorie/allCategorie'));
  }

  Future<List<Stock>> fetchAllStock() async {
    stockListe = await StockService().fetchStockByActeur(acteur.idActeur!);

    return stockListe;
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
        stockListeFuture = StockService().fetchStockByActeur(acteur.idActeur!);
      });
    }
  }

  Future<void> _getResultFromNextScreen2(BuildContext context, Stock s) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddAndUpdateProductScreen(
                  isEditable: true,
                  stock: s,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        stockListeFuture = StockService().fetchStockByActeur(acteur.idActeur!);
      });
    }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // if (isSearchMode) {
    //   _searchController = TextEditingController();
    // } else {
    // }
    _searchController.dispose();
    // Disposez le TextEditingController lorsque vous n'en avez plus besoin
    scrollableController.dispose();
    scrollableController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: d_colorGreen,
            centerTitle: true,
            toolbarHeight: 75,
            leading: (widget.isRoute ?? false)
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context, true);
                      });
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  )
                : Container(),
            title: Text(
              'Mes Produits',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            actions: [
              (widget.isRoute ?? false)
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          stockListeFuture = StockService()
                              .fetchStockByActeur(acteur.idActeur!);
                        });
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ))
                  : Container(),
            ]),
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
                              (typeActeurData
                                          .map((e) => e.libelle!.toLowerCase())
                                          .contains("commercant") ||
                                      typeActeurData
                                          .map((e) => e.libelle!.toLowerCase())
                                          .contains("commerçant") ||
                                      typeActeurData
                                          .map((e) => e.libelle!.toLowerCase())
                                          .contains("transformateur") ||
                                      typeActeurData
                                          .map((e) => e.libelle!.toLowerCase())
                                          .contains("admin") ||
                                      typeActeurData
                                          .map((e) => e.libelle!.toLowerCase())
                                          .contains("producteur") ||
                                      typeActeurData
                                          .map((e) => e.libelle!.toLowerCase())
                                          .contains(
                                              "partenaires de développement") ||
                                      typeActeurData
                                          .map((e) => e.libelle!.toLowerCase())
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
                                            MediaQuery.of(context).size.width,
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
                                                    fontWeight: FontWeight.bold,
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
                                                    fontWeight: FontWeight.bold,
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
                                                    fontWeight: FontWeight.bold,
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
                                            } else if (value == 'add_store') {
                                              _getResultFromMagasinPage(
                                                  context);
                                            } else if (value == 'add_zone') {
                                              _getResultFromZonePage(context);
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
                                        stockListeFuture = StockService()
                                            .fetchStockByActeur(
                                                acteur.idActeur!);
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
                                ),
                            ]),
                      ),
                      Visibility(
                        visible: isSearchMode,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 10),
                          child: SearchFieldAutoComplete<String>(
                            controller: _searchController,
                            placeholder: 'Rechercher...',
                            autofocus: false,
                            placeholderStyle:
                                TextStyle(fontStyle: FontStyle.italic),
                            suggestions: AutoComplet.getAgriculturalProducts,
                            suggestionsDecoration: SuggestionDecoration(
                              marginSuggestions: const EdgeInsets.all(8.0),
                              color: const Color.fromARGB(255, 236, 234, 234),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            onSuggestionSelected: (selectedItem) {
                              if (mounted) {
                                _searchController.text = selectedItem.searchKey;
                              }
                            },
                            suggestionItemBuilder: (context, searchFieldItem) {
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
                      selectedCat != null
                          ? setState(() {
                              stockListeFuture1 = fetchAllStock();
                            })
                          : setState(() {
                              stockListeFuture = fetchAllStock();
                            });
                      debugPrint("refresh page ${page}");
                    },
                    child: SingleChildScrollView(
                      controller: scrollableController,
                      child: Consumer<StockService>(
                          builder: (context, sService, child) {
                        return FutureBuilder(
                            future: stockListeFuture,
                            // future: (widget.isRoute ?? false)
                            //     ? stockListeFuture
                            //     : sService.fetchStockByActeur(acteur.idActeur!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildShimmerEffect();
                              }

                              if (!snapshot.hasData) {
                                return SingleChildScrollView(
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                stockListe = snapshot.data!;
                                String searchText = "";
                                List<Stock> filteredSearch =
                                    stockListe.where((cate) {
                                  String nomCat =
                                      cate.nomProduit!.toLowerCase();
                                  searchText =
                                      _searchController.text.toLowerCase();
                                  return nomCat.contains(searchText);
                                }).toList();
                                return filteredSearch.isEmpty
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
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          childAspectRatio: 0.8,
                                        ),
                                        itemCount: filteredSearch.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index < filteredSearch.length) {
                                            return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailProduits(
                                                              stock:
                                                                  filteredSearch[
                                                                      index]),
                                                    ),
                                                  );
                                                },
                                                child: Card(
                                                  margin: EdgeInsets.all(8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: SizedBox(
                                                          height: 72,
                                                          child: filteredSearch[
                                                                              index]
                                                                          .photo ==
                                                                      null ||
                                                                  filteredSearch[
                                                                          index]
                                                                      .photo!
                                                                      .isEmpty
                                                              ? Image.asset(
                                                                  "assets/images/default_image.png",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : CachedNetworkImage(
                                                                  imageUrl:
                                                                      "https://koumi.ml/api-koumi/Stock/${filteredSearch[index].idStock}/image",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const Center(
                                                                          child:
                                                                              CircularProgressIndicator()),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image
                                                                          .asset(
                                                                    'assets/images/default_image.png',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                          filteredSearch[index]
                                                              .nomProduit!,
                                                          style: TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 15),
                                                        child: Text(
                                                          filteredSearch[index]
                                                                      .monnaie !=
                                                                  null
                                                              ? "${filteredSearch[index].prix.toString()} ${filteredSearch[index].monnaie!.libelle}"
                                                              : "${filteredSearch[index].prix.toString()} FCFA",
                                                          style: TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            _buildEtat(
                                                                filteredSearch[
                                                                        index]
                                                                    .statutSotck!),
                                                            SizedBox(
                                                                width: 100),
                                                            Expanded(
                                                              child:
                                                                  PopupMenuButton<
                                                                      String>(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                itemBuilder:
                                                                    (context) =>
                                                                        <PopupMenuEntry<
                                                                            String>>[
                                                                  PopupMenuItem<
                                                                      String>(
                                                                    child:
                                                                        ListTile(
                                                                      leading:
                                                                          const Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      title:
                                                                          const Text(
                                                                        "Modifier le produit",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.green,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        _getResultFromNextScreen2(
                                                                            context,
                                                                            filteredSearch[index]);
                                                                      },
                                                                    ),
                                                                  ),
                                                                  PopupMenuItem<
                                                                      String>(
                                                                    child:
                                                                        ListTile(
                                                                      leading:
                                                                          const Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      title:
                                                                          const Text(
                                                                        "Modifier la quantité",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.green,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .pop();

                                                                        await afficherBottomSheet(context,
                                                                                filteredSearch[index])
                                                                            .then((value) {
                                                                          Provider.of<StockService>(context, listen: false)
                                                                              .applyChange();
                                                                          setState(
                                                                              () {
                                                                            page++;
                                                                            stockListeFuture =
                                                                                StockService().fetchStockByActeur(acteur.idActeur!);
                                                                          });
                                                                          // Navigator.of(context).pop();
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  PopupMenuItem<
                                                                      String>(
                                                                    child:
                                                                        ListTile(
                                                                      leading: filteredSearch[index].statutSotck ==
                                                                              false
                                                                          ? Icon(
                                                                              Icons.check,
                                                                              color: Colors.green,
                                                                            )
                                                                          : Icon(
                                                                              Icons.disabled_visible,
                                                                              color: Colors.orange[400],
                                                                            ),
                                                                      title:
                                                                          Text(
                                                                        filteredSearch[index].statutSotck ==
                                                                                false
                                                                            ? "Activer"
                                                                            : "Desactiver",
                                                                        style:
                                                                            TextStyle(
                                                                          color: filteredSearch[index].statutSotck == false
                                                                              ? Colors.green
                                                                              : Colors.orange[400],
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        // Changement d'état du magasin ici
                                                                        filteredSearch[index].statutSotck ==
                                                                                false
                                                                            ? await StockService()
                                                                                .activerStock(filteredSearch[index].idStock!)
                                                                                .then((value) => {
                                                                                      Provider.of<StockService>(context, listen: false).applyChange(),
                                                                                      setState(() {
                                                                                        page++;
                                                                                        stockListeFuture = StockService().fetchStockByActeur(acteur.idActeur!);
                                                                                      }),
                                                                                      Navigator.of(context).pop(),
                                                                                    })
                                                                                .catchError((onError) => {
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                                        const SnackBar(
                                                                                          content: Row(
                                                                                            children: [
                                                                                              Text("Une erreur s'est produite"),
                                                                                            ],
                                                                                          ),
                                                                                          duration: Duration(seconds: 5),
                                                                                        ),
                                                                                      ),
                                                                                      Navigator.of(context).pop(),
                                                                                    })
                                                                            : await StockService().desactiverStock(filteredSearch[index].idStock!).then((value) => {
                                                                                  Provider.of<StockService>(context, listen: false).applyChange(),
                                                                                  setState(() {
                                                                                    page++;
                                                                                    stockListeFuture = StockService().fetchStockByActeur(acteur.idActeur!);
                                                                                  }),
                                                                                  Navigator.of(context).pop(),
                                                                                });

                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(SnackBar(
                                                                          content:
                                                                              Row(
                                                                            children: [
                                                                              Text(filteredSearch[index].statutSotck == false ? "Activer avec succèss " : "Desactiver avec succèss"),
                                                                            ],
                                                                          ),
                                                                          duration:
                                                                              Duration(seconds: 2),
                                                                        ));
                                                                      },
                                                                    ),
                                                                  ),
                                                                  PopupMenuItem<
                                                                      String>(
                                                                    child:
                                                                        ListTile(
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
                                                                          color:
                                                                              Colors.red,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        await StockService()
                                                                            .deleteStock(filteredSearch[index]
                                                                                .idStock!)
                                                                            .then((value) =>
                                                                                {
                                                                                  Provider.of<StockService>(context, listen: false).applyChange(),
                                                                                  setState(() {
                                                                                    page++;
                                                                                    stockListeFuture = StockService().fetchStockByActeur(acteur.idActeur!);
                                                                                  }),
                                                                                  Navigator.of(context).pop(),
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    const SnackBar(
                                                                                      content: Row(
                                                                                        children: [
                                                                                          Text("Produit supprimer avec succès"),
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
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ));
                                          } else {
                                            return isLoading == true
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 32),
                                                    child: Center(
                                                        child: const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.orange,
                                                      ),
                                                    )),
                                                  )
                                                : Container();
                                          }
                                        },
                                      );
                              }
                            });
                      }),
                    ))),
          ),
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

  Future<dynamic> afficherBottomSheet(
      BuildContext context, Stock? stock) async {
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
              child: DialodEdit(stock: stock)),
        );
      },
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
          fetchStockByCategorieAndActeur(acteur.idActeur!, refresh: true);
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

class DialodEdit extends StatefulWidget {
  Stock? stock;
  DialodEdit({super.key, this.stock});

  @override
  State<DialodEdit> createState() => _DialodEditState();
}

class _DialodEditState extends State<DialodEdit> {
  TextEditingController quantiteController = TextEditingController();
  late Stock stocks;
  String? idStock;
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    stocks = widget.stock!;
    idStock = stocks.idStock;
    quantiteController.text = stocks.quantiteStock!.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Container(
        height: 250,
        child: Form(
            key: formkey,
            child: Column(children: [
              Text(
                "Modification de la quantité",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez remplir ce champ";
                  }
                  return null;
                },
                controller: quantiteController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Quantité",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final qte = quantiteController.text;

                      final qteF = double.tryParse(qte);

                      if (qteF! > stocks.quantiteStock!) {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Non autorisé"),
                            content: Text(
                                "Toute augmentation de quantité neccessite une nouvelle ajout de produits",
                                style: TextStyle(
                                  color: Colors.black87,
                                )),
                            actions: [
                              TextButton(
                                child: Text("Fermer"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: Text("Ajouter"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddAndUpdateProductScreen(
                                                isEditable: false,
                                              )));
                                },
                              ),
                            ],
                          ),
                        );

                        return;
                      }
                      print(qte);
                      if (formkey.currentState!.validate()) {
                        try {
                          setState(() {
                            _isLoading = true;
                          });
                          await StockService()
                              .updateQuantiteStock(
                                  id: stocks.idStock!, quantite: qteF!)
                              .then((value) => {
                                    setState(() {
                                      _isLoading = false;
                                    }),
                                    Provider.of<StockService>(context,
                                            listen: false)
                                        .applyChange(),
                                    Navigator.of(context).pop(),
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Text(
                                                "Quantité modifier avec success"),
                                          ],
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    )
                                  })
                              .catchError((onError) => {
                                    setState(() {
                                      _isLoading = false;
                                    }),
                                    print(onError)
                                  });
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });
                          final String errorMessage = e.toString();
                          print(errorMessage);
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
                      backgroundColor: d_colorGreen,

                      // fixedSize: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                    ),
                    child: Text(
                      "Modifier",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                    ),
                    child: Text(
                      "Annuler",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ])),
      ),
    );
  }
}
