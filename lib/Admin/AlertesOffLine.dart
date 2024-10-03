import 'package:flutter/material.dart';
// import 'package:koumi/Admin/AddAlertesOffLine.dart';
import 'package:koumi/Admin/AlerteDisable.dart';
import 'package:koumi/Admin/DetailAlertesOffLine.dart';
// import 'package:koumi/Admin/UpdateAlertesOffLine.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/AlertesOffLine.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/AlertesOffLineService.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AlertesOffLineScreen extends StatefulWidget {
  const AlertesOffLineScreen({super.key});

  @override
  State<AlertesOffLineScreen> createState() => _AlertesOffLineScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _AlertesOffLineScreenState extends State<AlertesOffLineScreen> {
  late Acteur acteur = Acteur();
  String? email = "";
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late TextEditingController _searchController;
  late Future<List<AlertesOffLine>> _liste;
  List<AlertesOffLine> alerteList = [];

  // Future<List<AlertesOffLine>> getAlerteOffLineListe() async {
  //   final response = await AlertesOffLineService()
  //       .fetchAlertes();
  //   return response;
  // }

  // void verify() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   email = prefs.getString('emailActeur');
  //   if (email != null) {
  //     // Si l'email de l'acteur est présent, exécute checkLoggedIn
  //     acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
  //     typeActeurData = acteur.typeActeur!;
  //     type = typeActeurData.map((data) => data.libelle).join(', ');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    typeActeurData = acteur.typeActeur!;
    type = typeActeurData.map((data) => data.libelle).join(', ');
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
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
              icon: const Icon(Icons.arrow_back_ios)),
          title: const Text(
            "Alertes",
            style: TextStyle(
              color: d_colorGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: type.toLowerCase() != 'admin'
              ? null
              : [
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) {
                      return <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          child: ListTile(
                            leading: const Icon(
                              Icons.add,
                              color: d_colorGreen,
                            ),
                            title: const Text(
                              "Ajouter Alerte ",
                              style: TextStyle(
                                color: d_colorGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             AddAlertesOffLineScreen()));
                            },
                          ),
                        ),
                        PopupMenuItem<String>(
                          child: ListTile(
                            leading: const Icon(
                              Icons.remove_red_eye,
                              color: d_colorGreen,
                            ),
                            title: const Text(
                              "Alerte Désactiver ",
                              style: TextStyle(
                                color: d_colorGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AlerteDisable()));
                            },
                          ),
                        ),
                      ];
                    },
                  )
                ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50], // Couleur d'arrière-plan
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: Colors.blueGrey[400]), // Couleur de l'icône
                    SizedBox(
                        width:
                            10), // Espacement entre l'icône et le champ de recherche
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: Colors
                                  .blueGrey[400]), // Couleur du texte d'aide
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<AlertesOffLineService>(
                builder: (context, alerteService, child) {
              return FutureBuilder(
                  future: alerteService.fetchAlertes(),
                  // future: _liste,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return buildShimmerEffect();
                    }

                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(child: Text("Aucune alerte trouvé")),
                      );
                    } else {
                      alerteList = snapshot.data!;
                      String searchText = "";
                      List<AlertesOffLine> filtereSearch =
                          alerteList.where((search) {
                        String libelle =
                            search.titreAlerteOffLine!.toLowerCase();
                        searchText = _searchController.text.toLowerCase();
                        return libelle.contains(searchText);
                      }).toList();
                      return alerteList
                              // .where((element) => element.statutAlerteOffLine == true)
                              .isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(10),
                              child:
                                  Center(child: Text("Aucun alerte  trouvé")),
                            )
                          : Column(
                              children: filtereSearch
                                  // .where(
                                  // (element) => element.statutAlerteOffLine == true)
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailAlertesOffLine(
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
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 5,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Column(children: [
                                              ListTile(
                                                  leading: Image.asset(
                                                    "assets/images/alt.png",
                                                    width: 80,
                                                    height: 80,
                                                  ),
                                                  title: Text(
                                                      e.titreAlerteOffLine!
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )),
                                                  subtitle: Text(
                                                      e.descriptionAlerteOffLine!,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ))),
                                              Text(
                                                  "Date d'ajout : ${e.dateAjout!}",
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.italic,
                                                  )),
                                              SizedBox(height: 10),
                                              typeActeurData
                                                      .map((e) => e.libelle!
                                                          .toLowerCase())
                                                      .contains('admin')
                                                  ? Container(
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
                                                          _buildEtat(e
                                                              .statutAlerteOffLine!),
                                                          PopupMenuButton<
                                                              String>(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            itemBuilder: (context) =>
                                                                <PopupMenuEntry<
                                                                    String>>[
                                                              PopupMenuItem<
                                                                  String>(
                                                                child: ListTile(
                                                                  leading: e.statutAlerteOffLine ==
                                                                          false
                                                                      ? Icon(
                                                                          Icons
                                                                              .check,
                                                                          color:
                                                                              Colors.green,
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .disabled_visible,
                                                                          color:
                                                                              Colors.orange[400]),
                                                                  title: Text(
                                                                    e.statutAlerteOffLine ==
                                                                            false
                                                                        ? "Activer"
                                                                        : "Desactiver",
                                                                    style:
                                                                        TextStyle(
                                                                      color: e.statutAlerteOffLine ==
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
                                                                    e.statutAlerteOffLine ==
                                                                            false
                                                                        ? await AlertesOffLineService()
                                                                            .activerAlertesOffLine(e
                                                                                .idAlerteOffLine!)
                                                                            .then((value) =>
                                                                                {
                                                                                  // setState(() {
                                                                                  //   _liste = getAlerteOffLineListe();
                                                                                  // }),
                                                                                  Provider.of<AlertesOffLineService>(context, listen: false).applyChange(),
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
                                                                        : await AlertesOffLineService()
                                                                            .desactiverAlertesOffLine(e
                                                                                .idAlerteOffLine!)
                                                                            .then((value) =>
                                                                                {
                                                                                  // setState(() {
                                                                                  //   _liste = getAlerteOffLineListe();
                                                                                  // }),
                                                                                  Provider.of<AlertesOffLineService>(context, listen: false).applyChange(),
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
                                                                    // Navigator.push(
                                                                    //     context,
                                                                    //     MaterialPageRoute(
                                                                    //         builder: (context) =>
                                                                    //             UpdateAlertesOffLine(alertes: e)));
                                                                  },
                                                                ),
                                                              ),
                                                              PopupMenuItem<
                                                                  String>(
                                                                child: ListTile(
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
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  onTap:
                                                                      () async {
                                                                    await AlertesOffLineService()
                                                                        .deleteAlertesOffLine(e
                                                                            .idAlerteOffLine!)
                                                                        .then((value) =>
                                                                            {
                                                                              // setState(() {
                                                                              //       _liste = getAlerteOffLineListe();
                                                                              //     }),
                                                                              Provider.of<AlertesOffLineService>(context, listen: false).applyChange(),
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
