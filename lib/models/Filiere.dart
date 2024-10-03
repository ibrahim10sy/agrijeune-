import 'dart:convert';


class Filiere {
  final String? idFiliere;
  final String? codeFiliere;
  final String? libelleFiliere;
  final String? descriptionFiliere;
  final bool? statutFiliere;
  final String? dateAjout;
  final String? personneModif;
  final String? dateModif;
  Filiere({
    this.idFiliere,
    this.codeFiliere,
    this.libelleFiliere,
    this.descriptionFiliere,
    this.statutFiliere,
    this.dateAjout,
    this.personneModif,
    this.dateModif,
  });
 

  Filiere copyWith({
    String? idFiliere,
    String? codeFiliere,
    String? libelleFiliere,
    String? descriptionFiliere,
    bool? statutFiliere,
    String? dateAjout,
    String? personneModif,
    String? dateModif,
  }) {
    return Filiere(
      idFiliere: idFiliere ?? this.idFiliere,
      codeFiliere: codeFiliere ?? this.codeFiliere,
      libelleFiliere: libelleFiliere ?? this.libelleFiliere,
      descriptionFiliere: descriptionFiliere ?? this.descriptionFiliere,
      statutFiliere: statutFiliere ?? this.statutFiliere,
      dateAjout: dateAjout ?? this.dateAjout,
      personneModif: personneModif ?? this.personneModif,
      dateModif: dateModif ?? this.dateModif,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idFiliere': idFiliere,
      'codeFiliere': codeFiliere,
      'libelleFiliere': libelleFiliere,
      'descriptionFiliere': descriptionFiliere,
      'statutFiliere': statutFiliere,
      'dateAjout': dateAjout,
      'personneModif': personneModif,
      'dateModif': dateModif,
    };
  }

  factory Filiere.fromMap(Map<String, dynamic> map) {
    return Filiere(
      idFiliere: map['idFiliere'] != null ? map['idFiliere'] as String : null,
      codeFiliere: map['codeFiliere'] != null ? map['codeFiliere'] as String : null,
      libelleFiliere: map['libelleFiliere'] != null ? map['libelleFiliere'] as String : null,
      descriptionFiliere: map['descriptionFiliere'] != null ? map['descriptionFiliere'] as String : null,
      statutFiliere: map['statutFiliere'] != null ? map['statutFiliere'] as bool : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Filiere.fromJson(String source) => Filiere.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Filiere(idFiliere: $idFiliere, codeFiliere: $codeFiliere, libelleFiliere: $libelleFiliere, descriptionFiliere: $descriptionFiliere, statutFiliere: $statutFiliere, dateAjout: $dateAjout, personneModif: $personneModif, dateModif: $dateModif)';
  }

  @override
  bool operator ==(covariant Filiere other) {
    if (identical(this, other)) return true;
  
    return 
      other.idFiliere == idFiliere &&
      other.codeFiliere == codeFiliere &&
      other.libelleFiliere == libelleFiliere &&
      other.descriptionFiliere == descriptionFiliere &&
      other.statutFiliere == statutFiliere &&
      other.dateAjout == dateAjout &&
      other.personneModif == personneModif &&
      other.dateModif == dateModif;
  }

  @override
  int get hashCode {
    return idFiliere.hashCode ^
      codeFiliere.hashCode ^
      libelleFiliere.hashCode ^
      descriptionFiliere.hashCode ^
      statutFiliere.hashCode ^
      dateAjout.hashCode ^
      personneModif.hashCode ^
      dateModif.hashCode;
  }
}
