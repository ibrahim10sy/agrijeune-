import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/DetailMateriel.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Materiels.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/models/TypeMateriel.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:koumi/screens/AddMateriel.dart';
import 'package:koumi/screens/ListeMaterielByActeur.dart';
import 'package:koumi/service/MaterielService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:search_field_autocomplete/search_field_autocomplete.dart';

class Location extends StatefulWidget {
  Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _LocationState extends State<Location> {
  // late TypeMateriel type = TypeMateriel();
  List<Materiels> materielListe = [];
  late Acteur acteur;
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late Future<List<Materiels>> materielListeFuture;
  late Future<List<Materiels>> materielListeFuture1;
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  String? nomP;
  late Future _paysList;
  bool isExist = false;
  String? email = "";
  String? typeValue;
  TypeMateriel? selectedType;
  late Future _typeList;
  bool isSearchMode = false;
  bool isFilterMode = false;
  CountryProvider? countryProvider;
  String? detectedCountry;

  ScrollController scrollableController = ScrollController();
  ScrollController scrollableController1 = ScrollController();

  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;

  bool isLoadingLibelle = true;

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedType == null) {
      if (mounted)
        setState(() {
          // Rafraîchir les données ici
          page++;
        });
      debugPrint("yes - fetch all materiel by pays");
      fetchMateriel(detectedCountry != null ? detectedCountry! : "mali")
          .then((value) {
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
        selectedType != null) {
      if (mounted) debugPrint("yes - fetch by type and pays");
      setState(() {
        page++;
      });

      fetchMaterielByType(detectedCountry != null ? detectedCountry! : "mali");
    } else if (nomP != null && nomP!.isNotEmpty) {
      debugPrint("yes - fetch by country");
      if (mounted)
        setState(() {
          page++;
        });

      fetchAllByPays().then((value) {
        setState(() {
          debugPrint("page pour pays ${nomP} inc all ${page}");
        });
      });
    }
    debugPrint("no");
  }

  Future<List<Materiels>> fetchMateriel(String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (mounted) if (refresh) {
      setState(() {
        materielListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getMaterielsByPaysWithPagination?niveau3PaysActeur=$niveau3PaysActeur&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();
          setState(() {
            materielListe.addAll(newMateriels.where((newMateriel) =>
                !materielListe.any((existeMate) =>
                    existeMate.idMateriel == newMateriel.idMateriel)));
          });
        }

        debugPrint(
            "response body all materiel with pagination ${page} par défilement soit ${materielListe.length}");
        return materielListe;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiels: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return materielListe;
  }

  Future<List<Materiels>> fetchAllByPays({bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (mounted) if (refresh) {
      setState(() {
        materielListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getAllByPaysWithPagination?nomPays=$nomP&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();
          setState(() {
            materielListe.addAll(newMateriels.where((newMateriel) =>
                !materielListe.any((existeMate) =>
                    existeMate.idMateriel == newMateriel.idMateriel)));
          });
        }

        debugPrint(
            "response body all materiel with pagination ${page} par défilement soit ${materielListe.length}");
        return materielListe;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiels: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return materielListe;
  }

  Future<List<Materiels>> fetchMaterielByType(String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        materielListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getMaterielsByPaysAndTypeMaterielWithPagination?idTypeMateriel=${selectedType!.idTypeMateriel}&niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();
          setState(() {
            materielListe.addAll(newMateriels.where((newMateriel) =>
                !materielListe.any((existeMate) =>
                    existeMate.idMateriel == newMateriel.idMateriel)));
          });
        }

        debugPrint(
            "response body all materiel by type mateirle and pays with pagination ${page} par défilement soit ${materielListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiel: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return materielListe;
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

  Future<List<Materiels>> getAllMateriel() async {
    if (selectedType != null) {
      materielListe = await MaterielService()
          .fetchMaterielByTypeAndPaysWithPagination(
              selectedType!.idTypeMateriel!);
    } else if (nomP != null) {
      materielListe = await MaterielService().fetchMaterielByPays(nomP!);
    } else {
      materielListe = await MaterielService()
          .fetchMateriel(detectedCountry != null ? detectedCountry! : "mali");
    }
    return materielListe;
  }

  void refreshList() {
    setState(() {
      materielListeFuture = materielListeFuture1 = getAllMateriel();
    });
  }

  @override
  void initState() {
    super.initState();
    _paysList = http.get(Uri.parse('$apiOnlineUrl/pays/read'));
    verify();
    final paysProvider = Provider.of<DetectorPays>(context, listen: false);
    paysProvider.hasLocation
        ? detectedCountry =
            Provider.of<DetectorPays>(context, listen: false).detectedCountry!
        : detectedCountry = "Mali";
    detectedCountry != null
        ? debugPrint("pays fetch location materiel page ${detectedCountry!} ")
        : debugPrint("null pays non fetch location materiel page");
    _searchController = TextEditingController();
    _typeList = http.get(Uri.parse('$apiOnlineUrl/TypeMateriel/read'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //code will run when widget rendering complete
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //code will run when widget rendering complete
      scrollableController1.addListener(_scrollListener1);
    });
    if (detectedCountry != null) {
      print("pays location ! ${detectedCountry}");
    } else {
      print("pays location null");
    }
    materielListeFuture = materielListeFuture1 = getAllMateriel();
    // refreshList();
  }

  Future<void> _getResultFromNextScreen1(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddMateriel(isEquipement: false)));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        materielListeFuture = getAllMateriel();
      });
    }
  }

  Future<void> _getResultFromNextScreen2(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListeMaterielByActeur(
                  isRoute: true,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        materielListeFuture = getAllMateriel();
      });
    }
  }

