import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Niveau1Pays.dart';

class Magasin {
  String? idMagasin;
  String? codeMagasin;
  String? nomMagasin;
  String? latitude;
  String? longitude;
  String? localiteMagasin;
  String? contactMagasin;
  String? personneModif;
  bool? statutMagasin;
  String? dateAjout;
  String? dateModif;
  String? photo;
  int? nbreView;
  String? pays;
  Acteur? acteur;
  Niveau1Pays? niveau1Pays;

  Magasin({
    this.idMagasin,
    this.codeMagasin,
    this.nomMagasin,
    this.latitude,
    this.longitude,
    this.localiteMagasin,
    this.contactMagasin,
    this.personneModif,
    this.statutMagasin,
    this.dateAjout,
    this.dateModif,
    this.photo,
    this.nbreView,
    this.pays,
    this.acteur,
    this.niveau1Pays,
  });

  factory Magasin.fromJson(Map<String, dynamic> json) => Magasin(
        idMagasin: json["idMagasin"],
        codeMagasin: json["codeMagasin"],
        nomMagasin: json["nomMagasin"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        localiteMagasin: json["localiteMagasin"],
        contactMagasin: json["contactMagasin"],
        personneModif: json["personneModif"],
        statutMagasin: json["statutMagasin"],
        dateAjout: json["dateAjout"],
        dateModif: json["dateModif"],
        photo: json["photo"],
        nbreView: json["nbreView"],
        pays: json["pays"],
        acteur: Acteur.fromJson(json["acteur"]),
        niveau1Pays: Niveau1Pays.fromJson(json["niveau1Pays"]),
      );

  Map<String, dynamic> toJson() => {
        "idMagasin": idMagasin,
        "codeMagasin": codeMagasin,
        "nomMagasin": nomMagasin,
        "latitude": latitude,
        "longitude": longitude,
        "localiteMagasin": localiteMagasin,
        "contactMagasin": contactMagasin,
        "personneModif": personneModif,
        "statutMagasin": statutMagasin,
        "dateAjout": dateAjout,
        "dateModif": dateModif,
        "photo": photo,
        "nbreView": nbreView,
        "pays": pays,
        "acteur": acteur?.toJson(),
        "niveau1Pays": niveau1Pays?.toJson(),
      };

  Magasin copyWith({
    String? idMagasin,
    String? codeMagasin,
    String? nomMagasin,
    String? latitude,
    String? longitude,
    String? localiteMagasin,
    String? contactMagasin,
    String? personneModif,
    bool? statutMagasin,
    String? dateAjout,
    String? dateModif,
    String? photo,
    int? nbreView,
    Acteur? acteur,
    Niveau1Pays? niveau1Pays,
  }) {
    return Magasin(
      idMagasin: idMagasin ?? this.idMagasin,
      codeMagasin: codeMagasin ?? this.codeMagasin,
      nomMagasin: nomMagasin ?? this.nomMagasin,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      localiteMagasin: localiteMagasin ?? this.localiteMagasin,
      contactMagasin: contactMagasin ?? this.contactMagasin,
      personneModif: personneModif ?? this.personneModif,
      statutMagasin: statutMagasin ?? this.statutMagasin,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      photo: photo ?? this.photo,
      nbreView: nbreView ?? this.nbreView,
      acteur: acteur ?? this.acteur,
      niveau1Pays: niveau1Pays ?? this.niveau1Pays,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idMagasin': idMagasin,
      'codeMagasin': codeMagasin,
      'nomMagasin': nomMagasin,
      'latitude': latitude,
      'longitude': longitude,
      'localiteMagasin': localiteMagasin,
      'contactMagasin': contactMagasin,
      'personneModif': personneModif,
      'statutMagasin': statutMagasin,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'photo': photo,
      'nbreView': nbreView,
      'pays': pays,
      'acteur': acteur?.toMap(),
      'niveau1Pays': niveau1Pays?.toMap(),
    };
  }

  @override
  String toString() {
    return 'Magasin(idMagasin: $idMagasin, codeMagasin: $codeMagasin, nomMagasin: $nomMagasin, latitude: $latitude, longitude: $longitude, localiteMagasin: $localiteMagasin, contactMagasin: $contactMagasin, personneModif: $personneModif, statutMagasin: $statutMagasin, dateAjout: $dateAjout, dateModif: $dateModif, photo: $photo, acteur: $acteur, niveau1Pays: $niveau1Pays)';
  }

  @override
  bool operator ==(covariant Magasin other) {
    if (identical(this, other)) return true;

    return other.idMagasin == idMagasin &&
        other.codeMagasin == codeMagasin &&
        other.nomMagasin == nomMagasin &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.localiteMagasin == localiteMagasin &&
        other.contactMagasin == contactMagasin &&
        other.personneModif == personneModif &&
        other.statutMagasin == statutMagasin &&
        other.dateAjout == dateAjout &&
        other.dateModif == dateModif &&
        other.photo == photo &&
        other.nbreView == nbreView &&
        other.acteur == acteur &&
        other.niveau1Pays == niveau1Pays;
  }

  @override
  int get hashCode {
    return idMagasin.hashCode ^
        codeMagasin.hashCode ^
        nomMagasin.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        localiteMagasin.hashCode ^
        contactMagasin.hashCode ^
        personneModif.hashCode ^
        statutMagasin.hashCode ^
        dateAjout.hashCode ^
        dateModif.hashCode ^
        photo.hashCode ^
        nbreView.hashCode ^
        acteur.hashCode ^
        niveau1Pays.hashCode;
  }

  factory Magasin.fromMap(Map<String, dynamic> map) {
    return Magasin(
      idMagasin: map['idMagasin'] != null ? map['idMagasin'] as String : null,
      codeMagasin:
          map['codeMagasin'] != null ? map['codeMagasin'] as String : null,
      nomMagasin:
          map['nomMagasin'] != null ? map['nomMagasin'] as String : null,
      latitude: map['latitude'] != null ? map['latitude'] as String : null,
      longitude: map['longitude'] != null ? map['longitude'] as String : null,
      localiteMagasin: map['localiteMagasin'] != null
          ? map['localiteMagasin'] as String
          : null,
      contactMagasin: map['contactMagasin'] != null
          ? map['contactMagasin'] as String
          : null,
      personneModif:
          map['personneModif'] != null ? map['personneModif'] as String : null,
      statutMagasin:
          map['statutMagasin'] != null ? map['statutMagasin'] as bool : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      photo: map['photo'] != null ? map['photo'] as String : null,
      nbreView: map['nbreView'] != null ? map['nbreView'] as int : null,
      pays: map['pays'] != null ? map['pays'] as String : null,
      acteur: map['acteur'] != null
          ? Acteur.fromMap(map['acteur'] as Map<String, dynamic>)
          : null,
      niveau1Pays: map['niveau1Pays'] != null
          ? Niveau1Pays.fromMap(map['niveau1Pays'] as Map<String, dynamic>)
          : null,
    );
  }
}
