// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:koumi/models/Superficie.dart';

class DetailSuperficie extends StatefulWidget {
  final Superficie suerficie;
  const DetailSuperficie({
    Key? key,
    required this.suerficie,
  }) : super(key: key);

  @override
  State<DetailSuperficie> createState() => _DetailSuperficieState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _DetailSuperficieState extends State<DetailSuperficie> {
  late Superficie superficies;

  @override
  void initState() {
    super.initState();
    superficies = widget.suerficie;
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Text(
          'Détail',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [viewData()]),
      ),
    );
  }

  Widget viewData() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: d_colorOr,
            ),
            child: Center(
              child: Text(
                "Superficie cultiver",
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        _buildData(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: d_colorOr,
            ),
            child: Center(
              child: Text(
                'Autre informations',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        _buildItem(
            'Spéculation cultiver ', superficies.speculation.nomSpeculation!),
        _buildItem('Intrant utilisé ',
            superficies.intrants!.map((data) => data).join(', ')),
        _buildItem('Campagne agricole ', superficies.campagne.nomCampagne),
      ],
    );
  }

  _buildData() {
    return Column(
      children: [
        _buildItem('Superficie ', superficies.superficieHa!),
        _buildItem('Localité ', superficies.localite!),
        _buildItem('Date sémence ', superficies.dateSemi!),
        _buildItem('Date d\'ajout ', superficies.dateSemi!),
      ],
    );
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
  // Widget _buildItem(String title, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.all(10.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           title,
  //           style: const TextStyle(
  //               color: Colors.black87,
  //               fontWeight: FontWeight.w500,
  //               fontStyle: FontStyle.italic,
  //               overflow: TextOverflow.ellipsis,
  //               fontSize: 18),
  //         ),
  //         Text(
  //           value,
  //           textAlign: TextAlign.justify,
  //           softWrap: true,
  //           style: const TextStyle(
  //             color: Colors.black,
  //             fontWeight: FontWeight.w800,
  //             overflow: TextOverflow.ellipsis,
  //             fontSize: 16,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}
