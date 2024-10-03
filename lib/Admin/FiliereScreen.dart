import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/AddCategorie.dart';
import 'package:koumi/Admin/UpdatesFiliere.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Filiere.dart';
import 'package:koumi/models/ParametreGeneraux.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/CategorieService.dart';
import 'package:koumi/service/FiliereService.dart';
import 'package:provider/provider.dart';

class FiliereScreen extends StatefulWidget {
  const FiliereScreen({super.key});

  @override
  State<FiliereScreen> createState() => _FiliereScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _FiliereScreenState extends State<FiliereScreen> {
  List<Filiere> filiereList = [];
  late ParametreGeneraux para;
  List<ParametreGeneraux> paraList = [];
  late Acteur acteur;
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? filiereValue;
  late Future _filiereList;
  late Future<List<Filiere>> _liste;
  late Filiere filiere;
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  List<Filiere> filiereListe = [];
  bool isSearchMode = false;
  late ScrollController _scrollController;

  Future<List<Filiere>> getFil() async {
    filiereListe = await FiliereService().fetchFiliere();
    return filiereListe;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    // paraList = Provider.of<ParametreGenerauxProvider>(context, listen: false)
    //     .parametreList!;
    // para = paraList[0];
    _filiereList = http.get(Uri.parse('$apiOnlineUrl/Filiere/getAllFiliere/'));
    _liste = getFil();
  }

  @override
  void dispose() {
    if (mounted) {
      _searchController.dispose();
    }
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
          "Filières agricoles",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
       
      ),
      body: Container(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                                    value: 'add_fil',
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.add,
                                        color: d_colorGreen,
                                      ),
                                      title: const Text(
                                        "Ajouter une filière",
                                        style: TextStyle(
                                          color: d_colorGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
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
                                  if (value == 'add_fil') {
                                    _showBottomSheet();
                                  } else if (value == 'add_cat') {
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
                                  color:
                                      isSearchMode ? Colors.red : d_colorGreen,
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
                Consumer<FiliereService>(
                  builder: (context, filiereService, child) {
                    return FutureBuilder(
                        future: filiereService.fetchFiliere(),
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
                            return Padding(
                                padding: EdgeInsets.all(10),
                                child: Text('Aucune filière trouvé ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      overflow: TextOverflow.ellipsis,
                                    )));
                          } else {
                            filiereList = snapshot.data!;
                            String searchText = "";
                            List<Filiere> filteredFiliereSearch =
                                filiereList.where((fil) {
                              String nomfiliere =
                                  fil.libelleFiliere!.toLowerCase();
                              searchText = _searchController.text.toLowerCase();
                              return nomfiliere.contains(searchText);
                            }).toList();
                            return filteredFiliereSearch.isEmpty
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
                                              'Aucune filière trouvé',
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
                                : Column(
                                    children: filteredFiliereSearch
                                        .map((e) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 15),
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
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AddCategorie(
                                                                  filiere: e,
                                                                )));
                                                  },
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                          leading:
                                                              _getIconForFiliere(e
                                                                  .libelleFiliere!),
                                                          title: Text(
                                                              e.libelleFiliere!
                                                                  .toUpperCase(),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                          subtitle: Text(
                                                              e.descriptionFiliere!
                                                                  .trim(),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ))),
                                                      Container(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            _buildEtat(e
                                                                .statutFiliere!),
                                                            PopupMenuButton<
                                                                String>(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              itemBuilder: (context) =>
                                                                  <PopupMenuEntry<
                                                                      String>>[
                                                                PopupMenuItem<
                                                                    String>(
                                                                  child:
                                                                      ListTile(
                                                                    leading: e.statutFiliere ==
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
                                                                                Colors.orange[400]),
                                                                    title: Text(
                                                                      e.statutFiliere ==
                                                                              false
                                                                          ? "Activer"
                                                                          : "Desactiver",
                                                                      style:
                                                                          TextStyle(
                                                                        color: e.statutFiliere ==
                                                                                false
                                                                            ? Colors.green
                                                                            : Colors.orange[400],
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    onTap:
                                                                        () async {
                                                                      e.statutFiliere ==
                                                                              false
                                                                          ? await FiliereService()
                                                                              .activerFiliere(e.idFiliere!)
                                                                              .then((value) => {
                                                                                    Provider.of<FiliereService>(context, listen: false).applyChange(),
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
                                                                          : await FiliereService()
                                                                              .desactiverFiliere(e.idFiliere!)
                                                                              .then((value) => {
                                                                                    Provider.of<FiliereService>(context, listen: false).applyChange(),
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
                                                                          .edit,
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
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    onTap:
                                                                        () async {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();

                                                                      bottomUpdateFiliere(
                                                                          context,
                                                                          e);
                                                                      Provider.of<FiliereService>(
                                                                              context,
                                                                              listen: false)
                                                                          .applyChange();
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
                                                                        color: Colors
                                                                            .red,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    onTap:
                                                                        () async {
                                                                      await FiliereService()
                                                                          .deleteFiliere(e
                                                                              .idFiliere!)
                                                                          .then((value) =>
                                                                              {
                                                                                Provider.of<FiliereService>(context, listen: false).applyChange(),
                                                                                Navigator.of(context).pop(),
                                                                                setState(() {
                                                                                  _filiereList = http.get(Uri.parse('$apiOnlineUrl/Filiere/getAllFiliere/'));
                                                                                })
                                                                              })
                                                                          .catchError((onError) =>
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

// Méthode pour afficher la feuille inférieure (bottom sheet)
  void bottomUpdateFiliere(BuildContext context, Filiere? filiere) {
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
              child: UpdatesFilieres(filiere: filiere!)),
        );
      },
    );
  }

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
      case 'animale':
        return Image.asset(
          "assets/images/betail.png",
          width: 80,
          height: 80,
        );
      case 'légumes':
      case 'légume':
      case 'legumes':
      case 'legume':
      case 'végétale':
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
                      "Ajouter une filière",
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
                              await FiliereService()
                                  .addFileres(
                                    libelleFiliere: libelle,
                                    descriptionFiliere: description,
                                  )
                                  .then((value) => {
                                        Provider.of<FiliereService>(context,
                                                listen: false)
                                            .applyChange(),
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Text(
                                                    "Filière ajouté avec success"),
                                              ],
                                            ),
                                            duration: Duration(seconds: 5),
                                          ),
                                        ),
                                        setState(() {
                                          _filiereList = http.get(Uri.parse(
                                              '$apiOnlineUrl/Filiere/getAllFiliere/'));
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
                                      Text("Cette filière existe déjà"),
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
          ),
        );
      },
    );
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  SizedBox(height: 10),
                  Form(
                    key: formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                        Consumer<FiliereService>(
                            builder: (context, filiereService, child) {
                          return FutureBuilder(
                            future: _filiereList,
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              // if (snapshot.hasError) {
                              //   return Text("${snapshot.error}");
                              // }
                              if (snapshot.hasData) {
                                dynamic jsonString =
                                    utf8.decode(snapshot.data.bodyBytes);
                                dynamic responseData = json.decode(jsonString);

                                // Vérifier si responseData est une liste
                                if (responseData is List) {
                                  final reponse = responseData;
                                  final filiereList = reponse
                                      .map((e) => Filiere.fromMap(e))
                                      .where((con) => con.statutFiliere == true)
                                      .toList();

                                  if (filiereList.isEmpty) {
                                    return DropdownButtonFormField(
                                      items: [],
                                      onChanged: null,
                                      decoration: InputDecoration(
                                        labelText: 'Aucun filière trouvé',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }

                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    items: filiereList
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.idFiliere,
                                            child: Text(e.libelleFiliere!),
                                          ),
                                        )
                                        .toList(),
                                    value: filiereValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        filiereValue = newValue;
                                        if (newValue != null) {
                                          filiere = filiereList.firstWhere(
                                            (element) =>
                                                element.idFiliere == newValue,
                                          );
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Sélectionner une filière',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                } else {
                                  return DropdownButtonFormField(
                                    items: [],
                                    onChanged: null,
                                    decoration: InputDecoration(
                                      labelText: 'Aucun filière trouvé',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                }
                              }
                              return DropdownButtonFormField(
                                items: [],
                                onChanged: null,
                                decoration: InputDecoration(
                                  labelText: 'Aucun filière trouvé',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
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
                        SizedBox(height: 20),
                        ElevatedButton.icon(
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
                                          Provider.of<CategorieService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          setState(() {
                                            filiere == null;
                                          }),
                                          libelleController.clear(),
                                          descriptionController.clear(),
                                          Navigator.of(context).pop(),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Text(
                                                      "Catégorie ajouté avec success"),
                                                ],
                                              ),
                                              duration: Duration(seconds: 3),
                                            ),
                                          )
                                        });
                              } catch (e) {
                                final String errorMessage = e.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Text("Cette catgorie existe déjà"),
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
                  ),
                ],
              ),
            ));
      },
    );
  }
}
