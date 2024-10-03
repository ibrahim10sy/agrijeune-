// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Forme {
  String? idForme;
  String? codeForme;
  String? libelleForme;
  String? descriptionForme;
  bool? statutForme;
  String? dateAjout;
  Forme({
    this.idForme,
    this.codeForme,
    this.libelleForme,
    this.descriptionForme,
    this.statutForme,
    this.dateAjout,
  });

  Forme copyWith({
    String? idForme,
    String? codeForme,
    String? libelleForme,
    String? descriptionForme,
    bool? statutForme,
    String? dateAjout,
  }) {
    return Forme(
      idForme: idForme ?? this.idForme,
      codeForme: codeForme ?? this.codeForme,
      libelleForme: libelleForme ?? this.libelleForme,
      descriptionForme: descriptionForme ?? this.descriptionForme,
      statutForme: statutForme ?? this.statutForme,
      dateAjout: dateAjout ?? this.dateAjout,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idForme': idForme,
      'codeForme': codeForme,
      'libelleForme': libelleForme,
      'descriptionForme': descriptionForme,
      'statutForme': statutForme,
      'dateAjout': dateAjout,
    };
  }

  factory Forme.fromMap(Map<String, dynamic> map) {
    return Forme(
      idForme: map['idForme'] != null ? map['idForme'] as String : null,
      codeForme: map['codeForme'] != null ? map['codeForme'] as String : null,
      libelleForme: map['libelleForme'] != null ? map['libelleForme'] as String : null,
      descriptionForme: map['descriptionForme'] != null ? map['descriptionForme'] as String : null,
      statutForme: map['statutForme'] != null ? map['statutForme'] as bool : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Forme.fromJson(String source) => Forme.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Forme(idForme: $idForme, codeForme: $codeForme, libelleForme: $libelleForme, descriptionForme: $descriptionForme, statutForme: $statutForme, dateAjout: $dateAjout)';
  }

  @override
  bool operator ==(covariant Forme other) {
    if (identical(this, other)) return true;
  
    return 
      other.idForme == idForme &&
      other.codeForme == codeForme &&
      other.libelleForme == libelleForme &&
      other.descriptionForme == descriptionForme &&
      other.statutForme == statutForme &&
      other.dateAjout == dateAjout;
  }

  @override
  int get hashCode {
    return idForme.hashCode ^
      codeForme.hashCode ^
      libelleForme.hashCode ^
      descriptionForme.hashCode ^
      statutForme.hashCode ^
      dateAjout.hashCode;
  }
}
