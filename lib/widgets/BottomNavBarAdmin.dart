import 'dart:async';

import 'package:flutter/material.dart';
import 'package:koumi/Admin/AcceuilAdmin.dart';
import 'package:koumi/Admin/ProfilA.dart';

import 'package:koumi/screens/MyProduct.dart';
import 'package:koumi/screens/Panier.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:provider/provider.dart';

class BottomNavBarAdmin extends StatefulWidget {
  const BottomNavBarAdmin({super.key});

  @override
  State<BottomNavBarAdmin> createState() => _BottomNavBarAdminState();
  static final GlobalKey<_BottomNavBarAdminState> navBarKey =
      GlobalKey<_BottomNavBarAdminState>();
}

// const d_color = Color.fromRGBO(254, 243, 231, 1);
// const d_colorPage = Color.fromRGBO(255, 255, 255, 1);
// const d_colorOr = Color.fromRGBO(254, 243, 231, 1);

class _BottomNavBarAdminState extends State<BottomNavBarAdmin> {
  int activePageIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    // GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  List pages = <Widget>[
    const AcceuilAdmin(),
    MyProductScreen(),
    // Panier(),
    ProfilA()
  ];

  void _changeActivePageValue(int index) {
    setState(() {
      activePageIndex = index;
    });
  }

  void resetIndex(int index) {
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
    Future.microtask(() {
      Provider.of<BottomNavigationService>(context, listen: false)
          .changeIndex(0);
    });
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
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
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
              children: [
                _buildOffstageNavigator(0),
                _buildOffstageNavigator(1),
                // _buildOffstageNavigator(2),
                _buildOffstageNavigator(2)
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 5.0,
          items: const [
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
          ],
          unselectedItemColor: Colors.black,
          selectedItemColor: Color(0xFFFF8A00),
          iconSize: 30,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(color: Colors.black),
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
