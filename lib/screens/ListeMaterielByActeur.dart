import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/DetailMateriel.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Materiels.dart';
import 'package:koumi/models/TypeMateriel.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddMateriel.dart';
import 'package:koumi/service/MaterielService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shimmer/shimmer.dart';

class ListeMaterielByActeur extends StatefulWidget {
  bool? isRoute;
  ListeMaterielByActeur({super.key, this.isRoute});

  @override
  State<ListeMaterielByActeur> createState() => _ListeMaterielByActeurState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _ListeMaterielByActeurState extends State<ListeMaterielByActeur> {
  late TypeMateriel type = TypeMateriel();
  List<Materiels> materielListe = [];
  late Future<List<Materiels>> futureListe;
  bool isExist = false;
  late Acteur acteur = Acteur();
  late Future futureList;
  bool _isActive = false;
  bool _isNotActive = false;
  int page = 0;
  bool isLoading = false;
  int size = 100;
  // int size = sized;
  bool hasMore = true;
  ScrollController scrollableController = ScrollController();
  late TextEditingController _searchController;

  Future<List<Materiels>> fetchMaterielByActeur(String idActeur,
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
          '$apiOnlineUrl/Materiel/getAllMaterielsByActeurWithPagination?idActeur=$idActeur&page=${page}&size=${size}'));

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
            "response body all materiel by acteur with pagination ${page} par défilement soit ${materielListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
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

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        acteur.idActeur != null) {
      // if (selectedCat != null) {
      // Incrementez la page et récupérez les stocks par catégorie
      debugPrint("yes - fetch materiel  by acteur");
      setState(() {
        // Rafraîchir les données ici
        page++;
      });
      fetchMaterielByActeur(acteur.idActeur!).then((value) {
        setState(() {
          // Rafraîchir les données ici
        });
      });
    }
    debugPrint("no");
  }

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    futureListe =
        MaterielService().fetchMaterielByActeurWithPagination(acteur.idActeur!);
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //code will run when widget rendering complete
      scrollableController.addListener(_scrollListener);
    });
  }

  bool isSearchMode = false;
  void _selectMode(String mode) {
    setState(() {
      if (mode == 'Rechercher') {
        isSearchMode = true;
      } else if (mode == 'Fermer') {
        isSearchMode = false;
      }
    });
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
        futureListe = MaterielService()
            .fetchMaterielByActeurWithPagination(acteur.idActeur!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Disposez le TextEditingController lorsque vous n'en avez plus besoin
    scrollableController.dispose();
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
              "Mes Matériels",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            actions: [
              (widget.isRoute ?? false)
                  ? IconButton(
                      onPressed: () {
                        futureListe = MaterielService()
                            .fetchMaterielByActeurWithPagination(
                                acteur.idActeur!);
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white))
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              elevation: 8.0,
                            ).then((value) {
                              if (value != null) {
                                if (value == 'add_mat') {
                                  _getResultFromNextScreen1(context);
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
                      child: SearchFieldAutoComplete<String>(
                        controller: _searchController,
                        itemHeight: 25,
                        placeholder: 'Rechercher...',
                        placeholderStyle:
                            TextStyle(fontStyle: FontStyle.italic),
                        suggestions: AutoComplet.getMateriels,
                        suggestionsDecoration: SuggestionDecoration(
                          marginSuggestions: const EdgeInsets.all(8.0),
                          color: const Color.fromARGB(255, 236, 234, 234),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        onSuggestionSelected: (selectedItem) {
                          _searchController.text = selectedItem.searchKey;
                          // setState(() {});
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
                  futureListe = MaterielService()
                      .fetchMaterielByActeurWithPagination(acteur.idActeur!);
                });
              },
              child: SingleChildScrollView(
                  controller: scrollableController,
                  child: Consumer<MaterielService>(
                    builder: (context, materielService, child) {
                      return FutureBuilder(
                          future: (widget.isRoute ?? false)
                              ? futureListe
                              : materielService
                                  .fetchMaterielByActeurWithPagination(
                                      acteur.idActeur!),
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
                                          'Aucun materiel trouvé',
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
                              materielListe = snapshot.data!;
                              String searchText = "";
                              List<Materiels> filtereSearch =
                                  materielListe.where((search) {
                                String libelle = search.nom!.toLowerCase();
                                searchText =
                                    _searchController.text.trim().toLowerCase();
                                return libelle.contains(searchText);
                              }).toList();
                              if (filtereSearch.isEmpty &&
                                  _searchController.text.isNotEmpty) {
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return filtereSearch.isEmpty && isLoading == false
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
                                                'Aucun matériel trouvé',
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
                                      itemCount: filtereSearch.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < filtereSearch.length) {
                                          // var e = filtereSearch
                                          // .where((element) => element.statut== true)
                                          // .elementAt(index);

                                          return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailMateriel(
                                                                materiel:
                                                                    filtereSearch[
                                                                        index])));
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
                                                          child: SizedBox(
                                                            height: 72,
                                                            child: filtereSearch[index]
                                                                            .photoMateriel ==
                                                                        null ||
                                                                    filtereSearch[
                                                                            index]
                                                                        .photoMateriel!
                                                                        .isEmpty
                                                                ? Image.asset(
                                                                    "assets/images/default_image.png",
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height: 72,
                                                                  )
                                                                : CachedNetworkImage(
                                                                    imageUrl:
                                                                        "https://koumi.ml/api-koumi/Materiel/${filtereSearch[index].idMateriel}/image",
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
                                                        SizedBox(height: 2),
                                                        ListTile(
                                                          title: Text(
                                                            filtereSearch[index]
                                                                .nom!,
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
                                                            filtereSearch[index]
                                                                .localisation!,
                                                            style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              _buildEtat(
                                                                  filtereSearch[
                                                                          index]
                                                                      .statut!),
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
                                                                      leading: filtereSearch[index].statut ==
                                                                              false
                                                                          ? Icon(
                                                                              Icons.check,
                                                                              color: Colors.green)
                                                                          : Icon(
                                                                              Icons.disabled_visible,
                                                                              color: Colors.orange[400],
                                                                            ),
                                                                      title:
                                                                          Text(
                                                                        filtereSearch[index].statut ==
                                                                                false
                                                                            ? "Activer"
                                                                            : "Desactiver",
                                                                        style:
                                                                            TextStyle(
                                                                          color: filtereSearch[index].statut == false
                                                                              ? Colors.green
                                                                              : Colors.orange[400],
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        filtereSearch[index].statut ==
                                                                                false
                                                                            ? await MaterielService()
                                                                                .activerMateriel(filtereSearch[index].idMateriel!)
                                                                                .then((value) => {
                                                                                      Provider.of<MaterielService>(context, listen: false).applyChange(),
                                                                                      setState(() {
                                                                                        futureListe = MaterielService().fetchMaterielByActeurWithPagination(acteur.idActeur!);
                                                                                      }),
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
                                                                            : await MaterielService()
                                                                                .desactiverMateriel(filtereSearch[index].idMateriel!)
                                                                                .then((value) => {
                                                                                      Provider.of<MaterielService>(context, listen: false).applyChange(),
                                                                                      setState(() {
                                                                                        futureListe = MaterielService().fetchMaterielByActeurWithPagination(acteur.idActeur!);
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
                                                                                    });

                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                            content:
                                                                                Row(
                                                                              children: [
                                                                                Text("Désactiver avec succèss "),
                                                                              ],
                                                                            ),
                                                                            duration:
                                                                                Duration(seconds: 2),
                                                                          ),
                                                                        );
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
                                                                        await MaterielService()
                                                                            .deleteMateriel(filtereSearch[index]
                                                                                .idMateriel!)
                                                                            .then((value) =>
                                                                                {
                                                                                  setState(() {
                                                                                    futureListe = MaterielService().fetchMaterielByActeurWithPagination(acteur.idActeur!);
                                                                                  }),
                                                                                  Navigator.of(context).pop(),
                                                                                })
                                                                            .catchError((onError) =>
                                                                                {
                                                                                  print(onError),
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
                                                        ),
                                                      ])));
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
                    },
                  )),
            ),
          )),
        ));
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
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
}




 /*
 
 */