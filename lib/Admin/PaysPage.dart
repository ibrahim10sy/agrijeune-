import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:koumi/Admin/Addpays.dart';
import 'package:koumi/Admin/Niveau1List.dart';
import 'package:koumi/Admin/UpdatesPays.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:koumi/models/ParametreGeneraux.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/service/Niveau1Service.dart';
import 'package:koumi/service/PaysService.dart';
import 'package:provider/provider.dart';

class PaysPage extends StatefulWidget {
  // final SousRegion sousRegions;
  const PaysPage({super.key});

  @override
  State<PaysPage> createState() => _PaysPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _PaysPageState extends State<PaysPage> {
  List<Pays> paysList = [];
  late Future<List<Pays>> _liste;
  late ParametreGeneraux para;
  List<Niveau1Pays> niveauList = [];
  List<ParametreGeneraux> paraList = [];
  bool isSearchMode = false;
  late ScrollController _scrollController;

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: d_colorGreen,
        centerTitle: true,
        toolbarHeight: 75,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: const Text(
          "Pays",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          // PopupMenuButton<String>(
          //   padding: EdgeInsets.zero,
          //   itemBuilder: (context) => <PopupMenuEntry<String>>[
          //     PopupMenuItem<String>(
          //       child: ListTile(
          //         leading: const Icon(
          //           Icons.add,
          //           color: Colors.green,
          //         ),
          //         title: Text(
          //           "Ajouter un pays",
          //           style: TextStyle(
          //               color: Colors.green,
          //               fontWeight: FontWeight.bold,
          //               overflow: TextOverflow.ellipsis),
          //         ),
          //         onTap: () async {
          //           if (mounted) Navigator.of(context).pop();
          //           Navigator.push(context,
          //               MaterialPageRoute(builder: (context) => Addpays()));
          //         },
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
      body: Container(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                  child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // The PopupMenuButton is used here to display the menu when the button is pressed.
                          showMenu<String>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              0,
                              50, // Adjust this value based on the desired position of the menu
                              MediaQuery.of(context).size.width,
                              0,
                            ),
                            items: [
                              PopupMenuItem<String>(
                                value: 'add_store',
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.add,
                                    color: d_colorGreen,
                                  ),
                                  title: const Text(
                                    "Ajouter un pays ",
                                    style: TextStyle(
                                      color: d_colorGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            elevation: 8.0,
                          ).then((value) {
                            if (value != null) {
                              if (value == 'add_store') {
                                // if (mounted) Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Addpays()));
                              }
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: d_colorGreen,
                            ),
                            SizedBox(width: 8), // Space between icon and text
                            Text(
                              'Ajouter',
                              style: TextStyle(
                                color: d_colorGreen,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isSearchMode = !isSearchMode;
                            _searchController.clear();
                          });
                        },
                        icon: Icon(
                          isSearchMode ? Icons.close : Icons.search,
                          color: isSearchMode ? Colors.red : d_colorGreen,
                        ),
                        label: Text(
                          isSearchMode ? 'Fermer' : 'Rechercher...',
                          style: TextStyle(
                              color: isSearchMode ? Colors.red : d_colorGreen,
                              fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSearchMode)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.blueGrey[400]),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Rechercher',
                                border: InputBorder.none,
                                hintStyle:
                                    TextStyle(color: Colors.blueGrey[400]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ])),
            ];
          },
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Consumer<PaysService>(
                  builder: (context, paysService, child) {
                    return FutureBuilder(
                        future: paysService.fetchPays(),
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
                              child: Center(child: Text("Aucun pays trouvé")),
                            );
                          } else {
                            paysList = snapshot.data!;
                            String searchText = "";
                            List<Pays> filteredPaysSearch =
                                paysList.where((pays) {
                              String nomPays = pays.nomPays!.toLowerCase();
                              searchText = _searchController.text.toLowerCase();
                              return nomPays.contains(searchText);
                            }).toList();
                            return Column(
                                children: filteredPaysSearch
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Niveau1List(
                                                              pays: e)));
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    offset: const Offset(0, 2),
                                                    blurRadius: 5,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                      leading:
                                                          getFlag(e.nomPays!),
                                                      title: Text(
                                                          e.nomPays!
                                                              .toUpperCase(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
                                                      subtitle: Text(
                                                          e.descriptionPays!
                                                              .trim(),
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ))),
                                                  FutureBuilder(
                                                      future: Niveau1Service()
                                                          .fetchNiveau1ByPays(
                                                              e.idPays!),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                          );
                                                        }

                                                        if (!snapshot.hasData) {
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombre de niveau 1 :",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    )),
                                                                Text("0",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ))
                                                              ],
                                                            ),
                                                          );
                                                        } else {
                                                          niveauList =
                                                              snapshot.data!;
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "Nombre de niveau 1 :",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    )),
                                                                Text(
                                                                    niveauList
                                                                        .length
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ))
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      }),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        _buildEtat(
                                                            e.statutPays!),
                                                        PopupMenuButton<String>(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          itemBuilder:
                                                              (context) =>
                                                                  <PopupMenuEntry<
                                                                      String>>[
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    e.statutPays ==
                                                                            false
                                                                        ? Icon(
                                                                            Icons.check,
                                                                            color:
                                                                                Colors.green,
                                                                          )
                                                                        : Icon(
                                                                            Icons.disabled_visible,
                                                                            color:
                                                                                Colors.orange[400],
                                                                          ),
                                                                title: Text(
                                                                  e.statutPays ==
                                                                          false
                                                                      ? "Activer"
                                                                      : "Desactiver",
                                                                  style:
                                                                      TextStyle(
                                                                    color: e.statutPays ==
                                                                            false
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .orange[400],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                onTap:
                                                                    () async {
                                                                  // Navigator.of(
                                                                  //         context)
                                                                  //     .pop();
                                                                  e.statutPays ==
                                                                          false
                                                                      ? await PaysService()
                                                                          .activerPays(e
                                                                              .idPays!)
                                                                          .then((value) =>
                                                                              {
                                                                                Provider.of<PaysService>(context, listen: false).applyChange(),
                                                                                setState(() {
                                                                                  // _liste = PaysService().fetchPaysBySousRegion(sousRegion.idSousRegion!);
                                                                                }),
                                                                                Navigator.of(context).pop(),
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Row(
                                                                                      children: [
                                                                                        Text("Activer avec succèss "),
                                                                                      ],
                                                                                    ),
                                                                                    duration: Duration(seconds: 2),
                                                                                  ),
                                                                                )
                                                                              })
                                                                          .catchError((onError) =>
                                                                              {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Row(
                                                                                      children: [
                                                                                        Text("Une erreur s'est produit"),
                                                                                      ],
                                                                                    ),
                                                                                    duration: Duration(seconds: 5),
                                                                                  ),
                                                                                ),
                                                                                Navigator.of(context).pop(),
                                                                              })
                                                                      : await PaysService()
                                                                          .desactiverPays(e
                                                                              .idPays!)
                                                                          .then((value) =>
                                                                              {
                                                                                Provider.of<PaysService>(context, listen: false).applyChange(),
                                                                                // setState(() {
                                                                                //   _liste = PaysService().fetchPaysBySousRegion(sousRegion.idSousRegion!);
                                                                                // }),
                                                                                Navigator.of(context).pop(),
                                                                              })
                                                                          .catchError((onError) =>
                                                                              {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Row(
                                                                                      children: [
                                                                                        Text("Une erreur s'est produit"),
                                                                                      ],
                                                                                    ),
                                                                                    duration: Duration(seconds: 5),
                                                                                  ),
                                                                                ),
                                                                                Navigator.of(context).pop(),
                                                                              });

                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                              "Désactiver avec succèss "),
                                                                        ],
                                                                      ),
                                                                      duration: Duration(
                                                                          seconds:
                                                                              2),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons.edit,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                title:
                                                                    const Text(
                                                                  "Modifier",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                onTap:
                                                                    () async {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              UpdatesPays(pays: e)));
                                                                },
                                                              ),
                                                            ),
                                                            PopupMenuItem<
                                                                String>(
                                                              child: ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                title:
                                                                    const Text(
                                                                  "Supprimer",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                onTap:
                                                                    () async {
                                                                  await PaysService()
                                                                      .deletePays(e
                                                                          .idPays!)
                                                                      .then(
                                                                          (value) =>
                                                                              {
                                                                                Provider.of<PaysService>(context, listen: false).applyChange(),
                                                                                Navigator.of(context).pop(),
                                                                              })
                                                                      .catchError(
                                                                          (onError) =>
                                                                              {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Row(
                                                                                      children: [
                                                                                        Text("Impossible de supprimer"),
                                                                                      ],
                                                                                    ),
                                                                                    duration: Duration(seconds: 2),
                                                                                  ),
                                                                                )
                                                                              });
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList());
                          }
                        });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEtat(bool isState) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isState ? Colors.green : Colors.red,
      ),
    );
  }

  Map<String, String> countries = {
    "afghanistan": "AF",
    "albanie": "AL",
    "algérie": "DZ",
    "andorre": "AD",
    "angola": "AO",
    "antigua-et-barbuda": "AG",
    "argentine": "AR",
    "arménie": "AM",
    "australie": "AU",
    "autriche": "AT",
    "azerbaïdjan": "AZ",
    "bahamas": "BS",
    "bahreïn": "BH",
    "bangladesh": "BD",
    "barbade": "BB",
    "biélorussie": "BY",
    "belgique": "BE",
    "belize": "BZ",
    "bénin": "BJ",
    "bhoutan": "BT",
    "bolivie": "BO",
    "bosnie-herzégovine": "BA",
    "botswana": "BW",
    "brésil": "BR",
    "brunei": "BN",
    "bulgarie": "BG",
    "burkina faso": "BF",
    "burundi": "BI",
    "cambodge": "KH",
    "cameroun": "CM",
    "canada": "CA",
    "cap-vert": "CV",
    "république centrafricaine": "CF",
    "tchad": "TD",
    "chili": "CL",
    "chine": "CN",
    "colombie": "CO",
    "comores": "KM",
    "congo (brazzaville)": "CG",
    "congo (kinshasa)": "CD",
    "costa rica": "CR",
    "côte d'ivoire": "CI",
    "croatie": "HR",
    "cuba": "CU",
    "chypre": "CY",
    "république tchèque": "CZ",
    "danemark": "DK",
    "djibouti": "DJ",
    "dominique": "DM",
    "république dominicaine": "DO",
    "équateur": "EC",
    "égypte": "EG",
    "el salvador": "SV",
    "guinée équatoriale": "GQ",
    "érythrée": "ER",
    "estonie": "EE",
    "éthiopie": "ET",
    "fidji": "FJ",
    "finlande": "FI",
    "france": "FR",
    "gabon": "GA",
    "gambie": "GM",
    "géorgie": "GE",
    "allemagne": "DE",
    "ghana": "GH",
    "grèce": "GR",
    "grenade": "GD",
    "guatemala": "GT",
    "guinée": "GN",
    "guinée-bissau": "GW",
    "guyana": "GY",
    "haïti": "HT",
    "honduras": "HN",
    "hongrie": "HU",
    "islande": "IS",
    "inde": "IN",
    "indonésie": "ID",
    "iran": "IR",
    "irak": "IQ",
    "irlande": "IE",
    "israël": "IL",
    "italie": "IT",
    "jamaïque": "JM",
    "japon": "JP",
    "jordanie": "JO",
    "kazakhstan": "KZ",
    "kenya": "KE",
    "kiribati": "KI",
    "corée du nord": "KP",
    "corée du sud": "KR",
    "koweït": "KW",
    "kirghizistan": "KG",
    "laos": "LA",
    "lettonie": "LV",
    "liban": "LB",
    "lesotho": "LS",
    "libéria": "LR",
    "libye": "LY",
    "liechtenstein": "LI",
    "lituanie": "LT",
    "luxembourg": "LU",
    "macédoine": "MK",
    "madagascar": "MG",
    "malawi": "MW",
    "malaisie": "MY",
    "maldives": "MV",
    "mali": "ML",
    "malte": "MT",
    "îles marshall": "MH",
    "mauritanie": "MR",
    "maurice": "MU",
    "mexique": "MX",
    "micronésie": "FM",
    "moldavie": "MD",
    "monaco": "MC",
    "mongolie": "MN",
    "monténégro": "ME",
    "maroc": "MA",
    "mozambique": "MZ",
    "birmanie": "MM",
    "namibie": "NA",
    "nauru": "NR",
    "népal": "NP",
    "pays-bas": "NL",
    "nouvelle-zélande": "NZ",
    "nicaragua": "NI",
    "niger": "NE",
    "nigeria": "NG",
    "niué": "NU",
    "norvège": "NO",
    "oman": "OM",
    "pakistan": "PK",
    "palaos": "PW",
    "palestine": "PS",
    "panama": "PA",
    "papouasie-nouvelle-guinée": "PG",
    "paraguay": "PY",
    "pérou": "PE",
    "philippines": "PH",
    "pologne": "PL",
    "portugal": "PT",
    "qatar": "QA",
    "roumanie": "RO",
    "russie": "RU",
    "rwanda": "RW",
    "saint-kitts-et-nevis": "KN",
    "sainte-lucie": "LC",
    "saint-vincent-et-les-grenadines": "VC",
    "samoa": "WS",
    "saint-marin": "SM",
    "sao tomé-et-principe": "ST",
    "arabie saoudite": "SA",
    "sénégal": "SN",
    "serbie": "RS",
    "seychelles": "SC",
    "sierra leone": "SL",
    "singapour": "SG",
    "slovaquie": "SK",
    "slovénie": "SI",
    "salomon": "SB",
    "somalie": "SO",
    "afrique du sud": "ZA",
    "soudan du sud": "SS",
    "espagne": "ES",
    "sri lanka": "LK",
    "soudan": "SD",
    "suriname": "SR",
    "swaziland": "SZ",
    "suède": "SE",
    "suisse": "CH",
    "syrie": "SY",
    "tadjikistan": "TJ",
    "tanzanie": "TZ",
    "thaïlande": "TH",
    "timor oriental": "TL",
    "togo": "TG",
    "tonga": "TO",
    "trinité-et-tobago": "TT",
    "tunisie": "TN",
    "turquie": "TR",
    "turkménistan": "TM",
    "tuvalu": "TV",
    "ouganda": "UG",
    "ukraine": "UA",
    "émirats arabes unis": "AE",
    "royaume-uni": "GB",
    "états-unis": "US",
    "uruguay": "UY",
    "ouzbékistan": "UZ",
    "vanuatu": "VU",
    "vatican": "VA",
    "vénézuéla": "VE",
    "vietnam": "VN",
    "yémen": "YE",
    "zambie": "ZM",
    "zimbabwe": "ZW",
  };

  Widget getFlag(String pays) {
    String code = '';
    String p = pays.toLowerCase();
    countries.forEach((key, value) {
      if (p == key) {
        // setState(() {

        // });
        code = value;
      }
    });
    return code.isEmpty
        ? Image.asset(
            "assets/images/sous.png",
            width: 50,
            height: 50,
          )
        : CountryFlag.fromCountryCode(
            code,
            height: 48,
            width: 62,
          );
  }
}
