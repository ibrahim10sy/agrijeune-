import 'dart:convert';

import 'package:koumi/models/Commande.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/Intrant.dart';

class DetailCommande {
  String? idDetailCommande;
  String? codeProduit;
  double? quantiteDemande;
  double? quantiteLivree;
  double? quantiteNonLivree;
  String? nomProduit;
  String? description;
  String? dateAjout;
  bool? isStock;
  bool? isDelivered;
  Commande? commande;
  Stock? stock;
  Intrant? intrant;

  DetailCommande({
    this.idDetailCommande,
    this.codeProduit,
    this.quantiteDemande,
    this.quantiteLivree,
    this.quantiteNonLivree,
    this.nomProduit,
    this.description,
    this.dateAjout,
    this.isStock,
    this.isDelivered,
    this.commande,
    this.stock,
    this.intrant,
  });

  DetailCommande copyWith({
    String? idDetailCommande,
    String? codeProduit,
    double? quantiteDemande,
    double? quantiteLivree,
    double? quantiteNonLivree,
    String? nomProduit,
    String? description,
    String? dateAjout,
    bool? isStock,
    bool? isDelivered,
    Commande? commande,
    Stock? stock,
    Intrant? intrant,
  }) {
    return DetailCommande(
      idDetailCommande: idDetailCommande ?? this.idDetailCommande,
      codeProduit: codeProduit ?? this.codeProduit,
      quantiteDemande: quantiteDemande ?? this.quantiteDemande,
      quantiteLivree: quantiteLivree ?? this.quantiteLivree,
      quantiteNonLivree: quantiteNonLivree ?? this.quantiteNonLivree,
      nomProduit: nomProduit ?? this.nomProduit,
      description: description ?? this.description,
      dateAjout: dateAjout ?? this.dateAjout,
      isStock: isStock ?? this.isStock,
      isDelivered: isDelivered ?? this.isDelivered,
      commande: commande ?? this.commande,
      stock: stock ?? this.stock,
      intrant: intrant ?? this.intrant,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idDetailCommande': idDetailCommande,
      'codeProduit': codeProduit,
      'quantiteDemande': quantiteDemande,
      'quantiteLivree': quantiteLivree,
      'quantiteNonLivree': quantiteNonLivree,
      'nomProduit': nomProduit,
      'description': description,
      'dateAjout': dateAjout,
      'isStock': isStock,
      'isDelivered': isDelivered,
      'commande': commande?.toMap(),
      'stock': stock?.toMap(),
      'intrant': intrant?.toMap(),
    };
  }

  factory DetailCommande.fromMap(Map<String, dynamic> map) {
    return DetailCommande(
      idDetailCommande: map['idDetailCommande'] as String?,
      codeProduit: map['codeProduit'] as String?,
      quantiteDemande: map['quantiteDemande'] as double?,
      quantiteLivree: map['quantiteLivree'] as double?,
      quantiteNonLivree: map['quantiteNonLivree'] as double?,
      nomProduit: map['nomProduit'] as String?,
      description: map['description'] as String?,
      dateAjout: map['dateAjout'] as String?,
      isStock: map['isStock'] as bool?,
      isDelivered: map['isDelivered'] as bool?,
      commande: map['commande'] != null ? Commande.fromMap(map['commande'] as Map<String, dynamic>) : null,
      stock: map['stock'] != null ? Stock.fromMap(map['stock'] as Map<String, dynamic>) : null,
      intrant: map['intrant'] != null ? Intrant.fromMap(map['intrant'] as Map<String, dynamic>) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DetailCommande.fromJson(String source) => DetailCommande.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DetailCommande(idDetailCommande: $idDetailCommande, codeProduit: $codeProduit, quantiteDemande: $quantiteDemande, quantiteLivree: $quantiteLivree, quantiteNonLivree: $quantiteNonLivree, nomProduit: $nomProduit, description : $description, dateAjout: $dateAjout, isStock: $isStock, isDelivered: $isDelivered , commande: $commande, stock: $stock, intrant: $intrant)';
  }

  @override
  bool operator ==(covariant DetailCommande other) {
    if (identical(this, other)) return true;

    return 
      other.idDetailCommande == idDetailCommande &&
      other.codeProduit == codeProduit &&
      other.quantiteDemande == quantiteDemande &&
      other.quantiteLivree == quantiteLivree &&
      other.quantiteNonLivree == quantiteNonLivree &&
      other.nomProduit == nomProduit &&
      other.description == description &&
      other.dateAjout == dateAjout &&
      other.isStock == isStock &&
      other.isDelivered == isDelivered &&
      other.commande == commande &&
      other.stock == stock &&
      other.intrant == intrant;
  }

  @override
  int get hashCode {
    return idDetailCommande.hashCode ^
      codeProduit.hashCode ^
      quantiteDemande.hashCode ^
      quantiteLivree.hashCode ^
      quantiteNonLivree.hashCode ^
      nomProduit.hashCode ^
      description.hashCode ^
      dateAjout.hashCode ^
      isStock.hashCode ^
      isDelivered.hashCode ^
      commande.hashCode ^
      stock.hashCode ^
      intrant.hashCode;
  }
}
