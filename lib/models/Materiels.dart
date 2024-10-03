import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeMateriel.dart';

class Materiels {
  String? idMateriel;
  String? codeMateriel;
  int? prixParHeure;
  String? nom;
  String? description;
  String? photoMateriel;
  String? etatMateriel;
  String? localisation;
  String? personneModif;
  bool? statut;
  bool? statutCommande;
  String? pays;
  String? dateAjout;
  String? dateModif;
  int? nbreView;
  Acteur? acteur;
  TypeMateriel? typeMateriel;
  Monnaie? monnaie;
  Speculation? speculation;

  Materiels({
    this.idMateriel,
    this.codeMateriel,
    this.prixParHeure,
    this.nom,
    this.description,
    this.photoMateriel,
    this.etatMateriel,
    this.localisation,
    this.personneModif,
    this.statut,
    this.statutCommande,
    this.pays,
    this.dateAjout,
    this.dateModif,
    this.nbreView,
    this.acteur,
    this.typeMateriel,
    this.monnaie,
    this.speculation,
  });

  factory Materiels.fromJson(Map<String, dynamic> json) => Materiels(
        idMateriel: json["idMateriel"],
        codeMateriel: json["codeMateriel"],
        prixParHeure: json["prixParHeure"],
        nom: json["nom"],
        description: json["description"],
        photoMateriel: json["photoMateriel"],
        etatMateriel: json["etatMateriel"],
        localisation: json["localisation"],
        personneModif: json["personneModif"],
        statut: json["statut"],
        statutCommande: json["statutCommande"],
        pays: json["pays"],
        dateAjout: json["dateAjout"],
        dateModif: json["dateModif"],
        nbreView: json["nbreView"],
        acteur: Acteur.fromJson(json["acteur"]),
        typeMateriel: TypeMateriel.fromJson(json["typeMateriel"]),
        monnaie: Monnaie.fromJson(json["monnaie"]),
        speculation: Speculation.fromJson(json["speculation"]),
      );

  factory Materiels.fromMap(Map<String, dynamic> map) {
    return Materiels(
      idMateriel:
          map['idMateriel'] != null ? map['idMateriel'] as String : null,
      codeMateriel:
          map['codeMateriel'] != null ? map['codeMateriel'] as String : null,
      prixParHeure:
          map['prixParHeure'] != null ? map['prixParHeure'] as int : null,
      nom: map['nom'] != null ? map['nom'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      photoMateriel:
          map['photoMateriel'] != null ? map['photoMateriel'] as String : null,
      etatMateriel:
          map['etatMateriel'] != null ? map['etatMateriel'] as String : null,
      localisation:
          map['localisation'] != null ? map['localisation'] as String : null,
      personneModif:
          map['personneModif'] != null ? map['personneModif'] as String : null,
      statut: map['statut'] != null ? map['statut'] as bool : null,
      statutCommande:
          map['statutCommande'] != null ? map['statutCommande'] as bool : null,
      pays: map['pays'] != null ? map['pays'] as String : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      nbreView: map['nbreView'] != null ? map['nbreView'] as int : null,
      acteur: map['acteur'] != null
          ? Acteur.fromMap(map['acteur'] as Map<String, dynamic>)
          : null,
      typeMateriel: map['typeMateriel'] != null
          ? TypeMateriel.fromMap(map['typeMateriel'] as Map<String, dynamic>)
          : null,
      monnaie: map['monnaie'] != null
          ? Monnaie.fromMap(map['monnaie'] as Map<String, dynamic>)
          : null,
      speculation: map['speculation'] != null
          ? Speculation.fromMap(map['speculation'] as Map<String, dynamic>)
          : null,
    );
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idMateriel': idMateriel,
      'codeMateriel': codeMateriel,
      'prixParHeure': prixParHeure,
      'nom': nom,
      'description': description,
      'photoMateriel': photoMateriel,
      'etatMateriel': etatMateriel,
      'localisation': localisation,
      'personneModif': personneModif,
      'statut': statut,
      'statutCommande': statutCommande,
      'pays': pays,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      "nbreView": nbreView,
      'acteur': acteur?.toMap(),
      'typeMateriel': typeMateriel?.toMap(),
      'monnaie': monnaie?.toMap(),
      'speculation': speculation?.toMap(),
    };
  }

  Map<String, dynamic> toJson() => {
        "idMateriel": idMateriel,
        "codeMateriel": codeMateriel,
        "prixParHeure": prixParHeure,
        "nom": nom,
        "description": description,
        "photoMateriel": photoMateriel,
        "etatMateriel": etatMateriel,
        "localisation": localisation,
        "personneModif": personneModif,
        "statut": statut,
        "statutCommande": statutCommande,
        "pays": pays,
        "dateAjout": dateAjout,
        "dateModif": dateModif,
        "nbreView": nbreView,
        "acteur": acteur!.toJson(),
        "typeMateriel": typeMateriel!.toJson(),
        "monnaie": monnaie!.toJson(),
        "speculation": speculation!.toJson(),
      };
}
