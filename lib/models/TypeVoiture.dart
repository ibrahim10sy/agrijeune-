import 'dart:convert';

import 'package:koumi/models/Acteur.dart';


class TypeVoiture {
  final String? idTypeVoiture;
  final String? codeTypeVoiture;
  final String? nom;
  final int? nombreSieges;
  final String? description;
  final String? dateAjout;
  final String? dateModif;
  final bool? statutType;
  final Acteur acteur;
  
  TypeVoiture({
    this.idTypeVoiture,
    this.codeTypeVoiture,
    this.nom,
    this.nombreSieges,
    this.description,
    this.dateAjout,
    this.dateModif,
    this.statutType,
    required this.acteur,
  });

  

  TypeVoiture copyWith({
    String? idTypeVoiture,
    String? codeTypeVoiture,
    String? nom,
    int? nombreSieges,
    String? description,
    String? dateAjout,
    String? dateModif,
    bool? statutType,
    Acteur? acteur,
  }) {
    return TypeVoiture(
      idTypeVoiture: idTypeVoiture ?? this.idTypeVoiture,
      codeTypeVoiture: codeTypeVoiture ?? this.codeTypeVoiture,
      nom: nom ?? this.nom,
      nombreSieges: nombreSieges ?? this.nombreSieges,
      description: description ?? this.description,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      statutType: statutType ?? this.statutType,
      acteur: acteur ?? this.acteur,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idTypeVoiture': idTypeVoiture,
      'codeTypeVoiture': codeTypeVoiture,
      'nom': nom,
      'nombreSieges': nombreSieges,
      'description': description,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statutType': statutType,
      'acteur': acteur.toMap(),
    };
  }

  factory TypeVoiture.fromMap(Map<String, dynamic> map) {
    return TypeVoiture(
      idTypeVoiture: map['idTypeVoiture'] != null ? map['idTypeVoiture'] as String : null,
      codeTypeVoiture: map['codeTypeVoiture'] != null ? map['codeTypeVoiture'] as String : null,
      nom: map['nom'] != null ? map['nom'] as String : null,
      nombreSieges: map['nombreSieges'] != null ? map['nombreSieges'] as int : null,
      description: map['description'] != null ? map['description'] as String : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      statutType: map['statutType'] != null ? map['statutType'] as bool : null,
      acteur: Acteur.fromMap(map['acteur'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory TypeVoiture.fromJson(String source) => TypeVoiture.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TypeVoiture(idTypeVoiture: $idTypeVoiture, codeTypeVoiture: $codeTypeVoiture, nom: $nom, nombreSieges: $nombreSieges, description: $description, dateAjout: $dateAjout, dateModif: $dateModif, statutType: $statutType, acteur: $acteur)';
  }

  @override
  bool operator ==(covariant TypeVoiture other) {
    if (identical(this, other)) return true;
  
    return 
      other.idTypeVoiture == idTypeVoiture &&
      other.codeTypeVoiture == codeTypeVoiture &&
      other.nom == nom &&
      other.nombreSieges == nombreSieges &&
      other.description == description &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.statutType == statutType &&
      other.acteur == acteur;
  }

  @override
  int get hashCode {
    return idTypeVoiture.hashCode ^
      codeTypeVoiture.hashCode ^
      nom.hashCode ^
      nombreSieges.hashCode ^
      description.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      statutType.hashCode ^
      acteur.hashCode;
  }
}
