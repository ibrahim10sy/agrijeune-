import 'package:flutter/material.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Campagne.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/UpdateCampagne.dart';
import 'package:koumi/service/CampagneService.dart';
import 'package:provider/provider.dart';

class CampagnePage extends StatefulWidget {
  const CampagnePage({super.key});

  @override
  State<CampagnePage> createState() => _CampagnePageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _CampagnePageState extends State<CampagnePage> {
  List<Campagne> campagneList = [];
  final formkey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late TextEditingController _searchController;
  late Acteur acteur;
  bool isSearchMode = false;
  late ScrollController _scrollController;
  // double? si = fontSized;

  late Future<List<Campagne>> _liste;

  Future<List<Campagne>> getCampListe() async {
    final response =
        await CampagneService().fetchCampagneByActeur(acteur.idActeur!);
    return response;
  }

  @override
  void initState() {
      _scrollController = ScrollController();
    _searchController = TextEditingController();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _liste = getCampListe();
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
        title: const Text(
          "Campagne agricole",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:20),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _liste = getCampListe();
                });
              },
              icon: Icon(Icons.refresh,
                color: Colors.white,)),
         
        ],
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
                                _showDialog();
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
               
                Consumer<CampagneService>(builder: (context, camp, child) {
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
                          return const Padding(
                            padding: EdgeInsets.all(10),
                            child: Center(child: Text("Aucun donné trouvé")),
                          );
                        } else {
                          campagneList = snapshot.data!;
                          String searchText = "";
                          List<Campagne> filtereSearch =
                              campagneList.where((search) {
                            String libelle = search.nomCampagne.toLowerCase();
                            searchText = _searchController.text.toLowerCase();
                            return libelle.contains(searchText);
                          }).toList();
                          return filtereSearch.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(child: Text("Aucune donné trouvé")),
                                )
                              : Column(
                                  children: filtereSearch
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
                                              child: Column(children: [
                                                ListTile(
                                                    leading: Image.asset(
                                                      "assets/images/zone.png",
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                                    title: Text(
                                                        e.nomCampagne.toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                        )),
                                                    subtitle: Text(e.description,
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ))),
                                                SizedBox(height: 10),
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
                                                      _buildEtat(e.statutCampagne),
                                                      PopupMenuButton<String>(
                                                        padding: EdgeInsets.zero,
                                                        itemBuilder: (context) =>
                                                            <PopupMenuEntry<
                                                                String>>[
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  e.statutCampagne ==
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
                                                                e.statutCampagne ==
                                                                        false
                                                                    ? "Activer"
                                                                    : "Desactiver",
                                                                style: TextStyle(
                                                                  color: e.statutCampagne ==
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
                                                                e.statutCampagne ==
                                                                        false
                                                                    ? await CampagneService()
                                                                        .activerCampagne(e
                                                                            .idCampagne!)
                                                                        .then(
                                                                            (value) =>
                                                                                {
                                                                                  Provider.of<CampagneService>(context, listen: false).applyChange(),
                                                                                  Navigator.of(context).pop(),
                                                                                  setState(() {
                                                                                    _liste = getCampListe();
                                                                                  }),
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
                                                                    : await CampagneService()
                                                                        .desactiverCampagne(e
                                                                            .idCampagne!)
                                                                        .then(
                                                                            (value) =>
                                                                                {
                                                                                  Provider.of<CampagneService>(context, listen: false).applyChange(),
                                                                                  Navigator.of(context).pop(),
                                                                                  setState(() {
                                                                                    _liste = getCampListe();
                                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                                      const SnackBar(
                                                                                        content: Row(
                                                                                          children: [
                                                                                            Text("Desactiver avec succèss "),
                                                                                          ],
                                                                                        ),
                                                                                        duration: Duration(seconds: 2),
                                                                                      ),
                                                                                    );
                                                                                  })
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
                                                              onTap: () async {
                                                                // Ouvrir la boîte de dialogue de modification
                                                                var updatedSousRegion =
                                                                    await showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      AlertDialog(
                                                                          backgroundColor:
                                                                              Colors
                                                                                  .white,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(16),
                                                                          ),
                                                                          content: UpdateCampagne(
                                                                              campagnes:
                                                                                  e)),
                                                                );
          
                                                                // Si les détails sont modifiés, appliquer les changements
                                                                if (updatedSousRegion !=
                                                                    null) {
                                                                  Provider.of<CampagneService>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .applyChange();
                                                                  setState(() {
                                                                    // _liste =
                                                                    //     updatedSousRegion;
                                                                    _liste =
                                                                        getCampListe();
                                                                  });
                                                                  // Mettre à jour la liste des sous-régions
                                                                }
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
                                                                await CampagneService()
                                                                    .deleteCampagne(e
                                                                        .idCampagne!)
                                                                    .then(
                                                                        (value) => {
                                                                              Provider.of<CampagneService>(context, listen: false)
                                                                                  .applyChange(),
                                                                              Navigator.of(context)
                                                                                  .pop(),
                                                                            })
                                                                    .catchError(
                                                                        (onError) =>
                                                                            {
                                                                              ScaffoldMessenger.of(context)
                                                                                  .showSnackBar(
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
                                              ]),
                                            ),
                                          ))
                                      .toList(),
                                );
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

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Image.asset(
                    "assets/images/zone.png",
                    width: 50,
                    height: 50,
                  ),
                  title: Text(
                    "Ajouter une campagne ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 30,
                      )),
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
                        'Nom campagne',
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
                        controller: nomController,
                        decoration: InputDecoration(
                          hintText: "Nom campagne",
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
                          final String nom = nomController.text;
                          final String desc = descriptionController.text;
                          if (formkey.currentState!.validate()) {
                            try {
                              await CampagneService()
                                  .addCampagne(
                                      nomCampagne: nom,
                                      description: desc,
                                      acteur: acteur)
                                  .then((value) => {
                                        Provider.of<CampagneService>(context,
                                                listen: false)
                                            .applyChange(),
                                        nomController.clear(),
                                        descriptionController.clear(),
                                        setState(() {
                                          // _liste =
                                          //     updatedSousRegion;
                                          _liste = getCampListe();
                                        }),
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
