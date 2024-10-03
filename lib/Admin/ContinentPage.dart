import 'package:flutter/material.dart';
import 'package:koumi/Admin/SousRegionList.dart';
import 'package:koumi/Admin/UpdateContinents.dart';
import 'package:koumi/models/Continent.dart';
import 'package:koumi/models/SousRegion.dart';
import 'package:koumi/service/ContinentService.dart';
import 'package:koumi/service/SousRegionService.dart';
import 'package:provider/provider.dart';

class ContinentPage extends StatefulWidget {
  const ContinentPage({super.key});

  @override
  State<ContinentPage> createState() => _ContinentPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _ContinentPageState extends State<ContinentPage> {
  List<Continent> continentList = [];
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late TextEditingController _searchController;
  List<SousRegion> regionList = [];
  bool isSearchMode = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
          title: const Text(
            "Continent",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            // PopupMenuButton<String>(
            //   padding: EdgeInsets.zero,
            //   itemBuilder: (context) => <PopupMenuEntry<String>>[
            //     PopupMenuItem<String>(
            //       child: ListTile(
            //         leading: const Icon(
            //           Icons.add,
            //           color: Colors.green,
            //         ),
            //         title: const Text(
            //           "Ajouter continent",
            //           style: TextStyle(
            //               color: Colors.green,
            //               fontWeight: FontWeight.bold,
            //               overflow: TextOverflow.ellipsis),
            //         ),
            //         onTap: () async {
            //           Navigator.of(context).pop();
            //           _showBottomSheet();
            //         },
            //       ),
            //     ),
            //   ],
            // )
          ],
        ),
        body: Container(
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
                                      "Ajouter un continent ",
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
              child: Column(children: [
                Consumer<ContinentService>(
                  builder: (context, typeService, child) {
                    return FutureBuilder(
                        future: typeService.fetchContinent(),
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
                              child:
                                  Center(child: Text("Aucun continent trouvé")),
                            );
                          } else {
                            continentList = snapshot.data!;
                            String searchText = "";
                            List<Continent> filtereSearch =
                                continentList.where((search) {
                              String libelle =
                                  search.nomContinent.toLowerCase();
                              searchText = _searchController.text.toLowerCase();
                              return libelle.contains(searchText);
                            }).toList();
                            return Column(
                                children: filtereSearch
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SousRegionList(
                                                              continent: e)));
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
                                                      leading: Image.asset(
                                                        "assets/images/continent.png",
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                      title: Text(
                                                          e.nomContinent
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
                                                          e.descriptionContinent
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
                                                  FutureBuilder(
                                                      future: SousRegionService()
                                                          .fetchSousRegionByContinent(
                                                              e.idContinent!),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                          );
                                                        }

                                                        if (!snapshot.hasData) {
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombre de sous région :",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    )),
                                                                Text("0",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ))
                                                              ],
                                                            ),
                                                          );
                                                        } else {
                                                          regionList =
                                                              snapshot.data!;
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombres de sous région :",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    )),
                                                                Text(
                                                                    regionList
                                                                        .length
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ))
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      }),
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
                                                            e.statutContinent),
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
                                                                leading: e.statutContinent ==
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
                                                                  e.statutContinent ==
                                                                          false
                                                                      ? "Activer"
                                                                      : "Desactiver",
                                                                  style:
                                                                      TextStyle(
                                                                    color: e.statutContinent ==
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
                                                                  e.statutContinent ==
                                                                          false
                                                                      ? await ContinentService()
                                                                          .activerContinent(e
                                                                              .idContinent!)
                                                                          .then((value) =>
                                                                              {
                                                                                Provider.of<ContinentService>(context, listen: false).applyChange(),
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
                                                                      : await ContinentService()
                                                                          .desactiverContinent(e
                                                                              .idContinent!)
                                                                          .then((value) =>
                                                                              {
                                                                                Provider.of<ContinentService>(context, listen: false).applyChange(),
                                                                                Navigator.of(context).pop(),
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

                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                              "Désactiver avec succèss "),
                                                                        ],
                                                                      ),
                                                                      duration: Duration(
                                                                          seconds:
                                                                              2),
                                                                    ),
                                                                  );
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
                                                                onTap: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  bottomUpdatesheet(
                                                                      context,
                                                                      e);
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
                                                                  await ContinentService()
                                                                      .deleteContinent(e
                                                                          .idContinent!)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<ContinentService>(context, listen: false).applyChange(),
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
                                          ),
                                        ))
                                    .toList());
                          }
                        });
                  },
                ),
              ]),
            ),
          ),
        ));
  }

  Future<dynamic> bottomUpdatesheet(
      BuildContext context, Continent? continent) async {
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
          child: UpdateContinents(continent: continent!),
        ));
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
                        "Ajouter un continent",
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

                  // const SizedBox(height: 10),
                  Form(
                    key: formkey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Nom continent',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir les champs";
                            }
                            return null;
                          },
                          controller: libelleController,
                          decoration: InputDecoration(
                            hintText: "Nom continent",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Veuillez remplir les champs";
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
                            )),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final String libelle = libelleController.text;
                            final String desc = descriptionController.text;
                            if (formkey.currentState!.validate()) {
                              try {
                                await ContinentService()
                                    .addContinent(
                                        nomContinent: libelle,
                                        descriptionContinent: desc)
                                    .then((value) => {
                                          Provider.of<ContinentService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          libelleController.clear(),
                                          descriptionController.clear(),
                                          Navigator.of(context).pop()
                                        });
                              } catch (e) {
                                final String errorMessage = e.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Text("Une erreur s'est produit"),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(290, 45),
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
                        )
                      ],
                    ),
                  )
                ],
              ),
            ));
      },
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
