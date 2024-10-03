import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/Admin/ListeMaterielByType.dart';
import 'package:koumi/Admin/UpdateTypeMateriel.dart';
import 'package:koumi/models/Materiels.dart';
import 'package:koumi/models/TypeMateriel.dart';
import 'package:koumi/service/MaterielService.dart';
import 'package:koumi/service/TypeMaterielService.dart';
import 'package:provider/provider.dart';

class TypeMaterielPage extends StatefulWidget {
  const TypeMaterielPage({super.key});

  @override
  State<TypeMaterielPage> createState() => _TypeMaterielPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _TypeMaterielPageState extends State<TypeMaterielPage> {
  late TextEditingController _searchController;
  List<TypeMateriel> typeListe = [];
  late List<Materiels> materielList = [];
  final formkey = GlobalKey<FormState>();
bool isSearchMode = false;
  late ScrollController _scrollController;
  TextEditingController nomController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
   _searchController = TextEditingController();
      _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController = TextEditingController();
      _scrollController = ScrollController();
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
            'Type Matériel',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
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
            //             "Ajouter Type matériel ",
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
          ]),
      body: Container(
        child: NestedScrollView(
         headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                                    "Ajouter un type  ",
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
            child: Column(
              children: [
                
                Consumer<TypeMaterielService>(
                    builder: (context, typeService, child) {
                  return FutureBuilder(
                      future: typeService.fetchTypeMateriel(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          );
                        }
          
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(10),
                            child: Center(child: Text("Aucun donné trouvé")),
                          );
                        } else {
                          typeListe = snapshot.data!;
                          String searchText = "";
                          List<TypeMateriel> filtereSearch =
                              typeListe.where((search) {
                            String libelle = search.nom!.toLowerCase();
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
                                            Get.to(ListeMaterielByType(
                                              typeMateriel: e,
                                              
                                            ));
                                          },
                                          child: Container(
                                            width:
                                                MediaQuery.of(context).size.width *
                                                    0.9,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      Colors.grey.withOpacity(0.2),
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
                                                      "assets/images/typeMateriel.png",
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                                    title:
                                                        Text(e.nom!.toUpperCase(),
                                                            style: const TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 20,
                                                              overflow: TextOverflow
                                                                  .ellipsis,
                                                            )),
                                                    subtitle: Text(e.description!,
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ))),
                                                Consumer<MaterielService>(builder:
                                                    (context, typeService, child) {
                                                  return FutureBuilder(
                                                      future: typeService
                                                          .fetchMaterielByType(
                                                              e.idTypeMateriel!),
                                                      builder: (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color: Colors.orange,
                                                            ),
                                                          );
                                                        }
          
                                                        if (!snapshot.hasData) {
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal: 15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombre de matériel",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize: 17,
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
                                                                      fontSize: 18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ))
                                                              ],
                                                            ),
                                                          );
                                                        } else {
                                                          materielList =
                                                              snapshot.data!;
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal: 15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombre de matériel",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize: 17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    )),
                                                                Text(
                                                                    materielList
                                                                        .length
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize: 18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ))
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      });
                                                }),
                                                Container(
                                                  alignment: Alignment.bottomRight,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _buildEtat(e.statutType!),
                                                      PopupMenuButton<String>(
                                                        padding: EdgeInsets.zero,
                                                        itemBuilder: (context) =>
                                                            <PopupMenuEntry<
                                                                String>>[
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  e.statutType ==
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
                                                                e.statutType ==
                                                                        false
                                                                    ? "Activer"
                                                                    : "Desactiver",
                                                                style: TextStyle(
                                                                  color: e.statutType ==
                                                                          false
                                                                      ? Colors.green
                                                                      : Colors.orange[
                                                                          400],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                e.statutType ==
                                                                        false
                                                                    ? await TypeMaterielService()
                                                                        .activerType(e
                                                                            .idTypeMateriel!)
                                                                        .then(
                                                                            (value) =>
                                                                                {
                                                                                  Provider.of<TypeMaterielService>(context, listen: false).applyChange(),
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
                                                                                    SnackBar(
                                                                                      content: Row(
                                                                                        children: [
                                                                                          Text("Une erreur s'est produit"),
                                                                                        ],
                                                                                      ),
                                                                                      duration: const Duration(seconds: 5),
                                                                                    ),
                                                                                  ),
                                                                                  Navigator.of(context).pop(),
                                                                                })
                                                                    : await TypeMaterielService()
                                                                        .desactiverType(e
                                                                            .idTypeMateriel!)
                                                                        .then(
                                                                            (value) =>
                                                                                {
                                                                                  Provider.of<TypeMaterielService>(context, listen: false).applyChange(),
                                                                                  Navigator.of(context).pop(),
                                                                                })
                                                                        .catchError(
                                                                            (onError) =>
                                                                                {
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Row(
                                                                                        children: [
                                                                                          Text("Une erreur s'est produit"),
                                                                                        ],
                                                                                      ),
                                                                                      duration: const Duration(seconds: 5),
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
                                                                            " Desactiver avec succèss "),
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
                                                                Icons.edit,
                                                                color: Colors.green,
                                                              ),
                                                              title: const Text(
                                                                "Modifier",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors.green,
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
                                                                    context, e);
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
                                                                  color: Colors.red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                await TypeMaterielService()
                                                                    .deleteType(e
                                                                        .idTypeMateriel!)
                                                                    .then(
                                                                        (value) => {
                                                                              Provider.of<TypeMaterielService>(context, listen: false)
                                                                                  .applyChange(),
                                                                              Navigator.of(context)
                                                                                  .pop(),
                                                                            })
                                                                    .catchError(
                                                                        (onError) =>
                                                                            {
                                                                              print(
                                                                                  onError.toString()),
                                                                              ScaffoldMessenger.of(context)
                                                                                  .showSnackBar(
                                                                                const SnackBar(
                                                                                  content: Row(
                                                                                    children: [
                                                                                      Text("Ce type de materiel est déjà associer à un materiel"),
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

  Future<dynamic> bottomUpdatesheet(
      BuildContext context, TypeMateriel? typeMateriel) async {
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
              child: UpdateTypeMateriel(typeMateriel: typeMateriel!)),
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
                        "Ajouter un type matériel ",
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
                              return "Veuillez remplir les champs";
                            }
                            return null;
                          },
                          controller: nomController,
                          decoration: InputDecoration(
                            hintText: "Nom type matériel",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir les champs";
                            }
                            return null;
                          },
                          controller: descController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: "Description",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final String nom = nomController.text;
                            final String description = descController.text;

                            if (formkey.currentState!.validate()) {
                              try {
                                await TypeMaterielService()
                                    .addTypeMateriel(
                                        nom: nom, description: description)
                                    .then((value) => {
                                          Provider.of<TypeMaterielService>(
                                                  context,
                                                  listen: false)
                                              .applyChange(),
                                          nomController.clear(),
                                          descController.clear(),
                                          Navigator.of(context).pop()
                                        })
                                    .catchError((onError) => {
                                          print(onError.toString()),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Text(
                                                      "Ce type de matériel existe déjà"),
                                                ],
                                              ),
                                              duration: Duration(seconds: 5),
                                            ),
                                          )
                                        });
                              } catch (e) {
                                final String errorMessage = e.toString();
                                print(errorMessage);
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
                            // }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Orange color code
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
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ));
      },
    );
  }
}
