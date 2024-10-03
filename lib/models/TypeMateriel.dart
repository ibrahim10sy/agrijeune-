import 'dart:convert';

class TypeMateriel {
  final String? idTypeMateriel;
  final String? codeTypeMateriel;
  final String? nom;
  final String? description;
  final String? dateAjout;
  final String? dateModif;
  final bool? statutType;
  
  TypeMateriel({
    this.idTypeMateriel,
    this.codeTypeMateriel,
    this.nom,
    this.description,
    this.dateAjout,
    this.dateModif,
    this.statutType,
  });

  TypeMateriel copyWith({
    String? idTypeMateriel,
    String? codeTypeMateriel,
    String? nom,
    String? description,
    String? dateAjout,
    String? dateModif,
    bool? statutType,
  }) {
    return TypeMateriel(
      idTypeMateriel: idTypeMateriel ?? this.idTypeMateriel,
      codeTypeMateriel: codeTypeMateriel ?? this.codeTypeMateriel,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      statutType: statutType ?? this.statutType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idTypeMateriel': idTypeMateriel,
      'codeTypeMateriel': codeTypeMateriel,
      'nom': nom,
      'description': description,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statutType': statutType,
    };
  }

  factory TypeMateriel.fromMap(Map<String, dynamic> map) {
    return TypeMateriel(
      idTypeMateriel: map['idTypeMateriel'] != null ? map['idTypeMateriel'] as String : null,
      codeTypeMateriel: map['codeTypeMateriel'] != null ? map['codeTypeMateriel'] as String : null,
      nom: map['nom'] != null ? map['nom'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      statutType: map['statutType'] != null ? map['statutType'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TypeMateriel.fromJson(String source) => TypeMateriel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TypeMateriel(idTypeMateriel: $idTypeMateriel, codeTypeMateriel: $codeTypeMateriel, nom: $nom, description: $description, dateAjout: $dateAjout, dateModif: $dateModif, statutType: $statutType)';
  }

  @override
  bool operator ==(covariant TypeMateriel other) {
    if (identical(this, other)) return true;
  
    return 
      other.idTypeMateriel == idTypeMateriel &&
      other.codeTypeMateriel == codeTypeMateriel &&
      other.nom == nom &&
      other.description == description &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.statutType == statutType;
  }

  @override
  int get hashCode {
    return idTypeMateriel.hashCode ^
      codeTypeMateriel.hashCode ^
      nom.hashCode ^
      description.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      statutType.hashCode;
  }
}
