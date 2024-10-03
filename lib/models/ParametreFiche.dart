import 'dart:convert';

import 'package:flutter/foundation.dart';

class ParametreFiche {
    final String idParametreFiche;
    final String classeParametre;
    final String champParametre;
    final String codeParametre;
    final String libelleParametre;
    final String typeDonneeParametre;
    final List<String> listeDonneeParametre;
    final int valeurMax;
    final String? personneModif;
    final int valeurMin;
    final int valeurObligatoire;
    final String? dateAjout;
    final String? dateModif;
    final String critereChampParametre;
    final bool statutParametre;

  ParametreFiche({
    required this.idParametreFiche,
    required this.classeParametre,
    required this.champParametre,
    required this.codeParametre,
    required this.libelleParametre,
    required this.typeDonneeParametre,
    required this.listeDonneeParametre,
    required this.valeurMax,
    this.personneModif,
    required this.valeurMin,
    required this.valeurObligatoire,
    this.dateAjout,
    this.dateModif,
    required this.critereChampParametre,
    required this.statutParametre,
  });

  ParametreFiche copyWith({
    String? idParametreFiche,
    String? classeParametre,
    String? champParametre,
    String? codeParametre,
    String? libelleParametre,
    String? typeDonneeParametre,
    List<String>? listeDonneeParametre,
    int? valeurMax,
    String? personneModif,
    int? valeurMin,
    int? valeurObligatoire,
    String? dateAjout,
    String? dateModif,
    String? critereChampParametre,
    bool? statutParametre,
  }) {
    return ParametreFiche(
      idParametreFiche: idParametreFiche ?? this.idParametreFiche,
      classeParametre: classeParametre ?? this.classeParametre,
      champParametre: champParametre ?? this.champParametre,
      codeParametre: codeParametre ?? this.codeParametre,
      libelleParametre: libelleParametre ?? this.libelleParametre,
      typeDonneeParametre: typeDonneeParametre ?? this.typeDonneeParametre,
      listeDonneeParametre: listeDonneeParametre ?? this.listeDonneeParametre,
      valeurMax: valeurMax ?? this.valeurMax,
      personneModif: personneModif ?? this.personneModif,
      valeurMin: valeurMin ?? this.valeurMin,
      valeurObligatoire: valeurObligatoire ?? this.valeurObligatoire,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      critereChampParametre: critereChampParametre ?? this.critereChampParametre,
      statutParametre: statutParametre ?? this.statutParametre,
    );
  }

factory ParametreFiche.fromJson(Map<String, dynamic> map) {
    return ParametreFiche(
      idParametreFiche: map['idParametreFiche'] ?? '',
      classeParametre: map['classeParametre'] ?? '',
      champParametre: map['champParametre'] ?? '',
      codeParametre: map['codeParametre'] ?? '',
      libelleParametre: map['libelleParametre'] ?? '',
      typeDonneeParametre: map['typeDonneeParametre'] ?? '',
      listeDonneeParametre: map['listeDonneeParametre'] != null
          ? List<String>.from(map['listeDonneeParametre'])
          : [],
      valeurMax: map['valeurMax'] ?? 0,
      personneModif: map['personneModif'],
      valeurMin: map['valeurMin'] ?? 0,
      valeurObligatoire: map['valeurObligatoire'] ?? 0,
      dateAjout: map['dateAjout'],
      dateModif: map['dateModif'],
      critereChampParametre: map['critereChampParametre'] ?? '',
      statutParametre: map['statutParametre'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idParametreFiche': idParametreFiche,
      'classeParametre': classeParametre,
      'champParametre': champParametre,
      'codeParametre': codeParametre,
      'libelleParametre': libelleParametre,
      'typeDonneeParametre': typeDonneeParametre,
      'listeDonneeParametre': listeDonneeParametre.toList(),
      'valeurMax': valeurMax,
      'personneModif': personneModif,
      'valeurMin': valeurMin,
      'valeurObligatoire': valeurObligatoire,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'critereChampParametre': critereChampParametre,
      'statutParametre': statutParametre,
    };
  }

  factory ParametreFiche.fromMap(Map<String, dynamic> map) {
    return ParametreFiche(
      idParametreFiche: map['idParametreFiche'] as String,
      classeParametre: map['classeParametre'] as String,
      champParametre: map['champParametre'] as String,
      codeParametre: map['codeParametre'] as String,
      libelleParametre: map['libelleParametre'] as String,
      typeDonneeParametre: map['typeDonneeParametre'] as String,
      listeDonneeParametre:
          List<String>.from(map['listeDonneeParametre'] as List<String>),
      valeurMax: map['valeurMax'] as int,
      valeurMin: map['valeurMin'] as int,
      valeurObligatoire: map['valeurObligatoire'] as int,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      critereChampParametre: map['critereChampParametre'] as String,
      statutParametre: map['statutParametre'] as bool,
    );
  }

}
