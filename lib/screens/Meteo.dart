// import 'package:flutter/material.dart';






// String _fcmToken = '';

//   @override
//   void initState() {
//     super.initState();

//     FirebaseMessaging.instance.getToken().then((token) {
//       setState(() {
//         _fcmToken = token;
//       });
//       // Enregistrer le token FCM côté serveur pour l'utilisateur courant
//     });

//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         _handleMessage(message);
//       }
//     });

//     FirebaseMessaging.onMessage.listen((message) {
//       _handleMessage(message);
//     });
//   }

//   void _handleMessage(RemoteMessage message) {
//     // Extraire et afficher les informations de la notification
//     String notificationTitle = message.notification?.title;
//     String notificationBody = message.notification?.body;

//     // ... (afficher la notification à l'utilisateur)
//   }








// class Meteo extends StatefulWidget {
//   const Meteo({super.key});

//   @override
//   State<Meteo> createState() => _MeteoState();
// }

// class _MeteoState extends State<Meteo> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: const Color.fromARGB(255, 250, 250, 250),
//         appBar: AppBar(
//             centerTitle: true,
//             toolbarHeight: 100,
//             leading: IconButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 icon: const Icon(Icons.arrow_back_ios)),
//             title: const Text(
//               "Meteo",
//             )));
//   }
// }


// Magasin





//  import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:koumi_app/models/Acteur.dart';
// import 'package:koumi_app/models/Magasin.dart';
// import 'package:koumi_app/models/Niveau1Pays.dart';
// import 'package:koumi_app/models/TypeActeur.dart';
// import 'package:koumi_app/providers/ActeurProvider.dart';
// import 'package:koumi_app/screens/MagasinActeur.dart';
// import 'package:koumi_app/screens/Produit.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';

// import '../service/MagasinService.dart';

// class MagasinScreen extends StatefulWidget {
//   const MagasinScreen({super.key});

//   @override
//   State<MagasinScreen> createState() => _MagasinScreenState();
// }

// class _MagasinScreenState extends State<MagasinScreen>     with TickerProviderStateMixin {
 
 
  
//   TabController? _tabController;
//   late TextEditingController _searchController;

//   // List<Magasin> magasin = [];
//   late Acteur acteur = Acteur();
//   late List<TypeActeur> typeActeurData = [];
//   late String type;
//   List<Niveau1Pays> niveau1Pays = [];
//   String selectedRegionId =
//       ''; // Ajoutez une variable pour stocker l'ID de la région sélectionnée

//   double scaleFactor = 1;
//   bool isVisible = true;

//   String localiteMagasin = "";
//   String contactMagasin = "";
//   File? photo;
//   String searchText = "";

//        MagasinController  
//    _controller = Get.put(MagasinController() );



//   Future<void> fetchRegions() async {
//     try {
//       final response = await http
//           // .get(Uri.parse('https://koumi.ml/api-koumi/niveau1Pays/read'));
//           .get(Uri.parse('http://10.0.2.2:9000/api-koumi/niveau1Pays/read'));
//       if (response.statusCode == 200) {
//         final String jsonString = utf8.decode(response.bodyBytes);
//         List<dynamic> data = json.decode(jsonString);
//         setState(() {
//           niveau1Pays = data
//               .where((niveau1Pays) => niveau1Pays['statutN1'] == true)
//               .map((item) => Niveau1Pays(
//                   idNiveau1Pays: item['idNiveau1Pays'] as String,
//                   statutN1: item['statutN1'] as bool,
//                   nomN1: item['nomN1']))
//               .toList();
//         });

//         _tabController = TabController(length: niveau1Pays.length, vsync: this);
//         _tabController!.addListener(_handleTabChange);

//          // Fetch les magasins pour la première région
      
//          _controller.fetchMagasinByRegion(niveau1Pays.first.idNiveau1Pays!);
      

//               // controller.fetchMagasinByRegion(niveau1Pays.isNotEmpty ? niveau1Pays[_tabController!.index].idNiveau1Pays! : '');
//     // Appel de _handleTabChange pour capturer automatiquement l'ID de la première région
//         // fetchMagasinByRegion(
//         //     niveau1Pays.isNotEmpty ? niveau1Pays.first.idNiveau1Pays! : '');
//       } else {
//         throw Exception('Failed to load regions');
//       }
//     } catch (e) {
//       print('Error fetching regions: $e');
//     }
//   }
      
  

 

