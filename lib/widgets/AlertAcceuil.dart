import 'package:flutter/material.dart';
import 'package:koumi/Admin/DetailAlerte.dart';
import 'package:koumi/models/Alertes.dart';
import 'package:koumi/service/AlerteService.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class AlertAcceuil extends StatefulWidget {
  const AlertAcceuil({super.key});

  @override
  State<AlertAcceuil> createState() => _AlertAcceuilState();
}

class _AlertAcceuilState extends State<AlertAcceuil> {
  List<Alertes> alerteList = [];
  List<Alertes> alerteTrue = [];
  late Alertes alerte = Alertes();

  late Future<List<Alertes>> _liste;
  List<Alertes> alertList = [];

  Future<List<Alertes>> getAlertListe() async {
    return await AlertesService().fetchAlertes();
  }

  @override
  void initState() {
    _liste = getAlertListe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertesService>(builder: (context, alerteService, child) {
      return FutureBuilder(
          future: _liste,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
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
                  child: Center(
                    child: ListTile(
                      leading: Lottie.asset(
                        "assets/images/alerte.json",
                        fit: BoxFit.cover,
                      ),
                      title: Text("En cours de chargement ...",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
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
                  child: Center(
                    child: Row(
                      children: [
                        // ListTile(
                        //   leading: CircleAvatar(
                        //       radius: 40,
                        //       backgroundColor: Colors.transparent,
                        //       backgroundImage: AssetImage(
                        //         "assets/images/alt.png",
                        //       )
                        //       ),

                        //   title: Text("Aucun alerte",
                        //       style: const TextStyle(
                        //         color: Colors.black,
                        //         fontSize: 18,
                        //         overflow: TextOverflow.ellipsis,
                        //       )),
                        // ),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Lottie.asset(
                              "assets/images/alerte.json",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(width: 40),
                        Center(
                          child: Text("Aucun alerte",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              alerteList = snapshot.data!;

              alerteTrue = alerteList
                  .where((element) => element.statutAlerte == true)
                  .toList();
              if (alerteTrue.isNotEmpty) {
                alerte = alerteTrue[0];
              } else {
                alerte == null;
              }

              return alerte == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 12),
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
                        child: Center(
                          child: ListTile(
                            leading: Lottie.asset(
                              "assets/images/alerte.json",
                              fit: BoxFit.cover,
                            ),
                            title: Text("Aucun alerte",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            trailing: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.transparent,
                                backgroundImage: AssetImage(
                                  "assets/images/alt.png",
                                )),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DetailAlerte(alertes: alerte)));
                        },
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
                          child: Center(
                            child: ListTile(
                              leading: alerte.photoAlerte != null &&
                                      !alerte.photoAlerte!.isEmpty
                                  ? CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: NetworkImage(
                                        'https://koumi.ml/api-koumi/alertes/${alerte.idAlerte}/image',
                                      ),
                                    )
                                  : Lottie.asset(
                                      "assets/images/alerte.json",
                                      fit: BoxFit.cover,
                                    ),
                              title: Text(
                                  alerte.titreAlerte != null 
                                      ? alerte.titreAlerte!
                                      : "Aucun alerte",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                              subtitle: Text(
                                 alerte.descriptionAlerte != null ?
                                alerte.descriptionAlerte! : '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                              trailing: Lottie.asset(
                                "assets/images/alerte.json",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
            }
          });
    });
  }
}
