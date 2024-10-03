import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Magasin.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddMagasinScreen.dart';
import 'package:koumi/screens/MyProduct.dart';
import 'package:koumi/screens/ProductsByStores.dart';
import 'package:koumi/service/MagasinService.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MyStoresScreen extends StatefulWidget {
  const MyStoresScreen({super.key});

  @override
  State<MyStoresScreen> createState() => _MyStoresScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _MyStoresScreenState extends State<MyStoresScreen> {
  late Acteur acteur;
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late TextEditingController _searchController;
  List<Magasin> magasinListe = [];
  Future? futureList;
  Niveau1Pays? selectedNiveau1Pays;
  String? typeValue;
  late Future _niveau1PaysList;
  late Future<List<Magasin>> magasinListeFuture;
  bool isExist = false;
  String? email = "";

  int page = 0;
  bool isLoading = false;
  int size = 100;
  bool hasMore = true;
  ScrollController scrollableController = ScrollController();

  Future<List<Magasin>> fetchMagasins() async {
    if (selectedNiveau1Pays != null) {
      magasinListe = await MagasinService().fetchMagasinByRegionAndActeur(
          acteur.idActeur!, selectedNiveau1Pays!.idNiveau1Pays!);
    }
    return magasinListe;
  }

  Future<List<Magasin>> fetchMagasinss() async {
    magasinListe =
        await MagasinService().fetchMagasinByActeur(acteur.idActeur!);
    return magasinListe;
  }

  Future<List<Magasin>> fetchMagasinByActeur(String idActeur,
      {bool refresh = false}) async {
    // if (_stockService.isLoading == true) return [];

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
          '$apiOnlineUrl/Magasin/getAllMagasinsByActeurWithPagination?idActeur=$idActeur&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          setState(() {
            List<Magasin> newMag = body.map((e) => Magasin.fromMap(e)).toList();
            magasinListe.addAll(newMag);
          });
        }

        debugPrint(
            "response body all intrant by acteur with pagination ${page} par défilement soit ${magasinListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des intrant: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return magasinListe;
  }

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading) {
      // if (selectedCat != null) {
      // Incrementez la page et récupérez les stocks par catégorie
      debugPrint("yes - fetch magasin by acteur");
      setState(() {
        // Rafraîchir les données ici
        page++;
      });
      fetchMagasinByActeur(acteur.idActeur!).then((value) {
        setState(() {
          // Rafraîchir les données ici
        });
      });
    } else {
      debugPrint("no");
    }
  }

  @override
  void initState() {
    super.initState();

    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _searchController = TextEditingController();
    _niveau1PaysList = http.get(Uri.parse('$apiOnlineUrl/niveau1Pays/read'));
    futureList = fetchMagasinByActeur(acteur.idActeur!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController.addListener(_scrollListener);
    });
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
        futureList = MagasinService()
            .fetchMagasinByActeur(acteur.idActeur!, refresh: true);
      });
    }
  }

  bool isSearchMode = false;

  Future<void> _getResultFromNextScreen1(
      BuildContext context, Magasin m) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: AddMagasinScreen(
                magasin: m,
                isEditable: true,
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
        transitionDuration:
            const Duration(milliseconds: 500), // Durée de la transition
      ),
    );
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        futureList = MagasinService()
            .fetchMagasinByActeur(acteur.idActeur!, refresh: true);
      });
    }
  }

  @override
  void dispose() {
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
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
          title: Text(
            'Mes magasins',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
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
                                      ],
                                      elevation: 8.0,
                                    ).then((value) {
                                      if (value != null) {
                                        if (value == 'add_store') {
                                          _getResultFromNextScreen2(context);
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
                                ),
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
                                          _searchController.clear();
                                          _searchController =
                                              TextEditingController();
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
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .blueGrey[50], // Couleur d'arrière-plan
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search,
                                        color: Colors.blueGrey[400],
                                        size:
                                            28), // Utiliser une icône de recherche plus grande
                                    SizedBox(width: 10),
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
                                              color: Colors.blueGrey[400]),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ])),
                    ];
                  },
                  body: RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          page = 0;

                          futureList = MagasinService().fetchMagasinByActeur(
                              acteur.idActeur!,
                              refresh: true);
                        });
                        debugPrint("refresh page ${page}");
                      },
                      child: SingleChildScrollView(
                        controller: scrollableController,
                        child: Consumer<MagasinService>(
                            builder: (context, magasinService, child) {
                          return FutureBuilder(
                              future: futureList,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _buildShimmerEffect();
                                }

                                if (!snapshot.hasData) {
                                  return const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                        child: Text("Aucun données trouvée")),
                                  );
                                } else {
                                  magasinListe = snapshot.data!;
                                  String searchText = "";
                                  List<Magasin> filtereSearch =
                                      magasinListe.where((search) {
                                    String libelle =
                                        search.nomMagasin!.toLowerCase();
                                    searchText = _searchController.text
                                        .trim()
                                        .toLowerCase();
                                    return libelle.contains(searchText);
                                  }).toList();
                                  return filtereSearch.isEmpty
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
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            childAspectRatio: 0.8,
                                          ),
                                          itemCount: filtereSearch.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index < filtereSearch.length) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductsByStoresScreen(
                                                              id: filtereSearch[
                                                                      index]
                                                                  .idMagasin,
                                                              nom: filtereSearch[
                                                                      index]
                                                                  .nomMagasin,
                                                              pays:
                                                                  filtereSearch[
                                                                          index]
                                                                      .pays),
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
                                                        child: Container(
                                                          height: 72,
                                                          child: filtereSearch[
                                                                              index]
                                                                          .photo ==
                                                                      null ||
                                                                  filtereSearch[
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
                                                                      "https://koumi.ml/api-koumi/Magasin/${filtereSearch[index].idMagasin}/image",
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
                                                          filtereSearch[index]
                                                              .nomMagasin!,
                                                          style: TextStyle(
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
                                                        subtitle: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          filtereSearch[index]
                                                              .niveau1Pays!
                                                              .nomN1!,
                                                          style: TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                                filtereSearch[
                                                                        index]
                                                                    .statutMagasin!),
                                                            SizedBox(
                                                              width: 110,
                                                            ),
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
                                                                    leading: filtereSearch[index].statutMagasin ==
                                                                            false
                                                                        ? Icon(
                                                                            Icons.check,
                                                                            color:
                                                                                Colors.green,
                                                                          )
                                                                        : Icon(
                                                                            Icons
                                                                                .disabled_visible,
                                                                            color:
                                                                                d_colorGreen),
                                                                    title: Text(
                                                                      filtereSearch[index].statutMagasin ==
                                                                              false
                                                                          ? "Activer"
                                                                          : "Desactiver",
                                                                      style:
                                                                          TextStyle(
                                                                        color: filtereSearch[index].statutMagasin ==
                                                                                false
                                                                            ? Colors.green
                                                                            : d_colorGreen,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    onTap:
                                                                        () async {
                                                                      // Changement d'état du magasin ici

                                                                      filtereSearch[index].statutMagasin ==
                                                                              false
                                                                          ? await MagasinService()
                                                                              .activerMagasin(filtereSearch[index].idMagasin!)
                                                                              .then((value) => {
                                                                                    // Mettre à jour la liste des magasins après le changement d'état
                                                                                    Provider.of<MagasinService>(context, listen: false).applyChange(),
                                                                                    setState(() {
                                                                                      page++;
                                                                                      magasinListeFuture = MagasinService().fetchMagasinByActeur(acteur.idActeur!);
                                                                                    }),
                                                                                    Navigator.of(context).pop(),
                                                                                  })
                                                                              .catchError((onError) => {
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
                                                                          : await MagasinService().desactiverMagasin(filtereSearch[index].idMagasin!).then((value) => {
                                                                                Provider.of<MagasinService>(context, listen: false).applyChange(),
                                                                                setState(() {
                                                                                  page++;
                                                                                  magasinListeFuture = MagasinService().fetchMagasinByActeur(acteur.idActeur!);
                                                                                }),
                                                                                Navigator.of(context).pop(),
                                                                              });

                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Row(
                                                                            children: [
                                                                              Text(filtereSearch[index].statutMagasin == false ? "Activer avec succèss " : "Desactiver avec succèss"),
                                                                            ],
                                                                          ),
                                                                          duration:
                                                                              Duration(seconds: 2),
                                                                        ),
                                                                      );
                                                                    },
                                                                  )),
                                                                  PopupMenuItem<
                                                                      String>(
                                                                    child:
                                                                        ListTile(
                                                                      leading:
                                                                          Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: Colors
                                                                            .green[400],
                                                                      ),
                                                                      title:
                                                                          Text(
                                                                        "Modifier",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.green[400],
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        _getResultFromNextScreen1(
                                                                            context,
                                                                            filtereSearch[index]);
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
                                                                        await MagasinService()
                                                                            .deleteMagasin(filtereSearch[index]
                                                                                .idMagasin!)
                                                                            .then((value) =>
                                                                                {
                                                                                  Provider.of<MagasinService>(context, listen: false).applyChange(),
                                                                                  setState(() {
                                                                                    magasinListeFuture = MagasinService().fetchMagasinByActeur(acteur.idActeur!);
                                                                                  }),
                                                                                  Navigator.of(context).pop(),
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    const SnackBar(
                                                                                      content: Row(
                                                                                        children: [
                                                                                          Text("Magasin supprimer avec succès"),
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
                                                ),
                                              );
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
                                                          color: d_colorGreen,
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

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16),
            ),
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
}

/*

*/
