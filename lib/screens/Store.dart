import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Magasin.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddMagasinScreen.dart';
import 'package:koumi/screens/MyStores.dart';
import 'package:koumi/screens/ProductsByStores.dart';
import 'package:koumi/service/MagasinService.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class StoreScreen extends StatefulWidget {
  StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _StoreScreenState extends State<StoreScreen> {
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late Pays pays;
  String? paysValue;
  late Future _paysList;
  // String? detectedCountry;
  List<Magasin> magasinListe = [];
  List<Magasin> magasinListeSearch = [];
  List<Magasin> magasinList = [];
  late Future<List<Magasin>> magasinListeFuture;
  late Future<List<Magasin>> magasinListeFuture1;
  Niveau1Pays? selectedNiveau1Pays;
  late TextEditingController _searchController;
  String? typeValue;

  late Future _niveau1PaysList;
  late Future<List<Magasin>> _magasinList;
  bool isExist = false;
  String? email = "";
  bool isSearchMode = false;
  bool isFilterMode = false;

  ScrollController scrollableController = ScrollController();
  ScrollController scrollableController1 = ScrollController();

  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;
  String? detectedCountry;
  String? id = "";

  Future<List<Magasin>> getAllMagasins() async {
    if (selectedNiveau1Pays != null) {
      magasinListe = await MagasinService()
          .fetchMagasinByNiveau1PaysWithPagination(
              selectedNiveau1Pays!.idNiveau1Pays!);
    } else {
      magasinListe = await MagasinService().fetchAllMagasin();
    }

    return magasinListe;
  }

  Future<List<Magasin>> getAllMagasinBySearch() async {
    magasinList = await MagasinService().fetchSearchItems();
    return magasinList;
  }

  Future<List<Magasin>> fetchMagasin({bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (mounted) if (refresh) {
      setState(() {
        magasinListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Magasin/getAllMagasinWithPagination?page=${page}&size=${size}'));
      print(
          '$apiOnlineUrl/Magasin/getAllMagasinWithPagination?page=${page}&size=${size}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          setState(() {
            List<Magasin> newMagasins =
                body.map((e) => Magasin.fromMap(e)).toList();
            magasinListe.addAll(newMagasins);
          });
        }

        debugPrint(
            "response body all magasins with pagination ${page} par défilement soit ${magasinListe.length}");
        return magasinListe;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des magasins: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return magasinListe;
  }

  Future<List<Magasin>> fetchMagasinByNiveau1PaysWithPagination(
      String idNiveau1Pays,
      {bool refresh = false}) async {
    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        magasinListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Magasin/getAllMagasinByNiveau1PaysWithPagination?idNiveau1Pays=$idNiveau1Pays&page=${page}&size=${size}'));
      debugPrint(
          '$apiOnlineUrl/Magasin/getAllMagasinByNiveau1PaysWithPagination?idNiveau1Pays=$idNiveau1Pays&page=${page}&size=${size}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          setState(() {
            List<Magasin> newMagasin =
                body.map((e) => Magasin.fromMap(e)).toList();
            magasinListe.addAll(newMagasin);
          });
        }

        debugPrint(
            "response body all magasin by niveau 1 pays with pagination ${page} par défilement soit ${magasinListe.length}");
      } else {
        print(
            'Échec de la requête  mag niavec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des magasins: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return magasinListe;
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

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedNiveau1Pays == null) {
      setState(() {
        // Rafraîchir les données ici
        page++;
      });
      debugPrint("yes - fetch all magasin");
      fetchMagasin().then((value) {
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
        selectedNiveau1Pays != null) {
      debugPrint("yes - fetch by category");
      setState(() {
        // Rafraîchir les données ici
        page++;
      });

      fetchMagasinByNiveau1PaysWithPagination(
              selectedNiveau1Pays!.idNiveau1Pays!)
          .then((value) {
        setState(() {
          // Rafraîchir les données ici
          debugPrint("page inc all ${page}");
        });
      });
    }
    debugPrint("no");
  }

  // FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    final paysProvider = Provider.of<DetectorPays>(context, listen: false);
    paysProvider.hasLocation
        ? detectedCountry =
            Provider.of<DetectorPays>(context, listen: false).detectedCountry!
        : detectedCountry = "Mali";
    print("pays dans store : $detectedCountry");
    verify();

    _searchController = TextEditingController();
    _paysList = http.get(Uri.parse('$apiOnlineUrl/pays/read'));
    _magasinList = getAllMagasinBySearch();
    _niveau1PaysList = http.get(
        Uri.parse('$apiOnlineUrl/niveau1Pays/listeNiveau1PaysByIdPays/${id}'));
    magasinListeFuture = magasinListeFuture1 = getAllMagasins();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController1.addListener(_scrollListener1);
    });
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
  void dispose() {
    scrollableController.dispose();
    scrollableController1.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getResultFromNextScreen2(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddMagasinScreen(
                  isEditable: false,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        magasinListeFuture = MagasinService().fetchAllMagasin();
      });
    }
  }

  Future<void> _getResultFromMagasinPage(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyStoresScreen()));
    log(result.toString());
    if (result == true) {
      setState(() {
        magasinListeFuture = MagasinService().fetchAllMagasin();
      });
    }
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
              'Tous les magasins',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            actions:
                //  !isExist?
                [
              IconButton(
                  onPressed: () {
                    magasinListeFuture = MagasinService().fetchAllMagasin();
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white)),
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
                                                    value: 'store',
                                                    child: ListTile(
                                                      leading: const Icon(
                                                        Icons.remove_red_eye,
                                                        color: d_colorGreen,
                                                      ),
                                                      title: const Text(
                                                        "Mes magasins",
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
                                                  if (value == 'add_store') {
                                                    _getResultFromNextScreen2(
                                                        context);
                                                  } else if (value == 'store') {
                                                    _getResultFromMagasinPage(
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
                                          selectedNiveau1Pays = null;
                                          magasinListeFuture = MagasinService()
                                              .fetchAllMagasin();
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
                                                suffixIcon: Icon(Icons.search,
                                                    size: 19),
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
                                                    suffixIcon: Icon(
                                                        Icons.search,
                                                        size: 19),
                                                    labelText:
                                                        " Aucun pays trouvé"),
                                                cursorColor: Colors.green,
                                              );
                                            }

                                            return DropdownFormField<Pays>(
                                              onEmptyActionPressed:
                                                  (String str) async {},
                                              dropdownHeight: 200,
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
                                                  // label: Text("label"),

                                                  labelText:
                                                      "  Filtrer par pays"),
                                              onSaved: (dynamic pays) {
                                                print("onSaved : $pays");
                                              },
                                              onChanged: (dynamic p) {
                                                setState(() {
                                                  if (p != null) {
                                                    pays = paysList.firstWhere(
                                                        (element) =>
                                                            element.idPays ==
                                                            p.idPays);
                                                    _niveau1PaysList = http.get(
                                                        Uri.parse(
                                                            '$apiOnlineUrl/niveau1Pays/listeNiveau1PaysByIdPays/${p.idPays}'));
                                                  }
                                                });
                                              },
                                              displayItemFn: (dynamic item) =>
                                                  Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: Text(
                                                  item?.nomPays ?? '',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              findFn: (String str) async =>
                                                  paysList,
                                              selectedFn: (dynamic item1,
                                                  dynamic item2) {
                                                if (item1 != null &&
                                                    item2 != null) {
                                                  return item1.idPays ==
                                                      item2.idPays;
                                                }
                                                return false;
                                              },
                                              filterFn: (dynamic item,
                                                      String str) =>
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
                                                title: Text(
                                                  item.nomPays!,
                                                ),
                                                tileColor: focused
                                                    ? Color.fromARGB(
                                                        20, 0, 0, 0)
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
                                      future: _niveau1PaysList,
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
                                                suffixIcon: Icon(Icons.search,
                                                    size: 19),
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
                                            final reponse = responseData;
                                            final niveau3List = reponse
                                                .map((e) =>
                                                    Niveau1Pays.fromMap(e))
                                                .where((con) =>
                                                    con.statutN1 == true)
                                                .toList();
                                            if (niveau3List.isEmpty) {
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
                                                    suffixIcon: Icon(
                                                        Icons.search,
                                                        size: 19),
                                                    labelText:
                                                        " Aucune région trouvé"),
                                                cursorColor: Colors.green,
                                              );
                                            }

                                            return DropdownFormField<
                                                Niveau1Pays>(
                                              onEmptyActionPressed:
                                                  (String str) async {},
                                              dropdownHeight: 200,
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
                                                  suffixIcon: Icon(
                                                    Icons.search,
                                                    size: 19,
                                                  ),
                                                  // label: Text("label"),
                                                  labelText:
                                                      " Filtrer par région"),
                                              onSaved: (dynamic n) {
                                                // niveau3 = n?.nomN3;
                                                print("onSaved : $n");
                                              },
                                              onChanged: (dynamic n) {
                                                setState(() {
                                                  if (n != null) {
                                                    selectedNiveau1Pays = n;
                                                  }
                                                  page = 0;
                                                  hasMore = true;
                                                  fetchMagasinByNiveau1PaysWithPagination(
                                                      selectedNiveau1Pays!
                                                          .idNiveau1Pays!,
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
                                                        horizontal: 15),
                                                child: Text(
                                                  item?.nomN1 ?? '',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              findFn: (String str) async =>
                                                  niveau3List,
                                              selectedFn: (dynamic item1,
                                                  dynamic item2) {
                                                if (item1 != null &&
                                                    item2 != null) {
                                                  return item1.idNiveau1Pays ==
                                                      item2.idNiveau1Pays;
                                                }
                                                return false;
                                              },
                                              filterFn: (dynamic item,
                                                      String str) =>
                                                  item.nomN1!
                                                      .toLowerCase()
                                                      .contains(
                                                          str.toLowerCase()),
                                              dropdownItemFn: (dynamic item,
                                                      int position,
                                                      bool focused,
                                                      bool selected,
                                                      Function() onTap) =>
                                                  ListTile(
                                                title: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Text(item.nomN1!),
                                                ),
                                                tileColor: focused
                                                    ? Color.fromARGB(
                                                        20, 0, 0, 0)
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
                                                  Icon(Icons.search, size: 18),
                                              labelText:
                                                  "Aucune région trouvé"),
                                          cursorColor: Colors.green,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        Visibility(
                            visible: isSearchMode,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              child: FutureBuilder<List<Magasin>>(
                                future: _magasinList,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SearchFieldAutoComplete<String>(
                                      placeholder: 'Rechercher...',
                                      suggestions: [],
                                    );
                                  } else {
                                    magasinListeSearch = snapshot.data!;
                                    return SearchFieldAutoComplete<String>(
                                      controller: _searchController,
                                      // focusNode: _focusNode,
                                      placeholder: 'Rechercher...',
                                      placeholderStyle: TextStyle(
                                          fontStyle: FontStyle.italic),
                                      suggestions: magasinListeSearch
                                          .map((item) =>
                                              SearchFieldAutoCompleteItem<
                                                  String>(
                                                searchKey: item.nomMagasin!,
                                                value: item.nomMagasin!,
                                              ))
                                          .toList(),
                                      suggestionsDecoration:
                                          SuggestionDecoration(
                                        marginSuggestions:
                                            const EdgeInsets.all(8.0),
                                        color: const Color.fromARGB(
                                            255, 236, 234, 234),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      onSuggestionSelected: (selectedItem) {
                                        if (mounted) {
                                          _searchController.text =
                                              selectedItem.searchKey;
                                          FocusScope.of(context).unfocus();
                                        }
                                      },
                                      suggestionItemBuilder:
                                          (context, searchFieldItem) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            searchFieldItem.searchKey,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            )),
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
                        selectedNiveau1Pays != null
                            ? setState(() {
                                magasinListeFuture1 = MagasinService()
                                    .fetchMagasinByNiveau1PaysWithPagination(
                                        selectedNiveau1Pays!.idNiveau1Pays!);
                              })
                            : setState(() {
                                magasinListeFuture =
                                    MagasinService().fetchAllMagasin();
                              });
                      },
                      child: selectedNiveau1Pays == null
                          ? SingleChildScrollView(
                              controller: scrollableController,
                              child: Consumer<MagasinService>(
                                  builder: (context, magasinService, child) {
                                return FutureBuilder<List<Magasin>>(
                                    future: magasinListeFuture,
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
                                                  Text("Aucun magasin trouvé")),
                                        );
                                      } else {
                                        magasinListe = snapshot.data!;
                                        String searchText = "";

                                        List<Magasin> produitsLocaux =
                                            magasinListe
                                                .where(
                                          (element) =>
                                              element
                                                  .acteur!.niveau3PaysActeur! ==
                                              detectedCountry!,
                                        )
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomMagasin!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Magasin> produitsEtrangers =
                                            magasinListe
                                                .where(
                                          (element) =>
                                              element
                                                  .acteur!.niveau3PaysActeur! !=
                                              detectedCountry,
                                        )
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomMagasin!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Magasin> filteredSearch =
                                            magasinListe.where((cate) {
                                          String nomCat =
                                              cate.nomMagasin!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
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
                                                          'Aucun magasin trouvé',
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
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => ProductsByStoresScreen(
                                                                      id: produitsLocaux[
                                                                              index]
                                                                          .idMagasin,
                                                                      nom: produitsLocaux[
                                                                              index]
                                                                          .nomMagasin,
                                                                      pays: produitsLocaux[
                                                                              index]
                                                                          .pays),
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
                                                                          72,
                                                                      child: produitsLocaux[index].photo == null ||
                                                                              produitsLocaux[index].photo!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/Magasin/${produitsLocaux[index].idMagasin}/image",
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
                                                                          .nomMagasin!,
                                                                      maxLines:
                                                                          2,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      produitsLocaux[
                                                                              index]
                                                                          .localiteMagasin!,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  _buildItem(produitsLocaux[
                                                                          index]
                                                                      .contactMagasin!)
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
                                                  if (produitsEtrangers
                                                      .isNotEmpty) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Magasins autre pays",
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
                                                                          ProductsByStoresScreen(
                                                                    id: produitsEtrangers[
                                                                            index]
                                                                        .idMagasin,
                                                                    nom: produitsEtrangers[
                                                                            index]
                                                                        .nomMagasin,
                                                                    pays: produitsEtrangers[
                                                                            index]
                                                                        .pays,
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
                                                                          72,
                                                                      child: produitsEtrangers[index].photo == null ||
                                                                              produitsEtrangers[index].photo!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/Magasin/${produitsEtrangers[index].idMagasin}/image",
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
                                                                          .nomMagasin!,
                                                                      maxLines:
                                                                          2,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      produitsEtrangers[
                                                                              index]
                                                                          .localiteMagasin!,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  _buildItem(produitsEtrangers[
                                                                          index]
                                                                      .contactMagasin!)
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
                                                ],
                                              );
                                      }
                                    });
                              }),
                            )
                          : SingleChildScrollView(
                              controller: scrollableController1,
                              child: Consumer<MagasinService>(
                                  builder: (context, magasinService, child) {
                                return FutureBuilder<List<Magasin>>(
                                    future: magasinListeFuture1,
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
                                                    'Aucun magasin trouvé',
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
                                        );
                                      } else {
                                        magasinListe = snapshot.data!;
                                        String searchText = "";
                                        List<Magasin> produitsLocaux =
                                            magasinListe
                                                .where(
                                          (element) =>
                                              element
                                                  .acteur!.niveau3PaysActeur! ==
                                              detectedCountry!,
                                        )
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomMagasin!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Magasin> produitsEtrangers =
                                            magasinListe
                                                .where(
                                          (element) =>
                                              element
                                                  .acteur!.niveau3PaysActeur! !=
                                              detectedCountry,
                                        )
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomMagasin!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Magasin> filteredSearch =
                                            magasinListe.where((cate) {
                                          String nomCat =
                                              cate.nomMagasin!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();
                                        return filteredSearch
                                                    // .where((element) => element.statutMagasin == true)
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
                                                          'Aucun magasin trouvé',
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
                                            : filteredSearch.isEmpty &&
                                                    isLoading == true
                                                ? _buildShimmerEffect()
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
                                                            mainAxisSpacing: 10,
                                                            crossAxisSpacing:
                                                                10,
                                                            childAspectRatio:
                                                                0.8,
                                                          ),
                                                          itemCount:
                                                              produitsLocaux
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            if (index <
                                                                produitsLocaux
                                                                    .length) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              ProductsByStoresScreen(
                                                                        id: produitsLocaux[index]
                                                                            .idMagasin,
                                                                        nom: produitsLocaux[index]
                                                                            .nomMagasin,
                                                                        pays: produitsLocaux[index]
                                                                            .pays,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Card(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              72,
                                                                          child: produitsLocaux[index].photo == null || produitsLocaux[index].photo!.isEmpty
                                                                              ? Image.asset(
                                                                                  "assets/images/default_image.png",
                                                                                  fit: BoxFit.cover,
                                                                                )
                                                                              : CachedNetworkImage(
                                                                                  imageUrl: "https://koumi.ml/api-koumi/Magasin/${produitsLocaux[index].idMagasin}/image",
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
                                                                              .nomMagasin!,
                                                                          maxLines:
                                                                              2,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                        subtitle:
                                                                            Text(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          produitsLocaux[index]
                                                                              .localiteMagasin!,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      _buildItem(
                                                                          produitsLocaux[index]
                                                                              .contactMagasin!)
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
                                                                          vertical:
                                                                              32),
                                                                      child: Center(
                                                                          child: const Center(
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
                                                      ],
                                                      if (produitsEtrangers
                                                          .isNotEmpty) ...[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            "Magasins autre pays",
                                                            style: TextStyle(
                                                                color:
                                                                    d_colorGreen,
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
                                                            mainAxisSpacing: 10,
                                                            crossAxisSpacing:
                                                                10,
                                                            childAspectRatio:
                                                                0.8,
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
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              ProductsByStoresScreen(
                                                                        id: produitsEtrangers[index]
                                                                            .idMagasin,
                                                                        nom: produitsEtrangers[index]
                                                                            .nomMagasin,
                                                                        pays: produitsEtrangers[index]
                                                                            .pays,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Card(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              72,
                                                                          child: produitsEtrangers[index].photo == null || produitsEtrangers[index].photo!.isEmpty
                                                                              ? Image.asset(
                                                                                  "assets/images/default_image.png",
                                                                                  fit: BoxFit.cover,
                                                                                )
                                                                              : CachedNetworkImage(
                                                                                  imageUrl: "https://koumi.ml/api-koumi/Magasin/${produitsEtrangers[index].idMagasin}/image",
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
                                                                              .nomMagasin!,
                                                                          maxLines:
                                                                              2,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                        subtitle:
                                                                            Text(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          produitsEtrangers[index]
                                                                              .localiteMagasin!,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      _buildItem(
                                                                          produitsEtrangers[index]
                                                                              .contactMagasin!)
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
                                                                          vertical:
                                                                              32),
                                                                      child: Center(
                                                                          child: const Center(
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
                                                      ],
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

  Widget _buildItem(String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        maxLines: 2,
        style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            overflow: TextOverflow.ellipsis,
            fontSize: 16),
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
      List<Niveau1Pays> niveau1PaysList) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      items: niveau1PaysList
          .map((e) => DropdownMenuItem(
                value: e.idNiveau1Pays,
                child: Text(e.nomN1!),
              ))
          .toList(),
      hint: Text("--Filtrer par région--"),
      value: typeValue,
      onChanged: (newValue) {
        setState(() {
          typeValue = newValue;
          if (newValue != null) {
            selectedNiveau1Pays = niveau1PaysList.firstWhere(
              (element) => element.idNiveau1Pays == newValue,
            );
          }
          page = 0;
          hasMore = true;
          fetchMagasinByNiveau1PaysWithPagination(
              selectedNiveau1Pays!.idNiveau1Pays!,
              refresh: true);
          if (page == 0 && isLoading == true) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              scrollableController1.jumpTo(0.0);
            });
          }
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }

  DropdownButtonFormField buildEmptyDropdown() {
    return DropdownButtonFormField(
      items: [],
      isExpanded: true,
      onChanged: null,
      decoration: InputDecoration(
        labelText: '-- Aucune région trouvé --',
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
      isExpanded: true,
      onChanged: null,
      decoration: InputDecoration(
        labelText: 'Chargement...',
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
