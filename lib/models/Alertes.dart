// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Alertes {
  final String? idAlerte;
  final String? codeAlerte;
  final String? titreAlerte;
  final String? videoAlerte;
  final String? photoAlerte;
  final String? dateAjout;
  final String? dateModif;
  final String? personneModif;
  final String? descriptionAlerte;
  final String? audioAlerte;
  final String? pays;
  final String? codePays;
  final bool? statutAlerte;

  
  Alertes({
    this.idAlerte,
    this.codeAlerte,
    this.titreAlerte,
    this.videoAlerte,
    this.photoAlerte,
    this.dateAjout,
    this.dateModif,
    this.personneModif,
    this.descriptionAlerte,
    this.audioAlerte,
    this.pays,
    this.codePays,
    this.statutAlerte,
  });



  Alertes copyWith({
    String? idAlerte,
    String? codeAlerte,
    String? titreAlerte,
    String? videoAlerte,
    String? photoAlerte,
    String? dateAjout,
    String? dateModif,
    String? personneModif,
    String? descriptionAlerte,
    String? audioAlerte,
    String? pays,
    String? codePays,
    bool? statutAlerte,
  }) {
    return Alertes(
      idAlerte: idAlerte ?? this.idAlerte,
      codeAlerte: codeAlerte ?? this.codeAlerte,
      titreAlerte: titreAlerte ?? this.titreAlerte,
      videoAlerte: videoAlerte ?? this.videoAlerte,
      photoAlerte: photoAlerte ?? this.photoAlerte,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      personneModif: personneModif ?? this.personneModif,
      descriptionAlerte: descriptionAlerte ?? this.descriptionAlerte,
      audioAlerte: audioAlerte ?? this.audioAlerte,
      pays: pays ?? this.pays,
      codePays: codePays ?? this.codePays,
      statutAlerte: statutAlerte ?? this.statutAlerte,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idAlerte': idAlerte,
      'codeAlerte': codeAlerte,
      'titreAlerte': titreAlerte,
      'videoAlerte': videoAlerte,
      'photoAlerte': photoAlerte,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'personneModif': personneModif,
      'descriptionAlerte': descriptionAlerte,
      'audioAlerte': audioAlerte,
      'pays': pays,
      'codePays': codePays,
      'statutAlerte': statutAlerte,
    };
  }

  factory Alertes.fromMap(Map<String, dynamic> map) {
    return Alertes(
      idAlerte: map['idAlerte'] != null ? map['idAlerte'] as String : null,
      codeAlerte: map['codeAlerte'] != null ? map['codeAlerte'] as String : null,
      titreAlerte: map['titreAlerte'] != null ? map['titreAlerte'] as String : null,
      videoAlerte: map['videoAlerte'] != null ? map['videoAlerte'] as String : null,
      photoAlerte: map['photoAlerte'] != null ? map['photoAlerte'] as String : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      descriptionAlerte: map['descriptionAlerte'] != null ? map['descriptionAlerte'] as String : null,
      audioAlerte: map['audioAlerte'] != null ? map['audioAlerte'] as String : null,
      pays: map['pays'] != null ? map['pays'] as String : null,
      codePays: map['codePays'] != null ? map['codePays'] as String : null,
      statutAlerte: map['statutAlerte'] != null ? map['statutAlerte'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Alertes.fromJson(String source) => Alertes.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Alertes(idAlerte: $idAlerte, codeAlerte: $codeAlerte, titreAlerte: $titreAlerte, videoAlerte: $videoAlerte, photoAlerte: $photoAlerte, dateAjout: $dateAjout, pays: $pays, codePays:$codePays, dateModif: $dateModif, personneModif: $personneModif, descriptionAlerte: $descriptionAlerte, audioAlerte: $audioAlerte, statutAlerte: $statutAlerte)';
  }

  @override
  bool operator ==(covariant Alertes other) {
    if (identical(this, other)) return true;
  
    return 
      other.idAlerte == idAlerte &&
      other.codeAlerte == codeAlerte &&
      other.titreAlerte == titreAlerte &&
      other.videoAlerte == videoAlerte &&
      other.photoAlerte == photoAlerte &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.personneModif == personneModif &&
      other.descriptionAlerte == descriptionAlerte &&
      other.audioAlerte == audioAlerte &&
      other.pays == pays &&
      other.codePays == codePays &&
      other.statutAlerte == statutAlerte;
  }

  @override
  int get hashCode {
    return idAlerte.hashCode ^
      codeAlerte.hashCode ^
      titreAlerte.hashCode ^
      videoAlerte.hashCode ^
      photoAlerte.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      personneModif.hashCode ^
      descriptionAlerte.hashCode ^
      audioAlerte.hashCode ^
      pays.hashCode ^
      codePays.hashCode ^
      statutAlerte.hashCode;
  }
}
