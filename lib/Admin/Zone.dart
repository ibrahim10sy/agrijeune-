import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:koumi/Admin/AddZone.dart';
import 'package:koumi/Admin/UpdateZone.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/ZoneProduction.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/ZoneProductionService.dart';
import 'package:provider/provider.dart';

class Zone extends StatefulWidget {
  const Zone({super.key});

  @override
  State<Zone> createState() => _ZoneState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _ZoneState extends State<Zone> {
  late List<ZoneProduction> zoneList = [];
  late Acteur acteur;
  late TextEditingController _searchController;
  bool isSearchMode = false;
  late ScrollController _scrollController;
  Future<List<ZoneProduction>>? _liste;

  Future<List<ZoneProduction>> getZone(String id) async {
    final response = await ZoneProductionService().fetchZoneByActeur(id);
    return response;
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _liste = getZone(acteur.idActeur!);
    _searchController = TextEditingController();
    super.initState();
  }

  Future<void> _getResultFromZonePage(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddZone()));
    log(result.toString());
    if (result == true) {
       _liste = getZone(acteur.idActeur!);
      print("Rafraichissement en cours");
    }
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
              Navigator.pop(context, true);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: const Text(
          "Zone de production",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [],
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
                                    Icons.zoom_in_outlined,
                                    color: d_colorGreen,
                                  ),
                                  title: const Text(
                                    "Ajouter une zone de production",
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
                                _getResultFromZonePage(context);
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
              Consumer<ZoneProductionService>(
                  builder: (context, zoneService, child) {
                return FutureBuilder(
                    future: _liste,
                    // future: zoneService.fetchZoneByActeur(acteur.idActeur!),
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
                          child: Center(child: Text("Aucun zone trouvé")),
                        );
                      } else {
                        zoneList = snapshot.data!;
                        String searchText = "";
                        List<ZoneProduction> filtereSearch =
                            zoneList.where((search) {
                          String libelle =
                              search.nomZoneProduction!.toLowerCase();
                          searchText = _searchController.text.toLowerCase();
                          return libelle.contains(searchText);
                        }).toList();
                        return Column(
                            children: filtereSearch
                                .map((ZoneProduction zone) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Card(
                                        elevation: 5,
                                        shadowColor: Colors.black,
                                        color: Colors.white,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          // height: 305,
                                          child: Column(children: [
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: zone.photoZone == null ||
                                                        zone.photoZone!.isEmpty
                                                    ? Image.asset(
                                                        "assets/images/zoneProd.jpg",
                                                        fit: BoxFit.fitWidth,
                                                        height: 110,
                                                        width: double.infinity,
                                                      )
                                                    : CachedNetworkImage(
                                                        width: double.infinity,
                                                        height: 110,
                                                        imageUrl:
                                                            "https://koumi.ml/api-koumi/ZoneProduction/${zone.idZoneProduction}/image",
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            const Center(
                                                                child:
                                                                    CircularProgressIndicator()),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          'assets/images/default_image.png',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                      "Zone de production",
                                                      style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          overflow: TextOverflow
                                                              .ellipsis)),
                                                  Text(zone.nomZoneProduction!,
                                                      style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          overflow: TextOverflow
                                                              .ellipsis))
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text("Date d'ajout",
                                                      style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          overflow: TextOverflow
                                                              .ellipsis)),
                                                  Text(
                                                    zone.dateAjout!,
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    _buildEtat(
                                                        zone.statutZone!),
                                                    PopupMenuButton<String>(
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (context) =>
                                                          <PopupMenuEntry<
                                                              String>>[
                                                        PopupMenuItem<String>(
                                                          child: ListTile(
                                                            leading:
                                                                zone.statutZone ==
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
                                                                            .orange[400],
                                                                      ),
                                                            title: Text(
                                                              zone.statutZone ==
                                                                      false
                                                                  ? "Activer"
                                                                  : "Desactiver",
                                                              style: TextStyle(
                                                                color: zone.statutZone ==
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
                                                              zone.statutZone ==
                                                                      false
                                                                  ? await ZoneProductionService()
                                                                      .activerZone(zone
                                                                          .idZoneProduction!)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<ZoneProductionService>(context, listen: false).applyChange(),
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
                                                                  : await ZoneProductionService()
                                                                      .desactiverZone(zone
                                                                          .idZoneProduction!)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<ZoneProductionService>(context, listen: false).applyChange(),
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
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                            title: const Text(
                                                              "Modifier",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          UpdateZone(
                                                                              zone: zone)));
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
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            onTap: () async {
                                                              await ZoneProductionService()
                                                                  .deleteZone(zone
                                                                      .idZoneProduction!)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            Provider.of<ZoneProductionService>(context, listen: false).applyChange(),
                                                                            Navigator.of(context).pop(),
                                                                          })
                                                                  .catchError(
                                                                      (onError) =>
                                                                          {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              const SnackBar(
                                                                                content: Row(
                                                                                  children: [
                                                                                    Text("Ce type d'acteur est déjà associer à un acteur"),
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
                                                    )
                                                  ],
                                                ))
                                          ]),
                                        ),
                                      ),
                                    ))
                                .toList());
                      }
                    });
              })
            ]),
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
