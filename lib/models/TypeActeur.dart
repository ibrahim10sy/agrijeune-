import 'dart:convert';

class TypeActeur {
  final String? idTypeActeur;
  final String? libelle;
  final String? codeTypeActeur;
  final bool?    statutTypeActeur;
  final String? descriptionTypeActeur;
  final String? dateAjout;
  final String? dateModif;
  TypeActeur({
    this.idTypeActeur,
     this.libelle,
     this.codeTypeActeur,
     this.statutTypeActeur,
     this.descriptionTypeActeur,
    this.dateAjout,
    this.dateModif,
  });

  TypeActeur copyWith({
    String? idTypeActeur,
    String? libelle,
    String? codeTypeActeur,
    bool? statutTypeActeur,
    String? descriptionTypeActeur,
    String? dateAjout,
    String? dateModif,
  }) {
    return TypeActeur(
      idTypeActeur: idTypeActeur ?? this.idTypeActeur,
      libelle: libelle ?? this.libelle,
      codeTypeActeur: codeTypeActeur ?? this.codeTypeActeur,
      statutTypeActeur: statutTypeActeur ?? this.statutTypeActeur,
      descriptionTypeActeur: descriptionTypeActeur ?? this.descriptionTypeActeur,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idTypeActeur': idTypeActeur,
      'libelle': libelle,
      'codeTypeActeur': codeTypeActeur,
      'statutTypeActeur': statutTypeActeur,
      'descriptionTypeActeur': descriptionTypeActeur,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
    };
  }

  factory TypeActeur.fromMap(Map<String, dynamic> map) {
    return TypeActeur(
      idTypeActeur: map['idTypeActeur'] != null ? map['idTypeActeur'] as String : null,
      libelle: map['libelle'] as String,
      codeTypeActeur: map['codeTypeActeur'] as String,
      statutTypeActeur: map['statutTypeActeur'] as bool,
      descriptionTypeActeur: map['descriptionTypeActeur'] as String,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
    );
  }

  // String toJson() => json.encode(toMap());
  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'codeTypeActeur': codeTypeActeur,
      'statutTypeActeur': statutTypeActeur,
      'descriptionTypeActeur': descriptionTypeActeur,
      // Add other properties if needed
      if (idTypeActeur != null) 'idTypeActeur': idTypeActeur,
      if (dateAjout != null) 'dateAjout': dateAjout,
      if (dateModif != null) 'dateModif': dateModif,
    };
  }

  factory TypeActeur.fromJson(String source) => TypeActeur.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TypeActeur(idTypeActeur: $idTypeActeur, libelle: $libelle, codeTypeActeur: $codeTypeActeur, statutTypeActeur: $statutTypeActeur, descriptionTypeActeur: $descriptionTypeActeur, dateAjout: $dateAjout, dateModif: $dateModif)';
  }

 @override
bool operator ==(covariant TypeActeur other) {
  if (identical(this, other)) return true;

  return 
    other.idTypeActeur == idTypeActeur &&
    other.libelle == libelle &&
    other.codeTypeActeur == codeTypeActeur &&
    other.statutTypeActeur == statutTypeActeur &&
    other.descriptionTypeActeur == descriptionTypeActeur &&
    other.dateAjout == dateAjout &&
    other.dateModif == dateModif;
}


  @override
  int get hashCode {
    return idTypeActeur.hashCode ^
      libelle.hashCode ^
      codeTypeActeur.hashCode ^
      statutTypeActeur.hashCode ^
      descriptionTypeActeur.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode;
  }
}