
class ParametreGeneraux {
   String? idParametreGeneraux;
   String? sigleStructure;
   String? nomStructure;
   String? sigleSysteme;
   String? nomSysteme;
   String? descriptionSysteme;
   String? sloganSysteme;
   String? logoSysteme;
   String? adresseStructure;
   String? emailStructure;
   String? telephoneStructure;
   String? whattsAppStructure;
   String? codeNiveauStructure;
   String? localiteStructure;
   String? dateAjout;
   String? dateModif;
  ParametreGeneraux({
    this.idParametreGeneraux,
    this.sigleStructure,
    this.nomStructure,
    this.sigleSysteme,
    this.nomSysteme,
   
    this.descriptionSysteme,
    this.sloganSysteme,
    this.logoSysteme,
    this.adresseStructure,
    this.emailStructure,
    this.telephoneStructure,
    this.whattsAppStructure,
   
    this.codeNiveauStructure,
    this.localiteStructure,
    this.dateAjout,
    this.dateModif,
  });
 

  ParametreGeneraux copyWith({
    String? idParametreGeneraux,
    String? sigleStructure,
    String? nomStructure,
    String? sigleSysteme,
    String? nomSysteme,
  
    String? descriptionSysteme,
    String? sloganSysteme,
    String? logoSysteme,
    String? adresseStructure,
    String? emailStructure,
    String? telephoneStructure,
    String? whattsAppStructure,

    String? codeNiveauStructure,
    String? localiteStructure,
    String? dateAjout,
    String? dateModif,
  }) {
    return ParametreGeneraux(
      idParametreGeneraux: idParametreGeneraux ?? this.idParametreGeneraux,
      sigleStructure: sigleStructure ?? this.sigleStructure,
      nomStructure: nomStructure ?? this.nomStructure,
      sigleSysteme: sigleSysteme ?? this.sigleSysteme,
      nomSysteme: nomSysteme ?? this.nomSysteme,
    
      descriptionSysteme: descriptionSysteme ?? this.descriptionSysteme,
      sloganSysteme: sloganSysteme ?? this.sloganSysteme,
      logoSysteme: logoSysteme ?? this.logoSysteme,
      adresseStructure: adresseStructure ?? this.adresseStructure,
      emailStructure: emailStructure ?? this.emailStructure,
      telephoneStructure: telephoneStructure ?? this.telephoneStructure,
      whattsAppStructure: whattsAppStructure ?? this.whattsAppStructure,
    
      codeNiveauStructure: codeNiveauStructure ?? this.codeNiveauStructure,
      localiteStructure: localiteStructure ?? this.localiteStructure,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idParametreGeneraux': idParametreGeneraux,
      'sigleStructure': sigleStructure,
      'nomStructure': nomStructure,
      'sigleSysteme': sigleSysteme,
      'nomSysteme': nomSysteme,
     
      'descriptionSysteme': descriptionSysteme,
      'sloganSysteme': sloganSysteme,
      'logoSysteme': logoSysteme,
      'adresseStructure': adresseStructure,
      'emailStructure': emailStructure,
      'telephoneStructure': telephoneStructure,
      'whattsAppStructure': whattsAppStructure,
     
      'codeNiveauStructure': codeNiveauStructure,
      'localiteStructure': localiteStructure,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
    };
  }

  factory ParametreGeneraux.fromMap(Map<String, dynamic> map) {
    return ParametreGeneraux(
      idParametreGeneraux: map['idParametreGeneraux'] != null ? map['idParametreGeneraux'] as String : null,
      sigleStructure: map['sigleStructure'] != null ? map['sigleStructure'] as String : null,
      nomStructure: map['nomStructure'] != null ? map['nomStructure'] as String : null,
      sigleSysteme: map['sigleSysteme'] != null ? map['sigleSysteme'] as String : null,
      nomSysteme: map['nomSysteme'] != null ? map['nomSysteme'] as String : null,
     
      descriptionSysteme: map['descriptionSysteme'] != null ? map['descriptionSysteme'] as String : null,
      sloganSysteme: map['sloganSysteme'] != null ? map['sloganSysteme'] as String : null,
      logoSysteme: map['logoSysteme'] != null ? map['logoSysteme'] as String : null,
      adresseStructure: map['adresseStructure'] != null ? map['adresseStructure'] as String : null,
      emailStructure: map['emailStructure'] != null ? map['emailStructure'] as String : null,
      telephoneStructure: map['telephoneStructure'] != null ? map['telephoneStructure'] as String : null,
      whattsAppStructure: map['whattsAppStructure'] != null ? map['whattsAppStructure'] as String : null,
    
      codeNiveauStructure: map['codeNiveauStructure'] != null ? map['codeNiveauStructure'] as String : null,
      localiteStructure: map['localiteStructure'] != null ? map['localiteStructure'] as String : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
    );
  }


}
