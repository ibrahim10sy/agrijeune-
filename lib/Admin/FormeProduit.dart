import 'package:flutter/material.dart';
import 'package:koumi/models/Forme.dart';
import 'package:koumi/service/FormeService.dart';
import 'package:provider/provider.dart';

class FormeProduit extends StatefulWidget {
  const FormeProduit({super.key});

  @override
  State<FormeProduit> createState() => _FormeProduitState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _FormeProduitState extends State<FormeProduit> {
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  late TextEditingController _searchController;
  late List<Forme> formeList = [];
bool isSearchMode = false;
  late ScrollController _scrollController;
  late Future _liste;

  Future<List<Forme>> getListe() async {
    final response = await FormeService().fetchForme();
    return response;
  }

  @override
  void initState() {
    _searchController = TextEditingController();
      _scrollController = ScrollController();
    _liste = getListe();
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
        backgroundColor: d_colorGreen,
        centerTitle: true,
        toolbarHeight: 75,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: const Text(
          "Forme produit",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _liste = getListe();
              });
            },
            icon: const Icon(
              Icons.refresh,
              color: d_colorGreen,
              size: 28,
            ),
          ),
          // PopupMenuButton<String>(
          //   padding: EdgeInsets.zero,
          //   itemBuilder: (context) => <PopupMenuEntry<String>>[
          //     PopupMenuItem<String>(
          //       child: ListTile(
          //         leading: Icon(
          //           Icons.add,
          //           color: d_colorGreen,
          //         ),
          //         title: Text(
          //           "Ajouter une forme",
          //           style: TextStyle(
          //             color: d_colorGreen,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         onTap: () async {
          //           Navigator.of(context).pop();
          //           _showBottomSheet1();
          //         },
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
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
                                _showBottomSheet1();
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
               
                Consumer<FormeService>(
                  builder: (context, formeService, child) {
                    return FutureBuilder(
                        future: _liste,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            );
                          }
          
                          if (!snapshot.hasData) {
                            return Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Aucune forme trouvé ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            );
                          } else {
                            formeList = snapshot.data!;
                            String searchText = "";
                            List<Forme> filteredFiliereSearch =
                                formeList.where((fil) {
                              String nomfiliere = fil.libelleForme!.toLowerCase();
                              searchText = _searchController.text.toLowerCase();
                              return nomfiliere.contains(searchText);
                            }).toList();
                            return filteredFiliereSearch.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text('Aucune forme de produit trouvé ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  )
                                : Column(
                                    children: filteredFiliereSearch
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
                                                        leading: _getIconForForme(
                                                            e.libelleForme!),
                                                        title: Text(
                                                            e.libelleForme!
                                                                .toUpperCase(),
                                                            style: const TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 20,
                                                              overflow: TextOverflow
                                                                  .ellipsis,
                                                            )),
                                                        subtitle: Text(
                                                            e.descriptionForme!
                                                                .trim(),
                                                            style: const TextStyle(
                                                              color: Colors.black87,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              fontStyle:
                                                                  FontStyle.italic,
                                                            ))),
                                                    Container(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          _buildEtat(
                                                              e.statutForme!),
                                                          PopupMenuButton<String>(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            itemBuilder:
                                                                (context) =>
                                                                    <PopupMenuEntry<
                                                                        String>>[
                                                              PopupMenuItem<String>(
                                                                child: ListTile(
                                                                  leading: e.statutForme ==
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
                                                                              400]),
                                                                  title: Text(
                                                                    e.statutForme ==
                                                                            false
                                                                        ? "Activer"
                                                                        : "Desactiver",
                                                                    style:
                                                                        TextStyle(
                                                                      color: e.statutForme ==
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
                                                                    e.statutForme ==
                                                                            false
                                                                        ? await FormeService()
                                                                            .activerForme(e
                                                                                .idForme!)
                                                                            .then((value) =>
                                                                                {
                                                                                  Provider.of<FormeService>(context, listen: false).applyChange(),
                                                                                  setState(() {
                                                                                    _liste = getListe();
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
                                                                                    })
                                                                        : await FormeService()
                                                                            .desactiverForme(e
                                                                                .idForme!)
                                                                            .then((value) =>
                                                                                {
                                                                                  Provider.of<FormeService>(context, listen: false).applyChange(),
                                                                                  setState(() {
                                                                                    _liste = getListe();
                                                                                  }),
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
                                                              PopupMenuItem<String>(
                                                                child: ListTile(
                                                                  leading:
                                                                      const Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                  title: const Text(
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
                                                                  onTap: () async {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    await afficherBottomSheet(
                                                                            context,
                                                                            e)
                                                                        .then(
                                                                            (value) {
                                                                      Provider.of<FormeService>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .applyChange();
                                                                      setState(() {
                                                                        _liste =
                                                                            getListe();
                                                                      });
                                                                      // Navigator.of(context).pop();
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
                                                                    await FormeService()
                                                                        .deleteForme(e
                                                                            .idForme!)
                                                                        .then(
                                                                            (value) =>
                                                                                {
                                                                                  Provider.of<FormeService>(context, listen: false).applyChange(),
                                                                                  setState(() {
                                                                                    _liste = getListe();
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
                                                                                          Text(
                                                                                            "Impossible de supprimer car cette filière est déjà associé a une categorie",
                                                                                            style: TextStyle(overflow: TextOverflow.ellipsis),
                                                                                          ),
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

  Future<dynamic> afficherBottomSheet(
      BuildContext context, Forme? forme) async {
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
              child: UpdateFormeClass(forme: forme!)),
        );
      },
    );
  }

  Widget _getIconForForme(String libelle) {
    switch (libelle.toLowerCase()) {
      case 'graine':
      case 'graines':
        return Image.asset(
          "assets/images/graine.jpg",
          width: 80,
          height: 80,
        );
      case 'liquide':
      case 'liqudes':
        return Image.asset(
          "assets/images/liquide.jpg",
          width: 80,
          height: 80,
        );
      case 'sac':
      case 'sacs':
        return Image.asset(
          "assets/images/sac.png",
          width: 80,
          height: 80,
        );
      case 'poudre':
      case 'pourdes':
        return Image.asset(
          "assets/images/poudre.png",
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

  void _showBottomSheet1() {
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
                        "Ajouter une forme de produit",
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
                          controller: libelleController,
                          decoration: InputDecoration(
                            hintText: "Libelle",
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
                        ElevatedButton.icon(
                          onPressed: () async {
                            final String libelle = libelleController.text;
                            final String description =
                                descriptionController.text;
                            if (formkey.currentState!.validate()) {
                              try {
                                await FormeService()
                                    .addFormess(
                                      libelleForme: libelle,
                                      descriptionForme: description,
                                    )
                                    .then((value) => {
                                          Provider.of<FormeService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          setState(() {
                                            _liste = getListe();
                                          }),
                                          libelleController.clear(),
                                          descriptionController.clear(),
                                          Navigator.of(context).pop()
                                        });
                              } catch (e) {
                                final String errorMessage = e.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Text("Une erreur s'est produite"),
                                      ],
                                    ),
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
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
}

class UpdateFormeClass extends StatefulWidget {
  final Forme forme;
  const UpdateFormeClass({super.key, required this.forme});

  @override
  State<UpdateFormeClass> createState() => _UpdateFormeClassState();
}

class _UpdateFormeClassState extends State<UpdateFormeClass> {
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  late Forme formes;

  @override
  void initState() {
    formes = widget.forme;
    libelleController.text = formes.libelleForme!;
    descriptionController.text = formes.descriptionForme!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Modification",
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
                    controller: libelleController,
                    decoration: InputDecoration(
                      hintText: "Nom de la filiere",
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
                  ElevatedButton.icon(
                    onPressed: () async {
                      final String libelle = libelleController.text;
                      final String description = descriptionController.text;
                      if (formkey.currentState!.validate()) {
                        try {
                          await FormeService()
                              .updatesFormes(
                                idForme: formes.idForme!,
                                libelleForme: libelle,
                                descriptionForme: description,
                              )
                              .then((value) => {
                                    Provider.of<FormeService>(context,
                                            listen: false)
                                        .applyChange(),
                                    // setState(() {
                                    //                             _liste =
                                    //                                 getListe();
                                    //                           }),
                                    libelleController.clear(),
                                    descriptionController.clear(),
                                    Navigator.of(context).pop()
                                  });
                        } catch (e) {
                          final String errorMessage = e.toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Text("Une erreur s'est produite"),
                                ],
                              ),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Orange color code
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(290, 45),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Modifier",
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
      ),
    );
  }
}
