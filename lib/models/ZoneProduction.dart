import 'dart:convert';

import 'package:koumi/models/Acteur.dart';


class ZoneProduction {
  String? idZoneProduction;
  final String? codeZone;
   String? nomZoneProduction;
  String? personneModif;
  String? latitude;
  String? longitude;
  String? photoZone;
  String? dateAjout;
  String? dateModif;
  final bool? statutZone;
  final Acteur? acteur;
  
  ZoneProduction({
    this.idZoneProduction,
    this.codeZone,
     this.nomZoneProduction,
    this.personneModif,
    this.latitude,
    this.longitude,
    this.photoZone,
    this.dateAjout,
    this.dateModif,
     this.statutZone,
    this.acteur,
  });

 

  ZoneProduction copyWith({
    String? idZoneProduction,
    String? codeZone,
    String? nomZoneProduction,
    String? personneModif,
    String? latitude,
    String? longitude,
    String? photoZone,
    String? dateAjout,
    String? dateModif,
    bool? statutZone,
    Acteur? acteur,
  }) {
    return ZoneProduction(
      idZoneProduction: idZoneProduction ?? this.idZoneProduction,
      codeZone: codeZone ?? this.codeZone,
      nomZoneProduction: nomZoneProduction ?? this.nomZoneProduction,
      personneModif: personneModif ?? this.personneModif,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoZone: photoZone ?? this.photoZone,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      statutZone: statutZone ?? this.statutZone,
      acteur: acteur ?? this.acteur,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idZoneProduction': idZoneProduction,
      'codeZone': codeZone,
      'nomZoneProduction': nomZoneProduction,
      'personneModif': personneModif,
      'latitude': latitude,
      'longitude': longitude,
      'photoZone': photoZone,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statutZone': statutZone,
      'acteur': acteur?.toMap(),
    };
  }

  factory ZoneProduction.fromMap(Map<String, dynamic> map) {
    return ZoneProduction(
      idZoneProduction: map['idZoneProduction'] != null ? map['idZoneProduction'] as String : null,
      codeZone: map['codeZone'] != null ? map['codeZone'] as String : null,
      nomZoneProduction: map['nomZoneProduction'] as String,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      latitude: map['latitude'] != null ? map['latitude'] as String : null,
      longitude: map['longitude'] != null ? map['longitude'] as String : null,
      photoZone: map['photoZone'] != null ? map['photoZone'] as String : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      statutZone: map['statutZone'] as bool,
      acteur: map['acteur'] != null ? Acteur.fromMap(map['acteur'] as Map<String,dynamic>) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ZoneProduction.fromJson(String source) => ZoneProduction.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ZoneProduction(idZoneProduction: $idZoneProduction, codeZone: $codeZone, nomZoneProduction: $nomZoneProduction, personneModif: $personneModif, latitude: $latitude, longitude: $longitude, photoZone: $photoZone, dateAjout: $dateAjout, dateModif: $dateModif, statutZone: $statutZone, acteur: $acteur)';
  }

  @override
  bool operator ==(covariant ZoneProduction other) {
    if (identical(this, other)) return true;
  
    return 
      other.idZoneProduction == idZoneProduction &&
      other.codeZone == codeZone &&
      other.nomZoneProduction == nomZoneProduction &&
      other.personneModif == personneModif &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.photoZone == photoZone &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.statutZone == statutZone &&
      other.acteur == acteur;
  }

  @override
  int get hashCode {
    return idZoneProduction.hashCode ^
      codeZone.hashCode ^
      nomZoneProduction.hashCode ^
      personneModif.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      photoZone.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      statutZone.hashCode ^
      acteur.hashCode;
  }
}
