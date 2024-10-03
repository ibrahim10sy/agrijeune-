import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CartItem.dart';
import 'package:koumi/models/Commande.dart';
import 'package:koumi/models/CommandeAvecStocks.dart';
import 'package:koumi/models/Intrant.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CartProvider.dart';
import 'package:koumi/screens/PinLoginScreen.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/service/CommandeService.dart';
import 'package:koumi/widgets/CartListItem.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:koumi/widgets/SnackBar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginScreen.dart';

class Panier extends StatefulWidget {
  Panier({super.key});

  @override
  State<Panier> createState() => _PanierState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);
const d_colorPage = Color.fromRGBO(255, 255, 255, 1);

class _PanierState extends State<Panier> {
  // int itemCount = widget.cartItems?.length ?? 0;

  List<CartItem> cartItems = [];
  String currency = "FCFA";

  late Acteur acteur;
  bool isLoading = false;

  String? email = "";
  bool isExist = false;

  void verify() async {
     await Provider.of<ActeurProvider>(context, listen: false)
      .initializeActeurFromSharedPreferences();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      cartItems = Provider.of<CartProvider>(context, listen: false).cartItems;
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  static const String baseUrl = "$apiOnlineUrl/commande/add";

  _createCommande() async {
    // Get the current cart items
    List<Stock> stocks = [];
    List<Intrant> intrants = [];

    for (CartItem cartItem in cartItems) {
      if (cartItem.stock != null) {
        stocks.add(Stock(
          idStock: cartItem.stock!.idStock,
          quantiteStock: cartItem.quantiteStock.toDouble(),
        ));
      }

      if (cartItem.intrant != null) {
        intrants.add(Intrant(
          idIntrant: cartItem.intrant!.idIntrant,
          quantiteIntrant: cartItem.quantiteIntrant.toDouble(),
        ));
      }
    }

    // Prepare the Commande object
    Acteur acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;

    // Create CommandeAvecStocks object
    CommandeAvecStocks commandeAvecStocks = CommandeAvecStocks(
      acteur: acteur,
      stocks: stocks,
      intrants: intrants,
      quantitesDemandees: stocks.map((stock) => stock.quantiteStock!).toList(),
      quantitesIntrants:
          intrants.map((intrant) => intrant.quantiteIntrant!).toList(),
    );

    final url = '$apiOnlineUrl/commande/add';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(commandeAvecStocks.toJson()),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        // Commande ajoutée avec succès
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                   'Commande passée avec succès.',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.error_outline, color: Colors.white),
              ],
            ),
            backgroundColor: Colors.greenAccent, // Couleur de fond du SnackBar
            duration: Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior:
                SnackBarBehavior.floating, // Flottant pour un style moderne
            margin: EdgeInsets.all(10), // Espace autour du SnackBar
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande passée avec succès.'),
          ),
        );
        // Vérifier si la réponse est au format JSON avant de la décoder
        print('Commande ajoutée avec succès. ${response.body}');
        return await json.decode(json.encode(response.body));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Une erreur est survenue. Veuillez réessayer ultérieurement.',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.error_outline, color: Colors.white),
              ],
            ),
            backgroundColor: Colors.redAccent, // Couleur de fond du SnackBar
            duration: Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior:
                SnackBarBehavior.floating, // Flottant pour un style moderne
            margin: EdgeInsets.all(10), // Espace autour du SnackBar
          ),
        );
       
        print('Erreur lors de l\'ajout de la commande: ${response.body} et code ${response.statusCode}');
      }
    } catch (e) {
     
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Une erreur est survenue. Veuillez réessayer ultérieurement.'),
        ),
      );
      setState(() {
        isLoading = false;
      });
      print('Erreur lors de l\'envoi de la requête: $e');
    }
  }

  void _handleButtonPress() async {
    // Afficher l'indicateur de chargement
    setState(() {
      isLoading = true;
    });

    // await ajouterStocksACommandes().then((_) {
    await _createCommande().then((_) {
      // Cacher l'indicateur de chargement lorsque votre fonction est terminée
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    verify();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
         backgroundColor: const Color.fromARGB(255, 250, 250, 250),
         appBar: AppBar(
             backgroundColor: d_colorOr,
            centerTitle: true,
            toolbarHeight: 75,
          title: Text(
            "Panier",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: !isExist
              ? null
              : [
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return badges.Badge(
                        position:
                            badges.BadgePosition.bottomEnd(bottom: 1, end: 1),
                        badgeContent: Text(
                          cartProvider.cartItems.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        child: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.local_mall),
                          iconSize: 25,
                          onPressed: () {},
                        ),
                      );
                    },
                  ),
                ],
        ),
        // backgroundColor: Theme.of(context).colorScheme.primary,
        body: !isExist
            ? Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/lock.png",
                          width: 100, height: 100),
                      SizedBox(height: 20),
                      Text(
                        "Vous devez vous connecter pour faire des commades",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Future.microtask(() {
                          //   Provider.of<BottomNavigationService>(context,
                          //           listen: false)
                          //       .changeIndex(0);
                          // });
                          // Get.to(LoginScreen(),
                          //     duration: Duration(seconds: 1),
                          //     transition: Transition.leftToRight);
                           Future.microtask(() {
                            Provider.of<BottomNavigationService>(context,
                                    listen: false)
                                .changeIndex(0);
                          });
                          Get.to(
                            PinLoginScreen(),
                            duration: Duration(seconds: 1),
                            transition: Transition.leftToRight,
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          elevation: MaterialStateProperty.all<double>(0),
                          overlayColor: MaterialStateProperty.all<Color>(
                              Colors.grey.withOpacity(0.2)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: d_colorGreen),
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
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 80, top: 20),
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Consumer<CartProvider>(
                              builder: (context, cartProvider, child) {
                                final List<CartItem> cartItems =
                                    cartProvider.cartItems;

                                if (cartItems.isEmpty) {
                                  return SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Image.asset(
                                                'assets/images/notif.jpg'),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'Panier vide',
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
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: cartItems.length,
                                  itemBuilder: (context, index) {
                                    final cartItem = cartItems[index];
                                    return Dismissible(
                                      key: Key(cartItem.isStock == true
                                          ? cartItem.stock!.idStock!
                                          : cartItem.intrant!.idIntrant!),
                                      // Use a unique key for each item
                                      background: Container(
                                        color: Colors.red,
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        Provider.of<CartProvider>(context,
                                                listen: false)
                                            .removeCartItem(index);
                                      },
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: CartListItem(
                                          cartItem: cartItem,
                                          index: index,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Container()),
                                  cartProvider.cartItems.isEmpty
                                      ? SizedBox()
                                      : ElevatedButton(
                                          onPressed: () {
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .clearCart();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: const Text(
                                            "Vider panier",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                ],
                              ),
                              const Divider(
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Prix Total:',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    '${cartProvider.totalPrice.toInt()}F',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Prepare the JSON payload
                                    if (cartProvider.cartItems.isNotEmpty) {
                                      _handleButtonPress();
//                                  List<Stock> stocks = cartItems.map((cartItem) {
//   if (cartItem.stock != null) {
//     return Stock(
//       idStock: cartItem.stock!.idStock,
//       quantiteStock: cartItem.quantiteStock.toDouble(),
//     );
//   } else {
//     // Handle the case when stock is null
//     // For example, return a default Stock object or throw an exception
//     // Here, I'm returning a default Stock object with idStock as 0
//     return Stock(idStock: null, quantiteStock: 0);
//   }
// }).toList();

// // Map each CartItem to an Intrant object
// List<Intrant> intrants = cartItems.map((cartItem) {
//   if (cartItem.intrant != null) {
//     return Intrant(
//       idIntrant: cartItem.intrant!.idIntrant,
//       quantiteIntrant: cartItem.quantiteStock.toDouble(),
//     );
//   } else {
//     // Handle the case when intrant is null
//     // For example, return a default Intrant object or throw an exception
//     // Here, I'm returning a default Intrant object with idIntrant as 0
//     return Intrant(idIntrant: null, quantiteIntrant: 0);
//   }
// }).toList();

//     // Prepare the Commande object
//     // Create CommandeAvecStocks object

//    Commande commande = Commande();
//     CommandeAvecStocks commandeAvecStocks = CommandeAvecStocks(
//       commande: commande,
//       stocks: stocks,
//       intrants: intrants,
//       quantitesDemandees: stocks.map((stock) => stock.quantiteStock!).toList(),
//       quantitesIntrants: intrants.map((intrant) => intrant.quantiteIntrant!).toList(),
//     );
//        commandeAvecStocks.commande?.acteur = acteur;

//                                 ajouterStocksACommandes(
//                                   commandeAvecStocks
//                                   ).then((value) => {

//                                   });
                                    } else {
                                      Snack.error(
                                          titre: "Alerte",
                                          message:
                                              "Veuiller ajouté au moins 1 produit à votre panier");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    elevation: 10,
                                  ),
                                  child: const Text('Commander',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
