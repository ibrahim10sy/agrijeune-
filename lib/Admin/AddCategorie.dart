import 'package:flutter/material.dart';
import 'package:koumi/Admin/UpdatesCategorie.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Filiere.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/CategorieService.dart';
import 'package:provider/provider.dart';

class AddCategorie extends StatefulWidget {
  final Filiere filiere;
  const AddCategorie({super.key, required this.filiere});

  @override
  State<AddCategorie> createState() => _AddCategorieState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _AddCategorieState extends State<AddCategorie> {
  late Acteur acteur;
  late Filiere filiere;
  List<CategorieProduit> categorieList = [];
  late Future<List<CategorieProduit>> _liste;
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  bool isSearchMode = false;
  Future<List<CategorieProduit>> getCatListe(String id) async {
    return await CategorieService().fetchCategorieByFiliere(id);
  }

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    filiere = widget.filiere;
    _liste = getCatListe(filiere.idFiliere!);
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController
        .dispose(); // Disposez le TextEditingController lorsque vous n'en avez plus besoin
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
            filiere.libelleFiliere!.toUpperCase(),
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _liste = CategorieService()
                        .fetchCategorieByFiliere(filiere.idFiliere!);
                  });
                },
                icon: Icon(
                  Icons.refresh,
                  size: 30,
                  color: Colors.white,
                )),
            // PopupMenuButton<String>(
            //   padding: EdgeInsets.zero,
            //   itemBuilder: (context) {
            //     return <PopupMenuEntry<String>>[
            //       PopupMenuItem<String>(
            //         child: ListTile(
            //           leading: const Icon(
            //             Icons.add,
            //             color: Colors.green,
            //           ),
            //           title: const Text(
            //             "Ajouter une catégorie ",
            //             style: TextStyle(
            //               color: Colors.green,
            //               fontSize: 18,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //           onTap: () async {
            //             Navigator.of(context).pop();
            //             _showBottomSheet();
            //           },
            //         ),
            //       ),
            //     ];
            //   },
            // )
          ],
        ),
        body: Container(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    children: [
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
                                      value: 'add_cat',
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.add,
                                          color: d_colorGreen,
                                        ),
                                        title: const Text(
                                          "Ajouter une catégorie",
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
                                    if (value == 'add_cat') {
                                      _showBottomSheet();
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
                                      width: 8), // Space between icon and text
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
                                    color: isSearchMode
                                        ? Colors.red
                                        : d_colorGreen,
                                    fontSize: 17),
                              ),
                            ),
                          ],
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
                                      hintStyle: TextStyle(
                                        color: Colors.blueGrey[400],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Consumer<CategorieService>(
                    builder: (context, categorieService, child) {
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
                                child: Center(
                                    child: Text("Aucun catégorie trouvé")),
                              );
                            } else {
                              categorieList = snapshot.data!;
                              String searchText = "";
                              List<CategorieProduit> filteredCatSearch =
                                  categorieList.where((cate) {
                                String nomCat =
                                    cate.libelleCategorie!.toLowerCase();
                                searchText =
                                    _searchController.text.toLowerCase();
                                return nomCat.contains(searchText);
                              }).toList();
                              return Column(
                                  children: filteredCatSearch
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 15),
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
                                                      leading:
                                                          _getIconForFiliere(e
                                                              .filiere!
                                                              .libelleFiliere!),
                                                      title: Text(
                                                          e.libelleCategorie!
                                                              .toUpperCase(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
                                                      subtitle: Text(
                                                          e.descriptionCategorie!
                                                              .trim(),
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ))),
                                                  // const Padding(
                                                  //   padding: EdgeInsets.symmetric(
                                                  //       horizontal: 15),
                                                  //   child: Row(
                                                  //     mainAxisAlignment:
                                                  //         MainAxisAlignment
                                                  //             .spaceBetween,
                                                  //     children: [
                                                  //       Text("Nombres pays :",
                                                  //           style: TextStyle(
                                                  //             color: Colors.black87,
                                                  //             fontSize: 17,
                                                  //             fontWeight:
                                                  //                 FontWeight.w500,
                                                  //             fontStyle:
                                                  //                 FontStyle.italic,
                                                  //           )),
                                                  //       Text("10",
                                                  //           style: TextStyle(
                                                  //             color: Colors.black87,
                                                  //             fontSize: 18,
                                                  //             fontWeight:
                                                  //                 FontWeight.w800,
                                                  //           ))
                                                  //     ],
                                                  //   ),
                                                  // ),
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
                                                            e.statutCategorie!),
                                                        PopupMenuButton<String>(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          itemBuilder:
                                                              (context) =>
                                                                  <PopupMenuEntry<
                                                                      String>>[
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading: e.statutCategorie ==
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
                                                                            .orange[400]),
                                                                title: Text(
                                                                  e.statutCategorie ==
                                                                          false
                                                                      ? "Activer"
                                                                      : "Desactiver",
                                                                  style:
                                                                      TextStyle(
                                                                    color: e.statutCategorie ==
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
                                                                  e.statutCategorie ==
                                                                          false
                                                                      ? await CategorieService()
                                                                          .activerCategorie(e
                                                                              .idCategorieProduit!)
                                                                          .then((value) =>
                                                                              {
                                                                                Provider.of<CategorieService>(context, listen: false).applyChange(),
                                                                                setState(() {
                                                                                  _liste = CategorieService().fetchCategorieByFiliere(filiere.idFiliere!);
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
                                                                                Navigator.of(context).pop(),
                                                                              })
                                                                      : await CategorieService()
                                                                          .desactiverCategorie(e
                                                                              .idCategorieProduit!)
                                                                          .then((value) =>
                                                                              {
                                                                                Provider.of<CategorieService>(context, listen: false).applyChange(),
                                                                                setState(() {
                                                                                  _liste = CategorieService().fetchCategorieByFiliere(filiere.idFiliere!);
                                                                                }),
                                                                                Navigator.of(context).pop(),
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Row(
                                                                                      children: [
                                                                                        Text("Désactiver avec succèss "),
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
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons.edit,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                title:
                                                                    const Text(
                                                                  "Modifier",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                onTap:
                                                                    () async {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  // Ouvrir la boîte de dialogue de modification
                                                                  // var updatedSousRegion =
                                                                  //     await showDialog(
                                                                  //   context:
                                                                  //       context,
                                                                  //   builder: (BuildContext
                                                                  //           context) =>
                                                                  //       AlertDialog(
                                                                  //           backgroundColor:
                                                                  //               Colors
                                                                  //                   .white,
                                                                  //           shape:
                                                                  //               RoundedRectangleBorder(
                                                                  //             borderRadius:
                                                                  //                 BorderRadius.circular(16),
                                                                  //           ),
                                                                  //           content:
                                                                  //               UpdatesCategorie(categorieProduit: e)),
                                                                  // );
                                                                  bottomUpdatesheet(
                                                                      context,
                                                                      e);

                                                                  Provider.of<CategorieService>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .applyChange();
                                                                  setState(() {
                                                                    _liste = CategorieService()
                                                                        .fetchCategorieByFiliere(
                                                                            filiere.idFiliere!);
                                                                  });
                                                                  // if (updatedSousRegion !=
                                                                  //     null) {
                                                                  //   Provider.of<CategorieService>(
                                                                  //           context,
                                                                  //           listen:
                                                                  //               false)
                                                                  //       .applyChange();
                                                                  //   setState(() {
                                                                  //     _liste = CategorieService()
                                                                  //         .fetchCategorieByFiliere(
                                                                  //             filiere
                                                                  //                 .idFiliere!);
                                                                  //   });
                                                                  // }
                                                                },
                                                              ),
                                                            ),
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons.delete,
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
                                                                  await CategorieService()
                                                                      .deleteCategorie(e
                                                                          .idCategorieProduit!)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<CategorieService>(context, listen: false).applyChange(),
                                                                                setState(() {
                                                                                  _liste = CategorieService().fetchCategorieByFiliere(filiere.idFiliere!);
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
                                          ))
                                      .toList());
                            }
                          });
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void bottomUpdatesheet(
      BuildContext context, CategorieProduit? categorieProduit) {
    showModalBottomSheet(
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
              child: UpdatesCategorie(categorieProduit: categorieProduit!)),
        );
      },
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ajouter une catégorie",
                      maxLines: 2,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Fermer",
                          style: TextStyle(color: Colors.red, fontSize: 18)),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez remplir ce champ";
                          }
                          return null;
                        },
                        controller: libelleController,
                        decoration: InputDecoration(
                          labelText: "Nom de la catégorie",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez remplir ce champ";
                          }
                          return null;
                        },
                        controller: descriptionController,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final String libelle = libelleController.text;
                                final String description =
                                    descriptionController.text;
                                if (formkey.currentState!.validate()) {
                                  try {
                                    await CategorieService()
                                        .addCategorie(
                                          libelleCategorie: libelle,
                                          descriptionCategorie: description,
                                          filiere: filiere,
                                        )
                                        .then((value) => {
                                              Provider.of<CategorieService>(
                                                      context,
                                                      listen: false)
                                                  .applyChange(),
                                              Navigator.of(context).pop(),
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Text(
                                                          "Categorie ajouté avec success"),
                                                    ],
                                                  ),
                                                  duration:
                                                      Duration(seconds: 5),
                                                ),
                                              ),
                                              setState(() {
                                                _liste = CategorieService()
                                                    .fetchCategorieByFiliere(
                                                        filiere.idFiliere!);
                                              }),
                                              libelleController.clear(),
                                              descriptionController.clear(),
                                            });
                                  } catch (e) {
                                    final String errorMessage = e.toString();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Text("Cette categorie existe déjà"),
                                          ],
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Ajouter",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // void _showDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) => Dialog(
  //       backgroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Container(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               title: Text(
  //                 "Ajouter une ",
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black,
  //                   fontSize: 18,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //               trailing: IconButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 icon: Icon(
  //                   Icons.close,
  //                   color: Colors.red,
  //                   size: 24,
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 5),

  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _getIconForFiliere(String libelle) {
    switch (libelle.toLowerCase()) {
      case 'céréale':
      case 'céréales':
      case 'cereale':
      case 'cereales':
        return Image.asset(
          "assets/images/cereale.png",
          width: 80,
          height: 80,
        );
      case 'fruits':
      case 'fruit':
        return Image.asset(
          "assets/images/fruits.png",
          width: 80,
          height: 80,
        );
      case 'bétails':
      case 'bétail':
      case 'betails':
      case 'betail':
        return Image.asset(
          "assets/images/betail.png",
          width: 80,
          height: 80,
        );
      case 'légumes':
      case 'légume':
      case 'legumes':
      case 'legume':
        return Image.asset(
          "assets/images/legumes.png",
          width: 80,
          height: 80,
        );
      default:
        return Image.asset(
          "assets/images/default.png",
          width: 80,
          height: 80,
        );
    }
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
