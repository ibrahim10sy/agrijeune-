import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:profile_photo/profile_photo.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:koumi/constants.dart';

class DetailsActeur extends StatefulWidget {
  final Acteur acteur;
  const DetailsActeur({super.key, required this.acteur});

  @override
  State<DetailsActeur> createState() => _DetailsActeurState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _DetailsActeurState extends State<DetailsActeur> {
  late Acteur acteurs;
  bool active = false;

  @override
  void initState() {
    super.initState();
    acteurs = widget.acteur;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: d_colorOr,
        centerTitle: true,
        toolbarHeight: 75,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: Text(
          "Détails",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: ClipOval(
                                          child: CachedNetworkImage(
                                            width: 185,
                                            height: 185,
                                            imageUrl:
                                                "$apiOnlineUrl/acteur/${acteurs.idActeur}/image",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Image.asset(
                                                    'assets/images/profil.jpg'),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/images/profil.jpg',
                                              fit: BoxFit.cover,
                                              width: 185,
                                              height: 185,
                                            ),
                                          ),
                                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: Text(acteurs.nomActeur!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        overflow: TextOverflow.ellipsis,
                      ))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildPanel(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          active = !active;
        });
      },
      children: <ExpansionPanel>[
        ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfile("Adresse", acteurs.adresseActeur!),
                    _buildProfile("Téléphone", acteurs.telephoneActeur!),
                    _buildProfile("Email", acteurs.emailActeur!),
                  ],
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfile("whatsApp", acteurs.whatsAppActeur!),
                  // _buildProfile("Pays", acteurs.niveau3PaysActeur!),
                  _buildProfile("Localité", acteurs.localiteActeur!),
                ],
              ),
            ),
            isExpanded: active,
            canTapOnHeader: true)
      ],
    );
  }

  Widget _buildProfile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8),
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

//   Widget _buildPanel() {
//   return ExpansionPanelList(
//     expansionCallback: (int index, bool isExpanded) {
//       setState(() {});
//     },
//     children: <ExpansionPanel>[
//       ExpansionPanel(
//         headerBuilder: (context, isExpanded) {
//           return Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildProfile("Adresse", acteurs.adresseActeur),
//                 _buildProfile("Téléphone", acteurs.telephoneActeur),
//                 _buildProfile("Email", acteurs.emailActeur),
//               ],
//             ),
//           );
//         },
//         body: Container(), // Replace with your body widget if needed
//         isExpanded: active,
//         canTapOnHeader: true,
//       )
//     ],
//   );
// }

// Widget _buildProfile(String title, String value) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: const EdgeInsets.only(bottom: 8.0),
//         child: Text(
//           title,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(bottom: 16.0),
//         child: Text(
//           value,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 14,
//           ),
//         ),
//       ),
//       Divider(
//         height: 1,
//         color: Colors.grey[300],
//       ),
//     ],
//   );
// }
}
