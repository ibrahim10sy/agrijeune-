import 'dart:convert';

import 'package:koumi/models/Monnaie.dart';


class Device {
  String? idDevice;
  String? codeDevice;
  String? nomDevice;
  String? sigle;
  double? taux;
  String? dateAjout;
  String? dateModif;
  bool? statut;
  Monnaie? monnaie;
  Device({
    this.idDevice,
    this.codeDevice,
    this.nomDevice,
    this.sigle,
    this.taux,
    this.dateAjout,
    this.dateModif,
    this.statut,
    this.monnaie,
  });

  Device copyWith({
    String? idDevice,
    String? codeDevice,
    String? nomDevice,
    String? sigle,
    double? taux,
    String? dateAjout,
    String? dateModif,
    bool? statut,
    Monnaie? monnaie,
  }) {
    return Device(
      idDevice: idDevice ?? this.idDevice,
      codeDevice: codeDevice ?? this.codeDevice,
      nomDevice: nomDevice ?? this.nomDevice,
      sigle: sigle ?? this.sigle,
      taux: taux ?? this.taux,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      statut: statut ?? this.statut,
      monnaie: monnaie ?? this.monnaie,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idDevice': idDevice,
      'codeDevice': codeDevice,
      'nomDevice': nomDevice,
      'sigle': sigle,
      'taux': taux,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statut': statut,
      'monnaie': monnaie?.toMap(),
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      idDevice: map['idDevice'] != null ? map['idDevice'] as String : null,
      codeDevice: map['codeDevice'] != null ? map['codeDevice'] as String : null,
      nomDevice: map['nomDevice'] != null ? map['nomDevice'] as String : null,
      sigle: map['sigle'] != null ? map['sigle'] as String : null,
      taux: map['taux'] != null ? map['taux'] as double : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      statut: map['statut'] != null ? map['statut'] as bool : null,
       monnaie: map['monnaie'] != null
            ? Monnaie.fromMap(map['monnaie'] as Map<String, dynamic>)
            : null
    );
  }

  String toJson() => json.encode(toMap());

  factory Device.fromJson(String source) => Device.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Device(idDevice: $idDevice, codeDevice: $codeDevice, nomDevice: $nomDevice, sigle: $sigle, taux: $taux, dateAjout: $dateAjout, dateModif: $dateModif, statut: $statut, monnaie: $monnaie)';
  }

  @override
  bool operator ==(covariant Device other) {
    if (identical(this, other)) return true;
  
    return 
      other.idDevice == idDevice &&
      other.codeDevice == codeDevice &&
      other.nomDevice == nomDevice &&
      other.sigle == sigle &&
      other.taux == taux &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.statut == statut &&
      other.monnaie == monnaie;
  }

  @override
  int get hashCode {
    return idDevice.hashCode ^
      codeDevice.hashCode ^
      nomDevice.hashCode ^
      sigle.hashCode ^
      taux.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      statut.hashCode ^
      monnaie.hashCode;
  }
}
