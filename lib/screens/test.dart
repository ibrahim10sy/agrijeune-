// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:koumi_app/models/Magasin.dart';
// import 'package:koumi_app/models/Niveau1Pays.dart';
// import 'package:koumi_app/screens/Produit.dart';
// import 'package:shimmer/shimmer.dart';


// class MagasinScreen extends StatefulWidget {
//   const MagasinScreen({super.key});

//   @override
//   State<MagasinScreen> createState() => _MagasinScreenState();
// }
// class _MagasinScreenState extends State<MagasinScreen> with TickerProviderStateMixin {
//     // Déclarez une variable pour suivre si le chargement est terminé

//   TabController? _tabController;
//     late TextEditingController _searchController;

//   List<Magasin> magasinss = [];
//   Map<String, List<Magasin>> magasinsParRegion = {};

//   List<Magasin> magasinsParId = [];
//   List<Niveau1Pays> niveau1Pays = [];
//    String selectedRegionId = ''; // Ajoutez une variable pour stocker l'ID de la région sélectionnée
//    String idMagasin = "";
   

//   void fetchRegions() async {
//     try {
//       final response = await http.get(Uri.parse('http://10.0.2.2:9000/niveau1Pays/read'));
//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         setState(() {
//      niveau1Pays = data.map((item) => Niveau1Pays(
//         idNiveau1Pays: item['idNiveau1Pays'],
//         nomN1: item['nomN1'],
//       )).toList();
//         });
 
//         _tabController = TabController(length: niveau1Pays.length, vsync: this);
//         _tabController!.addListener(_handleTabChange);
//         // Fetch les magasins pour la première région
//         fetchMagasinsByRegion(niveau1Pays.isNotEmpty ? niveau1Pays[_tabController!.index].idNiveau1Pays! : '');
//       } else {
//         throw Exception('Failed to load regions');
//       }
//     } catch (e) {
//       print('Error fetching regions: $e');
//     }
//   }

//   void fetchMagasinsByRegion(String id) async {
//     try {
//       final response = await http.get(Uri.parse('http://10.0.2.2:9000/Magasin/getAllMagasinByPays/${id}'));
//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         setState(() {
//           magasinsParRegion[id] = data
//               .map((item) => Magasin(
//                     idMagasin: item['idMagasin'],
//                     nomMagasin: item['nomMagasin'],
//                     photo: item['photo'],
//                   ))
//               .toList();
//         });
       
//       } else {
//         throw Exception('Failed to load magasins for region $id');
//       }
//     } catch (e) {
//       print('Error fetching magasins for region $id: $e');
//     }
//   }

//  void _handleTabChange() {
//   if (_tabController != null && _tabController!.index >= 0 && _tabController!.index < niveau1Pays.length) {
//      selectedRegionId = niveau1Pays[_tabController!.index].idNiveau1Pays!;
//     fetchMagasinsByRegion(selectedRegionId);
//   }
// }

//   @override
//   void initState() {
//     super.initState();
//      _searchController = TextEditingController();
//      if (niveau1Pays.isNotEmpty) {
//       selectedRegionId = niveau1Pays[_tabController!.index].idNiveau1Pays!;
//     }
//     fetchRegions();
//     _buildShimmerEffect();
 
//   }

