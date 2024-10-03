import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/Admin/EditProfil.dart';
import 'package:koumi/Admin/Parametre.dart';
import 'package:koumi/Admin/ParametreGenerauxPage.dart';
import 'package:koumi/Admin/TypeActeurPage.dart';
import 'package:koumi/Admin/Zone.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/models/ZoneProduction.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/ResetPassword.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/service/ZoneProductionService.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:provider/provider.dart';

class ProfilA extends StatefulWidget {
  const ProfilA({super.key});

  @override
  State<ProfilA> createState() => _ProfilAState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);
const d_colorPage = Color.fromRGBO(255, 255, 255, 1);

class _ProfilAState extends State<ProfilA> {
  late Acteur acteur;
  late List<ZoneProduction> zoneList = [];

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    print("profil init : ${acteur.toString()}");
    super.initState();
  }

  Future<void> _refreshProfile() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
          backgroundColor: d_colorOr,
          centerTitle: true,
          toolbarHeight: 75,
          title: const Text(
            "Mon Profil",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Column(
                  children: [
                    Consumer<ActeurProvider>(
                      builder: (context, acteurProvider, child) {
                        final ac = acteurProvider.acteur;
                        // debugPrint("appBar ${ac.toString()}");
                        if (ac == null) {
                          return const CircularProgressIndicator();
                        }

                        List<TypeActeur> typeActeurData = ac.typeActeur!;
                        String type = typeActeurData
                            .map((data) => data.libelle)
                            .join(', ');
                        return Column(
                          children: [
                            ListTile(
                                leading: ClipOval(
                                    child: FadeInImage(
                                  image: NetworkImage(
                                   "$apiOnlineUrl/acteur/${acteur!.idActeur}/image?timestamp=${DateTime.now().millisecondsSinceEpoch}",
                                  ),
                                  placeholder:
                                      AssetImage('assets/images/profil.jpg'),
                                  placeholderFit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/profil.jpg',
                                      fit: BoxFit.cover,
                                      width: 50,
                                      height: 50,
                                    );
                                  },
                                )),
                                title: Text(
                                  ac.nomActeur!.toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(
                                  type,
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
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
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ac.emailActeur != null
                                        ? _buildProfile(
                                            'Email', ac.emailActeur!)
                                        : Container(),
                                    _buildProfile(
                                        'Téléphone', ac.telephoneActeur!),
                                    _buildProfile(
                                        'WhatsApp', ac.whatsAppActeur ?? ''),
                                    _buildProfile('Adresse', ac.adresseActeur!),
                                    _buildProfile(
                                        'Localité', ac.localiteActeur!),
                                    const Divider(
                                      color: Color.fromARGB(255, 235, 233, 233),
                                      height: 1,
                                      thickness: 1,
                                      indent: 0,
                                      endIndent: 0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          // Ouvrir la page de modification de profil
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProfil()),
                                          );

                                          // Après le retour, rafraîchir les données du profil
                                          await _refreshProfile();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Modifier le profil",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right_sharp,
                                              size: 20,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 15),
                        child: Column(
                          children: [
                            Row(children: [
                              const Icon(Icons.align_horizontal_left_outlined,
                                  color: Colors.black87, size: 25),
                              const SizedBox(
                                width: 15,
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ResetPassword(
                                                  acteurs: acteur,
                                                )));
                                  },
                                  child: Text(
                                    "Changer son mot de passe",
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.black87),
                                  ))
                            ]),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Image.asset("assets/images/settings.png",
                            width: 50, height: 50),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 15),
                        child: Row(children: [
                          const Icon(Icons.align_horizontal_left_outlined,
                              color: Colors.black87, size: 25),
                          const SizedBox(
                            width: 15,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TypeActeurPage()));
                              },
                              child: const Text(
                                "Ajouter un type d'acteur",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black87),
                              ))
                        ]),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Image.asset("assets/images/type.png",
                            width: 50, height: 50),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 15),
                        child: Row(children: [
                          const Icon(Icons.align_horizontal_left_outlined,
                              color: Colors.black87, size: 25),
                          const SizedBox(
                            width: 15,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ParametreGenerauxPage()));
                              },
                              child: const Text(
                                "Parametre Généraux",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black87),
                              ))
                        ]),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Image.asset("assets/images/settings.png",
                            width: 50, height: 50),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 15),
                        child: Row(children: [
                          const Icon(Icons.align_horizontal_left_outlined,
                              color: Colors.black87, size: 25),
                          const SizedBox(
                            width: 15,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Parametre()));
                              },
                              child: const Text(
                                "Parametre système",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black87),
                              ))
                        ]),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Image.asset("assets/images/settings.png",
                            width: 50, height: 50),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 15),
                        child: Column(
                          children: [
                            Row(children: [
                              const Icon(Icons.align_horizontal_left_outlined,
                                  color: Colors.black87, size: 25),
                              const SizedBox(
                                width: 15,
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Zone()));
                                  },
                                  child: Text(
                                    "Mes zones de production",
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.black87),
                                  ))
                            ]),
                            Consumer<ZoneProductionService>(
                                builder: (context, zoneService, child) {
                              return FutureBuilder(
                                  future: zoneService
                                      .fetchZoneByActeur(acteur.idActeur!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.orange,
                                        ),
                                      );
                                    }

                                    if (!snapshot.hasData) {
                                      return const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                            child: Text("Aucun zone trouvé")),
                                      );
                                    } else {
                                      zoneList = snapshot.data!;
                                      return Wrap(
                                          children: zoneList
                                              .map(
                                                (e) => Text(
                                                    "${e.nomZoneProduction} ,",
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                              )
                                              .toList());
                                    }
                                  });
                            })
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Image.asset("assets/images/zone.png",
                            width: 50, height: 50),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: ElevatedButton.icon(
                    onPressed: () async {
                      final acteurProvider =
                          Provider.of<ActeurProvider>(context, listen: false);

                      // Déconnexion avec le provider
                      await acteurProvider.logout();

                      Get.offAll(BottomNavigationPage(),
                          // duration: Duration(
                          //     seconds:
                          //         1), //duration of transitions, default 1 sec
                          transition: Transition.leftToRight);

                      Provider.of<BottomNavigationService>(context,
                              listen: false)
                          .changeIndex(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 10, // Orange color code
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(290, 45),
                    ),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: d_colorOr,
                    ),
                    label: Text(
                      "Déconnexion",
                      style: TextStyle(
                        fontSize: 20,
                        color: d_colorOr,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
              )
            ],
          ),
        ));
  }

  Widget _buildProfile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                overflow: TextOverflow.ellipsis,
                fontSize: 18),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
                fontSize: 16),
          )
        ],
      ),
    );
  }
}
