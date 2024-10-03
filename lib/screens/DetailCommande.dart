import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:koumi/models/DetailCommande.Dart';
import 'package:koumi/service/CommandeService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:koumi/widgets/SnackBar.dart';
import 'package:lottie/lottie.dart';

class DetailCommandeScreen extends StatefulWidget {
  String? idCommande;
  bool? isProprietaire;
  DetailCommandeScreen({super.key, this.idCommande, this.isProprietaire});

  @override
  State<DetailCommandeScreen> createState() => _DetailCommandeScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

class _DetailCommandeScreenState extends State<DetailCommandeScreen> {
  late Future<List<DetailCommande>> futureDetails;
  List<DetailCommande> details = [];
  TextEditingController _quantiteLivrerController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

  //  late Future<List<DetailCommande>> _liste;

  Future<List<DetailCommande>> getListe() async {
    return await CommandeService().fetchDetailsCommande(widget.idCommande!);
  }

  @override
  void initState() {
    super.initState();
    futureDetails = getListe();
  }

  @override
  Widget build(BuildContext context) {
    
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
            backgroundColor: d_colorGreen,
            centerTitle: true,
            toolbarHeight: 75,
          title: Text("Detail Commande",style: TextStyle(color: Colors.white,fontSize: 18,overflow: TextOverflow.ellipsis),),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "Produits commandés",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: const Divider(
                  height: 1,
                  color: Colors.orange,
                  thickness: 1,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<List<DetailCommande>>(
                  future: futureDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      debugPrint(
                          'Erreur lors du chargement des détails: ${snapshot.error}');
                      debugPrint(
                          'Détails de l\'erreur: ${snapshot.error.runtimeType}');
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset('assets/images/notif.jpg'),
                                SizedBox(height: 10),
                                Text(
                                  'Une erreur s\'est produite, veuillez réessayer plus tard',
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
                      );
                    } else if (!snapshot.hasData) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset('assets/images/notif.jpg'),
                                SizedBox(height: 10),
                                Text(
                                  'Aucun détail trouvé',
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
                      );
                    } else {
                      details = snapshot.data!;

                      return ListView.builder(
                        itemCount: details.length,
                        itemBuilder: (context, index) {
                          Future<void> _handleButtonPress() async {
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              if (_quantiteLivrerController.text.isEmpty) {
                                Snack.error(
                                    titre: "Alerte",
                                    message:
                                        "Veuillez remplir le champ quantité livrée");
                                return;
                              }

                              double quantiteLivree =
                                  double.parse(_quantiteLivrerController.text);
                              String message = await CommandeService()
                                  .confirmerLivraison(
                                      details[index].idDetailCommande!,
                                      quantiteLivree);
                              Snack.error(titre: "Alerte", message: message);
                              setState(() {
                                futureDetails = CommandeService()
                                    .fetchDetailsCommande(widget.idCommande!);
                              });
                            } catch (e) {
                              Snack.error(
                                  titre: "Erreur", message: e.toString());
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }

                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white12,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 0.5,
                                  blurRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (details[index].stock != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: details[index].stock!.photo != null
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                "https://koumi.ml/api-koumi/Stock/${details[index].stock!.idStock!}/image",
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 80,
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Image.asset(
                                                    "assets/images/default_image.png",
                                                    width: 50,
                                                    height: 80),
                                          )
                                        : Image.asset(
                                            "assets/images/default_image.png",
                                            width: 50,
                                            height: 80),
                                  )
                                else if (details[index].intrant != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: details[index]
                                                .intrant!
                                                .photoIntrant !=
                                            null
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                "https://koumi.ml/api-koumi/intrant/${details[index].intrant!.idIntrant}/image",
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 80,
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Image.asset(
                                                    "assets/images/default_image.png",
                                                    width: 50,
                                                    height: 80),
                                          )
                                        : Image.asset(
                                            "assets/images/default_image.png",
                                            width: 50,
                                            height: 80),
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        details[index].nomProduit!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Quantité demandée : ${details[index].quantiteDemande!.toInt()}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Quantité livrée : ${details[index].quantiteLivree!.toInt()}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            "${details[index].stock != null ? details[index].stock!.prix : details[index].intrant != null ? details[index].intrant!.prixIntrant : 00} F",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  color: Colors.black,
                                                ),
                                          ),
                                          Expanded(child: Container()),
                                          widget.isProprietaire == true &&
                                                  details[index]
                                                          .quantiteDemande!
                                                          .toInt() !=
                                                      details[index]
                                                          .quantiteLivree!
                                                          .toInt() &&
                                                  details[index].description ==
                                                      null
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Confirmer la livraison'),
                                                          content: TextField(
                                                            controller:
                                                                _quantiteLivrerController,
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'Quantité livrée',
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            onChanged: (value) {
                                                              // Store the quantity entered by the user
                                                            },
                                                          ),
                                                          actions: [
                                                            Row(children: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                    'Annuler'),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (_quantiteLivrerController
                                                                      .text
                                                                      .isEmpty) {
                                                                    Snack.error(
                                                                        titre:
                                                                            "Alerte",
                                                                        message:
                                                                            "Veuiller remplir le champ quantité demandé");
                                                                    return;
                                                                  } else {
                                                                    _handleButtonPress().then(
                                                                        (value) =>
                                                                            {
                                                                              setState(() {
                                                                                isLoading = false;
                                                                              })
                                                                            });
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
                                                                },
                                                                child: Text(
                                                                    'Confirmer'),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    _showCancelConfirmationDialog(
                                                                        details[index]
                                                                            .idDetailCommande!);
                                                                  },
                                                                  child: Text(
                                                                      'Annuler Livraison',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis)),
                                                                ),
                                                              ),
                                                            ]),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Text(' Livrer'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                )
                                              : details[index]
                                                          .commande!
                                                          .statutConfirmation! ==
                                                      true
                                                  ? Row(
                                                      children: [
                                                        Text(
                                                          "Confirmé",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  "Italic"),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          child: Center(
                                                            child: Lottie.asset(
                                                                "assets/anim.json"),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  : details[index]
                                                              .commande!
                                                              .statutConfirmation! ==
                                                          false
                                                      ? Row(
                                                          children: [
                                                            Text(
                                                              "Non confirmé",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      "Italic"),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Container(
                                                              width: 40,
                                                              height: 40,
                                                              child: Center(
                                                                child: Lottie.asset(
                                                                    "assets/cancel.json"),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      : Container(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange[100],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total des quantités demandées : ${details.fold(0.0, (sum, item) => sum + item.quantiteDemande!)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Total des sommes : ${details.fold(0.0, (sum, item) {
                        num? prix = item.stock != null
                            ? item.stock!.prix
                            : item.intrant != null
                                ? item.intrant!.prixIntrant
                                : 0.0;
                        return sum + (prix! * item.quantiteDemande!);
                      }).toStringAsFixed(2)} F",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmationDialog(String idDetailCommande) {
    Future<void> _handleButtonPressAnnulerLivraison() async {
      setState(() {
        isLoading = true;
      });

      try {
        String description = _descriptionController.text.trim();
        String message = await CommandeService().annulerLivraisonParProduit(
            idDetailCommande,
            description: description);
        Snack.error(titre: "Alerte", message: message);
        setState(() {
          futureDetails =
              CommandeService().fetchDetailsCommande(widget.idCommande!);
        });
      } catch (e) {
        Snack.error(titre: "Erreur", message: e.toString());
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer l\'annulation'),
          content: Text('Êtes-vous sûr de vouloir annuler la livraison?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // String message = await CommandeService().annulerLivraisonParProduit(idDetailCommande,description:description);
                // Snack.error(titre: "Alerte", message: message);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Annuler la livraison'),
                      content: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Description (optionnel)',
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          // Store the quantity entered by the user
                        },
                      ),
                      actions: [
                        Row(children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              _handleButtonPressAnnulerLivraison()
                                  .then((value) => {
                                        setState(() {
                                          isLoading = false;
                                        })
                                      });
                              Navigator.of(context).pop();
                            },
                            child: Text('Annuler livraison'),
                          ),
                        ]),
                      ],
                    );
                  },
                );
              },
              child: Text('Oui'),
            ),
          ],
        );
      },
    );
  }
}