//   void _handleTabChange() async {
//     if (_tabController != null &&
//         _tabController!.index >= 0 &&
//         _tabController!.index < niveau1Pays.length) {
         
//       selectedRegionId = niveau1Pays[_tabController!.index].idNiveau1Pays!;
//      await  _controller.fetchMagasinByRegion(selectedRegionId);
//      setState(() {
//        _controller.fetchMagasinByRegion(selectedRegionId);
//      });
//     }
//   }

//   bool isExist = false;
//   String? email = "";

//   void verify() async {

//      fetchRegions();

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     email = prefs.getString('emailActeur');
//     if (email != null) {
//       // Si l'email de l'acteur est présent, exécute checkLoggedIn
//       acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
//       // typeActeurData = acteur.typeActeur!;
//       // type = typeActeurData.map((data) => data.libelle).join(', ');
//       setState(() {
//         isExist = true;
//       selectedRegionId = niveau1Pays.isNotEmpty ? niveau1Pays.first.idNiveau1Pays! : '';
//         if (niveau1Pays.isNotEmpty) {
//       // fetchMagasinsByRegion(selectedRegionId);
//        _tabController = TabController(length: niveau1Pays.length, vsync: this);
//         _tabController!.addListener(_handleTabChange);
//         }

//        _controller.fetchMagasinByRegion(selectedRegionId);
    
//       });
//     } else {
//       setState(() {
//         isExist = false;
//       });
//     }
      
  

//   }


//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController();
//     // _buildShimmerEffect();
//     _controller.isLoadingn.listen((isLoading) {
//     if (!isLoading) {
//       // Les données sont chargées, mettez à jour l'interface utilisateur
//       setState(() {});
//     }
//   });
//   // Charger les régions
//   // fetchRegions();
//     verify();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
//         return
//          Container(
//           child: DefaultTabController(
//             length: niveau1Pays.length,
//             child: Scaffold(
//               backgroundColor: const Color.fromARGB(255, 250, 250, 250),
//               appBar: AppBar(
//                 centerTitle: true,
//                 toolbarHeight: 100,
//                 leading: IconButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
//                 title: Text('Tous les magasins'),
//                 bottom: TabBar(
//                   isScrollable: niveau1Pays.length > 4,
//                   labelColor: Colors.black,
//                   controller: _tabController, // Ajoutez le contrôleur TabBar
//                   tabs: niveau1Pays
//                       .map((region) => Tab(text: region.nomN1!))
//                       .toList(),
//                 ),
//                  actions: !isExist ? null :  [
//                  PopupMenuButton<String>(
//                     padding: EdgeInsets.zero,
//                     itemBuilder: (context) => <PopupMenuEntry<String>>[
                      
