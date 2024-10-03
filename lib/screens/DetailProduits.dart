import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:koumi/Admin/CodePays.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Device.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Stock.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CartProvider.dart';
import 'package:koumi/screens/AddAndUpdateProductScreen.dart';
import 'package:koumi/service/DeviceService.dart';
import 'package:koumi/widgets/SnackBar.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailProduits extends StatefulWidget {
  late Stock stock;
  DetailProduits({super.key, required this.stock});

  @override
  State<DetailProduits> createState() => _DetailProduitsState();
}

const double defaultPadding = 16.0;
const double defaultPadding_min = 5.0;
const double defaultBorderRadius = 12.0;

class _DetailProduitsState extends State<DetailProduits>
    with SingleTickerProviderStateMixin {
  // late AnimationController _controller;
  // late Animation<Offset> _animation;

  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late ValueNotifier<bool> isDialOpenNotifier;
  late Stock stock;
  int nbVue = 0;

  bool isExist = false;
  String? email = "";
  // List<ParametreGeneraux> paraList = [];
  // late ParametreGeneraux para = ParametreGeneraux();

  bool isLoadingLibelle = true;
  //  String? monnaie;
  late Future<Map<String, String>> rates;

  Future<List<Device>> getDeviceListe(String id) async {
    return await DeviceService().fetchDeviceByIdMonnaie(id);
  }

  Future<Map<String, String>> fetchConvert(Stock stock) async {
    Monnaie monnaie = stock.monnaie!;
    int? amount = stock.prix;
    Map<String, String> result = {};

    try {
      List<Device> devices = await getDeviceListe(monnaie.idMonnaie!);

      for (var device in devices) {
        double convertedAmount = amount! * device.taux!;
        String amountSubString = convertedAmount.toStringAsFixed(2);
        print(amountSubString);
        switch (device.nomDevice!.toLowerCase()) {
          case 'dollar':
            result[device.sigle!] = amountSubString;
            break;
          case 'euro':
            result[device.sigle!] = amountSubString;
            break;
          case 'yuan':
            result[device.sigle!] = amountSubString;
            break;
          default:
            print('Aucune devise trouvée pour ${device.nomDevice}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    print("conversion : ${result.toString()}");
    return result;
  }

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur.typeActeur!;
      type = typeActeurData.map((data) => data.libelle).join(', ');
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    verify();
    // verifyParam();
    stock = widget.stock;

    _loadNbVue();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await updateViews(stock);
      setState(() {
        stock.nbreView = nbVue;
      });
    });
    rates = fetchConvert(stock);
    isDialOpenNotifier = ValueNotifier<bool>(false);
  }

  Future<void> _loadNbVue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nbVue = prefs.getInt('nbVue_${stock.idStock}') ?? stock.nbreView ?? 0;
    });
  }

  updateViews(Stock s) async {
    if (acteur.idActeur != s.acteur!.idActeur) {
      final response = await http.put(
        Uri.parse('$apiOnlineUrl/Stock/updateView/${s.idStock}'),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          nbVue++;
          s.nbreView = nbVue;
          print('Nombre de vues mis à jour : ${s.nbreView}');
          // Sauvegarder la nouvelle valeur de nbVue
          _saveNbVue();
        });
      } else {
        print('Échec de la mise à jour du nombre de vues');
      }
    }
  }

  Future<void> _saveNbVue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nbVue_${stock.idStock}', nbVue);
  }

  @override
  Widget build(BuildContext context) {
    const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
    return Scaffold(
        appBar: AppBar(
            backgroundColor: d_colorOr,
            centerTitle: true,
            toolbarHeight: 75,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
            title: const Text("Détail Produit",
                style: TextStyle(fontSize: 20, color: Colors.white)),
            actions: 
                // ? [
                //     acteur.idActeur != widget.stock.acteur!.idActeur
                //         ? SizedBox()
                //         : IconButton(
                //             onPressed: () {
                //               Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                       builder: (context) =>
                //                           AddAndUpdateProductScreen(
                //                             isEditable: true,
                //                             stock: widget.stock,
                //                           )));
                //             },
                //             icon: Icon(Icons.edit, color: Colors.white),
                //           )
                //   ]
                 [
                  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CodePays().getFlagsApp(stock.acteur!.niveau3PaysActeur!),
                )]),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Set mainAxisSize to min
            children: [
              widget.stock.photo == null || widget.stock.photo!.isEmpty
                  ? Image.asset(
                      "assets/images/default_image.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    )
                  : CachedNetworkImage(
                      imageUrl:
                          'https://koumi.ml/api-koumi/Stock/${widget.stock.idStock}/image',
                      width: double.infinity,
                      height: 200,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/default_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: defaultPadding * 0.300),
              Container(
                padding: const EdgeInsets.fromLTRB(defaultPadding,
                    defaultPadding * 2, defaultPadding, defaultPadding),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(defaultBorderRadius * 3),
                    topRight: Radius.circular(defaultBorderRadius * 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: d_colorOr,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 2,
                          widget.stock.nomProduit!.toUpperCase(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Forme : ",
                          style: TextStyle(
                              fontSize: 20, fontStyle: FontStyle.italic),
                        ),
                        Text(
                          textAlign: TextAlign.right,
                          widget.stock
                              .formeProduit!, // Use optional chaining and ??
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quantité : ",
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Text(
                          widget.stock.quantiteStock!.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Unité Produit : ",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Text(
                          maxLines: 2,
                          textAlign: TextAlign.right,
                          widget.stock.unite!.nomUnite == null
                              ? ""
                              : widget.stock.unite!.nomUnite!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Prix",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Text(
                          maxLines: 2,
                          textAlign: TextAlign.right,
                          '${widget.stock.prix!.toInt()} ${widget.stock.monnaie!.libelle}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder<Map<String, String>>(
                      future: rates,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          return Column(
                            children: snapshot.data!.entries.map((entry) {
                              return _buildItem(
                                  "Prix en ${entry.key}", "${entry.value}");
                            }).toList(),
                          );
                        }
                      },
                    ),
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: d_colorOr,
                      ),
                      child: Center(
                        child: Text(
                          "Description",
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: ReadMoreText(
                        colorClickableText: Colors.orange,
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: "Lire plus",
                        trimExpandedText: "Lire moins",
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                        widget.stock.descriptionStock == null
                            ? ""
                            : widget.stock.descriptionStock!,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: d_colorOr,
                      ),
                      child: Center(
                        child: Text(
                          "Autres informations",
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    _getPays(stock),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nombre de vue : ",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Expanded(
                          child: Text(
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            stock.nbreView.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Speculation : ",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Expanded(
                          child: Text(
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            widget.stock.speculation == null
                                ? "Aucune spéculation"
                                : widget.stock.speculation!.nomSpeculation!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Type Produit : ",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Flexible(
                          child: Text(
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            widget.stock.typeProduit!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Origine : ",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Flexible(
                          child: Text(
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            widget.stock.origineProduit!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date production : ",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Flexible(
                          child: Text(
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            widget.stock.dateProduction!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Fournisseur",
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Text(
                          widget.stock.acteur!.nomActeur!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Contact",
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16),
                        ),
                        Text(
                          widget.stock.acteur!.whatsAppActeur != null
                              ? widget.stock.acteur!.whatsAppActeur!
                              : widget.stock.acteur!.telephoneActeur!,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                   
                    // const SizedBox(height: 20),
                    // isExist == true
                    //     ? widget.stock.acteur!.idActeur == acteur.idActeur
                    //         ? SizedBox()
                    //         : Center(
                    //             child: SizedBox(
                    //               width: 200,
                    //               height: 48,
                    //               child: ElevatedButton(
                    //                 onPressed: () {
                    //                   // _addToCart(widget.stock);
                    //                   if (widget.stock.acteur!.idActeur ==
                    //                       acteur.idActeur) {
                    //                     Snack.error(
                    //                         titre: "Alerte",
                    //                         message:
                    //                             "Désolé!, Vous ne pouvez pas commander un produit qui vous appartient");
                    //                   } else {
                    //                     Provider.of<CartProvider>(context,
                    //                             listen: false)
                    //                         .addToCart(widget.stock, 1, "");
                    //                   }
                    //                 },
                    //                 style: ElevatedButton.styleFrom(
                    //                     foregroundColor: Colors.orange,
                    //                     shape: const StadiumBorder()),
                    //                 child: Text(
                    //                   "Ajouter au panier",
                    //                   style: TextStyle(
                    //                       fontSize: 16,
                    //                       fontWeight: FontWeight.bold),
                    //                 ),
                    //               ),
                    //             ),
                    //           )
                    //     : SizedBox(),
                    const SizedBox(height: 10),
                  ],
                ),
              )
            ],
          ),
        ),

        //     floatingActionButton:
        //     widget.stock.acteur!.idActeur != acteur.idActeur ?
        // SpeedDial(
        //   backgroundColor: d_colorGreen,
        //   foregroundColor: Colors.white,
        //   overlayColor: Colors.black,
        //   overlayOpacity: 0.4,
        //   spacing: 12,
        //   icon: Icons.phone,
        //   children: [
        //     SpeedDialChild(
        //       child: FaIcon(FontAwesomeIcons.whatsapp),
        //       label: 'Par WhatsApp',
        //       labelStyle: TextStyle(
        //         color: Colors.black,
        //         fontSize: 15,
        //         fontWeight: FontWeight.w500,
        //       ),
        //       onTap: () {
        //         final String whatsappNumber = widget.stock.acteur!.whatsAppActeur!;
        //         _makePhoneWa(whatsappNumber);
        //       },
        //     ),
        //     SpeedDialChild(
        //       child: Icon(Icons.phone),
        //       label: 'Par téléphone',
        //       labelStyle: TextStyle(
        //         color: Colors.black,
        //         fontSize: 15,
        //         fontWeight: FontWeight.w500,
        //       ),
        //       onTap: () {
        //         final String numberPhone = widget.stock.acteur!.telephoneActeur!;
        //         _makePhoneCall(numberPhone);
        //       },
        //     )
        //   ],
        //   // État du Speed Dial (ouvert ou fermé)
        //   openCloseDial: isDialOpenNotifier,
        //   // Fonction appelée lorsque le bouton principal est pressé
        //   onPress: () {
        //     isDialOpenNotifier.value = !isDialOpenNotifier.value;
        //   },
        // )
        // :
        // Container()
        floatingActionButton: acteur.idActeur != stock.acteur!.idActeur
            ? SpeedDial(
                // animatedIcon: AnimatedIcons.close_menu,

                backgroundColor: d_colorGreen,
                foregroundColor: Colors.white,
                overlayColor: Colors.black,
                overlayOpacity: 0.7,
                spacing: 12,
                icon: Icons.phone,

                children: [
                  SpeedDialChild(
                    child: FaIcon(FontAwesomeIcons.whatsapp),
                    label: 'Par wathsApp',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    onTap: () {
                      final String whatsappNumber =
                          stock.acteur!.whatsAppActeur!;
                      _makePhoneWa(whatsappNumber);
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.phone),
                    label: 'Par téléphone ',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    onTap: () {
                      final String numberPhone = stock.acteur!.telephoneActeur!;
                      _makePhoneCall(numberPhone);
                    },
                  )
                ],
                // État du Speed Dial (ouvert ou fermé)
                openCloseDial: isDialOpenNotifier,
                // Fonction appelée lorsque le bouton principal est pressé
                onPress: () {
                  isDialOpenNotifier.value = !isDialOpenNotifier
                      .value; // Inverser la valeur du ValueNotifier
                },
              )
            : Container()
        //// Si l'utilisateur est connecté et que le stock lui appartient, ne pas afficher le bouton de téléphone
        );
  }

  Future<void> _makePhoneWa(String whatsappNumber) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: whatsappNumber,
    );
    print(Uri);
    await launchUrl(launchUri);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Widget _getPays(Stock m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "Pays",
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16),
            ),
          ),
          CodePays().getFlags(m.acteur!.niveau3PaysActeur!)
        ],
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              // softWrap: true,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 10) {
            Navigator.pop(context); // Ferme l'écran si glissé vers le bas
          }
        },
        child: Center(
          child: ListView(
            children: [
              Hero(
                tag:
                    "qrImage", // Référence au même tag utilisé dans l'écran précédent
                child: Image.asset("assets/images/qr.png"), // Image agrandie
              ),
              // Autres éléments de l'écran de détail ici...
            ],
          ),
        ),
      ),
      // Ferme l'écran si glissé vers la gauche ou la droite
      resizeToAvoidBottomInset: false,
    );
  }
}
