import 'package:flutter/material.dart';
import 'package:koumi/Admin/DetailsActeur.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:profile_photo/profile_photo.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:koumi/constants.dart';
class PageTransporteur extends StatefulWidget {
  const PageTransporteur({super.key});

  @override
  State<PageTransporteur> createState() => _PageTransporteurState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _PageTransporteurState extends State<PageTransporteur> {
  late TextEditingController _searchController;
  List<Acteur> acteurList = [];
  late Future<List<Acteur>> _liste;
  late Acteur acteur;

  Future<List<Acteur>> getActeur() async {
    final response = await ActeurService().fetchActeur();
    return response;
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    _liste = getActeur();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;

    super.initState();
  }

  @override
  void dispose() {
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: Text(
          "Listes des transporteurs",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
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
            Consumer<ActeurService>(builder: (context, acteurService, child) {
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
                        child: Center(child: Text("Aucun acteur trouvé")),
                      );
                    } else {
                      acteurList = snapshot.data!;
                      String searchText = "";
                      List<Acteur> filtereSearch = acteurList.where((search) {
                        String libelle = search.nomActeur!.toLowerCase();
                        searchText = _searchController.text.toLowerCase();
                        return libelle.contains(searchText);
                      }).toList();

                      return Column(
                          children: filtereSearch
                              .where((element) =>
                                  element.typeActeur!.any((e) => e.libelle!
                                      .toLowerCase()
                                      .contains('transporteur')) ||
                                  element.typeActeur!.any((e) => e.libelle!

                                          .toLowerCase()
                                          .contains('transporteurs')) &&
                                      element.idActeur == acteur.idActeur)
                              .map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailsActeur(acteur: e)));
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
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
                                              leading: ClipOval(
                                          child: CachedNetworkImage(
                                            width: 50,
                                            height: 50,
                                            imageUrl:
                                                "$apiOnlineUrl/acteur/${e.idActeur}/image",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Image.asset(
                                                    'assets/images/profil.jpg'),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/images/profil.jpg',
                                              fit: BoxFit.cover,
                                              width: 50,
                                              height: 50,
                                            ),
                                          ),
                                        ),
                                              title: Text(
                                                  e.nomActeur!.toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                              subtitle: Text(
                                                  e.typeActeur!
                                                      .map((data) =>
                                                          data.libelle)
                                                      .join(', '),
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.italic,
                                                  ))),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Menbres depuis  :",
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    )),
                                                Text(e.dateAjout!,
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )))
                              .toList());
                    }
                  });
            })
          ],
        ),
      ),
    );
  }
}
