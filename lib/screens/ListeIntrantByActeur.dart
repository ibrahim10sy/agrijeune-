import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Intrant.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddIntrant.dart';
import 'package:koumi/screens/DetailIntrant.dart';
import 'package:koumi/service/IntrantService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListeIntrantByActeur extends StatefulWidget {
  bool? isRoute;
  ListeIntrantByActeur({super.key, this.isRoute});

  @override
  State<ListeIntrantByActeur> createState() => _ListeIntrantByActeurState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _ListeIntrantByActeurState extends State<ListeIntrantByActeur> {
  late TextEditingController _searchController;
  List<Intrant> intrantListe = [];
  Future? futureList;
  late Acteur acteur = Acteur();
  // List<ParametreGeneraux> paraList = [];
  // late ParametreGeneraux para = ParametreGeneraux();

  int page = 0;
  bool isLoading = false;
  int size = 100;
  // int size = sized;
  bool hasMore = true;
  bool isExist = false;
  String? email = "";
  ScrollController scrollableController = ScrollController();

  bool isLoadingLibelle = true;

  Future<List<Intrant>> fetchIntrantByActeur(String idActeur,
      {bool refresh = false}) async {
    // if (_stockService.isLoading == true) return [];

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
          '$apiOnlineUrl/intrant/getAllIntrantsByActeurWithPagination?idActeur=$idActeur&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          setState(() {
            List<Intrant> newIntrant =
                body.map((e) => Intrant.fromMap(e)).toList();
            intrantListe.addAll(newIntrant);
          });
        }

        debugPrint(
            "response body all intrant by acteur with pagination ${page} par défilement soit ${intrantListe.length}");
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
    return intrantListe;
  }

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading) {
      // if (selectedCat != null) {
      // Incrementez la page et récupérez les stocks par catégorie
      debugPrint("yes - fetch intrant by acteur");
      setState(() {
        // Rafraîchir les données ici
        page++;
      });
      fetchIntrantByActeur(acteur.idActeur!).then((value) {
        setState(() {
          // Rafraîchir les données ici
        });
      });
    } else {
      debugPrint("no");
    }
  }

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;

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
    _searchController = TextEditingController();
    // acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    // verify();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;

    futureList = fetchIntrantByActeur(acteur.idActeur!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController.addListener(_scrollListener);
    });
  }

  Future<void> _getResultFromNextScreen(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddIntrant()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        futureList = IntrantService().fetchIntrantByActeurWithPagination(
            acteur.idActeur!,
            refresh: true);
      });
    }
  }

  Future<void> _getResultFromNextScreen1(
      BuildContext context, Intrant? intrant) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailIntrant(
                  intrant: intrant!,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        futureList = IntrantService()
            .fetchIntrantByActeurWithPagination(acteur.idActeur!);
      });
      // (widget.isRoute ?? false)
      //     ? setState(() {
      //         futureList = IntrantService()
      //             .fetchIntrantByActeurWithPagination(acteur.idActeur!);
      //       })
      //     : Container();
    }
  }

  bool isSearchMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    scrollableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
          backgroundColor: d_colorGreen,
          centerTitle: true,
          toolbarHeight: 75,
          leading: (widget.isRoute ?? false)
              ? IconButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                )
              : Container(),
          title: const Text(
            "Mes intrants",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            (widget.isRoute ?? false)
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        futureList = IntrantService()
                            .fetchIntrantByActeurWithPagination(
                                acteur.idActeur!,
                                refresh: true);
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  )
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
                                      "Ajouter un intrant",
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
                                  _getResultFromNextScreen(context);
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
                              style:
                                  TextStyle(color: d_colorGreen, fontSize: 17),
                            ),
                          ),
                        if (isSearchMode)
                          TextButton.icon(
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  isSearchMode = !isSearchMode;
                                  _searchController.clear();
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
                              style: TextStyle(color: Colors.red, fontSize: 17),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSearchMode)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SearchFieldAutoComplete<String>(
                        controller: _searchController,
                        itemHeight: 25,
                        placeholder: 'Rechercher...',
                        placeholderStyle:
                            TextStyle(fontStyle: FontStyle.italic),
                        suggestions: AutoComplet.getAgriculturalInputs,
                        suggestionsDecoration: SuggestionDecoration(
                          marginSuggestions: const EdgeInsets.all(8.0),
                          color: const Color.fromARGB(255, 236, 234, 234),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        onSuggestionSelected: (selectedItem) {
                          _searchController.text = selectedItem.searchKey;
                        },
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {});
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
                ])),
              ];
            },
            body: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  hasMore = true;
                  page = 0;
                  // Rafraîchir les données ici
                  futureList = IntrantService()
                      .fetchIntrantByActeurWithPagination(acteur.idActeur!,
                          refresh: true);
                });
                debugPrint("refresh page ${page}");
              },
              child: SingleChildScrollView(
                  controller: scrollableController,
                  child: Consumer<IntrantService>(
                      builder: (context, intrantService, child) {
                    return FutureBuilder(
                        future: futureList,
                        // : intrantService.fetchIntrantByActeurWithPagination(
                        //     acteur.idActeur!),
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
                                      Image.asset('assets/images/notif.jpg'),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Aucun intrant trouvé',
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
                            intrantListe = snapshot.data!;
                            String searchText = "";
                            List<Intrant> filtereSearch =
                                intrantListe.where((search) {
                              String libelle = search.nomIntrant!.toLowerCase();
                              searchText = _searchController.text.toLowerCase();
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
                                              'Aucun intrant trouvé',
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
                                    itemCount: filtereSearch.length + 1,
                                    itemBuilder: (context, index) {
                                      // var e = intrantListe.elementAt(index);
                                      if (index < filtereSearch.length) {
                                        return GestureDetector(
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         DetailIntrant(
                                            //       intrant: filtereSearch[index],
                                            //     )
                                            //   ),
                                            // );
                                            _getResultFromNextScreen1(
                                                context, filtereSearch[index]);
                                          },
                                          child: Card(
                                            margin: EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: SizedBox(
                                                    height: 72,
                                                    child: filtereSearch[index]
                                                                    .photoIntrant ==
                                                                null ||
                                                            filtereSearch[index]
                                                                .photoIntrant!
                                                                .isEmpty
                                                        ? Image.asset(
                                                            "assets/images/default_image.png",
                                                            fit: BoxFit.cover,
                                                          )
                                                        : CachedNetworkImage(
                                                            imageUrl:
                                                                "https://koumi.ml/api-koumi/intrant/${filtereSearch[index].idIntrant}/image",
                                                            fit: BoxFit.cover,
                                                            placeholder: (context,
                                                                    url) =>
                                                                const Center(
                                                                    child:
                                                                        CircularProgressIndicator()),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Image.asset(
                                                              'assets/images/default_image.png',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                    filtereSearch[index]
                                                        .nomIntrant!,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  subtitle: Text(
                                                    "${filtereSearch[index].prixIntrant.toString()} ${filtereSearch[index].monnaie!.libelle}",
                                                    style: TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 15,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
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
                                                          filtereSearch[index]
                                                              .statutIntrant!),
                                                      PopupMenuButton<String>(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        itemBuilder:
                                                            (context) =>
                                                                <PopupMenuEntry<
                                                                    String>>[
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  const Icon(
                                                                Icons.edit,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              title: const Text(
                                                                "Modifier la quantité",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                await afficherBottomSheet(
                                                                        context,
                                                                        filtereSearch[
                                                                            index])
                                                                    .then(
                                                                        (value) {
                                                                  Provider.of<IntrantService>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .applyChange();
                                                                  setState(() {
                                                                    page++;
                                                                    futureList =
                                                                        IntrantService()
                                                                            .fetchIntrantByActeurWithPagination(acteur.idActeur!);
                                                                  });
                                                                  // Navigator.of(context).pop();
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading: filtereSearch[
                                                                              index]
                                                                          .statutIntrant ==
                                                                      false
                                                                  ? Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .green,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .disabled_visible,
                                                                      color: Colors
                                                                              .orange[
                                                                          400],
                                                                    ),
                                                              title: Text(
                                                                filtereSearch[index]
                                                                            .statutIntrant ==
                                                                        false
                                                                    ? "Activer"
                                                                    : "Desactiver",
                                                                style:
                                                                    TextStyle(
                                                                  color: filtereSearch[index]
                                                                              .statutIntrant ==
                                                                          false
                                                                      ? Colors
                                                                          .green
                                                                      : Colors.orange[
                                                                          400],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                filtereSearch[index]
                                                                            .statutIntrant ==
                                                                        false
                                                                    ? await IntrantService()
                                                                        .activerIntrant(filtereSearch[index]
                                                                            .idIntrant!)
                                                                        .then((value) =>
                                                                            {
                                                                              Navigator.of(context).pop(),
                                                                              Provider.of<IntrantService>(context, listen: false).applyChange(),
                                                                              setState(() {
                                                                                page++;
                                                                                futureList = IntrantService().fetchIntrantByActeurWithPagination(acteur.idActeur!);
                                                                              }),
                                                                              // Navigator.of(context).pop(),
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
                                                                                })
                                                                    : await IntrantService()
                                                                        .desactiverIntrant(filtereSearch[index]
                                                                            .idIntrant!)
                                                                        .then((value) =>
                                                                            {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(
                                                                                  content: Row(
                                                                                    children: [
                                                                                      Text("Désactiver avec succèss "),
                                                                                    ],
                                                                                  ),
                                                                                  duration: Duration(seconds: 2),
                                                                                ),
                                                                              ),
                                                                              Navigator.of(context).pop(),
                                                                              Provider.of<IntrantService>(context, listen: false).applyChange(),
                                                                              setState(() {
                                                                                page++;
                                                                                futureList = IntrantService().fetchIntrantByActeurWithPagination(acteur.idActeur!);
                                                                              }),
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
                                                                              // Navigator.of(context).pop(),
                                                                            });
                                                              },
                                                            ),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              title: const Text(
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
                                                              onTap: () async {
                                                                await IntrantService()
                                                                    .deleteIntrant(
                                                                        filtereSearch[index]
                                                                            .idIntrant!)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              Navigator.of(context).pop(),
                                                                              Provider.of<IntrantService>(context, listen: false).applyChange(),
                                                                              setState(() {
                                                                                page++;
                                                                                futureList = IntrantService().fetchIntrantByActeurWithPagination(acteur.idActeur!);
                                                                              }),
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
                                        );
                                      } else {
                                        return isLoading == true
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                  })),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic?> afficherBottomSheet(
      BuildContext context, Intrant? intrant) async {
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
              child: DialodEdit(intrant: intrant)),
        );
      },
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

class DialodEdit extends StatefulWidget {
  Intrant? intrant;
  DialodEdit({super.key, this.intrant});

  @override
  State<DialodEdit> createState() => _DialodEditState();
}

class _DialodEditState extends State<DialodEdit> {
  TextEditingController quantiteController = TextEditingController();
  late Intrant intrants;
  String? idIntrant;
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    intrants = widget.intrant!;
    idIntrant = intrants.idIntrant!;
    quantiteController.text = intrants.quantiteIntrant!.toString();
    super.initState();
  }

  Future<void> _getResultFromNextScreen(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddIntrant()));
    log(result.toString());
    if (result == true) {}
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
                      if (qteF! > intrants.quantiteIntrant!) {
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
                                          builder: (context) => AddIntrant()));
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
                          await IntrantService()
                              .updateQuantiteIntrant(
                                  id: intrants.idIntrant!, quantite: qteF!)
                              .then((value) => {
                                    setState(() {
                                      _isLoading = false;
                                    }),
                                    Provider.of<IntrantService>(context,
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
