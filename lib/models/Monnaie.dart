import 'dart:convert';

class Monnaie {
  String? idMonnaie;
  String? codeMonnaie;
  String? libelle;
  String? sigle;
  String? dateAjout;
  String? dateModif;
  bool? statut;
  Monnaie({
     this.idMonnaie,
     this.codeMonnaie,
     this.libelle,
     this.sigle,
     this.dateAjout,
     this.dateModif,
     this.statut,
  });

  Monnaie copyWith({
    String? idMonnaie,
    String? codeMonnaie,
    String? libelle,
    String? sigle,
    String? dateAjout,
    String? dateModif,
    bool? statut,
  }) {
    return Monnaie(
      idMonnaie: idMonnaie ?? this.idMonnaie,
      codeMonnaie: codeMonnaie ?? this.codeMonnaie,
      libelle: libelle ?? this.libelle,
      sigle: sigle ?? this.sigle,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      statut: statut ?? this.statut,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idMonnaie': idMonnaie,
      'codeMonnaie': codeMonnaie,
      'libelle': libelle,
      'sigle': sigle,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statut': statut,
    };
  }

  factory Monnaie.fromMap(Map<String, dynamic> map) {
    return Monnaie(
      idMonnaie: map['idMonnaie'] as String,
      codeMonnaie: map['codeMonnaie'] as String,
      libelle: map['libelle'] as String,
      sigle: map['sigle'] as String,
       dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      statut: map['statut'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Monnaie.fromJson(String source) => Monnaie.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Monnaie(idMonnaie: $idMonnaie, codeMonnaie: $codeMonnaie, libelle: $libelle, sigle: $sigle, dateAjout: $dateAjout, dateModif: $dateModif, statut: $statut)';
  }

  @override
  bool operator ==(covariant Monnaie other) {
    if (identical(this, other)) return true;
  
    return 
      other.idMonnaie == idMonnaie &&
      other.codeMonnaie == codeMonnaie &&
      other.libelle == libelle &&
      other.sigle == sigle &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.statut == statut;
  }

  @override
  int get hashCode {
    return idMonnaie.hashCode ^
      codeMonnaie.hashCode ^
      libelle.hashCode ^
      sigle.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      statut.hashCode;
  }
}
