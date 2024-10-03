import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/Acceuil.dart';
import 'package:koumi/screens/ListeIntrantByActeur.dart';
import 'package:koumi/screens/ListeMaterielByActeur.dart';
import 'package:koumi/screens/MyProduct.dart';
import 'package:koumi/screens/Panier.dart';
import 'package:koumi/screens/Profil.dart';
import 'package:koumi/screens/VehiculesActeur.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connection_verify.dart';

class BottomNavigationPage extends StatefulWidget {
  // String? iso;
  BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

const d_color = Color.fromRGBO(254, 243, 231, 1);
const d_colorPage = Color.fromRGBO(255, 255, 255, 1);
const d_colorOr = Color.fromRGBO(254, 243, 231, 1);

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int activePageIndex = 0;
  Acteur? acteur = Acteur();
  List<TypeActeur>? typeActeurData = [];
  late String type;
  bool isExist = false;
  String? email = "";

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

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  List<Widget> pages = [];
  List<BottomNavigationBarItem> bottomNavigationBarItems = [];

  void _setupNavigationItems() {
    print('isExist set: $isExist');
    if (isExist) {
      if (typeActeurData!
              .map((e) => e.libelle!.toLowerCase())
              .contains("commercant") ||
          typeActeurData!
              .map((e) => e.libelle!.toLowerCase())
              .contains("commerçant") ||
          typeActeurData!
              .map((e) => e.libelle!.toLowerCase())
              .contains("transformateur") ||
          typeActeurData!
              .map((e) => e.libelle!.toLowerCase())
              .contains("producteur") ||
          typeActeurData!
              .map((e) => e.libelle!.toLowerCase())
              .contains("partenaires de développement") ||
          typeActeurData!
              .map((e) => e.libelle!.toLowerCase())
              .contains("partenaire de developpement")) {
        pages = [
          const Accueil(),
          MyProductScreen(),
          // Panier(),
          const Profil(),
        ];
         
        bottomNavigationBarItems = [
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.list_alt_sharp),
            label: "Mes Produits",
          ),
          // BottomNavigationBarItem(
          //   backgroundColor: Color.fromARGB(255, 250, 250, 250),
          //   icon: Icon(Icons.shopping_cart),
          //   label: "Panier",
          // ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.person_pin),
            label: "Profil",
          )
        ];
      } else if (typeActeurData!
          .map((e) => e.libelle!.toLowerCase())
          .contains("fournisseur")) {
        pages = [
          const Accueil(),
          ListeIntrantByActeur(),
          // Panier(),
          const Profil(),
        ];
        bottomNavigationBarItems = [
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.list_alt_sharp),
            label: "Mes Intrants",
          ),
          // BottomNavigationBarItem(
          //   backgroundColor: Color.fromARGB(255, 250, 250, 250),
          //   icon: Icon(Icons.shopping_cart),
          //   label: "Panier",
          // ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.person_pin),
            label: "Profil",
          ),
        ];
      } else if (typeActeurData!
          .map((e) => e.libelle!.toLowerCase())
          .contains("prestataire")) {
        pages = [
          const Accueil(),
          ListeMaterielByActeur(),
          // Panier(),
          const Profil(),
        ];
        bottomNavigationBarItems = [
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.list_alt_sharp),
            label: "Mes matériels",
          ),
          // BottomNavigationBarItem(
          //   backgroundColor: Color.fromARGB(255, 250, 250, 250),
          //   icon: Icon(Icons.shopping_cart),
          //   label: "Panier",
          // ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.person_pin),
            label: "Profil",
          ),
        ];
      } else if (typeActeurData!
          .map((e) => e.libelle!.toLowerCase())
          .contains("transporteur")) {
        pages = [
          const Accueil(),
          VehiculeActeur(),
          // Panier(),
          const Profil(),
        ];
        bottomNavigationBarItems = [
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.car_crash),
            label: "Mes véhicules",
          ),
          // BottomNavigationBarItem(
          //   backgroundColor: Color.fromARGB(255, 250, 250, 250),
          //   icon: Icon(Icons.shopping_cart),
          //   label: "Panier",
          // ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.person_pin),
            label: "Profil",
          ),
        ];
      } else {
        pages = [
          const Accueil(),
          MyProductScreen(),
          // Panier(),
          const Profil(),
        ];

        bottomNavigationBarItems = [
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.list_alt_sharp),
            label: "Mes Produits",
          ),
          // BottomNavigationBarItem(
          //   backgroundColor: Color.fromARGB(255, 250, 250, 250),
          //   icon: Icon(Icons.shopping_cart),
          //   label: "Panier",
          // ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            icon: Icon(Icons.person_pin),
            label: "Profil",
          ),
        ];
      }
    } else {
      pages = [
        const Accueil(),
        // MyProductScreen(),
        // Panier(),
        const Profil(),
      ];

      bottomNavigationBarItems = [
        BottomNavigationBarItem(
          backgroundColor: Color.fromARGB(255, 250, 250, 250),
          icon: Icon(Icons.home_filled),
          label: "Accueil",
        ),
        // BottomNavigationBarItem(
        //   backgroundColor: Color.fromARGB(255, 250, 250, 250),
        //   icon: Icon(Icons.shopping_cart),
        //   label: "Panier",
        // ),
        BottomNavigationBarItem(
          backgroundColor: Color.fromARGB(255, 250, 250, 250),
          icon: Icon(Icons.person_pin),
          label: "Profil",
        ),
      ];
    }
  }

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur!.typeActeur!;
      type = typeActeurData!.map((data) => data.libelle).join(', ');
      print("Type Acteur Data: $typeActeurData");
      setState(() {
        isExist = true;
        _setupNavigationItems(); // Appeler ici après la mise à jour de typeActeurData
      });
    } else {
      setState(() {
        isExist = false;
        _setupNavigationItems(); // Appeler ici aussi
      });
    }
  }

  void _changeActivePageValue(int index) {
    setState(() {
      activePageIndex = index;
    });
  }

  void _onItemTap(int index) {
    Provider.of<BottomNavigationService>(context, listen: false)
        .changeIndex(index);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   
    verify();
    _setupNavigationItems();
    Get.put(ConnectionVerify(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[activePageIndex].currentState!.maybePop();
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        backgroundColor: d_colorPage,
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: Consumer<BottomNavigationService>(
          builder: (context, bottomService, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _changeActivePageValue(bottomService.pageIndex);
            });
            return Stack(
              children: List.generate(pages.length, (index) {
                return _buildOffstageNavigator(index);
              }),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 5.0,
          items: bottomNavigationBarItems,
          unselectedItemColor: Colors.black,
          selectedItemColor: Color(0xFFFF8A00),
          iconSize: 30,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(
            color: Colors.black,
          ),
          currentIndex: activePageIndex,
          onTap: _onItemTap,
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) => pages[index],
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
