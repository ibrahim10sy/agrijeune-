import 'package:flutter/material.dart';
import 'package:koumi/Admin/AddAlerte.dart';
// import 'package:koumi/Admin/AddAlerte.dart';
import 'package:koumi/Admin/AlerteDisable.dart';
import 'package:koumi/Admin/DetailAlerte.dart';
import 'package:koumi/Admin/UpdateAlerte.dart';
// import 'package:koumi/Admin/UpdateAlerte.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Alertes.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/AlerteService.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AlerteScreen extends StatefulWidget {
  const AlerteScreen({super.key});

  @override
  State<AlerteScreen> createState() => _AlerteScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AlerteScreenState extends State<AlerteScreen> {
  late Acteur acteur = Acteur();
  String? email = "";
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late TextEditingController _searchController;
  List<Alertes> alerteList = [];
  bool isSearchMode = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    typeActeurData = acteur.typeActeur!;
    _scrollController = ScrollController();
    type = typeActeurData.map((data) => data.libelle).join(', ');
    _searchController = TextEditingController();
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: const Text(
          "Alertes ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                      typeActeurData
                              .map((e) => e.libelle!.toLowerCase())
                              .contains("admin")
                          ? TextButton(
                              onPressed: () {
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
                                      value: 'add',
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.add,
                                          color: d_colorGreen,
                                        ),
                                        title: const Text(
                                          "Ajouter une alerte",
                                          style: TextStyle(
                                            color: d_colorGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'disable',
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.remove_red_eye,
                                          color: d_colorGreen,
                                        ),
                                        title: const Text(
                                          "Alerte désactiver",
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
                                    if (value == 'add') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddAlerte()));
                                    }
                                    if (value == 'disable') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AlerteDisable()));
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
                            )
                          : Container(),
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
                Consumer<AlertesService>(
                    builder: (context, alerteService, child) {
                  return FutureBuilder(
                      future: alerteService.fetchAlertes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return buildShimmerEffect();
                        }

                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(10),
                            child: Center(child: Text("Aucun conseil trouvé")),
                          );
                        } else {
                          alerteList = snapshot.data!;
                          String searchText = "";
                          List<Alertes> filtereSearch =
                              alerteList.where((search) {
                            String libelle = search.titreAlerte!.toLowerCase();
                            searchText = _searchController.text.toLowerCase();
                            return libelle.contains(searchText);
                          }).toList();
                          return filtereSearch
                                  .where(
                                      (element) => element.statutAlerte == true)
                                  .isEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                      child: Text("Aucun alerte trouvé")),
                                )
                              : Column(
                                  children: filtereSearch
                                      .where((element) =>
                                          element.statutAlerte == true)
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 15),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailAlerte(
                                                                alertes: e)));
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
                                                child: Column(children: [
                                                  ListTile(
                                                      leading: Image.asset(
                                                        "assets/images/alt21.png",
                                                        width: 80,
                                                        height: 80,
                                                      ),
                                                      title: Text(
                                                          e.titreAlerte!
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
                                                          e.descriptionAlerte!,
                                                          maxLines: 2,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ))),
                                                  Text(
                                                      "Date d'ajout : ${e.dateAjout!}",
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      )),
                                                  SizedBox(height: 10),
                                                  type.toLowerCase() != 'admin'
                                                      ? Container()
                                                      : Container(
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
                                                              _buildEtat(e
                                                                  .statutAlerte!),
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
                                                                      leading: e.statutAlerte ==
                                                                              false
                                                                          ? Icon(
                                                                              Icons.check,
                                                                              color: Colors.green,
                                                                            )
                                                                          : Icon(
                                                                              Icons.disabled_visible,
                                                                              color: d_colorOr),
                                                                      title:
                                                                          Text(
                                                                        e.statutAlerte ==
                                                                                false
                                                                            ? "Activer"
                                                                            : "Desactiver",
                                                                        style:
                                                                            TextStyle(
                                                                          color: e.statutAlerte == false
                                                                              ? Colors.green
                                                                              : d_colorOr,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        e.statutAlerte ==
                                                                                false
                                                                            ? await AlertesService()
                                                                                .activerAlertes(e.idAlerte!)
                                                                                .then((value) => {
                                                                                      Provider.of<AlertesService>(context, listen: false).applyChange(),
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
                                                                            : await AlertesService()
                                                                                .desactiverAlertes(e.idAlerte!)
                                                                                .then((value) => {
                                                                                      Provider.of<AlertesService>(context, listen: false).applyChange(),
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
                                                                            .edit,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      title:
                                                                          const Text(
                                                                        "Modifier",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.green,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => UpdateAlerted(alertes: e)));
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
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        await AlertesService()
                                                                            .deleteAlertes(e
                                                                                .idAlerte!)
                                                                            .then((value) =>
                                                                                {
                                                                                  Provider.of<AlertesService>(context, listen: false).applyChange(),
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
                                                ]),
                                              ),
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

  Widget buildShimmerEffect() {
    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: GestureDetector(
                onTap: () {
                  // Handle onTap action
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300]!,
                        ),
                        title: Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.grey[300]!,
                        ),
                        subtitle: Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.grey[300]!,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 100,
                              height: 20,
                              color: Colors.grey[300]!,
                            ),
                            Container(
                              width: 100,
                              height: 20,
                              color: Colors.grey[300]!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
