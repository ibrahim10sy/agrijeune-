import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CartProvider.dart';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:koumi/providers/ParametreGenerauxProvider.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/service/AlerteService.dart';
import 'package:koumi/service/AlertesOffLineService.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/service/CampagneService.dart';
import 'package:koumi/service/CategorieService.dart';
import 'package:koumi/service/CommandeService.dart';
import 'package:koumi/service/ConseilService.dart';
import 'package:koumi/service/ContinentService.dart';
import 'package:koumi/service/FiliereService.dart';
import 'package:koumi/service/FormeService.dart';
import 'package:koumi/service/IntrantService.dart';
import 'package:koumi/service/MagasinService.dart';
import 'package:koumi/service/MaterielService.dart';
import 'package:koumi/service/MessageService.dart';
import 'package:koumi/service/Niveau1Service.dart';
import 'package:koumi/service/Niveau2Service.dart';
import 'package:koumi/service/Niveau3Service.dart';
import 'package:koumi/service/ParametreFicheService.dart';
import 'package:koumi/service/ParametreGenerauxService.dart';
import 'package:koumi/service/PaysService.dart';
import 'package:koumi/service/SousRegionService.dart';
import 'package:koumi/service/SpeculationService.dart';
import 'package:koumi/service/StockService.dart';
import 'package:koumi/service/SuperficieService.dart';
import 'package:koumi/service/TypeActeurService.dart';
import 'package:koumi/service/TypeMaterielService.dart';
import 'package:koumi/service/TypeVoitureService.dart';
import 'package:koumi/service/UniteService.dart';
import 'package:koumi/service/VehiculeService.dart';
import 'package:koumi/service/ZoneProductionService.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:koumi/widgets/SplashScreen.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => CountryProvider()),
    ChangeNotifierProvider(create: (_) => DetectorPays()),
    ChangeNotifierProvider(create: (context) => MagasinService()),
    ChangeNotifierProvider(create: (context) => CommandeService()),
    ChangeNotifierProvider(create: (context) => CartProvider()),
    ChangeNotifierProvider(create: (context) => ActeurService()),
    ChangeNotifierProvider(create: (context) => TypeActeurService()),
    ChangeNotifierProvider(create: (context) => ActeurProvider()),
    ChangeNotifierProvider(create: (context) => StockService()),
    ChangeNotifierProvider(create: (context) => ParametreGenerauxService()),
    ChangeNotifierProvider(create: (context) => ParametreGenerauxProvider()),
    ChangeNotifierProvider(create: (context) => UniteService()),
    ChangeNotifierProvider(create: (context) => ParametreFicheService()),
    ChangeNotifierProvider(create: (context) => ZoneProductionService()),
    ChangeNotifierProvider(create: (context) => PaysService()),
    ChangeNotifierProvider(create: (context) => ConseilService()),
    ChangeNotifierProvider(create: (context) => TypeMaterielService()),
    ChangeNotifierProvider(create: (context) => SuperficieService()),
    ChangeNotifierProvider(create: (context) => AlertesService()),
    ChangeNotifierProvider(create: (context) => AlertesOffLineService()),
    ChangeNotifierProvider(create: (context) => IntrantService()),
    ChangeNotifierProvider(create: (context) => TypeVoitureService()),
    ChangeNotifierProvider(create: (context) => CampagneService()),
    ChangeNotifierProvider(create: (context) => TypeVoitureService()),
    ChangeNotifierProvider(create: (context) => TypeMaterielService()),
    ChangeNotifierProvider(create: (context) => TypeVoitureService()),
    ChangeNotifierProvider(create: (context) => MessageService()),
    ChangeNotifierProvider(create: (context) => MaterielService()),
    ChangeNotifierProvider(create: (context) => VehiculeService()),
    ChangeNotifierProvider(create: (context) => ContinentService()),
    ChangeNotifierProvider(create: (context) => CategorieService()),
    ChangeNotifierProvider(create: (context) => SpeculationService()),
    ChangeNotifierProvider(create: (context) => SousRegionService()),
    ChangeNotifierProvider(create: (context) => Niveau1Service()),
    ChangeNotifierProvider(create: (context) => Niveau2Service()),
    ChangeNotifierProvider(create: (context) => FiliereService()),
    ChangeNotifierProvider(create: (context) => Niveau3Service()),
    ChangeNotifierProvider(create: (context) => FormeService()),
    ChangeNotifierProvider(create: (context) => BottomNavigationService())
  ], child: MyApp()));
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay :true,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange.shade400),
        useMaterial3: true,
      ),
      routes: {
        '/BottomNavigationPage': (context) => BottomNavigationPage(),
      },
      home: const SplashScreen(),
    );
  }
}