//                       PopupMenuItem<String>(
//                         child: ListTile(
//                           leading: const Icon(
//                             Icons.remove_red_eye,
//                             color: Colors.green,
//                           ),
//                           title: const Text(
//                             "Mes magasins",
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           onTap: () async {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     // builder: (context) => AaaaScreen()));
//                                     // builder: (context) => AaaaScreen()));
//                                     builder: (context) => MagasinActeurScreen()));
//                           },
//                         ),
//                       ),
                      
//                     ],
//                   )
//                 ],
//               ),
//               body: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey[50], // Couleur d'arrière-plan
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.search,
//                                 color: Colors.blueGrey[400]), // Couleur de l'icône
//                             SizedBox(
//                                 width:
//                                     10), // Espacement entre l'icône et le champ de recherche
//                             Expanded(
//                               child: TextField(
//                                 controller: _searchController,
//                                 onChanged: (value) {
//                                   setState(() {});
//                                 },
//                                 decoration: InputDecoration(
//                                   hintText: 'Rechercher',
//                                   border: InputBorder.none,
//                                   hintStyle: TextStyle(
//                                       color: Colors.blueGrey[
//                                           400]), // Couleur du texte d'aide
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     // const SizedBox(height:10),
//                     Flexible(
//                       child: GestureDetector(
//                         child: 
//  TabBarView(
//    controller:
//        _tabController, // Ajoutez le contrôleur TabBarView
//    children: niveau1Pays.map((region) {
//      return buildGridView(region.idNiveau1Pays!);
//    }).toList(),
//  ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
               
//        );
      
//   }

//      Widget buildGridView(String id) {

//           final controller = Get.find<MagasinController>();
//         debugPrint("taille : ${controller.magasinListen.length}");
     
//      // Si aucun magasin n'est trouvé après le filtrage
//         List<Magasin> filteredMagasins = controller.magasinListen.where((magasin) {
//       String nomMagasin = magasin.nomMagasin!.toString().toLowerCase();
//       searchText = _searchController.text.toLowerCase();
//       return nomMagasin.contains(searchText);
//     }).toList();

//     //   if (filteredMagasins.isEmpty) {
//     //   // Vous pouvez afficher une image ou un texte ici
//     //   return 
//     //   SingleChildScrollView(
//     //       child: Padding(
//     //         padding: EdgeInsets.all(10),
//     //         child: Center(
//     //           child: Column(
//     //             children: [
//     //               Image.asset('assets/images/notif.jpg'),
//     //               SizedBox(
//     //                 height: 10,
//     //               ),
//     //               Text(
//     //                 'Aucun magasin trouvé ' ,
//     //                 style: TextStyle(
//     //                   color: Colors.black,
//     //                   fontSize: 17,
//     //                   overflow: TextOverflow.ellipsis,
//     //                 ),
//     //               ),
//     //             ],
//     //           ),
//     //         ),
//     //       ),
//     //     );

//     // }
//                                         if (controller.magasinListen.isEmpty) {
//       // Vous pouvez afficher une image ou un texte ici
//       return 
//       SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(10),
//             child: Center(
//               child: Column(
//                 children: [
//                   Image.asset('assets/images/notif.jpg'),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     'Aucun magasin trouvé ' ,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 17,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );

//     }
//       if (filteredMagasins.isEmpty &&  _searchController.text.isNotEmpty) {
//       // Vous pouvez afficher une image ou un texte ici
//       return 
//       SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(10),
//             child: Center(
//               child: Column(
//                 children: [
//                   Image.asset('assets/images/notif.jpg'),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     'Aucun magasin trouvé avec le nom ' + _searchController.text.toUpperCase(),
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 17,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );

//     }
//           debugPrint("m f : ${filteredMagasins.length}");
//                                 return Obx(
//         () => _controller.isLoadingn.value
//                                   ? _buildShimmerEffect() :
 
//                                    Container(
//                                                             child: GridView.builder(
//                                                               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                                                                 crossAxisCount: 2,
//                                                                 mainAxisSpacing: 2,
//                                                                 crossAxisSpacing: 10,
//                                                               ),
//                                                               itemCount: filteredMagasins.length,
//                                                               itemBuilder: (context, index) {
//                                                                 Magasin magasinn = filteredMagasins[index];
//                                                                 Magasin currentMagasin = magasinn;
//                                                                 String typeActeurList = '';
                                                  
//                                                                 // Vérifiez d'abord si l'acteur est disponible dans le magasin
//                                                                 if (currentMagasin.acteur != null &&
//                                                     currentMagasin.acteur!.typeActeur != null) {
//                                                   // Parcourez la liste des types d'acteurs et extrayez les libellés
//                                                   typeActeurList = currentMagasin.acteur!.typeActeur!
//                                                       .map((type) => type
//                                                           .libelle) // Utilisez la propriété libelle pour récupérer le libellé
//                                                       .join(', '); // Joignez tous les libellés avec une virgule
//                                                                 }
//                                                                 // ici on a recuperer les details du  magasin
//                                                                 // String magasin = filteredMagasins[index].photo!;
//                                                                 return GestureDetector(
//                                                          onTap: () {
//                                                         String id = magasinn.idMagasin!;
//                                                         String nom = magasinn.nomMagasin!;
                                                    
