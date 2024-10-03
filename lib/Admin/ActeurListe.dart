import 'package:flutter/material.dart';
import 'package:koumi/Admin/DetailsActeur.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:profile_photo/profile_photo.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:koumi/constants.dart';


class ActeurList extends StatefulWidget {
  final TypeActeur typeActeur;
  const ActeurList({super.key, required this.typeActeur});

  @override
  State<ActeurList> createState() => _ActeurListState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _ActeurListState extends State<ActeurList> {
  late TextEditingController _searchController;
  List<Acteur> acteurList = [];
  late TypeActeur typeActeurs;
  late Future<List<Acteur>> _liste;
  ScrollController scrollableController = ScrollController();
  bool isSearchMode = false;
  Future<List<Acteur>> getActeurListe(String id) async {
    return await ActeurService().fetchActeurByTypeActeur(id);
  }

  @override
  void initState() {
    scrollableController = ScrollController();
    _searchController = TextEditingController();
    typeActeurs = widget.typeActeur;
    _liste = getActeurListe(typeActeurs.idTypeActeur!);
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollableController.dispose();
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: Text(
          typeActeurs.libelle!.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
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
                  ],
                ),
              )
            ];
          },
          body: SingleChildScrollView(
            controller: scrollableController,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Consumer<ActeurService>(
                    builder: (context, acteurService, child) {
                  return FutureBuilder(
                      future: _liste,
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

                          return Column(
                              children: filtereSearch
                                  .where((element) => !element.typeActeur!.any(
                                      (e) => e.libelle!
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
                                                offset: const Offset(0, 2),
                                                blurRadius: 5,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                  leading: ClipOval(
                                          child: CachedNetworkImage(
                                            width: 50,
                                            height: 50,
                                            imageUrl:
                                                "$apiOnlineUrl/acteur/${e.idActeur}/image",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Image.asset(
                                                    'assets/images/profil.jpg'),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/images/profil.jpg',
                                              fit: BoxFit.cover,
                                              width: 50,
                                              height: 50,
                                            ),
                                          ),
                                        ),
                                                  title: Text(
                                                      e.nomActeur!
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )),
                                                  subtitle: Text(
                                                      e.typeActeur!
                                                          .map((data) =>
                                                              data.libelle!)
                                                          .join(', '),
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ))),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("Date d'adhésion :",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        )),
                                                    Text(e.dateAjout!,
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ))
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.bottomRight,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // _buildEtat(e.statutActeur!),
                                                    PopupMenuButton<String>(
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (context) =>
                                                          <PopupMenuEntry<
                                                              String>>[
                                                        PopupMenuItem<String>(
                                                          child: ListTile(
                                                            leading: const Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                            title: const Text(
                                                              "Activer",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            onTap: () async {
                                                              await ActeurService()
                                                                  .activerActeur(e
                                                                      .idActeur!)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            Provider.of<ActeurService>(context, listen: false).applyChange(),
                                                                            setState(() {
                                                                              _liste = getActeurListe(typeActeurs.idTypeActeur!);
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
                                                                            Navigator.of(context).pop(),
                                                                          });
                                                            },
                                                          ),
                                                        ),
                                                        PopupMenuItem<String>(
                                                          child: ListTile(
                                                            leading: Icon(
                                                              Icons
                                                                  .disabled_visible,
                                                              color: Colors
                                                                  .orange[400],
                                                            ),
                                                            title: Text(
                                                              "Désactiver",
                                                              style: TextStyle(
                                                                color: Colors
                                                                        .orange[
                                                                    400],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            onTap: () async {
                                                              await ActeurService()
                                                                  .desactiverActeur(e
                                                                      .idActeur!)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            Provider.of<ActeurService>(context, listen: false).applyChange(),
                                                                            setState(() {
                                                                              _liste = getActeurListe(typeActeurs.idTypeActeur!);
                                                                            }),
                                                                            Navigator.of(context).pop(),
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
                                                                            Navigator.of(context).pop(),
                                                                          });

                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Row(
                                                                    children: [
                                                                      Text(
                                                                          "Désactiver avec succèss "),
                                                                    ],
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        PopupMenuItem<String>(
                                                          child: ListTile(
                                                            leading: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                            title: const Text(
                                                              "Supprimer",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            onTap: () async {
                                                              await ActeurService()
                                                                  .deleteActeur(e
                                                                      .idActeur!)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            Provider.of<ActeurService>(context, listen: false).applyChange(),
                                                                            setState(() {
                                                                              _liste = getActeurListe(typeActeurs.idTypeActeur!);
                                                                            }),
                                                                            Navigator.of(context).pop(),
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
