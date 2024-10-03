import 'package:flutter/material.dart';
import 'package:koumi/Admin/DetailsActeur.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:profile_photo/profile_photo.dart';
import 'package:provider/provider.dart';

class ActeurScreen extends StatefulWidget {
  const ActeurScreen({super.key});

  @override
  State<ActeurScreen> createState() => _ActeurScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _ActeurScreenState extends State<ActeurScreen> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  List<Acteur> acteurList = [];
  bool _isLoading = false;
  late ActeurService _acteurService;
  bool isSearchMode = false;

  @override
  void initState() {
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  void _activerActeur(String idActeur) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _acteurService.activerActeur(idActeur);
      _acteurService.applyChange();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Activer avec succès"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Une erreur s'est produite"),
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _desactiverActeur(String idActeur) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _acteurService.desactiverActeur(idActeur);
      _acteurService.applyChange();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Désactiver avec succès"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Une erreur s'est produite"),
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectMode(String mode) {
    setState(() {
      if (mode == 'Rechercher') {
        isSearchMode = true;
      } else if (mode == 'Fermer') {
        isSearchMode = false;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _acteurService = Provider.of<ActeurService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
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
            "Listes des acteurs",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: Container(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                    child: Column(children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isSearchMode = !isSearchMode;
                          _searchController.clear();
                        });
                      },
                      icon: Icon(
                        isSearchMode ? Icons.close : Icons.search,
                        color: isSearchMode ? Colors.red : Colors.green,
                      ),
                      label: Text(
                        isSearchMode ? 'Fermer' : 'Rechercher...',
                        style: TextStyle(
                            color: isSearchMode ? Colors.red : Colors.green,
                            fontSize: 17),
                      ),
                    ),
                  ),
                  if (isSearchMode)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.blueGrey[400]),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Rechercher',
                                  border: InputBorder.none,
                                  hintStyle:
                                      TextStyle(color: Colors.blueGrey[400]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ])),
              ];
            },
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Consumer<ActeurService>(
                      builder: (context, acteurService, child) {
                    return FutureBuilder(
                        future: acteurService.fetchActeur(),
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
                            return const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(child: Text("Aucun acteur trouvé")),
                            );
                          } else {
                            acteurList = snapshot.data!;
                            String searchText = "";
                            List<Acteur> filtereSearch =
                                acteurList.where((search) {
                              String libelle = search.nomActeur!.toLowerCase();
                              searchText = _searchController.text.toLowerCase();
                              return libelle.contains(searchText);
                            }).toList();

                            return filtereSearch
                                    .where((element) => !element.typeActeur!
                                        .any((e) => e.libelle!
                                            .toLowerCase()
                                            .contains('admin')))
                                    .isEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                        child: Text("Aucun acteur trouvé")),
                                  )
                                : Column(
                                    children: filtereSearch
                                        .where((element) => !element.typeActeur!
                                            .any((e) => e.libelle!
                                                .toLowerCase()
                                                .contains('admin')))
                                        .map((e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 15),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailsActeur(
                                                                acteur: e)));
                                              },
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
                                                    ListTile(
                                                        leading: e.logoActeur ==
                                                                    null ||
                                                                e.logoActeur!
                                                                    .isEmpty
                                                            ? ProfilePhoto(
                                                                totalWidth: 50,
                                                                cornerRadius:
                                                                    50,
                                                                color: Colors
                                                                    .black,
                                                                image: const AssetImage(
                                                                    'assets/images/profil.jpg'),
                                                              )
                                                            : ProfilePhoto(
                                                                totalWidth: 50,
                                                                cornerRadius:
                                                                    50,
                                                                color: Colors
                                                                    .black,
                                                                image: NetworkImage(
                                                                    "https://koumi.ml/api-koumi/acteur/${e.idActeur}/image"),
                                                              ),
                                                        title: Text(
                                                            e.nomActeur!
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 20,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            )),
                                                        subtitle: Text(
                                                            e.typeActeur!
                                                                .map((data) =>
                                                                    data
                                                                        .libelle)
                                                                .join(', '),
                                                            style:
                                                                const TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ))),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              "Date d'adhésion :",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              )),
                                                          Text(
                                                              e.dateAjout! ??
                                                                  "",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ))
                                                        ],
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
                                                              e.statutActeur!),
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
                                                                  leading: e.statutActeur ==
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
                                                                    e.statutActeur ==
                                                                            false
                                                                        ? "Activer"
                                                                        : "Desactiver",
                                                                    style:
                                                                        TextStyle(
                                                                      color: e.statutActeur ==
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
                                                                    e.statutActeur ==
                                                                            false
                                                                        ? _activerActeur(e
                                                                            .idActeur!)
                                                                        : _desactiverActeur(
                                                                            e.idActeur!);
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
                                                                    await ActeurService()
                                                                        .deleteActeur(e
                                                                            .idActeur!)
                                                                        .then((value) =>
                                                                            {
                                                                              Provider.of<ActeurService>(context, listen: false).applyChange(),
                                                                              Navigator.of(context).pop(),
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
                                            )))
                                        .toList());
                          }
                        });
                  })
                ],
              ),
            ),
          ),
        ),
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
