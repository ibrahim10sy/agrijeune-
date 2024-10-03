import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koumi/Admin/UpdateTypeVehicule.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/TypeVoiture.dart';
import 'package:koumi/models/Vehicule.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/ListeVehiculeByType.dart';
import 'package:koumi/service/TypeVoitureService.dart';
import 'package:koumi/service/VehiculeService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';

class TypeVehicule extends StatefulWidget {
  
  TypeVehicule({super.key});

  @override
  State<TypeVehicule> createState() => _TypeVehiculeState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _TypeVehiculeState extends State<TypeVehicule> {
  late Acteur acteur;
  late TextEditingController _searchController;
  List<TypeVoiture> typeListe = [];

bool isSearchMode = false;
  late ScrollController _scrollController;
  late List<Vehicule> vehiculeList = [];
  final formkey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController nombreSiegesController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
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
          title: Text(
            'Type de véhicule',
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
            //             "Ajouter un type de véhicule",
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
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
        child: Container(
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
                                    "Ajouter une forme de produit ",
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
                    child: SearchFieldAutoComplete<String>(
                      controller: _searchController,
                        itemHeight: 25,
                      placeholder: 'Rechercher...',
                      placeholderStyle: TextStyle(fontStyle: FontStyle.italic),
                      suggestions: AutoComplet.getTransportVehicles,
                      suggestionsDecoration: SuggestionDecoration(
                        marginSuggestions: const EdgeInsets.all(8.0),
                        color: const Color.fromARGB(255, 236, 234, 234),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      onSuggestionSelected: (selectedItem) {
                        if (mounted) {
                          _searchController.text = selectedItem.searchKey;
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
            body: SingleChildScrollView(
              child: Column(
                children: [
                                   Consumer<TypeVoitureService>(
                      builder: (context, typeService, child) {
                    return FutureBuilder(
                        future: typeService.fetchTypeVoiture(),
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
                            List<TypeVoiture> filtereSearch =
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
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ListeVehiculeByType(
                                                              typeVoitures: e)));
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
                                              child: Column(children: [
                                                ListTile(
                                                    leading: Image.asset(
                                                      "assets/images/trans.png",
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                                    title: Text(e.nom!.toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                        )),
                                                    subtitle: e.nombreSieges != 0
                                                        ? Text(
                                                            "Nombre de sièges : ${e.nombreSieges.toString().trim()}",
                                                            style: const TextStyle(
                                                              color: Colors.black87,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              fontStyle:
                                                                  FontStyle.italic,
                                                            ))
                                                        : Text(
                                                            "Nombre de sièges : Non renseigné",
                                                            style: const TextStyle(
                                                              color: Colors.black87,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              fontStyle:
                                                                  FontStyle.italic,
                                                            ))),
                                                Consumer<VehiculeService>(builder:
                                                    (context, typeService, child) {
                                                  return FutureBuilder(
                                                      future: typeService
                                                          .fetchVehiculeByTypeVehicule(
                                                              e.idTypeVoiture!),
                                                      builder: (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState.waiting) {
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color: Colors.orange,
                                                            ),
                                                          );
                                                        }
            
                                                        if (!snapshot.hasData) {
                                                          return Padding(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal: 15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombre de véhicule",
                                                                    style: TextStyle(
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
                                                                    style: TextStyle(
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
                                                          vehiculeList =
                                                              snapshot.data!;
                                                          return Padding(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal: 15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombres de véhicule",
                                                                    style: TextStyle(
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
                                                                    vehiculeList
                                                                        .length
                                                                        .toString(),
                                                                    style: TextStyle(
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
                                                  padding: const EdgeInsets.symmetric(
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
                                                            <PopupMenuEntry<String>>[
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading: e.statutType ==
                                                                      false
                                                                  ? Icon(
                                                                      Icons.check,
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
                                                                e.statutType == false
                                                                    ? "Activer"
                                                                    : "Desactiver",
                                                                style: TextStyle(
                                                                  color: e.statutType ==
                                                                          false
                                                                      ? Colors.green
                                                                      : Colors.orange[
                                                                          400],
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                e.statutType == false
                                                                    ? await TypeVoitureService()
                                                                        .activerType(e
                                                                            .idTypeVoiture!)
                                                                        .then(
                                                                            (value) =>
                                                                                {
                                                                                  Provider.of<TypeVoitureService>(context, listen: false).applyChange(),
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
                                                                                          Text("Une erreur s'est produit : $onError"),
                                                                                        ],
                                                                                      ),
                                                                                      duration: const Duration(seconds: 5),
                                                                                    ),
                                                                                  ),
                                                                                  Navigator.of(context).pop(),
                                                                                })
                                                                    : await TypeVoitureService()
                                                                        .desactiverType(e
                                                                            .idTypeVoiture!)
                                                                        .then(
                                                                            (value) =>
                                                                                {
                                                                                  Provider.of<TypeVoitureService>(context, listen: false).applyChange(),
                                                                                  Navigator.of(context).pop(),
                                                                                })
                                                                        .catchError(
                                                                            (onError) =>
                                                                                {
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Row(
                                                                                        children: [
                                                                                          Text("Une erreur s'est produit : $onError"),
                                                                                        ],
                                                                                      ),
                                                                                      duration: const Duration(seconds: 5),
                                                                                    ),
                                                                                  ),
                                                                                  Navigator.of(context).pop(),
                                                                                });
            
                                                                ScaffoldMessenger.of(
                                                                        context)
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
                                                                  color: Colors.green,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                Navigator.of(context)
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
                                                                      FontWeight.bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                await TypeVoitureService()
                                                                    .deleteType(e
                                                                        .idTypeVoiture!)
                                                                    .then((value) => {
                                                                          Provider.of<TypeVoitureService>(
                                                                                  context,
                                                                                  listen:
                                                                                      false)
                                                                              .applyChange(),
                                                                          Navigator.of(
                                                                                  context)
                                                                              .pop(),
                                                                        })
                                                                    .catchError(
                                                                        (onError) => {
                                                                              print(onError
                                                                                  .toString()),
                                                                              ScaffoldMessenger.of(context)
                                                                                  .showSnackBar(
                                                                                const SnackBar(
                                                                                  content:
                                                                                      Row(
                                                                                    children: [
                                                                                      Text("Ce type de vehicule est déjà associer à un véhicule"),
                                                                                    ],
                                                                                  ),
                                                                                  duration:
                                                                                      Duration(seconds: 2),
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
                                              ]),
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
      ),
    );
  }

  Future<dynamic> bottomUpdatesheet(
      BuildContext context, TypeVoiture? typeVoiture) async {
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
              child: UpdateTypeVehicule(typeVoiture: typeVoiture!)),
        );
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
                        "Ajouter un type de véhicule",
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
                            hintText: "Nom type vehicule",
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
                          controller: nombreSiegesController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: "nombre siège facultatif",
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
                            final String siege = nombreSiegesController.text;
                            final String description = descController.text;
                            // if (formkey.currentState != null &&
                            //     formkey.currentState!.validate()) {
                            // Votre code ici

                            print(nom);
                            print(siege);
                            print(description);
                            try {
                              await TypeVoitureService()
                                  .addTypeVoiture(
                                      nom: nom,
                                      nombreSieges: siege,
                                      description: description,
                                      acteur: acteur)
                                  .then((value) => {
                                        Provider.of<TypeVoitureService>(context,
                                                listen: false)
                                            .applyChange(),
                                        nomController.clear(),
                                        descController.clear(),
                                        nombreSiegesController.clear(),
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
                                                    "Ce type de véhicule existe déjà"),
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
                                      Text(
                                          "Une erreur s'est produit : $errorMessage"),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                            // }
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
