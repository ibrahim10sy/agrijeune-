import 'dart:convert';

import 'package:koumi/models/Acteur.dart';


class Conseil {
  final String? idConseil;
  final String? codeConseil;
  final String titreConseil;
  final String? videoConseil;
  final String? photoConseil;
  final String? dateAjout;
  final String? dateModif;
  final String? personneModif;
  final String descriptionConseil;
  final String? audioConseil;
  final bool statutConseil;
  final Acteur acteur;
  Conseil({
    this.idConseil,
    this.codeConseil,
    required this.titreConseil,
    this.videoConseil,
    this.photoConseil,
    this.dateAjout,
    this.dateModif,
    this.personneModif,
    required this.descriptionConseil,
    this.audioConseil,
    required this.statutConseil,
    required this.acteur,
  });


  Conseil copyWith({
    String? idConseil,
    String? codeConseil,
    String? titreConseil,
    String? videoConseil,
    String? photoConseil,
    String? dateAjout,
    String? dateModif,
    String? personneModif,
    String? descriptionConseil,
    String? audioConseil,
    bool? statutConseil,
    Acteur? acteur,
  }) {
    return Conseil(
      idConseil: idConseil ?? this.idConseil,
      codeConseil: codeConseil ?? this.codeConseil,
      titreConseil: titreConseil ?? this.titreConseil,
      videoConseil: videoConseil ?? this.videoConseil,
      photoConseil: photoConseil ?? this.photoConseil,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      personneModif: personneModif ?? this.personneModif,
      descriptionConseil: descriptionConseil ?? this.descriptionConseil,
      audioConseil: audioConseil ?? this.audioConseil,
      statutConseil: statutConseil ?? this.statutConseil,
      acteur: acteur ?? this.acteur,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idConseil': idConseil,
      'codeConseil': codeConseil,
      'titreConseil': titreConseil,
      'videoConseil': videoConseil,
      'photoConseil': photoConseil,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'personneModif': personneModif,
      'descriptionConseil': descriptionConseil,
      'audioConseil': audioConseil,
      'statutConseil': statutConseil,
      'acteur': acteur.toMap(),
    };
  }

  factory Conseil.fromMap(Map<String, dynamic> map) {
    return Conseil(
      idConseil: map['idConseil'] != null ? map['idConseil'] as String : null,
      codeConseil: map['codeConseil'] != null ? map['codeConseil'] as String : null,
      titreConseil: map['titreConseil'] as String,
      videoConseil: map['videoConseil'] != null ? map['videoConseil'] as String : null,
      photoConseil: map['photoConseil'] != null ? map['photoConseil'] as String : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      descriptionConseil: map['descriptionConseil'] as String,
      audioConseil: map['audioConseil'] != null ? map['audioConseil'] as String : null,
      statutConseil: map['statutConseil'] as bool,
      acteur: Acteur.fromMap(map['acteur'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Conseil.fromJson(String source) => Conseil.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Conseil(idConseil: $idConseil, codeConseil: $codeConseil, titreConseil: $titreConseil, videoConseil: $videoConseil, photoConseil: $photoConseil, dateAjout: $dateAjout, dateModif: $dateModif, personneModif: $personneModif, descriptionConseil: $descriptionConseil, audioConseil: $audioConseil, statutConseil: $statutConseil, acteur: $acteur)';
  }

  @override
  bool operator ==(covariant Conseil other) {
    if (identical(this, other)) return true;
  
    return 
      other.idConseil == idConseil &&
      other.codeConseil == codeConseil &&
      other.titreConseil == titreConseil &&
      other.videoConseil == videoConseil &&
      other.photoConseil == photoConseil &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.personneModif == personneModif &&
      other.descriptionConseil == descriptionConseil &&
      other.audioConseil == audioConseil &&
      other.statutConseil == statutConseil &&
      other.acteur == acteur;
  }

  @override
  int get hashCode {
    return idConseil.hashCode ^
      codeConseil.hashCode ^
      titreConseil.hashCode ^
      videoConseil.hashCode ^
      photoConseil.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      personneModif.hashCode ^
      descriptionConseil.hashCode ^
      audioConseil.hashCode ^
      statutConseil.hashCode ^
      acteur.hashCode;
  }
}
