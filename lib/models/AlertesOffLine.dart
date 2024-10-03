// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


class AlertesOffLine {
    String? idAlerteOffLine;
    String? codeAlerteOffLine;
    String? titreAlerteOffLine;
    String? videoAlerteOffLine;
    String? photoAlerteOffLine;
    String? codePays;
    String? dateAjout;
    String? dateModif;
    String? personneModif;
    String? descriptionAlerteOffLine;
    String? audioAlerteOffLine;
    bool? statutAlerteOffLine;
    String? pays;

    AlertesOffLine({
         this.idAlerteOffLine,
         this.codeAlerteOffLine,
         this.titreAlerteOffLine,
         this.videoAlerteOffLine,
         this.photoAlerteOffLine,
         this.codePays,
         this.dateAjout,
         this.dateModif,
         this.personneModif,
         this.descriptionAlerteOffLine,
         this.audioAlerteOffLine,
         this.statutAlerteOffLine,
         this.pays,
    });

    factory AlertesOffLine.fromJson(Map<String, dynamic> json) => AlertesOffLine(
        idAlerteOffLine: json["idAlerteOffLine"],
        codeAlerteOffLine: json["codeAlerteOffLine"],
        titreAlerteOffLine: json["titreAlerteOffLine"],
        videoAlerteOffLine: json["videoAlerteOffLine"],
        photoAlerteOffLine: json["photoAlerteOffLine"],
        codePays: json["codePays"],
        dateAjout: json["dateAjout"],
        dateModif: json["dateModif"],
        personneModif: json["personneModif"],
        descriptionAlerteOffLine: json["descriptionAlerteOffLine"],
        audioAlerteOffLine: json["audioAlerteOffLine"],
        statutAlerteOffLine: json["statutAlerteOffLine"],
        pays: json["pays"],
    );

    Map<String, dynamic> toJson() => {
        "idAlerteOffLine": idAlerteOffLine,
        "codeAlerteOffLine": codeAlerteOffLine,
        "titreAlerteOffLine": titreAlerteOffLine,
        "videoAlerteOffLine": videoAlerteOffLine,
        "photoAlerteOffLine": photoAlerteOffLine,
        "codePays": codePays,
        "dateAjout": dateAjout,
        "dateModif": dateModif,
        "personneModif": personneModif,
        "descriptionAlerteOffLine": descriptionAlerteOffLine,
        "audioAlerteOffLine": audioAlerteOffLine,
        "statutAlerteOffLine": statutAlerteOffLine,
        "pays": pays,
    };

  AlertesOffLine copyWith({
    String? idAlerteOffLine,
    String? codeAlerteOffLine,
    String? titreAlerteOffLine,
    String? videoAlerteOffLine,
    String? photoAlerteOffLine,
    String? codePays,
    String? dateAjout,
    String? dateModif,
    String? personneModif,
    String? descriptionAlerteOffLine,
    String? audioAlerteOffLine,
    bool? statutAlerteOffLine,
    String? pays,
  }) {
    return AlertesOffLine(
      idAlerteOffLine: idAlerteOffLine ?? this.idAlerteOffLine,
      codeAlerteOffLine: codeAlerteOffLine ?? this.codeAlerteOffLine,
      titreAlerteOffLine: titreAlerteOffLine ?? this.titreAlerteOffLine,
      videoAlerteOffLine: videoAlerteOffLine ?? this.videoAlerteOffLine,
      photoAlerteOffLine: photoAlerteOffLine ?? this.photoAlerteOffLine,
      codePays: codePays ?? this.codePays,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      personneModif: personneModif ?? this.personneModif,
      descriptionAlerteOffLine: descriptionAlerteOffLine ?? this.descriptionAlerteOffLine,
      audioAlerteOffLine: audioAlerteOffLine ?? this.audioAlerteOffLine,
      statutAlerteOffLine: statutAlerteOffLine ?? this.statutAlerteOffLine,
      pays: pays ?? this.pays,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idAlerteOffLine': idAlerteOffLine,
      'codeAlerteOffLine': codeAlerteOffLine,
      'titreAlerteOffLine': titreAlerteOffLine,
      'videoAlerteOffLine': videoAlerteOffLine,
      'photoAlerteOffLine': photoAlerteOffLine,
      'codePays': codePays,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'personneModif': personneModif,
      'descriptionAlerteOffLine': descriptionAlerteOffLine,
      'audioAlerteOffLine': audioAlerteOffLine,
      'statutAlerteOffLine': statutAlerteOffLine,
      'pays': pays,
    };
  }

