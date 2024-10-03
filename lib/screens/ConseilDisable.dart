import 'package:flutter/material.dart';
import 'package:koumi/models/Conseil.dart';
import 'package:koumi/screens/DetailConseil.dart';
import 'package:koumi/screens/UpdateConseil.dart';
import 'package:koumi/service/ConseilService.dart';
import 'package:provider/provider.dart';

class ConseilDisable extends StatefulWidget {
  const ConseilDisable({super.key});

  @override
  State<ConseilDisable> createState() => _ConseilDisableState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _ConseilDisableState extends State<ConseilDisable> {
  late TextEditingController _searchController;
  List<Conseil> conseilList = [];
  late Future _liste;
  bool isSearchMode = false;

  Future<List<Conseil>> getListe() async {
    final response = ConseilService().fetchConseil();
    return response;
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

  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _liste = getListe();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: const Text(
          "Conseil désactiver",
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isSearchMode = !isSearchMode;
                        _searchController.clear();
                      });
                    },
                    icon: Icon(
                      isSearchMode ? Icons.close : Icons.search,
                      color: isSearchMode ? Colors.red : Colors.green,
                    ),
                    label: Text(
                      isSearchMode ? 'Fermer' : 'Rechercher...',
                      style: TextStyle(
                          color: isSearchMode ? Colors.red : Colors.green,
                          fontSize: 17),
                    ),
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
                      future: _liste,
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
                                      element.statutConseil == false)
                                  .isEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                      child: Text("Aucun conseil trouvé")),
                                )
                              : Column(
                                  children: filtereSearch
                                      .where((element) =>
                                          element.statutConseil == false)
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
                                                          "Date d'ajout : ${e.dateAjout!}",
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ))),
                                                  SizedBox(height: 10),
                                                  Container(
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
                                                        _buildEtat(
                                                            e.statutConseil),
                                                        PopupMenuButton<String>(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          itemBuilder:
                                                              (context) =>
                                                                  <PopupMenuEntry<
                                                                      String>>[
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    e.statutConseil ==
                                                                            false
                                                                        ? Icon(
                                                                            Icons.check,
                                                                            color:
                                                                                Colors.green,
                                                                          )
                                                                        : Icon(
                                                                            Icons.disabled_visible,
                                                                            color:
                                                                                d_colorGreen,
                                                                          ),
                                                                title: Text(
                                                                  "Activer",
                                                                  style:
                                                                      TextStyle(
                                                                    color: e.statutConseil ==
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
                                                                      Navigator.of(context)
                                                                            .pop();
                                                                  await ConseilService()
                                                                      .activerConseil(e
                                                                          .idConseil!)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<ConseilService>(context, listen: false).applyChange(),
                                                                                Navigator.of(context).pop(),
                                                                                setState(() {
                                                                                  _liste = getListe();
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
                                                                              });
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
                                                                      Navigator.of(context)
                                                                            .pop();
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              UpdateConseil(conseils: e)));
                                                                },
                                                              ),
                                                            ),
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons.delete,
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
                                                                      Navigator.of(context)
                                                                            .pop();
                                                                  await ConseilService()
                                                                      .deleteConseil(e
                                                                          .idConseil!)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<ConseilService>(context, listen: false).applyChange(),
                                                                                Navigator.of(context).pop(),
                                                                                setState(() {
                                                                                  _liste = getListe();
                                                                                }),
                                                                              })
                                                                      .catchError(
                                                                          (onError) =>
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
