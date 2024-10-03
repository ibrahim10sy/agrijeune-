import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:koumi/Admin/CodePays.dart';
import 'package:koumi/Admin/Zone.dart';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddAndUpdateProductScreen.dart';
import 'package:koumi/screens/DetailProduits.dart';
import 'package:koumi/screens/MyProduct.dart';
import 'package:koumi/service/StockService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProductsByStoresScreen extends StatefulWidget {
  String? id, nom, pays;
  ProductsByStoresScreen({super.key, this.id, this.nom, this.pays});

  @override
  State<ProductsByStoresScreen> createState() => _ProductsByStoresScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

const d_colorPage = Color.fromRGBO(255, 255, 255, 1);

class _ProductsByStoresScreenState extends State<ProductsByStoresScreen> {
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  bool isSearchMode = false;
  bool isFilterMode = false;

  late String type;
  late TextEditingController _searchController;
  List<Stock> stockListe = [];
  late Future<List<Stock>> stockListeFuture;
  late Future<List<Stock>> stockListeFuture1;
  late Future<List<Stock>> stockListeFutureNew;
  CategorieProduit? selectedCat;
  String? typeValue;
  late Future _catList;
  bool isExist = false;
  String? email = "";
  ScrollController scrollableController = ScrollController();
  ScrollController scrollableController1 = ScrollController();

  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;
  bool isLoadingLibelle = true;
  String? p;

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

