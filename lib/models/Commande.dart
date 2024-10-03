
import 'package:koumi/models/Acteur.dart';

class Commande {
    String? idCommande;
    String? codeCommande;
    String? descriptionCommande;
    bool? statutCommande;
    bool? statutCommandeLivrer;
    bool? statutConfirmation;
    String? dateCommande;
    double? quantiteDemande;
    String? nomProduit;
    String? codeAcheteur;
    String? dateModif;
    Acteur? acteur;
    Acteur? acteurProprietaire;
    String? personneModif;

    Commande({
         this.idCommande,
         this.codeCommande,
         this.descriptionCommande,
         this.statutCommande,
         this.statutCommandeLivrer,
         this.statutConfirmation,
         this.dateCommande,
         this.quantiteDemande,
         this.nomProduit,
         this.codeAcheteur,
         this.dateModif,
         this.acteur,
         this.acteurProprietaire,
         this.personneModif,
    });

    factory Commande.fromJson(Map<String, dynamic> json) => Commande(
        idCommande: json["idCommande"],
        codeCommande: json["codeCommande"],
        descriptionCommande: json["descriptionCommande"],
        statutCommande: json["statutCommande"],
        statutCommandeLivrer: json["statutCommandeLivrer"],
        statutConfirmation: json["statutConfirmation"],
        dateCommande: json["dateCommande"],
        quantiteDemande: json["quantiteDemande"],
        nomProduit: json["nomProduit"],
        codeAcheteur: json["codeAcheteur"],
        dateModif: json["dateModif"],
        acteur: Acteur.fromJson(json["acteur"]),
        acteurProprietaire: Acteur.fromJson(json["acteurProprietaire"]),
        personneModif: json["personneModif"],
    );

    Map<String, dynamic> toJson() => {
        "idCommande": idCommande,
        "codeCommande": codeCommande,
        "descriptionCommande": descriptionCommande,
        "statutCommande": statutCommande,
        "statutCommandeLivrer": statutCommandeLivrer,
        "statutConfirmation": statutConfirmation,
        "dateCommande": dateCommande,
        "quantiteDemande": quantiteDemande,
        "nomProduit": nomProduit,
        "codeAcheteur": codeAcheteur,
        "dateModif": dateModif,
        "acteur": acteur?.toJson(),
        "acteurProprietaire": acteurProprietaire?.toJson(),
        "personneModif": personneModif,
    };

  Commande copyWith({
    String? idCommande,
    String? codeCommande,
    String? descriptionCommande,
    bool? statutCommande,
    bool? statutCommandeLivrer,
    bool? statutConfirmation,
    String? dateCommande,
    double? quantiteDemande,
    String? nomProduit,
    String? codeAcheteur,
    String? dateModif,
    Acteur? acteur,
    Acteur? acteurProprietaire,
    String? personneModif,
  }) {
    return Commande(
      idCommande: idCommande ?? this.idCommande,
      codeCommande: codeCommande ?? this.codeCommande,
      descriptionCommande: descriptionCommande ?? this.descriptionCommande,
      statutCommande: statutCommande ?? this.statutCommande,
      statutCommandeLivrer: statutCommandeLivrer ?? this.statutCommandeLivrer,
      statutConfirmation: statutConfirmation ?? this.statutConfirmation,
      dateCommande: dateCommande ?? this.dateCommande,
      quantiteDemande: quantiteDemande ?? this.quantiteDemande,
      nomProduit: nomProduit ?? this.nomProduit,
      codeAcheteur: codeAcheteur ?? this.codeAcheteur,
      dateModif: dateModif ?? this.dateModif,
      acteur: acteur ?? this.acteur,
      acteurProprietaire: acteurProprietaire ?? this.acteurProprietaire,
      personneModif: personneModif ?? this.personneModif,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idCommande': idCommande,
      'codeCommande': codeCommande,
      'descriptionCommande': descriptionCommande,
      'statutCommande': statutCommande,
      'statutCommandeLivrer': statutCommandeLivrer,
      'statutConfirmation': statutConfirmation,
      'dateCommande': dateCommande,
      'quantiteDemande': quantiteDemande,
      'nomProduit': nomProduit,
      'codeAcheteur': codeAcheteur,
      'dateModif': dateModif,
      'acteur': acteur?.toMap(),
      'acteurProprietaire': acteurProprietaire?.toMap(),
      'personneModif': personneModif,
    };
  }

