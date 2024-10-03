import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Conseil.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddConseil.dart';
import 'package:koumi/screens/ConseilDisable.dart';
import 'package:koumi/screens/DetailConseil.dart';
import 'package:koumi/screens/UpdateConseil.dart';
import 'package:koumi/service/ConseilService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ConseilScreen extends StatefulWidget {
  const ConseilScreen({super.key});

  @override
  State<ConseilScreen> createState() => _ConseilScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _ConseilScreenState extends State<ConseilScreen> {
  bool isExist = false;
  late Acteur acteur = Acteur();
  String? email = "";
  late List<TypeActeur> typeActeurData = [];
  late ScrollController _scrollController;
  // late String? type;
  late TextEditingController _searchController;
  List<Conseil> conseilList = [];
  bool isSearchMode = false;
  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur.typeActeur!;
      // type = typeActeurData.map((data) => data.libelle).join(', ');
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    // typeActeurData = acteur.typeActeur!;
    // type = typeActeurData.map((data) => data.libelle).join(', ');
    verify();
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
          backgroundColor: d_colorGreen,
          centerTitle: true,
          toolbarHeight: 75,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
          title: const Text(
            "Conseils",
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
                     !isExist
              ? Container()
              : (typeActeurData
                      .map((e) => e.libelle!.toLowerCase())
                      .contains("admin"))
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
                                          "Ajouter conseil",
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
                                          "Conseil désactiver",
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
                                                  AddConseil()));
                                    }
                                    if (value == 'disable') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ConseilDisable()));
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
                            
                          : (typeActeurData
                      .map((e) => e.libelle!.toLowerCase())
                      .contains("producteur")) ?TextButton(
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
                                          "Ajouter conseil",
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
                                                  AddConseil()));
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
                            ) : Container(),
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
                Consumer<ConseilService>(
                    builder: (context, conseilService, child) {
                  return FutureBuilder(
                      future: conseilService.fetchConseil(),
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
                          conseilList = snapshot.data!;
                          String searchText = "";
                          List<Conseil> filtereSearch =
                              conseilList.where((search) {
                            String libelle = search.titreConseil.toLowerCase();
                            searchText = _searchController.text.toLowerCase();
                            return libelle.contains(searchText);
                          }).toList();
                          return filtereSearch
                                  .where((element) =>
                                      element.statutConseil == true)
                                  .isEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                      child: Text("Aucun conseil trouvé")),
                                )
                              : Column(
                                  children: filtereSearch
                                      .where((element) =>
                                          element.statutConseil == true)
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 15),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailConseil(
                                                                conseil: e)));
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
                                                        "assets/images/conseille.png",
                                                        width: 80,
                                                        height: 80,
                                                      ),
                                                      title: Text(
                                                          e.titreConseil
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
                                                          e.descriptionConseil,
                                                          maxLines: 2,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 17,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                                                  (typeActeurData
                                                          .map((e) => e.libelle!
                                                              .toLowerCase())
                                                          .contains("admin"))
                                                      ? Container(
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
                                                                  .statutConseil),
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
                                                                      leading: e.statutConseil ==
                                                                              false
                                                                          ? Icon(
                                                                              Icons.check,
                                                                              color: Colors.green,
                                                                            )
                                                                          : Icon(
                                                                              Icons.disabled_visible,
                                                                              color: Colors.orange[400],
                                                                            ),
                                                                      title:
                                                                          Text(
                                                                        e.statutConseil ==
                                                                                false
                                                                            ? "Activer"
                                                                            : "Desactiver",
                                                                        style:
                                                                            TextStyle(
                                                                          color: e.statutConseil == false
                                                                              ? Colors.green
                                                                              : Colors.orange[400],
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        e.statutConseil ==
                                                                                false
                                                                            ? await ConseilService()
                                                                                .activerConseil(e.idConseil!)
                                                                                .then((value) => {
                                                                                      Provider.of<ConseilService>(context, listen: false).applyChange(),
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
                                                                            : await ConseilService()
                                                                                .desactiverConseil(e.idConseil!)
                                                                                .then((value) => {
                                                                                      Provider.of<ConseilService>(context, listen: false).applyChange(),
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
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => UpdateConseil(conseils: e)));
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
                                                                        await ConseilService()
                                                                            .deleteConseil(e
                                                                                .idConseil!)
                                                                            .then((value) =>
                                                                                {
                                                                                  Provider.of<ConseilService>(context, listen: false).applyChange(),
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
                                                      : Container()
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