  factory AlertesOffLine.fromMap(Map<String, dynamic> map) {
    return AlertesOffLine(
      idAlerteOffLine: map['idAlerteOffLine'] != null ? map['idAlerteOffLine'] as String : null,
      codeAlerteOffLine: map['codeAlerteOffLine'] != null ? map['codeAlerteOffLine'] as String : null,
      titreAlerteOffLine: map['titreAlerteOffLine'] != null ? map['titreAlerteOffLine'] as String : null,
      videoAlerteOffLine: map['videoAlerteOffLine'] != null ? map['videoAlerteOffLine'] as String : null,
      photoAlerteOffLine: map['photoAlerteOffLine'] != null ? map['photoAlerteOffLine'] as String : null,
      codePays: map['codePays'] != null ? map['codePays'] as String : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      descriptionAlerteOffLine: map['descriptionAlerteOffLine'] != null ? map['descriptionAlerteOffLine'] as String : null,
      audioAlerteOffLine: map['audioAlerteOffLine'] != null ? map['audioAlerteOffLine'] as String : null,
      statutAlerteOffLine: map['statutAlerteOffLine'] != null ? map['statutAlerteOffLine'] as bool : null,
      pays: map['pays'] != null ? map['pays'] as String : null,
    );
  }

  // String toJson() => json.encode(toMap());

  // factory AlertesOffLine.fromJson(String source) => AlertesOffLine.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AlertesOffLine(idAlerteOffLine: $idAlerteOffLine, codeAlerteOffLine: $codeAlerteOffLine, titreAlerteOffLine: $titreAlerteOffLine, videoAlerteOffLine: $videoAlerteOffLine, photoAlerteOffLine: $photoAlerteOffLine, codePays: $codePays, dateAjout: $dateAjout, dateModif: $dateModif, personneModif: $personneModif, descriptionAlerteOffLine: $descriptionAlerteOffLine, audioAlerteOffLine: $audioAlerteOffLine, statutAlerteOffLine: $statutAlerteOffLine, pays: $pays)';
  }

  @override
  bool operator ==(covariant AlertesOffLine other) {
    if (identical(this, other)) return true;
  
    return 
      other.idAlerteOffLine == idAlerteOffLine &&
      other.codeAlerteOffLine == codeAlerteOffLine &&
      other.titreAlerteOffLine == titreAlerteOffLine &&
      other.videoAlerteOffLine == videoAlerteOffLine &&
      other.photoAlerteOffLine == photoAlerteOffLine &&
      other.codePays == codePays &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.personneModif == personneModif &&
      other.descriptionAlerteOffLine == descriptionAlerteOffLine &&
      other.audioAlerteOffLine == audioAlerteOffLine &&
      other.statutAlerteOffLine == statutAlerteOffLine &&
      other.pays == pays;
  }

  @override
  int get hashCode {
    return idAlerteOffLine.hashCode ^
      codeAlerteOffLine.hashCode ^
      titreAlerteOffLine.hashCode ^
      videoAlerteOffLine.hashCode ^
      photoAlerteOffLine.hashCode ^
      codePays.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      personneModif.hashCode ^
      descriptionAlerteOffLine.hashCode ^
      audioAlerteOffLine.hashCode ^
      statutAlerteOffLine.hashCode ^
      pays.hashCode;
  }
}
