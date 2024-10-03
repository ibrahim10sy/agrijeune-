// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Commande.dart';
import 'package:koumi/models/Intrant.dart';
import 'package:koumi/models/Stock.dart';


class CommandeAvecStocks {
  Commande? commande;
  Acteur? acteur;
  List<Stock>? stocks;
  List<Intrant>? intrants;
  List<double>? quantitesDemandees;
  List<double>? quantitesIntrants;


  CommandeAvecStocks({
     this.commande,
     this.acteur,
     this.stocks,
     this.intrants,
     this.quantitesDemandees,
     this.quantitesIntrants,
  });


  // CommandeAvecStocks copyWith({
  //   Commande? commande,
  //   List<Stock>? stocks,
  //   List<double>? quantitesDemandees,
  // }) {
  //   return CommandeAvecStocks(
  //     commande: commande ?? this.commande,
  //     stocks: stocks ?? this.stocks,
  //     quantitesDemandees: quantitesDemandees ?? this.quantitesDemandees,
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      'commande': commande?.toMap(),
      'acteur': acteur?.toMap(),
      'stocks': stocks?.map((stock) => stock.toMap()).toList(),
      'intrants': intrants?.map((intrant) => intrant.toMap()).toList(),
      'quantitesDemandees': quantitesDemandees,
      'quantitesIntrants': quantitesIntrants,
    };
  }

  
  factory CommandeAvecStocks.fromMap(Map<String, dynamic> map) {
    return CommandeAvecStocks(
      commande: map['commande'] != null ? Commande.fromMap(map['commande'] as Map<String,dynamic>) : null,
      acteur: map['acteur'] != null ? Acteur.fromMap(map['acteur'] as Map<String,dynamic>) : null,
      stocks: List<Stock>.from((map['stocks'] as List<int>).map<Stock>((x) => Stock.fromMap(x as Map<String,dynamic>),),),
      intrants: List<Intrant>.from((map['intrants'] as List<int>).map<Intrant>((x) => Intrant.fromMap(x as Map<String,dynamic>),),),
      quantitesDemandees: List<double>.from((map['quantitesDemandees'] as List<double>),),
      quantitesIntrants: List<double>.from((map['quantitesIntrants'] as List<double>),)
    );
  }


  factory CommandeAvecStocks.fromJson(String source) => CommandeAvecStocks.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CommandeAvecStocks(commande: $commande,acteur:$acteur ,stocks: $stocks,intrants: $intrants ,quantitesDemandees: $quantitesDemandees, quantitesIntrants: $quantitesIntrants)';

  @override
  bool operator ==(covariant CommandeAvecStocks other) {
    if (identical(this, other)) return true;
  
    return 
      other.commande == commande &&
      other.acteur == acteur &&
      listEquals(other.stocks, stocks) &&
      listEquals(other.intrants, intrants) &&
      listEquals(other.quantitesDemandees, quantitesDemandees)&&
      listEquals(other.quantitesIntrants, quantitesIntrants);
  }

  @override
  int get hashCode => commande.hashCode ^ commande.hashCode ^ stocks.hashCode ^ intrants.hashCode ^ quantitesDemandees.hashCode ^ quantitesIntrants.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'commande': commande?.toMap(),
      'acteur': acteur?.toMap(),
      'stocks': stocks?.map((x) => x.toMap()).toList(),
      'intrants': intrants?.map((x) => x.toMap()).toList(),
      'quantitesDemandees': quantitesDemandees,
      'quantitesIntrants': quantitesIntrants,
    };
  }

 }