  factory Commande.fromMap(Map<String, dynamic> map) {
    return Commande(
      idCommande: map['idCommande'] != null ? map['idCommande'] as String : null,
      codeCommande: map['codeCommande'] != null ? map['codeCommande'] as String : null,
      descriptionCommande: map['descriptionCommande'] != null ? map['descriptionCommande'] as String : null,
      statutCommande: map['statutCommande'] != null ? map['statutCommande'] as bool : null,
      statutCommandeLivrer: map['statutCommandeLivrer'] != null ? map['statutCommandeLivrer'] as bool : null,
      statutConfirmation: map['statutConfirmation'] != null ? map['statutConfirmation'] as bool : null,
      dateCommande: map['dateCommande'] != null ? map['dateCommande'] as String : null,
      quantiteDemande: map['quantiteDemande'] != null ? map['quantiteDemande'] as double : null,
      nomProduit: map['nomProduit'] != null ? map['nomProduit'] as String : null,
      codeAcheteur: map['codeAcheteur'] != null ? map['codeAcheteur'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      acteur: map['acteur'] != null ? Acteur.fromMap(map['acteur'] as Map<String,dynamic>) : null,
      acteurProprietaire: map['acteurProprietaire'] != null ? Acteur.fromMap(map['acteurProprietaire'] as Map<String,dynamic>) : null,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
    );
  }

  // String toJson() => json.encode(toMap());

  // factory Commande.fromJson(String source) => Commande.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Commande(idCommande: $idCommande, codeCommande: $codeCommande, descriptionCommande: $descriptionCommande, statutCommande: $statutCommande, statutCommandeLivrer: $statutCommandeLivrer, statutConfirmation: $statutConfirmation, dateCommande: $dateCommande, quantiteDemande: $quantiteDemande, nomProduit: $nomProduit, codeAcheteur: $codeAcheteur, dateModif: $dateModif, acteur: $acteur, acteurProprietaire: $acteurProprietaire, personneModif: $personneModif)';
  }

  @override
  bool operator ==(covariant Commande other) {
    if (identical(this, other)) return true;
  
    return 
      other.idCommande == idCommande &&
      other.codeCommande == codeCommande &&
      other.descriptionCommande == descriptionCommande &&
      other.statutCommande == statutCommande &&
      other.statutCommandeLivrer == statutCommandeLivrer &&
      other.statutConfirmation == statutConfirmation &&
      other.dateCommande == dateCommande &&
      other.quantiteDemande == quantiteDemande &&
      other.nomProduit == nomProduit &&
      other.codeAcheteur == codeAcheteur &&
      other.dateModif == dateModif &&
      other.acteur == acteur &&
      other.acteurProprietaire == acteurProprietaire &&
      other.personneModif == personneModif;
  }

  @override
  int get hashCode {
    return idCommande.hashCode ^
      codeCommande.hashCode ^
      descriptionCommande.hashCode ^
      statutCommande.hashCode ^
      statutCommandeLivrer.hashCode ^
      statutConfirmation.hashCode ^
      dateCommande.hashCode ^
      quantiteDemande.hashCode ^
      nomProduit.hashCode ^
      codeAcheteur.hashCode ^
      dateModif.hashCode ^
      acteur.hashCode ^
      acteurProprietaire.hashCode ^
      personneModif.hashCode;
  }
}



 

  


  // String toJson() => json.encode(toMap());


