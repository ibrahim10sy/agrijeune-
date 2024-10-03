import 'dart:convert';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Magasin.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/Unite.dart';
import 'package:koumi/models/ZoneProduction.dart';


class Stock {
  String? idStock;
   String? codeStock;
   String? nomProduit;
   String? formeProduit;
   String? origineProduit;
   String? dateProduction;
   double? quantiteStock;
   int? prix;
   int? nbreView;
   String? typeProduit;
   String? descriptionStock;
   String? photo;
   ZoneProduction? zoneProduction;
   String? dateAjout;
  String? dateModif;
   String? personneModif;
   String? pays;
   bool? statutSotck;
   Speculation? speculation;
   Unite? unite;
   Magasin? magasin;
   Acteur? acteur;
   Monnaie? monnaie;

  Stock({
    this.idStock,
    this.codeStock,
     this.nomProduit,
     this.formeProduit,
     this.origineProduit,
    this.dateProduction,
     this.quantiteStock,
     this.prix,
     this.nbreView,
     this.typeProduit,
     this.descriptionStock,
    this.photo,
     this.zoneProduction,
    this.dateAjout,
    this.dateModif,
    this.personneModif,
    this.pays,
     this.statutSotck,
     this.speculation,
     this.unite,
     this.magasin,
     this.acteur,
     this.monnaie
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idStock': idStock,
      'codeStock': codeStock,
      'nomProduit': nomProduit,
      'formeProduit': formeProduit,
      'origineProduit': origineProduit,
      'dateProduction': dateProduction,
      'quantiteStock': quantiteStock,
      'prix': prix,
      'nbreView': nbreView,
      'typeProduit': typeProduit,
      'descriptionStock': descriptionStock,
      'photo': photo,
      'zoneProduction': zoneProduction?.toMap(),
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'personneModif': personneModif,
      'pays': pays,
      'statutSotck': statutSotck,
      'speculation': speculation?.toMap(),
      'unite': unite?.toMap(),
      'magasin': magasin?.toMap(),
      'acteur': acteur?.toMap(),
      'monnaie' : monnaie?.toMap(),
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
  return Stock(
    idStock: map['idStock'] ,
    codeStock: map['codeStock'] ,
    nomProduit: map['nomProduit'] ,
    formeProduit: map['formeProduit'] ,
    origineProduit: map['origineProduit'] ,
    dateProduction: map['dateProduction'] ,
    quantiteStock: (map['quantiteStock'] as num).toDouble(),
    prix: (map['prix'] as num).toInt(),
    nbreView: (map['nbreView'] as num).toInt(),
    typeProduit: map['typeProduit'] ,
    descriptionStock: map['descriptionStock'] ,
    photo: map['photo'] ,
    zoneProduction: map['zoneProduction'] != null
        ? ZoneProduction.fromMap(map['zoneProduction'] as Map<String, dynamic>)
        : ZoneProduction(), // Create an empty ZoneProduction if null
    dateAjout: map['dateAjout'] ,
    dateModif: map['dateModif'] ,
    personneModif: map['personneModif'] ,
    pays: map['pays'] ,
    statutSotck: map['statutSotck'] as bool? ?? false,
    speculation: map['speculation'] != null
        ? Speculation.fromMap(map['speculation'] as Map<String, dynamic>)
        : Speculation(), // Create an empty Speculation if null
    unite: map['unite'] != null
        ? Unite.fromMap(map['unite'] as Map<String, dynamic>)
        : Unite(), // Create an empty Unite if null
    magasin: map['magasin'] != null
        ? Magasin.fromMap(map['magasin'] as Map<String, dynamic>)
        : Magasin(), // Create an empty Magasin if null
    acteur: map['acteur'] != null
        ? Acteur.fromMap(map['acteur'] as Map<String, dynamic>)
        : Acteur(),
    monnaie: map['monnaie'] != null
        ? Monnaie.fromMap(map['monnaie'] as Map<String, dynamic>)
        : Monnaie(),
  
  );
}



  String toJson() => json.encode(toMap());

  factory Stock.fromJson(String source) => Stock.fromMap(json.decode(source) as Map<String, dynamic>);



  
}