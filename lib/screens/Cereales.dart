// import 'package:flutter/material.dart';
// import 'package:koumi_app/models/Stock.dart';
// import 'package:koumi_app/service/StockService.dart';
// import 'package:provider/provider.dart';

// class Cereales extends StatefulWidget {
//   const Cereales({super.key});

//   @override
//   State<Cereales> createState() => _CerealesState();
// }

// class _CerealesState extends State<Cereales> {
//   List<Stock> stockList = [];

//   @override
//   void initState() {
//     super.initState();
//     // FstockList = getStock();
//     // debugPrint(FstockList.toString());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text("Mes produits"),
//       // ),
//       body: ListView(children: [
//         Consumer<StockService>(builder: (context, stockService, child) {
//           return FutureBuilder(
//               future: stockService.fetchStock(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: CircularProgressIndicator(),
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   debugPrint(snapshot.error.toString());
//                   return Center(
//                     child: Text(snapshot.error.toString()),
//                   );
//                 }

//                 if (!snapshot.hasData) {
//                   return const Center(child: Text("Aucun produit trouvé"));
//                 } else {
//                   stockList = snapshot.data!;
//                   debugPrint(stockList.toString());
//                   return SizedBox(
//                     // height: 800,
//                     child: GridView.count(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       crossAxisCount: 2,
//                       children: stockList
//                           .map(
//                             (stock) => _buildAcceuilCard(
//                               stock.nomProduit,
//                               stock.prix,
//                               stock.quantiteStock,
//                               stock,
//                               stock.photo!,
//                               context,
//                             ),
//                           )
//                           .toList(),
//                     ),
//                   );
//                 }
//               });
//         })
//       ]),
//     );
//   }

//   bool isValidImageUrl(String url) {
//     // Vérifie si l'URL commence par http:// ou https://
//     if (!url.startsWith('http://') && !url.startsWith('https://')) {
//       return false;
//     }

//     // Vérifie s'il y a un hôte spécifié dans l'URL
//     Uri? uri = Uri.tryParse(url);
//     if (uri == null || uri.host.isEmpty) {
//       return false;
//     }

//     // Si l'URL a passé toutes les vérifications, elle est considérée comme valide
//     return true;
//   }

//   Widget _buildAcceuilCard(
//     String nomProduit,
//     int prix,
//     double quantite,
//     Stock stock,
//     String imgLocation,
//     BuildContext context,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(5.0),
//       child: Card(
//         semanticContainer: true,
//         clipBehavior: Clip.antiAliasWithSaveLayer,
//         margin: const EdgeInsets.all(10.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         elevation: 5.0,
//         child: Padding(
//           padding: const EdgeInsets.all(5.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.28,
//                 child: isValidImageUrl("http:10.0.2.2/$imgLocation")
//                     ? Expanded(
//                         child: Image.network(
//                           "http:10.0.2.2/$imgLocation",
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : Expanded(
//                         child: Image.asset(
//                           "assets/images/pomme.png",
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 nomProduit,
//                 style: const TextStyle(
//                   fontSize: 17,
//                   overflow: TextOverflow.ellipsis,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Prix",
//                     style: TextStyle(
//                       fontSize: 17,
//                       overflow: TextOverflow.ellipsis,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     "$prix FCFA",
//                     style: const TextStyle(
//                       fontSize: 17,
//                       overflow: TextOverflow.ellipsis,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 5),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Quantité",
//                     style: TextStyle(
//                       fontSize: 17,
//                       overflow: TextOverflow.ellipsis,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     quantite.toString(),
//                     style: const TextStyle(
//                       fontSize: 17,
//                       overflow: TextOverflow.ellipsis,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),

//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.end,
//               //   children: [
//               //     ElevatedButton(
//               //       onPressed: () {
//               //         Navigator.push(
//               //           context,
//               //           MaterialPageRoute(
//               //             builder: (context) => DetailProduits(stock: stock),
//               //           ),
//               //         );
//               //       },
//               //       child: const Text("Voir"),
//               //     ),
//               //   ],
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
