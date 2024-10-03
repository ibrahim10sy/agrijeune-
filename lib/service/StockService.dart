import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Magasin.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/Unite.dart';
import 'package:koumi/models/ZoneProduction.dart';
import 'package:path/path.dart';

class StockService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Stock';

  List<Stock> stockList = [];
  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;

  // List<dynamic> stockList = [];
  // addStock

  Future<void> creerStock({
    required String nomProduit,
    required String formeProduit,
    required String origineProduit,
    required String prix,
    required String quantiteStock,
    required String typeProduit,
    required String descriptionStock,
    File? photo,
    required ZoneProduction zoneProduction,
    required Speculation speculation,
    required Unite unite,
    required Magasin magasin,
    required Acteur acteur,
    required Monnaie monnaie,
  }) async {
    try {
      var requete =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/addStock'));

      if (photo != null) {
        requete.files.add(http.MultipartFile(
            'image', photo.readAsBytes().asStream(), photo.lengthSync(),
            filename: basename(photo.path)));
      }

      requete.fields['stock'] = jsonEncode({
        'nomProduit': nomProduit,
        'formeProduit': formeProduit,
        'origineProduit': origineProduit,
        'prix': prix,
        'quantiteStock': int.tryParse(quantiteStock),
        'typeProduit': typeProduit,
        'descriptionStock': descriptionStock,
        'photo': "",
        'zoneProduction': zoneProduction.toMap(),
        'speculation': speculation.toMap(),
        'unite': unite.toMap(),
        'magasin': magasin.toMap(),
        'acteur': acteur.toMap(),
        'monnaie': monnaie.toMap()
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 ||
          responsed.statusCode == 201 ||
          responsed.statusCode == 202) {
        final donneesResponse = json.decode(responsed.body);
        Get.snackbar("Succès", "Produit ajouté avec succès",
            duration: Duration(seconds: 5));
        debugPrint('stock service ${donneesResponse.toString()}');
      } else {
        Get.snackbar(
            "Erreur", "Une erreur s'est produite veuiller réessayer plus tard",
            duration: Duration(seconds: 5));

        throw Exception(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode}');
      }
    } catch (e) {
      debugPrint('stock service erreur $e');

      Get.snackbar("Erreur de connexion",
          "Une erreur s'est produite veuiller réessayer ultérieurement",
          duration: Duration(seconds: 5));
      // throw Exception(
      //     'Une erreur s\'est produite lors de l\'ajout de acteur : $e');
    }
  }

  Future<void> updateStock(
      {required String idStock,
      required String nomProduit,
      required String formeProduit,
      required String prix,
      required String origineProduit,
      required String quantiteStock,
      required String typeProduit,
      required String descriptionStock,
      required String dateProduction,
      File? photo,
      required ZoneProduction zoneProduction,
      required Speculation speculation,
      required Unite unite,
      required Magasin magasin,
      required Acteur acteur,
      required Monnaie monnaie}) async {
    try {
      var requete = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl/updateStock/$idStock'));

      if (photo != null) {
        requete.files.add(http.MultipartFile(
            'image', photo.readAsBytes().asStream(), photo.lengthSync(),
            filename: basename(photo.path)));
      }

      requete.fields['stock'] = jsonEncode({
        'idStock': idStock,
        'nomProduit': nomProduit,
        'formeProduit': formeProduit,
        'origineProduit': origineProduit,
        'prix': prix,
        'quantiteStock': double.tryParse(quantiteStock),
        'typeProduit': typeProduit,
        'descriptionStock': descriptionStock,
        'dateProduction': dateProduction,
        'photo': "",
        'zoneProduction': zoneProduction.toMap(),
        'speculation': speculation.toMap(),
        'unite': unite.toMap(),
        'magasin': magasin.toMap(),
        'acteur': acteur.toMap(),
        'monnaie': monnaie.toMap()
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 ||
          responsed.statusCode == 201 ||
          responsed.statusCode == 202) {
        Get.snackbar("Succès", "Produit modifier avec succès",
            duration: Duration(seconds: 3));
        final donneesResponse = json.decode(responsed.body);
        debugPrint('stock service update ${donneesResponse.toString()}');
      } else {
        //  Get.snackbar("Erreur", "Une erreur s'est produite veuiller réessayer ultérieurement",duration: Duration(seconds: 3));
        final errorMessage =
            json.decode(utf8.decode(responsed.bodyBytes))['message'];
        debugPrint(' erreur : ${errorMessage}');
        Get.snackbar(
            "Une erreur s'est produit", "Veuiller réessayer ultérieurement",
            duration: Duration(seconds: 3));
        print(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode}');
      }
    } catch (e) {
      Get.snackbar("Erreur de connexion", "Veuiller réessayer ultérieurement",
          duration: Duration(seconds: 3));
      debugPrint("catch erreur : $e");
      print(
          'Une erreur s\'est produite lors de la modification du produit : $e');
    }
  }

  Future<List<Stock>> fetchStockBySpeculation(String idSpeculation) async {
    final response = await http
        .get(Uri.parse('$baseUrl/getAllStocksBySpeculation/$idSpeculation'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      stockList = body.map((item) => Stock.fromMap(item)).toList();
      debugPrint(response.body);
      return stockList;
    } else {
      stockList = [];

      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> updateQuantiteStock({
    required String id,
    required double quantite,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id/quantite?quantite=$quantite'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final donneesResponse = json.decode(response.body);
        debugPrint('Stock service update: ${donneesResponse.toString()}');
        // return Stock.fromJson(json.decode(response.body));
        // applyChange();
      } else {
        Get.snackbar(
          "Erreur",
          "Une erreur s'est produite, veuillez réessayer ultérieurement",
          duration: Duration(seconds: 3),
        );
        throw Exception(
          'Impossible de mettre à jour la quantité : ${quantite} et code : ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Une erreur s'est produite, veuillez réessayer ultérieurement",
        duration: Duration(seconds: 3),
      );
      debugPrint('Erreur lors de la mise à jour de la quantité: $e');
      throw Exception('Erreur lors de la mise à jour de la quantité: $e');
    }
  }

  Future<List<Stock>> fetchStock({bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getStocksByPaysWithPagination?page=${page}&size=${size}'));
      debugPrint(
          '$apiOnlineUrl/Stock/getStocksByPaysWithPagination?page=${page}&size=${size}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock with pagination ${page} par défilement soit ${stockList.length}");
        return stockList;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  // Future<List<Stock>> fetchStock(String niveau3PaysActeur,
  //     {bool refresh = false}) async {
  //   if (isLoading == true) return [];

  //   isLoading = true;

  //   if (refresh) {
  //     stockList.clear();
  //     page = 0;
  //     hasMore = true;
  //   }

  //   try {
  //     final response = await http.get(Uri.parse(
  //         '$apiOnlineUrl/Stock/getStocksByPaysWithPagination?niveau3PaysActeur=$niveau3PaysActeur&page=${page}&size=${size}'));
  //     debugPrint(
  //         '$apiOnlineUrl/Stock/getStocksByPaysWithPagination?niveau3PaysActeur=$niveau3PaysActeur&page=${page}&size=${size}');
  //     if (response.statusCode == 200) {
  //       final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
  //       final List<dynamic> body = jsonData['content'];

  //       if (body.isEmpty) {
  //         hasMore = false;
  //       } else {
  //         List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
  //         stockList.addAll(newStocks.where((newStock) => !stockList
  //             .any((existStock) => existStock.idStock == newStock.idStock)));
  //       }

  //       debugPrint(
  //           "response body all stock with pagination ${page} par défilement soit ${stockList.length}");
  //       return stockList;
  //     } else {
  //       print(
  //           'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print(
  //         'Une erreur s\'est produite lors de la récupération des stocks: $e');
  //   } finally {
  //     isLoading = false;
  //   }
  //   return stockList;
  // }

  Future<List<Stock>> fetchStockByCategorie(
      String idCategorie, String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllStocksByCategorieAndPaysWithPagination?idCategorie=${idCategorie}&niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock by categorie and pays with pagination ${page} par défilement soit ${stockList.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  Future<List<Stock>> fetchStockByPays(String nomPays,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllStocksByPays?nomPays=${nomPays}&page=$page&size=$size'));
      print(
          "servcie : $apiOnlineUrl/Stock/getAllStocksByPays?nomPays=${nomPays}&page=$page&size=$size");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();

          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock by categorie and pays with pagination ${page} par défilement soit ${stockList.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  Future<List<Stock>> fetchStockByPaysAndFiliere(String libelle, String nomPays,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllByFiliereAndPays?libelle=${libelle}&nomPays=${nomPays}&page=$page&size=$size'));
      print(
          "servcie :$apiOnlineUrl/Stock/getAllByFiliereAndPays?libelle=${libelle}&nomPays=${nomPays}&page=$page&size=$size");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();

          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock by categorie and pays with pagination ${page} par défilement soit ${stockList.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  Future<List<Stock>> fetchStockByCategorieAndFiliere(
      String idCategorie, String libelleFiliere,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllStocksByCategorieAndFiliere?idCategorie=${idCategorie}&libelleFiliere=$libelleFiliere&page=$page&size=$size'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock by categorie and pays with pagination ${page} par défilement soit ${stockList.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }
  // Future<List<Stock>> fetchStockByCategorieAndFiliere(
  //     String idCategorie, String libelleFiliere, String niveau3PaysActeur,
  //     {bool refresh = false}) async {
  //   if (isLoading == true) return [];

  //   isLoading = true;

  //   if (refresh) {
  //     stockList.clear();
  //     page = 0;
  //     hasMore = true;
  //   }

  //   try {
  //     final response = await http.get(Uri.parse(
  //         '$apiOnlineUrl/Stock/getAllStocksByCategorieAndFiliere?idCategorie=${idCategorie}&libelleFiliere=$libelleFiliere&niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));

  //     if (response.statusCode == 200) {
  //       final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
  //       final List<dynamic> body = jsonData['content'];

  //       if (body.isEmpty) {
  //         hasMore = false;
  //       } else {
  //         List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
  //         stockList.addAll(newStocks.where((newStock) => !stockList
  //             .any((existStock) => existStock.idStock == newStock.idStock)));
  //       }

  //       debugPrint(
  //           "response body all stock by categorie and pays with pagination ${page} par défilement soit ${stockList.length}");
  //     } else {
  //       print(
  //           'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
  //     }
  //   } catch (e) {
  //     print(
  //         'Une erreur s\'est produite lors de la récupération des stocks: $e');
  //   } finally {
  //     isLoading = false;
  //   }
  //   return stockList;
  // }

  Future<List<Stock>> fetchStockByIdActeurAndIdCategorie(
      String idCategorie, String idActeur,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getStocksByCategorieAndActeur?idCategorie=${idCategorie}&idActeur=$idActeur&page=$page&size=$size'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock by categorie and pays with pagination ${page} par défilement soit ${stockList.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  Future<List<Stock>> fetchProduitByCategorieProduitMagAndActeur(
      String idCategorie, String idMagasin, String idActeur) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/categorieAndActeur/$idCategorie/$idMagasin/$idActeur'));

      if (response.statusCode == 200) {
        print("Fetching data all stock by id ,categorie, magasin and acteur");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        stockList = body
            // .where((stock) => stock['statutSotck'] == true)
            .map((e) => Stock.fromMap(e))
            .toList();
        // debugPrint(stockList.toString());
        return stockList;
      } else {
        debugPrint('Failed to load stock');
        return stockList = [];
      }
    } catch (e) {
      print('Error fetching stock by id ,categorie, magasin and acteur: $e');
    }
    return stockList = [];
  }

  Future<List<Stock>> fetchStockByMagasin(String idMagasin,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getStocksByPaysAndMagasinWithPagination?idMagasin=$idMagasin&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock by magasin and pays with pagination ${page} par défilement soit ${stockList.length}");
        return stockList;
      } else {
        print(
            'Échec de la requête stock cat mag pag avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  Future<List<Stock>> fetchStockByCategorieAndMagasin(
      String idCategorieProduit, String idMagasin,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getStocksByPaysAndMagasinAndCategorieProduitWithPagination?idCategorieProduit=${idCategorieProduit}&idMagasin=${idMagasin}&page=$page&size=$size'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock by pays and magasin and categorie with pagination ${page} par défilement soit ${stockList.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  Future<List<Stock>> fetchProduitByCategorieAndActeur(
      String idCategorie, String idActeur) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/categorieAndIdActeur/$idCategorie/$idActeur'));
      if (response.statusCode == 200) {
        // await Future.delayed(Duration(seconds: 2));
        print("Fetching data all stock by id categorie and id acteur");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        stockList = body
            // .where((stock) => stock['statutSotck'] == true)
            .map((e) => Stock.fromMap(e))
            .toList();
        // debugPrint(stockList.toString());
      } else {
        print('Failed to load stock');
        return stockList = [];
      }
    } catch (e) {
      print('Error fetching stock by id categorie and id acteu: $e');
    }
    return stockList = [];
  }

  Future<List<Stock>> fetchStockByActeur(String idActeur,
      {bool refresh = false}) async {
    // if (_stockService.isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllStocksByActeurWithPagination?idActeur=$idActeur&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock by acteur with pagination ${page} par défilement soit ${stockList.length}");
      } else {
        print(
            'Échec de la requête stock ac avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  Future<List<Stock>> fetchStockByMagasinAndActeur(
      String idMagasin, String idActeur,
      {bool refresh = false}) async {
    // if (_stockService.isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllStocksByMagasinAndActeurWithPagination?idMagasin=$idMagasin&idActeur=$idActeur&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStock = body.map((e) => Stock.fromMap(e)).toList();
          stockList.addAll(newStock.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body all stock by acteur with pagination ${page} par défilement soit ${stockList.length}");
      } else {
        print(
            'Échec de la requête  stoc pag ac avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  Future<List<Stock>> fetchStockByMagasinWithPagination(String idMagasin,
      {bool refresh = false}) async {
    if (isLoading) return [];

    isLoading = true;

    if (refresh) {
      stockList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllStocksByMagasinWithPagination?idMagasin=$idMagasin&page=$page&size=$size'));

      if (response.statusCode == 200) {
        // debugPrint("url: $response");
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          stockList.addAll(newStocks.where((newStock) => !stockList
              .any((existStock) => existStock.idStock == newStock.idStock)));
        }

        debugPrint(
            "response body  stock by magasin with pagination $page par défilement soit ${stockList.length}");
        return stockList;
      } else {
        print(
            'Échec de la requête pag avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      isLoading = false;
    }
    return stockList;
  }

  Future deleteStock(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deleteStocks/$id'));

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      applyChange();
    } else {
      // Get.snackbar("Erreur", "Une erreur s'est produite veuiller réessayer ultérieurement",duration: Duration(seconds: 3));
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future activerStock(String id) async {
    final response = await http.put(Uri.parse('$baseUrl/activer/$id'));

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      applyChange();
    } else {
      // Get.snackbar("Erreur", "Une erreur s'est produite veuiller réessayer ultérieurement",duration: Duration(seconds: 3));
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future desactiverStock(String id) async {
    final response = await http.put(Uri.parse('$baseUrl/desactiver/$id'));

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      applyChange();
    } else {
      // Get.snackbar("Erreur", "Une erreur s'est produite veuiller réessayer ultérieurement",duration: Duration(seconds: 3));
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  void applyChange() {
    notifyListeners();
  }
}

class StockController extends GetxController {
  List<Stock> stockListn = [];
  List<Stock> stockList1 = [];
  List<Stock> stockList2 = [];
  var isLoadingn = true.obs;
  var isLoading1 = true.obs;
  var isLoading2 = true.obs;

  void clearstockListn() {
    stockListn.clear();
  }

  void clearstockList1() {
    stockList1.clear();
  }
}
