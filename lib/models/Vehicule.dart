
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/TypeVoiture.dart';


class Vehicule {
  String idVehicule;
  String nomVehicule;
  String capaciteVehicule;
  String? codeVehicule;
  String? description;
  int? nbKilometrage;
  int? nbreView;
  Map<String, int> prixParDestination;
  bool statutVehicule;
  String? photoVehicule;
  String localisation;
  String? dateAjout;
  String? dateModif;
  String etatVehicule;
  String? personneModif;
  Acteur acteur;
  TypeVoiture typeVoiture;
  Monnaie? monnaie;

  Vehicule({
    required this.idVehicule,
    required this.nomVehicule,
    required this.capaciteVehicule,
    required this.codeVehicule,
    this.description,
    this.nbKilometrage,
    this.nbreView,
    required this.prixParDestination,
    required this.statutVehicule,
    this.photoVehicule,
    required this.localisation,
    this.dateAjout,
    this.dateModif,
    required this.etatVehicule,
    this.personneModif,
    required this.acteur,
    required this.typeVoiture,
    required this.monnaie
  });

  Vehicule copyWith({
    String? idVehicule,
    String? nomVehicule,
    String? capaciteVehicule,
    String? codeVehicule,
    String? description,
    int? nbKilometrage,
    int? nbreView,
    Map<String, int>? prixParDestination,
    bool? statutVehicule,
    String? photoVehicule,
    String? localisation,
    String? dateAjout,
    String? dateModif,
    String? etatVehicule,
    String? personneModif,
    Acteur? acteur,
    TypeVoiture? typeVoiture,
    Monnaie? monnaie
  }) {
    return Vehicule(
      idVehicule: idVehicule ?? this.idVehicule,
      nomVehicule: nomVehicule ?? this.nomVehicule,
      capaciteVehicule: capaciteVehicule ?? this.capaciteVehicule,
      codeVehicule: codeVehicule ?? this.codeVehicule,
      description: description ?? this.description,
      nbKilometrage: nbKilometrage ?? this.nbKilometrage,
      nbreView: nbreView ?? this.nbreView,
      prixParDestination: prixParDestination ?? this.prixParDestination,
      statutVehicule: statutVehicule ?? this.statutVehicule,
      photoVehicule: photoVehicule ?? this.photoVehicule,
      localisation: localisation ?? this.localisation,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      etatVehicule: etatVehicule ?? this.etatVehicule,
      personneModif: personneModif ?? this.personneModif,
      acteur: acteur ?? this.acteur,
      typeVoiture: typeVoiture ?? this.typeVoiture,
      monnaie: monnaie ?? this.monnaie,
    );
  }

factory Vehicule.fromMap(Map<String, dynamic> map) {
    return Vehicule(
      idVehicule: map['idVehicule'] as String,
      nomVehicule: map['nomVehicule'] as String,
      capaciteVehicule: map['capaciteVehicule'] as String,
      codeVehicule: map['codeVehicule'] as String,
      description: map['description']
          as String?,
      nbKilometrage: map['nbKilometrage']
          as int?,
      nbreView: map['nbreView']
          as int?,
      prixParDestination: Map<String, int>.from(
          map['prixParDestination'] as Map<String, dynamic>),
      statutVehicule: map['statutVehicule'] as bool,
      photoVehicule: map['photoVehicule']
          as String?,
      localisation: map['localisation'] as String,
      dateAjout: map['dateAjout']
          as String?,
      dateModif: map['dateModif']
          as String?,
      etatVehicule: map['etatVehicule'] as String,
      personneModif: map['personneModif']
          as String?,
      acteur: Acteur.fromMap(map['acteur'] as Map<String, dynamic>),
      typeVoiture:
          TypeVoiture.fromMap(map['typeVoiture'] as Map<String, dynamic>),
      monnaie: map['monnaie'] != null
            ? Monnaie.fromMap(map['monnaie'] as Map<String, dynamic>)
            : Monnaie()
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idVehicule': idVehicule,
      'nomVehicule': nomVehicule,
      'capaciteVehicule': capaciteVehicule,
      'codeVehicule': codeVehicule,
      'description': description,
      'nbKilometrage': nbKilometrage,
      'nbreView': nbreView,
      'prixParDestination': prixParDestination,
      'statutVehicule': statutVehicule,
      'photoVehicule': photoVehicule,
      'localisation': localisation,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'etatVehicule': etatVehicule,
      'personneModif': personneModif,
      'acteur': acteur.toMap(),
      'typeVoiture': typeVoiture.toMap(),
      'monnaie' : monnaie!.toMap(),
    };
  }

  
}