  Future<List<Stock>> getAllStock() async {
    if (selectedCat == null && widget.id != null) {
      stockListe = await StockService().fetchStockByMagasin(widget.id!);
    } else if (selectedCat != null && widget.id != null)
      stockListe = await StockService().fetchStockByCategorieAndMagasin(
          selectedCat!.idCategorieProduit!, widget.id!);

    return stockListe;
  }

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedCat == null &&
        widget.id != null) {
      if (mounted)
        setState(() {
          // Rafraîchir les données ici
          page++;
        });
      debugPrint("yes - fetch all stocks by magasin");
      fetchStockByMagasin(widget.id!);
    }
    debugPrint("no");
  }

  void _scrollListener1() {
    if (scrollableController1.position.pixels >=
            scrollableController1.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedCat != null &&
        widget.id != null) {
      // if (selectedCat != null) {
      // Incrementez la page et récupérez les stocks par catégorie
      debugPrint("yes - fetch by category and magasin");
      if (mounted)
        setState(() {
          // Rafraîchir les données ici
          page++;
        });

      fetchStockByCategorieAndMagasin();
    }
    debugPrint("no");
  }

  Future<List<Stock>> fetchStockByMagasin(String idMagasin,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (mounted) if (refresh) {
      setState(() {
        stockListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getStocksByPaysAndMagasinWithPagination?idMagasin=$idMagasin&page=${page}&size=${size}'));

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
            "response body all stock by magasin with pagination ${page} par défilement soit ${stockListe.length}");
        return stockListe;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
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

  Future<List<Stock>> fetchStockByCategorieAndMagasin(
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
          '$apiOnlineUrl/Stock/getStocksByPaysAndMagasinAndCategorieProduitWithPagination?idCategorieProduit=${selectedCat!.idCategorieProduit}&idMagasin=${widget.id}&page=$page&size=$size'));

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
            "response body all stock with pagination ${page} par défilement soit ${stockListe.length}");
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

  @override
  void initState() {
    super.initState();
    //  scrollableController = ScrollController()..addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //write or call your logic
      //code will run when widget rendering complete
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //write or call your logic
      //code will run when widget rendering complete
      scrollableController1.addListener(_scrollListener1);
    });
    p = widget.pays!;
    verify();
    updateViews();
    _searchController = TextEditingController();
    _catList = http.get(Uri.parse('$apiOnlineUrl/Categorie/allCategorie'));
      
    stockListeFuture = stockListeFuture1 = getAllStock();
  }

  updateViews() async {
    final response = await http.put(
      Uri.parse('$apiOnlineUrl/Magasin/updateView/${widget.id}'),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {
      print('Échec de la mise à jour du nombre de vues');
    }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _getResultFromZonePage(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Zone()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
    }
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
        stockListeFuture = stockListeFuture1 = getAllStock();
      });
    }
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
            overflow: TextOverflow.ellipsis,
            widget.nom!.toUpperCase(),
            style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          actions: [
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CodePays().getFlagsApp(p!),
            )
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
                          isExist
                              ? (typeActeurData
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
                                    _searchController = TextEditingController();
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
                                style:
                                    TextStyle(color: Colors.red, fontSize: 17),
                              ),
                            ),
                        ]),
                  ),
                  Visibility(
                    visible: isSearchMode,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      child: FutureBuilder(
                        future: _catList,
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return TextDropdownFormField(
                              options: [],
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                  labelText: "Chargement..."),
                              cursorColor: Colors.green,
                            );
                          }

                          if (snapshot.hasData) {
                            dynamic jsonString =
                                utf8.decode(snapshot.data.bodyBytes);
                            dynamic responseData = json.decode(jsonString);

                            if (responseData is List) {
                              final paysList = responseData
                                  .map((e) => CategorieProduit.fromMap(e))
                                  .where((con) => con.statutCategorie == true)
                                  .toList();
                              if (paysList.isEmpty) {
                                return TextDropdownFormField(
                                  options: [],
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      suffixIcon: Icon(Icons.search, size: 19),
                                      labelText: "Aucune catégorie trouvé"),
                                  cursorColor: Colors.green,
                                );
                              }

                              return DropdownFormField<CategorieProduit>(
                                onEmptyActionPressed: (String str) async {},
                                dropdownHeight: 200,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    suffixIcon: Icon(Icons.search, size: 19),
                                    labelText: "Filtrer par catégorie"),
                                onSaved: (dynamic cat) {
                                  selectedCat = cat;
                                  print("onSaved : $cat");
                                },
                                onChanged: (dynamic cat) {
                                  setState(() {
                                    selectedCat = cat;
                                    page = 0;
                                    hasMore = true;
                                    fetchStockByCategorieAndMagasin(
                                        refresh: true);

                                    if (page == 0 && isLoading == true) {
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) {
                                        scrollableController1.jumpTo(0.0);
                                      });
                                    }
                                  });
                                },
                                displayItemFn: (dynamic item) => Text(
                                  item?.libelleCategorie ?? '',
                                  style: TextStyle(fontSize: 16),
                                ),
                                findFn: (String str) async => paysList,
                                selectedFn: (dynamic item1, dynamic item2) {
                                  if (item1 != null && item2 != null) {
                                    return item1.idCategorieProduit ==
                                        item2.idCategorieProduit;
                                  }
                                  return false;
                                },
                                filterFn: (dynamic item, String str) => item
                                    .libelleCategorie!
                                    .toLowerCase()
                                    .contains(str.toLowerCase()),
                                dropdownItemFn: (dynamic item,
                                        int position,
                                        bool focused,
                                        bool selected,
                                        Function() onTap) =>
                                    ListTile(
                                  title: Text(item.libelleCategorie!),
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
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                suffixIcon: Icon(Icons.search, size: 19),
                                labelText: "Aucune catégorie trouvé"),
                            cursorColor: Colors.green,
                          );
                        },
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
                        placeholder: 'Rechercher...',
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
                setState(() {
                  page = 0;
                  // Rafraîchir les données ici
                });
                debugPrint("refresh page ${page}");
                setState(() {
                  stockListeFuture = stockListeFuture1 = getAllStock();
                });
              },
              child: selectedCat == null
                  ? SingleChildScrollView(
                      controller: scrollableController,
                      child: Consumer<StockService>(
                          builder: (context, stockService, child) {
                        return FutureBuilder<List<Stock>>(
                            future: stockListeFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildShimmerEffect();
                              }
                              if (snapshot.hasError == true) {
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
                                            'Aucun produit trouvé une erreur s\'est produite',
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
                              }
                              if (snapshot.hasError) {
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
                                            "Une erreur s'est produite veuiller réessayer",
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
                                // Vous pouvez afficher une image ou un texte ici
                                String searchText = "";
                                // List<Stock> filtereSearch = stockListe.where((search) {
                                //   String libelle = search.nomProduit!.toLowerCase();
                                //   searchText = _searchController.text.trim().toLowerCase();
                                //   return libelle.contains(searchText);
                                // }).toList();

                                return stockListe
                                        // .where((element) => element.statutSotck == true )
                                        .isEmpty
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
                                    : Center(
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            childAspectRatio: 0.8,
                                          ),
                                          itemCount: stockListe.length + 1,
                                          // itemCount: stockListe.length + (isLoading ? 1 : 0),
                                          itemBuilder: (context, index) {
                                            //     if (index == stockListe.length) {
                                            // return
                                            // _buildShimmerEffects()
                                            // // Center(
                                            // //   child: CircularProgressIndicator(
                                            // //     color: Colors.orange,
                                            // //   ),
                                            // // )
                                            // ;
                                            //     }

                                            if (index < stockListe.length) {
                                              // var e = stockListe
                                              //     // .where((element) =>
                                              //     //     element.statutSotck == true)
                                              //     .elementAt(index-1);
                                              return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailProduits(
                                                          stock:
                                                              stockListe[index],
                                                        ),
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
                                                                  .circular(
                                                                      8.0),
                                                          child: Container(
                                                            height: 85,
                                                            child: stockListe[index]
                                                                            .photo ==
                                                                        null ||
                                                                    stockListe[
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
                                                                        "https://koumi.ml/api-koumi/Stock/${stockListe[index].idStock}/image",
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
                                                        // SizedBox(height: 8),
                                                        ListTile(
                                                          title: Text(
                                                            stockListe[index]
                                                                .nomProduit!,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          subtitle: Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            "${stockListe[index].quantiteStock!.toString()} ${stockListe[index].unite!.nomUnite} ",
                                                            style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15),
                                                          child: Text(
                                                            stockListe[index]
                                                                        .monnaie !=
                                                                    null
                                                                ? "${stockListe[index].prix.toString()} ${stockListe[index].monnaie!.libelle}"
                                                                : "${stockListe[index].prix.toString()} ",
                                                            style: TextStyle(
                                                              fontSize: 15,
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
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 32),
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
                                        ),
                                      );
                              }
                            });
                      }),
                    )
                  : SingleChildScrollView(
                      controller: scrollableController1,
                      child: Consumer<StockService>(
                          builder: (context, stockService, child) {
                        return FutureBuilder<List<Stock>>(
                            future: stockListeFuture1,
                            // StockService().fetchStockByCategorieWithPagination(selectedCat!.idCategorieProduit!),
                            // fetchStockByCategorie(selectedCat!.idCategorieProduit!) ,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildShimmerEffect();
                                // const Center(
                                //   child: CircularProgressIndicator(
                                //     color: Colors.orange,
                                //   ),
                                // );
                              }
                              if (snapshot.hasError == true) {
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
                                            'Aucun produit trouvé une erreur s\'est produite',
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
                                // Vous pouvez afficher une image ou un texte ici
                                String searchText = "";
                                // List<Stock> filtereSearch = stockListe.where((search) {
                                //   String libelle = search.nomProduit!.toLowerCase();
                                //   searchText = _searchController.text.trim().toLowerCase();
                                //   return libelle.contains(searchText);
                                // }).toList();

                                return stockListe
                                            // .where((element) => element.statutSotck == true )
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
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : stockListe
                                                // .where((element) => element.statutSotck == true )
                                                .isEmpty &&
                                            isLoading == true
                                        ? _buildShimmerEffect()
                                        : Center(
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                mainAxisSpacing: 10,
                                                crossAxisSpacing: 10,
                                                childAspectRatio: 0.8,
                                              ),
                                              itemCount: stockListe.length + 1,
                                              //  itemCount: stockListe.length + (!isLoading ? 1 : 0),
                                              itemBuilder: (context, index) {
                                                //   if (index == stockListe.length) {
                                                // return
                                                // _buildShimmerEffect()
                                                // // Center(
                                                // //   child: CircularProgressIndicator(
                                                // //     color: Colors.orange,
                                                // //   ),
                                                // // )
                                                // ;
                                                //     }

                                                if (index < stockListe.length) {
                                                  return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                DetailProduits(
                                                              stock: stockListe[
                                                                  index],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Card(
                                                        margin:
                                                            EdgeInsets.all(8),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: Container(
                                                                height: 85,
                                                                child: stockListe[index].photo ==
                                                                            null ||
                                                                        stockListe[index]
                                                                            .photo!
                                                                            .isEmpty
                                                                    ? Image
                                                                        .asset(
                                                                        "assets/images/default_image.png",
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : CachedNetworkImage(
                                                                        imageUrl:
                                                                            "https://koumi.ml/api-koumi/Stock/${stockListe[index].idStock}/image",
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                const Center(child: CircularProgressIndicator()),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Image.asset(
                                                                          'assets/images/default_image.png',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                              ),
                                                            ),
                                                            // SizedBox(height: 8),
                                                            ListTile(
                                                              title: Text(
                                                                stockListe[
                                                                        index]
                                                                    .nomProduit!,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              subtitle: Text(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                "${stockListe[index].quantiteStock!.toString()} ${stockListe[index].unite!.nomUnite} ",
                                                                style:
                                                                    TextStyle(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15),
                                                              child: Text(
                                                                stockListe[index]
                                                                            .monnaie !=
                                                                        null
                                                                    ? "${stockListe[index].prix.toString()} ${stockListe[index].monnaie!.libelle}"
                                                                    : "${stockListe[index].prix.toString()} FCFA",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
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
                                                                  horizontal:
                                                                      32),
                                                          child: Center(
                                                              child:
                                                                  const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                          )),
                                                        )
                                                      : Container();
                                                }
                                              },
                                            ),
                                          );
                              }
                            });
                      }),
                    ),
            ),
          ),
        ),
      ),
    );
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

  // Define the _buildShimmerEffects function
  Widget _buildShimmerEffects() {
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
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                overflow: TextOverflow.ellipsis,
                fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
                fontSize: 16),
          )
        ],
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
      hint: Text("-- Filtre par catégorie --"),
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
          fetchStockByCategorieAndMagasin(refresh: true);

          if (page == 0 && isLoading == true) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              scrollableController1.jumpTo(0.0);
            });
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
        labelText: '-- Aucun catégorie trouvé --',
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
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
