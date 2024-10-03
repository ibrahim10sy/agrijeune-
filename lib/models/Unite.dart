import 'dart:convert';

import 'package:koumi/models/Acteur.dart';

class Unite {
   String? idUnite;
  final String? codeUnite;
   String? nomUnite;
  final String? sigleUnite;
  final String? description;
   String? dateAjout;
   String? dateModif;
  final bool?  statutUnite;
   String? personneModif;
   Acteur? acteur;
  Unite({
    this.idUnite,
    this.codeUnite,
     this.nomUnite,
     this.sigleUnite,
     this.description,
    this.dateAjout,
    this.dateModif,
     this.statutUnite,
    this.personneModif,
     this.acteur,
  });
 

  Unite copyWith({
    String? idUnite,
    String? codeUnite,
    String? nomUnite,
    String? sigleUnite,
    String? description,
    String? dateAjout,
    String? dateModif,
    bool? statutUnite,
    String? personneModif,
    Acteur? acteur,
  }) {
    return Unite(
      idUnite: idUnite ?? this.idUnite,
      codeUnite: codeUnite ?? this.codeUnite,
      nomUnite: nomUnite ?? this.nomUnite,
      sigleUnite: sigleUnite ?? this.sigleUnite,
      description: description ?? this.description,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      statutUnite: statutUnite ?? this.statutUnite,
      personneModif: personneModif ?? this.personneModif,
      acteur: acteur ?? this.acteur,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idUnite': idUnite,
      'codeUnite': codeUnite,
      'nomUnite': nomUnite,
      'sigleUnite': sigleUnite,
      'description': description,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statutUnite': statutUnite,
      'personneModif': personneModif,
      'acteur': acteur?.toMap(),
    };
  }

factory Unite.fromMap(Map<String, dynamic> map) {
  return Unite(
    idUnite: map['idUnite'] != null ? map['idUnite'] as String : null,
    codeUnite: map['codeUnite'] != null ? map['codeUnite'] as String : null,
    nomUnite: map['nomUnite'] as String,
    sigleUnite: map['sigleUnite'] as String,
    description: map['description'] as String,
    dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
    dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
    statutUnite: map['statutUnite'] as bool,
    personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
    acteur: map['acteur'] != null ? Acteur.fromMap(map['acteur'] as Map<String,dynamic>) : null,
  );
}


  // String toJson() => json.encode(toMap());
   Map<String, dynamic> toJson() => {
        "idUnite": idUnite,
        "codeUnite": codeUnite,
        "nomUnite": nomUnite,
        "sigleUnite": sigleUnite,
        "description": description,
        "dateAjout": dateAjout,
        "dateModif": dateModif,
        "statutUnite": statutUnite,
        "personneModif": personneModif,
        "acteur": acteur?.toJson(),
    };

  factory Unite.fromJson(String source) => Unite.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Unite(idUnite: $idUnite, codeUnite: $codeUnite, nomUnite: $nomUnite, sigleUnite: $sigleUnite, description: $description, dateAjout: $dateAjout, dateModif: $dateModif, statutUnite: $statutUnite, personneModif: $personneModif, acteur: $acteur)';
  }

  @override
  bool operator ==(covariant Unite other) {
    if (identical(this, other)) return true;
  
    return 
      other.idUnite == idUnite &&
      other.codeUnite == codeUnite &&
      other.nomUnite == nomUnite &&
      other.sigleUnite == sigleUnite &&
      other.description == description &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.statutUnite == statutUnite &&
      other.personneModif == personneModif &&
      other.acteur == acteur;
  }

  @override
  int get hashCode {
    return idUnite.hashCode ^
      codeUnite.hashCode ^
      nomUnite.hashCode ^
      sigleUnite.hashCode ^
      description.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      statutUnite.hashCode ^
      personneModif.hashCode ^
      acteur.hashCode;
  }
}
