import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Commande.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/DetailCommande.dart';
import 'package:koumi/screens/LoginScreen.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/service/CommandeService.dart';
import 'package:koumi/widgets/SnackBar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MesCommande extends StatefulWidget {
  const MesCommande({super.key});

  @override
  State<MesCommande> createState() => _MesCommandeState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _MesCommandeState extends State<MesCommande> {
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];

  late String type;
  late TextEditingController _searchController;
  List<Stock> stockListe = [];
  CategorieProduit? selectedCat;
  List<Commande> _liste = [];
  List<Commande> _filteredListe = [];
  String? typeValue;
  bool isExist = false;
  bool isLoading = true;
  bool isProprietaire = false;
  String? email = "";

  void _filterCommandes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredListe = _liste;
      } else {
        _filteredListe = _liste.where((commande) {
          final codeCommande = commande.codeCommande?.toLowerCase() ?? '';
          final dateCommande = commande.dateCommande?.toLowerCase() ?? '';
          final statutCommande =
              commande.statutCommande?.toString().toLowerCase() ?? '';

          // Inverser le format de la date pour les comparaisons
          String inverseDateFormat(String date) {
            if (date.contains('-')) {
              final parts = date.split('-');
              if (parts.length == 3) {
                return '${parts[2]}-${parts[1]}-${parts[0]}';
              }
            }
            return date;
          }

          final invertedDateCommande = inverseDateFormat(dateCommande);

          final searchQuery = query.toLowerCase();
          return codeCommande.contains(searchQuery) ||
              dateCommande.contains(searchQuery) ||
              invertedDateCommande.contains(searchQuery) ||
              statutCommande.contains(searchQuery);
        }).toList();
      }
    });
  }

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur.typeActeur!;
      type = typeActeurData.map((data) => data.libelle).join(', ');
      setState(() {
        isExist = true;
        //     if (_liste.any((commande) => commande.acteur?.idActeur == acteur.idActeur)) {

        // getAllCommandeByActeur(acteur.idActeur!).then((value) => {
        //   _liste = value
        // });
        // }else{
        //   setState(() {
        //     isProprietaire = true;
        //   });
        // fetchCommandeByActeurProprietaire(acteur.idActeur!).then((value) => {
        //   _liste = value
        // });
        // }
        fetchAllCommandes(acteur.idActeur!).then((combinedList) {
          setState(() {
            _liste = combinedList;
            _filteredListe = combinedList;
            isLoading = false;
          });
        });
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  Future<void> _getDetailCommande(
      BuildContext context, Commande? commande) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailCommandeScreen(
                  idCommande: commande!.idCommande,
                  isProprietaire: acteur.idActeur == commande.acteur?.idActeur
                      ? false
                      : true,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        fetchAllCommandes(acteur.idActeur!).then((combinedList) {
          setState(() {
            _liste = combinedList;
            _filteredListe = combinedList;
            isLoading = false;
          });
        });
      });
    }
  }

  Future<List<Commande>> fetchAllCommandes(String idActeur) async {
    final commandesActeur = await getAllCommandeByActeur(idActeur);
    final commandesProprietaire =
        await fetchCommandeByActeurProprietaire(idActeur);
    return [...commandesActeur, ...commandesProprietaire];
  }

  Future<List<Commande>> getAllCommandeByActeur(String idActeur) async {
    final response = await CommandeService().fetchCommandeByActeur(idActeur);
    return response;
  }

  Future<List<Commande>> fetchCommandeByActeurProprietaire(
      String acteurProprietaire) async {
    final response = await CommandeService()
        .fetchCommandeByActeurProprietaire(acteurProprietaire);
    return response;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController = TextEditingController();
    verify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
          title: Text(
            "Mes commandes",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    fetchAllCommandes(acteur.idActeur!).then((combinedList) {
                      setState(() {
                        _liste = combinedList;
                        _filteredListe = combinedList;
                        isLoading = false;
                      });
                    });
                  });
                },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                )),
          ],
        ),
        body: !isExist
            ? Center(
                child: Container(
                  padding: EdgeInsets.all(
                      20), // Ajouter un padding pour l'espace autour du contenu

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/lock.png",
                          width: 100,
                          height:
                              100), // Ajuster la taille de l'image selon vos besoins
                      SizedBox(
                          height:
                              20), // Ajouter un espace entre l'image et le texte
                      Text(
                        "Vous devez vous connecter pour voir vos commandes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                          height:
                              20), // Ajouter un espace entre le texte et le bouton
                      ElevatedButton(
                        onPressed: () {
                          Future.microtask(() {
                            Provider.of<BottomNavigationService>(context,
                                    listen: false)
                                .changeIndex(0);
                          });
                          Get.to(LoginScreen(),
                              duration: Duration(
                                  seconds:
                                      1), //duration of transitions, default 1 sec
                              transition: Transition.leftToRight);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          elevation: MaterialStateProperty.all<double>(
                              0), // Supprimer l'élévation du bouton
                          overlayColor: MaterialStateProperty.all<Color>(
                              Colors.grey.withOpacity(
                                  0.2)), // Couleur de l'overlay du bouton lorsqu'il est pressé
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                  color:
                                      d_colorGreen), // Bordure autour du bouton
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            "Se connecter",
                            style: TextStyle(fontSize: 16, color: d_colorGreen),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    fetchAllCommandes(acteur.idActeur!).then((value) => {
                          // _liste = value,
                          _filteredListe = value
                        });
                  });
                },
                child: SingleChildScrollView(
                    child: Column(
                  children: [
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
                                color: Colors.blueGrey[400],
                                size:
                                    28), // Utiliser une icône de recherche plus grande
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  _filterCommandes(value);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Rechercher',
                                  border: InputBorder.none,
                                  hintStyle:
                                      TextStyle(color: Colors.blueGrey[400]),
                                ),
                              ),
                            ),
                            // Ajouter un bouton de réinitialisation pour effacer le texte de recherche
                            IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterCommandes('');
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text("Liste des commandes :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Table(
                          border: TableBorder.all(color: Colors.black38),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            // Header row

                            TableRow(
                              decoration:
                                  BoxDecoration(color: Colors.redAccent),
                              children: [
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        "Code",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        "Date",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        "Statut",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                // TableCell(
                                //   verticalAlignment:
                                //       TableCellVerticalAlignment.middle,
                                //   child: Padding(
                                //     padding: const EdgeInsets.all(8.0),
                                //     child: Center(
                                //       child: Text(
                                //         "Action",
                                //         style: TextStyle(
                                //             color: Colors.white,
                                //             fontSize: 14,
                                //             fontWeight: FontWeight.bold),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),

                            if (isLoading)
                              ...List.generate(10, (index) => buildShimmerRow())
                            else
                              // Data rows

                              ..._filteredListe
                                  .where(
                                    (element) => element.statutCommande == true,
                                  )
                                  .map(
                                    (commande) => TableRow(
                                      children: [
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                _getDetailCommande(
                                                    context, commande);
                                                if (acteur.idActeur ==
                                                    commande.acteur?.idActeur) {
                                                  print(
                                                      "acteur qui a commande");
                                                } else {
                                                  print("acteur proprietaire");
                                                }
                                              },
                                              child: Center(
                                                child: Text(
                                                    commande.codeCommande!,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                _getDetailCommande(
                                                    context, commande);
                                                if (acteur.idActeur ==
                                                    commande.acteur?.idActeur) {
                                                  print(
                                                      "acteur qui a commande");
                                                } else {
                                                  print("acteur proprietaire");
                                                }
                                              },
                                              child: Center(
                                                child: Text(
                                                    commande.dateCommande!,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: GestureDetector(
                                                child: Center(
                                                  child: Container(
                                                    width: 80,
                                                    color:
                                                        commande.statutConfirmation ==
                                                                false
                                                            ? Colors.red
                                                            : Colors.green,
                                                    child: Center(
                                                      child: Text(
                                                        commande.statutConfirmation ==
                                                                false
                                                            ? "En attende"
                                                            : "Valider",
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (acteur.idActeur ==
                                                      commande
                                                          .acteur?.idActeur) {
                                                    print(
                                                        "acteur qui a commande");

                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(commande
                                                                      .statutConfirmation ==
                                                                  false
                                                              ? 'Suppression la commande'
                                                              : 'Annulation la commande'),
                                                          content: Text(commande
                                                                      .statutConfirmation ==
                                                                  false
                                                              ? 'Êtes-vous sûr de vouloir supprimer la commande ?'
                                                              : 'Êtes-vous sûr de vouloir annuler la commande ?'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: const Text(
                                                                  'Non',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green)),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                try {
                                                                  commande.statutConfirmation! ==
                                                                          false
                                                                      ? await CommandeService()
                                                                          .disableCommane(commande
                                                                              .idCommande!)
                                                                          .then((value) =>
                                                                              {
                                                                                Navigator.of(context).pop(),
                                                                                // Mettre à jour la liste
                                                                                Provider.of<CommandeService>(context, listen: false).applyChange(),
                                                                                fetchAllCommandes(acteur.idActeur!).then((combinedList) {
                                                                                  setState(() {
                                                                                    _liste = combinedList;
                                                                                    _filteredListe = combinedList;
                                                                                    isLoading = false;
                                                                                  });
                                                                                }),
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Row(
                                                                                      children: [
                                                                                        Text("Supprimer avec succèss"),
                                                                                      ],
                                                                                    ),
                                                                                    duration: Duration(seconds: 5),
                                                                                  ),
                                                                                ),
                                                                              })
                                                                          .catchError((onError) =>
                                                                              {
                                                                                print("onError : ${onError.toString()}"),
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
                                                                      : await CommandeService()
                                                                          .disableCommandeWithNotif(commande
                                                                              .idCommande!)
                                                                          .then((value) =>
                                                                              {
                                                                                Navigator.of(context).pop(),
                                                                                // Mettre à jour la liste
                                                                                Provider.of<CommandeService>(context, listen: false).applyChange(),
                                                                                fetchAllCommandes(acteur.idActeur!).then((combinedList) {
                                                                                  setState(() {
                                                                                    _liste = combinedList;
                                                                                    _filteredListe = combinedList;
                                                                                    isLoading = false;
                                                                                  });
                                                                                }),
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Row(
                                                                                      children: [
                                                                                        Text("Commande annulé avec succèss"),
                                                                                      ],
                                                                                    ),
                                                                                    duration: Duration(seconds: 5),
                                                                                  ),
                                                                                ),
                                                                              })
                                                                          .catchError((onError) =>
                                                                              {
                                                                                print("onError : ${onError.toString()}"),
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
                                                                  ;
                                                                } catch (e) {
                                                                  print(
                                                                      "catch : ${e.toString()}");
                                                                }
                                                              },
                                                              child: const Text(
                                                                'Oui',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),

                                                            // TextButton(
                                                            //   onPressed:
                                                            //       () async {
                                                            //     Navigator.pop(
                                                            //         context);
                                                            //     // Call the callback function for cancellation

                                                            //     commande.statutCommande! ==
                                                            //             true
                                                            //         ? await CommandeService()
                                                            //             .disableCommane(commande
                                                            //                 .idCommande!)
                                                            //             .then((value) =>
                                                            //                 {
                                                            //                   // Mettre à jour la liste
                                                            //                   // Provider.of<CommandeService>(context, listen: false).applyChange(),
                                                            //                   // // setState(() { }),
                                                            //                   //   setState(() {

                                                            //                   //     _filteredListe = _liste;

                                                            //                   //   }),

                                                            //                   Navigator.of(context).pop(),

                                                            //                   ScaffoldMessenger.of(context).showSnackBar(
                                                            //                     const SnackBar(
                                                            //                       content: Row(
                                                            //                         children: [
                                                            //                           Text("Commande annulé avec succèss"),
                                                            //                         ],
                                                            //                       ),
                                                            //                       duration: Duration(seconds: 5),
                                                            //                     ),
                                                            //                   ),
                                                            //                 })
                                                            //             .catchError(
                                                            //                 (onError) =>
                                                            //                     {
                                                            //                       ScaffoldMessenger.of(context).showSnackBar(
                                                            //                         const SnackBar(
                                                            //                           content: Row(
                                                            //                             children: [
                                                            //                               Text("Une erreur s'est produit"),
                                                            //                             ],
                                                            //                           ),
                                                            //                           duration: Duration(seconds: 5),
                                                            //                         ),
                                                            //                       ),
                                                            //                       Navigator.of(context).pop(),
                                                            //                     })
                                                            //         : null;
                                                            //   },
                                                            //   child: const Text(
                                                            //       'Oui',
                                                            //       style: TextStyle(
                                                            //           color: Colors
                                                            //               .red)),
                                                            // ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    print(
                                                        "je suis propriétaire");
                                                    Snack.error(
                                                        titre: "Alerte",
                                                        message:
                                                            "Vos produits ont été commandé donc uniquement l'acheteur peut annuler la commande");
                                                  }
                                                },
                                              ),
                                            ))
                                      ],
                                    ),
                                  )
                          ],
                        ))
                  ],
                )),
              ));
  }

  TableRow buildShimmerRow() {
    return TableRow(
      children: [
        buildShimmerCell(),
        buildShimmerCell(),
        buildShimmerCell(),
      ],
    );
  }

  TableCell buildShimmerCell() {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
