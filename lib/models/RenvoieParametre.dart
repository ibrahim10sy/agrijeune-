import 'dart:convert';

import 'package:koumi/models/ParametreFiche.dart';


class RenvoieParametre {
  final String? idRenvoiParametre;
  final String conditionRenvoi;
  final String? dateAjout;
  final String? dateModif;
  final String personneAjout;
  final String valeurConditionRenvoi;
  final String descriptionRenvoie;
  final bool statutRenvoie;
  final ParametreFiche parametreFiche;

  RenvoieParametre({
    this.idRenvoiParametre,
    required this.conditionRenvoi,
    this.dateAjout,
    this.dateModif,
    required this.personneAjout,
    required this.valeurConditionRenvoi,
    required this.descriptionRenvoie,
    required this.statutRenvoie,
    required this.parametreFiche,
  });

 

  RenvoieParametre copyWith({
    String? idRenvoiParametre,
    String? conditionRenvoi,
    String? dateAjout,
    String? dateModif,
    String? personneAjout,
    String? valeurConditionRenvoi,
    String? descriptionRenvoie,
    bool? statutRenvoie,
    ParametreFiche? parametreFiche,
  }) {
    return RenvoieParametre(
      idRenvoiParametre: idRenvoiParametre ?? this.idRenvoiParametre,
      conditionRenvoi: conditionRenvoi ?? this.conditionRenvoi,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      personneAjout: personneAjout ?? this.personneAjout,
      valeurConditionRenvoi: valeurConditionRenvoi ?? this.valeurConditionRenvoi,
      descriptionRenvoie: descriptionRenvoie ?? this.descriptionRenvoie,
      statutRenvoie: statutRenvoie ?? this.statutRenvoie,
      parametreFiche: parametreFiche ?? this.parametreFiche,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idRenvoiParametre': idRenvoiParametre,
      'conditionRenvoi': conditionRenvoi,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'personneAjout': personneAjout,
      'valeurConditionRenvoi': valeurConditionRenvoi,
      'descriptionRenvoie': descriptionRenvoie,
      'statutRenvoie': statutRenvoie,
      'parametreFiche': parametreFiche.toMap(),
    };
  }

  factory RenvoieParametre.fromMap(Map<String, dynamic> map) {
    return RenvoieParametre(
      idRenvoiParametre: map['idRenvoiParametre'] != null ? map['idRenvoiParametre'] as String : null,
      conditionRenvoi: map['conditionRenvoi'] as String,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      personneAjout: map['personneAjout'] as String,
      valeurConditionRenvoi: map['valeurConditionRenvoi'] as String,
      descriptionRenvoie: map['descriptionRenvoie'] as String,
      statutRenvoie: map['statutRenvoie'] as bool,
      parametreFiche: ParametreFiche.fromMap(map['parametreFiche'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory RenvoieParametre.fromJson(String source) => RenvoieParametre.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RenvoieParametre(idRenvoiParametre: $idRenvoiParametre, conditionRenvoi: $conditionRenvoi, dateAjout: $dateAjout, dateModif: $dateModif, personneAjout: $personneAjout, valeurConditionRenvoi: $valeurConditionRenvoi, descriptionRenvoie: $descriptionRenvoie, statutRenvoie: $statutRenvoie, parametreFiche: $parametreFiche)';
  }

  @override
  bool operator ==(covariant RenvoieParametre other) {
    if (identical(this, other)) return true;
  
    return 
      other.idRenvoiParametre == idRenvoiParametre &&
      other.conditionRenvoi == conditionRenvoi &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.personneAjout == personneAjout &&
      other.valeurConditionRenvoi == valeurConditionRenvoi &&
      other.descriptionRenvoie == descriptionRenvoie &&
      other.statutRenvoie == statutRenvoie &&
      other.parametreFiche == parametreFiche;
  }

  @override
  int get hashCode {
    return idRenvoiParametre.hashCode ^
      conditionRenvoi.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      personneAjout.hashCode ^
      valeurConditionRenvoi.hashCode ^
      descriptionRenvoie.hashCode ^
      statutRenvoie.hashCode ^
      parametreFiche.hashCode;
  }
}
