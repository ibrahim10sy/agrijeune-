import 'package:flutter/material.dart';
import 'package:koumi/models/Continent.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/models/SousRegion.dart';
import 'package:koumi/service/SousRegionService.dart';
import 'package:provider/provider.dart';

class SousRegionList extends StatefulWidget {
  final Continent continent;
  const SousRegionList({super.key, required this.continent});

  @override
  State<SousRegionList> createState() => _SousRegionListState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _SousRegionListState extends State<SousRegionList> {
  List<SousRegion> regionList = [];
  late TextEditingController _searchController;
  late Continent continents;
  late Future<List<SousRegion>> _liste;
  List<Pays> paysList = [];

  Future<List<SousRegion>> getSousListe() async {
    return await SousRegionService()
        .fetchSousRegionByContinent(continents.idContinent!);
  }

  @override
  void initState() {
    super.initState();
    continents = widget.continent;
    _liste = getSousListe();
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
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
          title: Text(
            continents.nomContinent.toUpperCase(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 20),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
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
            Consumer<SousRegionService>(
              builder: (context, sousService, child) {
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
                          child:
                              Center(child: Text("Aucun sous region trouvé")),
                        );
                      } else {
                        regionList = snapshot.data!;
                        String searchText = "";
                        List<SousRegion> filtereSearch =
                            regionList.where((search) {
                          String libelle = search.nomSousRegion.toLowerCase();
                          searchText = _searchController.text.toLowerCase();
                          return libelle.contains(searchText);
                        }).toList();
                        return Column(
                            children: filtereSearch
                                .map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
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
                                                  "assets/images/sous.png",
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                title: Text(
                                                    e.nomSousRegion
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                subtitle: Text(
                                                    e.continent.nomContinent.trim(),
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ))),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Continent :",
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      )),
                                                  Text(e.continent.nomContinent,
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ))
                                                ],
                                              ),
                                            ),
                                           

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
                                                  _buildEtat(
                                                      e.statutSousRegion),
                                                  PopupMenuButton<String>(
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder: (context) =>
                                                        <PopupMenuEntry<
                                                            String>>[
                                                      PopupMenuItem<String>(
                                                        child: ListTile(
                                                          leading:
                                                              e.statutSousRegion ==
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
                                                            e.statutSousRegion ==
                                                                    false
                                                                ? "Activer"
                                                                : "Desactiver",
                                                            style: TextStyle(
                                                              color: e.statutSousRegion ==
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
                                                            e.statutSousRegion ==
                                                                    false
                                                                ? await SousRegionService()
                                                                    .activerSousRegion(e
                                                                        .idSousRegion!)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              Provider.of<SousRegionService>(context, listen: false).applyChange(),
                                                                              setState(() {
                                                                                _liste = SousRegionService().fetchSousRegionByContinent(continents.idContinent!);
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
                                                                : await SousRegionService()
                                                                    .desactiverSousRegion(e
                                                                        .idSousRegion!)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              Provider.of<SousRegionService>(context, listen: false).applyChange(),
                                                                              setState(() {
                                                                                _liste = SousRegionService().fetchSousRegionByContinent(continents.idContinent!);
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
                                                            await SousRegionService()
                                                                .deleteSousRegion(e
                                                                    .idSousRegion!)
                                                                .then(
                                                                    (value) => {
                                                                          Provider.of<SousRegionService>(context, listen: false)
                                                                              .applyChange(),
                                                                              setState(
                                                                              () {
                                                                            _liste =
                                                                                SousRegionService().fetchSousRegionByContinent(continents.idContinent!);
                                                                          }),
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
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList());
                      }
                    });
              },
            ),
          ]),
        ));
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