//                                                         Navigator.push(
//                                                           context,
//                                                           PageRouteBuilder(
//                                                             pageBuilder: (context, animation, secondaryAnimation) =>
//                                                                 ProduitScreen(
//                                                               id: id,
//                                                               nom: nom,
//                                                             ),
//                                                             transitionsBuilder:
//                                                                 (context, animation, secondaryAnimation, child) {
//                                                               var begin =
//                                   Offset(0.0, 1.0); // Commencer en bas de l'écran
//                                                               var end = Offset.zero; // Finir en haut de l'écran
//                                                               var curve = Curves.ease;
//                                                               var tween = Tween(begin: begin, end: end)
//                                   .chain(CurveTween(curve: curve));
//                                                               return SlideTransition(
//                                                                 position: animation.drive(tween),
//                                                                 child: child,
//                                                               );
//                                                             },
//                                                             transitionDuration: const Duration(
//                                                                 milliseconds: 1900), // Durée de la transition
//                                                           ),
//                                                         );
//                                                       },
//                                                   child: Column(
//                                                     children: [
//                                                              Container(
//                                                               // height: MediaQuery.sizeOf(context).height,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(15),
//                                         boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.grey
//                                                       .withOpacity(0.2),
//                                                   offset: const Offset(0, 2),
//                                                   blurRadius: 5,
//                                                   spreadRadius: 2,
//                                                 ),
//                                               ],
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(4.0),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.stretch,
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.all(8.0),
//                                               child: ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8.0),
//                                                 child: SizedBox(
//                                                   height: 80,
//                                                   child: magasinn.photo == null
//                                                       ? Image.asset(
//                                                           "assets/images/magasin.png",
//                                                           fit: BoxFit.cover,
//                                                         )
//                                                       : Image.network(
//                                                           "https://koumi.ml/api-koumi/Magasin/${magasinn.idMagasin}/image",
//                                                           fit: BoxFit.cover,
//                                                           errorBuilder:
//                                                               (BuildContext
//                                                                       context,
//                                                                   Object
//                                                                       exception,
//                                                                   StackTrace?
//                                                                       stackTrace) {
//                                                             return Image.asset(
//                                                               'assets/images/magasin.png',
//                                                               fit: BoxFit.cover,
//                                                             );
//                                                           },
//                                                         ),
                                                        
//                                                 ),
//                                               ),
//                                             ),
//                                             // _buildItem(
//                                             //     "Nom :", magasin.nomMagasin!.toUpperCase()),
//                                          Column(
//                                                       children: [
//                                                            Padding(
//                                                padding: const EdgeInsets.all(4.0),
//                                                child: Row(
//                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                  children: [
//                                                    Flexible(
//                                                      child: Text(
//                                                        "Nom",
//                                                        style: const TextStyle(
                                                       
//                                                            color: Colors.black87,
//                                                            fontWeight: FontWeight.w800,
//                                                            fontStyle: FontStyle.italic,
//                                                            overflow: TextOverflow.ellipsis,
//                                                            fontSize: 16),
//                                                      ),
//                                                    ),
//                                                    Flexible(
//                                                      child: Text(
//                                                        magasinn.nomMagasin!.toUpperCase(),
//                                                        style: const TextStyle(
//                                                            color: Colors.black,
//                                                            fontWeight: FontWeight.w800,
//                                                            overflow: TextOverflow.ellipsis,
//                                                            fontSize: 16),
//                                                      ),
//                                                    )
//                                                  ],
//                                                ),
//                                              ),
//                                             // _buildItem(
//                                             //     "Acteur ", type),
                                       
//                                                            ],
//                                          ),
                                            
//                                           ],
//                                         ),
//                                       ),
//                                     ),
                                                  
                                    
                                                     
//                                                     ],
//                                                   ),
//                                                                 );
//                                                               },
//                                                             ),
//                                                         ),
//                                 );
//                   // } else 
//     // } 
//               // );
    
//   }


 

//   Widget _buildShimmerEffect() {
//     return Shimmer.fromColors(
//       period: Duration(seconds: 2),
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 10,
//           crossAxisSpacing: 10,
//         ),
//         itemCount: 6, // Nombre de cellules de la grille
//         itemBuilder: (context, index) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           );
//         },
//       ),
//     );
//   }

//  Widget _buildItem(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Flexible(
//             child: Text(
//               title,
//               style: const TextStyle(
              
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w800,
//                   fontStyle: FontStyle.italic,
//                   overflow: TextOverflow.ellipsis,
//                   fontSize: 16),
//             ),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               style: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w800,
//                   overflow: TextOverflow.ellipsis,
//                   fontSize: 16),
//             ),
//           )
//         ],
//       ),
//     );
//   }

  

// }