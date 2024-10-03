import 'dart:convert';

class Continent {
  final String? idContinent;
  final String codeContinent;
  final String nomContinent;
  final String descriptionContinent;
  final bool statutContinent;
  final String? dateAjout;
  final String? dateModif;
  
  Continent({
    this.idContinent,
    required this.codeContinent,
    required this.nomContinent,
    required this.descriptionContinent,
    required this.statutContinent,
    this.dateAjout,
    this.dateModif,
  });

  Continent copyWith({
    String? idContinent,
    String? codeContinent,
    String? nomContinent,
    String? descriptionContinent,
    bool? statutContinent,
    String? dateAjout,
    String? dateModif,
  }) {
    return Continent(
      idContinent: idContinent ?? this.idContinent,
      codeContinent: codeContinent ?? this.codeContinent,
      nomContinent: nomContinent ?? this.nomContinent,
      descriptionContinent: descriptionContinent ?? this.descriptionContinent,
      statutContinent: statutContinent ?? this.statutContinent,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idContinent': idContinent,
      'codeContinent': codeContinent,
      'nomContinent': nomContinent,
      'descriptionContinent': descriptionContinent,
      'statutContinent': statutContinent,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
    };
  }

  factory Continent.fromMap(Map<String, dynamic> map) {
    return Continent(
      idContinent: map['idContinent'] != null ? map['idContinent'] as String : null,
      codeContinent: map['codeContinent'] as String,
      nomContinent: map['nomContinent'] as String,
      descriptionContinent: map['descriptionContinent'] as String,
      statutContinent: map['statutContinent'] as bool,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Continent.fromJson(String source) => Continent.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Continent(idContinent: $idContinent, codeContinent: $codeContinent, nomContinent: $nomContinent, descriptionContinent: $descriptionContinent, statutContinent: $statutContinent, dateAjout: $dateAjout, dateModif: $dateModif)';
  }

  @override
  bool operator ==(covariant Continent other) {
    if (identical(this, other)) return true;
  
    return 
      other.idContinent == idContinent &&
      other.codeContinent == codeContinent &&
      other.nomContinent == nomContinent &&
      other.descriptionContinent == descriptionContinent &&
      other.statutContinent == statutContinent &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif;
  }

  @override
  int get hashCode {
    return idContinent.hashCode ^
      codeContinent.hashCode ^
      nomContinent.hashCode ^
      descriptionContinent.hashCode ^
      statutContinent.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode;
  }
}
