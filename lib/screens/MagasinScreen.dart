
//  import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:koumi_app/Admin/CodePays.dart';
// import 'package:koumi_app/models/Acteur.dart';
// import 'package:koumi_app/models/Magasin.dart';
// import 'package:koumi_app/models/Niveau1Pays.dart';
// import 'package:koumi_app/models/Niveau2Pays.dart';
// import 'package:koumi_app/models/Niveau3Pays.dart';
// import 'package:koumi_app/models/ParametreGeneraux.dart';
// import 'package:koumi_app/providers/ActeurProvider.dart';
// import 'package:koumi_app/providers/ParametreGenerauxProvider.dart';
// import 'package:koumi_app/screens/AddAndUpdateProductScreen.dart';
// import 'package:koumi_app/screens/AddMagasinScreen.dart';
// import 'package:koumi_app/screens/MagasinActeur.dart';
// import 'package:koumi_app/screens/Produit.dart';
// import 'package:koumi_app/service/MagasinService.dart';
// import 'package:koumi_app/service/Niveau3Service.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';

// class MagasinScreen extends StatefulWidget {
//   const MagasinScreen({super.key});

//   @override
//   State<MagasinScreen> createState() => _MagasinScreenState();
// }

// const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
// 

// class _MagasinScreenState extends State<MagasinScreen>     with TickerProviderStateMixin{
//   late ParametreGeneraux para;
//   List<ParametreGeneraux> paraList = [];
//   late TextEditingController _searchController;
//     late Acteur acteur = Acteur();
//   TabController? _tabController;

//   List<Niveau1Pays> niveau1Pays = [];
//   List<Magasin> magasins = [];
//     String searchText = "";


 

//   String selectedRegionId =
//       ''; // Ajoutez une variable pour stocker l'ID de la région sélectionnée

//   bool isAdmin = false;


//    MagasinController  
//    controller = Get.put(MagasinController());

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
//                         .where((niveau1Pays) => niveau1Pays['statutN1'] == true)
//               .map((item) => Niveau1Pays(
//                   idNiveau1Pays: item['idNiveau1Pays'] as String,
//                   statutN1:item['statutN1'] as bool,
//                   nomN1: item['nomN1']))
//               .toList();
//         _tabController = TabController(length: niveau1Pays.length, vsync: this);
//         _tabController!.addListener(_handleTabChange);
//              selectedRegionId = niveau1Pays[_tabController!.index].idNiveau1Pays!;
//         controller.fetchMagasinByRegion(selectedRegionId);
//         });


//         // Fetch les magasins pour la première région
//       // controller.fetchMagasinByRegionAndActeur(acteur.idActeur!,niveau1Pays.first.idNiveau1Pays!);

//       } else {
//         throw Exception('Failed to load regions');
//       }
//     } catch (e) {
//       print('Error fetching regions: $e');
//      throw Exception('Error fetching regions: $e');

//     }
//   }

 

//   void _handleTabChange() async{
//   if (_tabController != null &&
//       _tabController!.index >= 0 &&
//       _tabController!.index < niveau1Pays.length) {
//     selectedRegionId = niveau1Pays[_tabController!.index].idNiveau1Pays!;
//        controller.clearMagasinListen();
//     await controller.fetchMagasinByRegion(selectedRegionId);
//   }
// }

//   bool isExist = false;

//   String? email = "";

//   void verify() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     email = prefs.getString('emailActeur');
//     if (email != null) {
//       // Si l'email de l'acteur est présent, exécute checkLoggedIn
//       acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;

//       setState(() {
//         isExist = true;
//           //  selectedRegionId = niveau1Pays.isNotEmpty ? niveau1Pays.first.idNiveau1Pays! : '';
//       if (niveau1Pays.isNotEmpty) {
//         _tabController = TabController(length: niveau1Pays.length, vsync: this);
//         _tabController!.addListener(_handleTabChange);
//       }
//       fetchRegions().then((value) => {
//          controller.fetchMagasinByRegion(niveau1Pays.isNotEmpty ? niveau1Pays.first.idNiveau1Pays! : '')
//         });
//       });
//     } else {
//       setState(() {
//         isExist = false;
//       });
//     }
//         // fetchRegions().then((value) => {
//         //  controller.fetchMagasinByRegionAndActeur(acteur.idActeur!, niveau1Pays.isNotEmpty ? niveau1Pays.first.idNiveau1Pays! : '')
//         // });
//     //     paraList = Provider.of<ParametreGenerauxProvider>(context, listen: false)
//     //     .parametreList!;
//     // para = paraList[0];
//   }

  
//   @override
//   void initState() {
//     super.initState();
//     verify();
//     _searchController = TextEditingController();
// controller.isLoadingn.listen((isLoading) {
//     if (!isLoading) {
//       // Les données sont chargées, mettez à jour l'interface utilisateur
//       setState(() {
        