//      @override
//   void dispose() {
//     _tabController?.dispose();
//     _searchController.dispose(); // Disposez le TextEditingController lorsque vous n'en avez plus besoin
//     super.dispose();
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: DefaultTabController(
//         length: niveau1Pays.length,
//         child: Scaffold(
//           appBar: AppBar(
//             centerTitle:true,
//             title: Text('Tous les boutiques'),
//             bottom: TabBar(
//               isScrollable: niveau1Pays.length > 4,
//               labelColor: Colors.black,
//               controller: _tabController, // Ajoutez le contrôleur TabBar
//               tabs: niveau1Pays.map((region) => Tab(text: region.nomN1)).toList(),
//             ),
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 const SizedBox(height:10),
//                  SizedBox(
//                      height:40,
//                    child: Container(
//                      padding: EdgeInsets.only(left: 5),
//                      decoration: BoxDecoration(
//                        color: Color.fromARGB(255, 245, 212, 169),
//                        borderRadius: BorderRadius.circular(30),
                                    
//                      ),
//                      child: TextField(
//                       controller: _searchController,
//                        onChanged: (value) {
//                               setState(() {
//                                 // Le changement de texte déclenche la reconstruction du widget
//                               });
//                             },
//                        decoration: InputDecoration(
//                          hintText: 'Rechercher',
//                          contentPadding: EdgeInsets.all(10),
//                          border: InputBorder.none,
//                        ),
//                      ),
//                    ),
//                  ),
//                 const SizedBox(height:10),
//                 // const SizedBox(height:10),
//                 Flexible(
//                   child: GestureDetector(
//                     child: TabBarView(
//                       controller: _tabController, // Ajoutez le contrôleur TabBarView
//                       children: magasinss.map((magasin) {
//                         return buildGridView(magasin.idMagasin!);
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//  Widget buildGridView(String id) {
//     List<Magasin>? magasins = magasinsParRegion[id];

//   if (magasins == null) {
//     // Si les données ne sont pas encore chargées, affichez l'effet Shimmer
//     return _buildShimmerEffect();
//   } else {
//     // Filtrer les magasins en fonction du texte de recherche
//     List<Magasin> filteredMagasins = magasins.where((magasin) {
//       String nomMagasin = magasin.nomMagasin!.toLowerCase();
//       String searchText = _searchController.text.toLowerCase();
//       return nomMagasin.contains(searchText);
//     }).toList();

//     // Si aucun magasin n'est trouvé après le filtrage
//     if (filteredMagasins.isEmpty) {
//       // Vous pouvez afficher une image ou un texte ici
//       return Center(
//         child: Text(
//           'Aucun magasin trouvé',
//           style: TextStyle(fontSize: 16),
//         ),
//       );
//     }

//     // Sinon, afficher la GridView avec les magasins filtrés
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisSpacing: 10,
//         crossAxisSpacing: 10,
//       ),
//       itemCount: filteredMagasins.length,
//       itemBuilder: (context, index) {
//         Magasin magasin = filteredMagasins[index];
//         return Container(
//           child: GestureDetector(
//             onTap: () {
//                idMagasin = magasin.idMagasin!;
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => ProduitScreen(id: id)),
//               );
//             },
//             child: Card(
//               shadowColor: Colors.white,
//               child: Column(
//                 children: [
//                   Stack(
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         child: Image.asset('assets/images/rc.png'),
//                       ),
//                       Container(
//                         child: Image.network(
//                           filteredMagasins[index].photo ?? 'assets/images/magasin.png',
//                           width: double.infinity,
//                           height: null,
//                           fit: BoxFit.cover,
//                           errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
//                             return Image.asset(
//                               'assets/images/magasin.png',
//                               width: double.infinity,
//                               height: 150,
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   Text(
//                     filteredMagasins[index].nomMagasin ?? 'Pas de nom défini',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   TextButton(
//                     style: ButtonStyle(
//                       fixedSize: MaterialStateProperty.all(Size(20, 10)),
//                       shape: MaterialStateProperty.all(RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50.0),
//                       )),
//                     ),
//                     onPressed: null,
//                     child: Text(
//                       'Voir',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


//   Widget _buildShimmerEffect() {
//     return Shimmer.fromColors(
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
// }





/*

FutureBuilder<List<Map<String, dynamic>>>(
      future: ShoppingCart().getCart(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/notif.jpg'),
                SizedBox(height: 10),
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
          );
        }
      _cartItems = snapshot.data!;
        return ListView.builder(
          itemCount: _cartItems.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> item = _cartItems[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.to(DetailProduits());
                  },
                  child: ListTile(
                    leading: Image.asset("assets/images/mang.jpg"),
                    title: Text(item['nomProduit'] ?? ''),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => _decrementQuantity(index),
                            ),
                            Text('${item['quantiteProduit']}', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _incrementQuantity(index),
                            ),
                          ],
                        ),
                        Text('${item['prix'] ?? 0} FCFA', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },




















    ),
    
    
    
    
    
    
    
     static final ShoppingCart _instance = ShoppingCart._internal();

  factory ShoppingCart() {
    return _instance;
  }

  ShoppingCart._internal();


     List<Map<String, dynamic>> _cartItems = [];

     Future<void> loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartString = prefs.getString('cart') ?? '[]';
    List<Map<String, dynamic>> cart = List<Map<String, dynamic>>.from(jsonDecode(cartString));
      _cartItems = cart;
  }

  // Méthode pour ajouter un produit au panier
  Future<void> addToCart(Stock product) async {
    // Vérifier si le produit existe déjà dans le panier
    bool productExists = await _checkProductExistence(product);

    if (productExists) {
      // Afficher un message d'erreur si le produit existe déjà dans le panier
      Snack.error(titre: "Alerte",
        message:"Le produit existe déjà dans le panier"
      );
    } else {
      // Ajouter le produit au panier avec une quantité initiale de 1
      Map<String, dynamic> cartItem = {
        'idStock': product.idStock,
        'nomProduit': product.nomProduit,
        'prix': product.prix,
        'quantiteProduit': 1,
      };
      List<Map<String, dynamic>> cart = await getCart();
      cart.add(cartItem);
      await _saveCart(cart);
      // Afficher un message de succès ou autre action après l'ajout au panier
      Snack.success(titre: "Succès",
        message:"Produit ajouté au panier"
      );
    }
    loadCartItems();
    applyChanges();
  }

  // Méthode pour vérifier si le produit existe déjà dans le panier
  Future<bool> _checkProductExistence(Stock product) async {
    List<Map<String, dynamic>> cart = await getCart();
    bool exists = cart.any((item) => item['idStock'] == product.idStock);
    return exists;
  }

  // Méthode pour récupérer le panier depuis les SharedPreferences
  Future<List<Map<String, dynamic>>> getCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartString = prefs.getString('cart') ?? '[]';
    List<Map<String, dynamic>> cart = List<Map<String, dynamic>>.from(jsonDecode(cartString));
    return cart;
  }

  // Méthode pour sauvegarder le panier dans les SharedPreferences
  Future<void> _saveCart(List<Map<String, dynamic>> cart) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartString = jsonEncode(cart);
    prefs.setString('cart', cartString);
    loadCartItems();
    getCart();
  }

  applyChanges(){
    notifyListeners();
  }


    
    
    
    
    
    
    import 'package:flutter/material.dart';
import 'package:koumi_app/screens/Acceuil.dart';
import 'package:koumi_app/screens/Panier.dart';
import 'package:koumi_app/screens/Produit.dart';
import 'package:koumi_app/screens/Profil.dart';
import 'package:koumi_app/service/BottomNavigationService.dart';
import 'package:provider/provider.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

const d_color = Color.fromRGBO(254, 243, 231, 1);
const d_colorPage = Color.fromRGBO(255, 255, 255, 1);
const d_colorOr = Color.fromRGBO(254, 243, 231, 1);

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int activePageIndex = 0;
  Future<bool> _onBackPressed() async {
    // Essayez de revenir en arrière dans la pile de navigation actuelle
    final NavigatorState? navigator =
        _navigatorKeys[activePageIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      // S'il y a une page précédente, pop la page
      navigator.pop();
      return false; // Indiquez que l'événement de retour a été géré
    }
    return true; // Indiquez que l'application peut se fermer
  }

  late PageController pageController;


Widget buildPageView() {
  return PageView(
    controller: pageController,
    onPageChanged: (index) {
      _changeActivePageValue(index);
    },
    children: <Widget>[
   const Accueil(),
          ProduitScreen(),
           Panier(),
          const Profil(),
    ],
  );
}

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  List pages = <Widget>[
    const Accueil(),
    ProduitScreen(),
     Panier(),
    const Profil()
  ];

  void _changeActivePageValue(int index) {
    setState(() {
      activePageIndex = index;
    });
  }

  void _onItemTap(int index) {
    Provider.of<BottomNavigationService>(context, listen: false)
        .changeIndex(index);
    //  pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      Provider.of<BottomNavigationService>(context, listen: false)
          .changeIndex(0);
    });
    pageController = PageController(initialPage: activePageIndex);
  }
  // void _onBackPressed(bool isBackPressed) async {
  //   if (!isBackPressed) {
  //     // Essayez de revenir en arrière dans la pile de navigation actuelle
  //     final NavigatorState? navigator =
  //         _navigatorKeys[activePageIndex].currentState;
  //     if (navigator != null && navigator.canPop()) {
  //       // S'il y a une page précédente, pop la page
  //       navigator.pop();
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: d_colorPage,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            activePageIndex = index;
          });
        },
        children: [
          Accueil(),
          ProduitScreen(),
          Panier(),
          Profil(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activePageIndex,
        onTap: (index) {
          setState(() {
            activePageIndex = index;
            pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: "Produit",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Panier",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {

        return [
          const Accueil(),
          ProduitScreen(),
           Panier(),
          const Profil()
        ].elementAt(index);
      },
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: activePageIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name]!(context),
          );
        },
      ),
    );
  }
}

    
    
    
    
    
    
     */