  Future<void> _getResultFromNextScreen3(
      BuildContext context, Materiels materiel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailMateriel(materiel: materiel),
      ),
    );
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        materielListeFuture = getAllMateriel();
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
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          title: Text(
            "Location Matériel",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions:
              // !isExist
              //     ?
              [
            IconButton(
                onPressed: () {
                  materielListeFuture = getAllMateriel();
                },
                icon: const Icon(Icons.refresh, color: Colors.white)),
          ],
         
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
                                                value: 'add_mat',
                                                child: ListTile(
                                                  leading: const Icon(
                                                    Icons.add,
                                                    color: d_colorGreen,
                                                  ),
                                                  title: const Text(
                                                    "Ajouter un matériel",
                                                    style: TextStyle(
                                                      color: d_colorGreen,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'mesMat',
                                                child: ListTile(
                                                  leading: const Icon(
                                                    Icons.remove_red_eye,
                                                    color: d_colorGreen,
                                                  ),
                                                  title: const Text(
                                                    "Mes matériels",
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
                                              if (value == 'add_mat') {
                                                _getResultFromNextScreen1(
                                                    context);
                                              } else if (value == 'mesMat') {
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
                                          selectedType =
                                              null; // Réinitialiser la catégorie sélectionnée
                                          materielListeFuture =
                                              MaterielService().fetchMateriel(
                                                  detectedCountry != null
                                                      ? detectedCountry!
                                                      : "mali",
                                                  refresh: true);
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
                                                fetchAllByPays(refresh: true);
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
                                              icon: Icon(Icons.search),
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
                                                  TypeMateriel.fromMap(e))
                                              .where((con) =>
                                                  con.statutType == true)
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
                                                      " Aucune type trouvé"),
                                              cursorColor: Colors.green,
                                            );
                                          }

                                          return DropdownFormField<
                                              TypeMateriel>(
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
                                                labelText: " Filtrer par type"),
                                            onSaved: (dynamic cat) {
                                              selectedType = cat;
                                              print("onSaved : $cat");
                                            },
                                            onChanged: (dynamic cat) {
                                              setState(() {
                                                selectedType = cat;
                                                page = 0;
                                                hasMore = true;
                                                fetchMaterielByType(
                                                    detectedCountry != null
                                                        ? detectedCountry!
                                                        : "mali",
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
                                                Text(
                                              item?.nom! ?? '',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            findFn: (String str) async =>
                                                paysList,
                                            selectedFn:
                                                (dynamic item1, dynamic item2) {
                                              if (item1 != null &&
                                                  item2 != null) {
                                                return item1.idTypeMateriel ==
                                                    item2.idTypeMateriel;
                                              }
                                              return false;
                                            },
                                            filterFn:
                                                (dynamic item, String str) =>
                                                    item.nom!
                                                        .toLowerCase()
                                                        .contains(
                                                            str.toLowerCase()),
                                            dropdownItemFn: (dynamic item,
                                                    int position,
                                                    bool focused,
                                                    bool selected,
                                                    Function() onTap) =>
                                                ListTile(
                                              title: Text(item.nom!),
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
                                            labelText: " Aucune type trouvé"),
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
                              placeholder: 'Rechercher un matériel ...',
                              placeholderStyle:
                                  TextStyle(fontStyle: FontStyle.italic),
                              suggestions: AutoComplet.getMateriels,
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
                          isLoading = false;
                          // Rafraîchir les données ici
                        });
                        debugPrint("refresh page ${page}");
                        // selectedType != null ?StockService().fetchStockByCategorieWithPagination(selectedCat!.idCategorieProduit!) :
                        selectedType == null || nomP == null
                            ? setState(() {
                                materielListeFuture = MaterielService()
                                    .fetchMateriel(
                                        detectedCountry != null
                                            ? detectedCountry!
                                            : "mali",
                                        refresh: true);
                              })
                            : setState(() {
                                selectedType != null
                                    ? materielListeFuture1 = MaterielService()
                                        .fetchMaterielByTypeAndPaysWithPagination(
                                            selectedType!.idTypeMateriel!,
                                            refresh: true)
                                    : materielListeFuture1 = MaterielService()
                                        .fetchMaterielByPays(nomP!);
                              });
                      },
                      child: selectedType == null && nomP == null
                          ? SingleChildScrollView(
                              controller: scrollableController,
                              child: Consumer<MaterielService>(
                                builder: (context, materielService, child) {
                                  return FutureBuilder(
                                      future: materielListeFuture,
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
                                                      'Aucun materiel trouvé',
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
                                          );
                                        } else {
                                          materielListe = snapshot.data!;
                                          String searchText = "";

                                          List<Materiels> produitsLocaux =
                                              materielListe
                                                  .where((stock) =>
                                                      stock.acteur!
                                                          .niveau3PaysActeur! ==
                                                      detectedCountry)
                                                  .where((cate) {
                                            String nomCat =
                                                cate.nom!.toLowerCase();
                                            searchText = _searchController.text
                                                .toLowerCase();
                                            return nomCat.contains(searchText);
                                          }).toList();

                                          List<Materiels> produitsEtrangers =
                                              materielListe
                                                  .where((stock) =>
                                                      stock.acteur!
                                                          .niveau3PaysActeur! !=
                                                      detectedCountry)
                                                  .where((cate) {
                                            String nomCat =
                                                cate.nom!.toLowerCase();
                                            searchText = _searchController.text
                                                .toLowerCase();
                                            return nomCat.contains(searchText);
                                          }).toList();

                                          List<Materiels> filteredSearch =
                                              materielListe.where((cate) {
                                            String nomCat =
                                                cate.nom!.toLowerCase();
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
                                                            'Aucun materiel trouvé',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
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
                                                          mainAxisSpacing: 10,
                                                          crossAxisSpacing: 10,
                                                          childAspectRatio: 0.8,
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
                                                                _getResultFromNextScreen3(
                                                                    context,
                                                                    produitsLocaux[
                                                                        index]);
                                                              },
                                                              child: Card(
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
                                                                            72,
                                                                        child: produitsLocaux[index].photoMateriel == null ||
                                                                                produitsLocaux[index].photoMateriel!.isEmpty
                                                                            ? Image.asset(
                                                                                "assets/images/default_image.png",
                                                                                fit: BoxFit.cover,
                                                                                height: 85,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                imageUrl: "https://koumi.ml/api-koumi/Materiel/${produitsLocaux[index].idMateriel}/image",
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
                                                                            .nom!,
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
                                                                        produitsLocaux[index]
                                                                            .localisation!,
                                                                        style:
                                                                            TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              15,
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
                                                                        "${produitsLocaux[index].prixParHeure.toString()} ${produitsLocaux[index].monnaie!.libelle}",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.black87,
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
                                                                        child: const Center(
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
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          "Matériel autre pays",
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
                                                          mainAxisSpacing: 10,
                                                          crossAxisSpacing: 10,
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
                                                                // Navigator.push(
                                                                //     context,
                                                                //     MaterialPageRoute(
                                                                //         builder: (context) =>
                                                                //             DetailMateriel(
                                                                //                 materiel:
                                                                //                     filteredSearch[index])));
                                                                _getResultFromNextScreen3(
                                                                    context,
                                                                    produitsEtrangers[
                                                                        index]);
                                                              },
                                                              child: Card(
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
                                                                            72,
                                                                        child: produitsEtrangers[index].photoMateriel == null ||
                                                                                produitsEtrangers[index].photoMateriel!.isEmpty
                                                                            ? Image.asset(
                                                                                "assets/images/default_image.png",
                                                                                fit: BoxFit.cover,
                                                                                height: 85,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                imageUrl: "https://koumi.ml/api-koumi/Materiel/${produitsEtrangers[index].idMateriel}/image",
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
                                                                            .nom!,
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
                                                                        produitsEtrangers[index]
                                                                            .localisation!,
                                                                        style:
                                                                            TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              15,
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
                                                                        "${produitsEtrangers[index].prixParHeure.toString()} ${produitsEtrangers[index].monnaie!.libelle}",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.black87,
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
                                                                        child: const Center(
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
                                },
                              ),
                            )
                          : SingleChildScrollView(
                              controller: scrollableController1,
                              child: Consumer<MaterielService>(
                                builder: (context, materielService, child) {
                                  return FutureBuilder(
                                      future: materielListeFuture1,
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
                                                      'Aucun matériel trouvé',
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
                                          );
                                        } else {
                                          materielListe = snapshot.data!;
                                          String searchText = "";

                                          List<Materiels> produitsLocaux =
                                              materielListe
                                                  .where((stock) =>
                                                      stock.acteur!
                                                          .niveau3PaysActeur! ==
                                                      detectedCountry)
                                                  .where((cate) {
                                            String nomCat =
                                                cate.nom!.toLowerCase();
                                            searchText = _searchController.text
                                                .toLowerCase();
                                            return nomCat.contains(searchText);
                                          }).toList();

                                          List<Materiels> produitsEtrangers =
                                              materielListe
                                                  .where((stock) =>
                                                      stock.acteur!
                                                          .niveau3PaysActeur! !=
                                                      detectedCountry)
                                                  .where((cate) {
                                            String nomCat =
                                                cate.nom!.toLowerCase();
                                            searchText = _searchController.text
                                                .toLowerCase();
                                            return nomCat.contains(searchText);
                                          }).toList();

                                          List<Materiels> filteredSearch =
                                              materielListe.where((cate) {
                                            String nomCat =
                                                cate.nom!.toLowerCase();
                                            searchText = _searchController.text
                                                .toLowerCase();
                                            return nomCat.contains(searchText);
                                          }).toList();
                                          return filteredSearch.isEmpty &&
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
                                                            'Aucun materiel trouvé',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
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
                                                              mainAxisSpacing:
                                                                  10,
                                                              crossAxisSpacing:
                                                                  10,
                                                              childAspectRatio:
                                                                  0.8,
                                                            ),
                                                            itemCount:
                                                                produitsLocaux
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              if (index <
                                                                  produitsLocaux
                                                                      .length) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    _getResultFromNextScreen3(
                                                                        context,
                                                                        produitsLocaux[
                                                                            index]);
                                                                  },
                                                                  child: Card(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .stretch,
                                                                      children: [
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                72,
                                                                            child: produitsLocaux[index].photoMateriel == null || produitsLocaux[index].photoMateriel!.isEmpty
                                                                                ? Image.asset(
                                                                                    "assets/images/default_image.png",
                                                                                    fit: BoxFit.cover,
                                                                                    height: 85,
                                                                                  )
                                                                                : CachedNetworkImage(
                                                                                    imageUrl: "https://koumi.ml/api-koumi/Materiel/${produitsLocaux[index].idMateriel}/image",
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
                                                                            produitsLocaux[index].nom!,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black87,
                                                                            ),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                          subtitle:
                                                                              Text(
                                                                            produitsLocaux[index].localisation!,
                                                                            style:
                                                                                TextStyle(
                                                                              overflow: TextOverflow.ellipsis,
                                                                              fontSize: 15,
                                                                              color: Colors.black87,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 15),
                                                                          child:
                                                                              Text(
                                                                            "${produitsLocaux[index].prixParHeure.toString()} ${produitsLocaux[index].monnaie!.libelle}",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.black87,
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
                                                              "Matériel autre pays",
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
                                                              mainAxisSpacing:
                                                                  10,
                                                              crossAxisSpacing:
                                                                  10,
                                                              childAspectRatio:
                                                                  0.8,
                                                            ),
                                                            itemCount:
                                                                produitsEtrangers
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              if (index <
                                                                  produitsEtrangers
                                                                      .length) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    // Navigator.push(
                                                                    //     context,
                                                                    //     MaterialPageRoute(
                                                                    //         builder: (context) =>
                                                                    //             DetailMateriel(
                                                                    //                 materiel:
                                                                    //                     filteredSearch[index])));
                                                                    _getResultFromNextScreen3(
                                                                        context,
                                                                        produitsEtrangers[
                                                                            index]);
                                                                  },
                                                                  child: Card(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .stretch,
                                                                      children: [
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                72,
                                                                            child: produitsEtrangers[index].photoMateriel == null || produitsEtrangers[index].photoMateriel!.isEmpty
                                                                                ? Image.asset(
                                                                                    "assets/images/default_image.png",
                                                                                    fit: BoxFit.cover,
                                                                                    height: 85,
                                                                                  )
                                                                                : CachedNetworkImage(
                                                                                    imageUrl: "https://koumi.ml/api-koumi/Materiel/${produitsEtrangers[index].idMateriel}/image",
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
                                                                            produitsEtrangers[index].nom!,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black87,
                                                                            ),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                          subtitle:
                                                                              Text(
                                                                            produitsEtrangers[index].localisation!,
                                                                            style:
                                                                                TextStyle(
                                                                              overflow: TextOverflow.ellipsis,
                                                                              fontSize: 15,
                                                                              color: Colors.black87,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 15),
                                                                          child:
                                                                              Text(
                                                                            "${produitsEtrangers[index].prixParHeure.toString()} ${produitsEtrangers[index].monnaie!.libelle}",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors.black87,
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
                                },
                              ),
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

  DropdownButtonFormField<String> buildDropdown(List<TypeMateriel> typeList) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      items: typeList
          .map((e) => DropdownMenuItem(
                value: e.idTypeMateriel,
                child: Text(e.nom!),
              ))
          .toList(),
      hint: Text("-- Filtre par categorie --"),
      value: typeValue,
      onChanged: (newValue) {
        setState(() {
          typeValue = newValue;
          if (newValue != null) {
            selectedType = typeList.firstWhere(
              (element) => element.idTypeMateriel == newValue,
            );
          }
          page = 0;
          hasMore = true;
          fetchMaterielByType(
              detectedCountry != null ? detectedCountry! : "mali",
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
        labelText: '-- Aucun type  trouvé --',
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