//       });
//     }
//   });
//     }

//   @override
//   void dispose() {
//     _tabController?.dispose();
//     _searchController
//         .dispose(); // Disposez le TextEditingController lorsque vous n'en avez plus besoin
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//  const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
//     return Container(
//       child: DefaultTabController(
//         length: niveau1Pays.length,
//         child: Scaffold(
//           // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

//           backgroundColor: const Color.fromARGB(255, 250, 250, 250),
//           appBar: AppBar(
//                actions: !isExist ? null :  [
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
//                             "Mes magasin",
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           onTap: () async {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => MagasinActeurScreen()));
//                           },
//                         ),
//                       ),
                      
//                       PopupMenuItem<String>(
//                         child: ListTile(
//                           leading: const Icon(
//                             Icons.remove_red_eye,
//                             color: Colors.green,
//                           ),
//                           title: const Text(
//                             "Ajouter Produit",
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           onTap: () async {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => AddAndUpdateProductScreen(isEditable:false)));
//                           },
//                         ),
//                       ),
                      
//                     ],
//                   )
//                 ],
       
//             centerTitle: true,
//             toolbarHeight: 100,
//             leading: IconButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
//             title: Text('Tous les boutiques'),
//             bottom: TabBar(
//               isScrollable: niveau1Pays.length > 4,
//               labelColor: Colors.black,
//               controller: _tabController, // Ajoutez le contrôleur TabBar
//               tabs: niveau1Pays
//                   .map((region) => Tab(text: region.nomN1!))
//                   .toList(),
//             ),
//           ),
//           body: Container(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       decoration: BoxDecoration(
//                         color: Colors.blueGrey[50], // Couleur d'arrière-plan
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.search,
//                               color:
//                                   Colors.blueGrey[400]), // Couleur de l'icône
//                           SizedBox(
//                               width:
//                                   10), // Espacement entre l'icône et le champ de recherche
//                           Expanded(
//                             child: TextField(
//                               controller: _searchController,
//                               onChanged: (value) {
//                                 setState(() {});
//                               },
//                               decoration: InputDecoration(
//                                 hintText: 'Rechercher',
//                                 border: InputBorder.none,
//                                 hintStyle: TextStyle(
//                                     color: Colors.blueGrey[
//                                         400]), // Couleur du texte d'aide
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   // const SizedBox(height:10),
//                   Flexible(
//                     child: GestureDetector(
//                       child: TabBarView(
//                         controller:
//                             _tabController, // Ajoutez le contrôleur TabBarView
//                         children: niveau1Pays.map((region) {
//                           return buildGridView(
//                               region.idNiveau1Pays!);
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }





//    Widget buildGridView(String idNiveau1Pays) {
//   // final List<Magasin> magasins = Get.find<MagasinController>().magasins.value;
     
                 
     
//      // Si aucun magasin n'est trouvé après le filtrage
//          if (controller.isLoadingn.value && controller.magasinListen.isEmpty) {
//     return _buildShimmerEffect(); // Afficher l'effet Shimmer
//   }

      
//                                   if (controller.magasinListen.isEmpty) {
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
//                     'Aucun magasin trouvé' ,
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
//          }
          
                              
//                                 List<Magasin> filteredMagasins = controller.magasinListen.where((magasin) {
//       String nomMagasin = magasin.nomMagasin!.toString().toLowerCase();
//       searchText = _searchController.text.toLowerCase();
//       return nomMagasin.contains(searchText);
//     }).toList();

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

//                                 return Obx(
//         () => controller.isLoadingn.value == true
//                                   ? _buildShimmerEffect() :
                                   
//                                    Container(
//                                                             child: GridView.builder(
//                                                               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                                                                 crossAxisCount: 2,
//                                                                 mainAxisSpacing: 10,
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
//                                          boxShadow: [
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
//                                                         )
//                                 );
                                
//                   // } else 
//     // } 
//               // );
    
//   }

//   Widget _buildShimmerEffect() {
//     return Shimmer.fromColors(
//       period: Duration(seconds:2),
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

//    Widget _buildEtat(bool isState) {
//     return Container(
//       width: 15,
//       height: 15,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         color: isState && mounted ? Colors.green : Colors.red,
//       ),
//     );
//   }
// }