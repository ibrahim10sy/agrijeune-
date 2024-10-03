// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MessageWa {
  final String idMessage;
  final String codeMessage;
  final String? personneModif;
  final String text;
  final String? dateAjout;
  final String? acteurConcerner;
  MessageWa({
    required this.idMessage,
    required this.codeMessage,
    this.personneModif,
    required this.text,
    this.dateAjout,
    this.acteurConcerner,
  });

  MessageWa copyWith({
    String? idMessage,
    String? codeMessage,
    String? personneModif,
    String? text,
    String? dateAjout,
    String? acteurConcerner,
  }) {
    return MessageWa(
      idMessage: idMessage ?? this.idMessage,
      codeMessage: codeMessage ?? this.codeMessage,
      personneModif: personneModif ?? this.personneModif,
      text: text ?? this.text,
      dateAjout: dateAjout ?? this.dateAjout,
      acteurConcerner: acteurConcerner ?? this.acteurConcerner,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idMessage': idMessage,
      'codeMessage': codeMessage,
      'personneModif': personneModif,
      'text': text,
      'dateAjout': dateAjout,
      'acteurConcerner': acteurConcerner,
    };
  }

  factory MessageWa.fromMap(Map<String, dynamic> map) {
    return MessageWa(
      idMessage: map['idMessage'] as String,
      codeMessage: map['codeMessage'] as String,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      text: map['text'] as String,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      acteurConcerner: map['acteurConcerner'] != null ? map['acteurConcerner'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageWa.fromJson(String source) => MessageWa.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MessageWa(idMessage: $idMessage, codeMessage: $codeMessage, personneModif: $personneModif, text: $text, dateAjout: $dateAjout, acteurConcerner: $acteurConcerner)';
  }

  @override
  bool operator ==(covariant MessageWa other) {
    if (identical(this, other)) return true;
  
    return 
      other.idMessage == idMessage &&
      other.codeMessage == codeMessage &&
      other.personneModif == personneModif &&
      other.text == text &&
      other.dateAjout == dateAjout &&
      other.acteurConcerner == acteurConcerner;
  }

  @override
  int get hashCode {
    return idMessage.hashCode ^
      codeMessage.hashCode ^
      personneModif.hashCode ^
      text.hashCode ^
      dateAjout.hashCode ^
      acteurConcerner.hashCode;
  }
}
