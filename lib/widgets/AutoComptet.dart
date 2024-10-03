import 'package:flutter/material.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';

class AutoComplet {

  static List<String> getTransport() {
    return [
      'Car', 'Bike', 'Bus', 'Truck', 'Van', 'Bicycle', 'Scooter', 'Motorcycle',
      'Tractor', 'Train', 'Airplane', 'Helicopter', 'Boat', 'Ship', 'Submarine'
    ];
  }
  static List<SearchFieldAutoCompleteItem<String>> get getTransportVehicles {
    return const [
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Monospace', value: 'Monospace'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Camion', value: 'Camion'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Fourgon', value: 'Fourgon'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Minibus', value: 'Minibus'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Bus', value: 'Bus'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Autobus', value: 'Autobus'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Autocar', value: 'Autocar'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Taxi', value: 'Taxi'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Vélo', value: 'Vélo'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Scooter', value: 'Scooter'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Tricycle motorisé', value: 'Tricycle motorisé'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Voiture', value: 'Voiture'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Berline', value: 'Berline'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'SUV', value: 'SUV'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Monospace', value: 'Monospace'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Coupé', value: 'Coupé'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Cabriolet', value: 'Cabriolet'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Limousine', value: 'Limousine'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camion-citerne', value: 'Camion-citerne'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camion frigorifique', value: 'Camion frigorifique'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camion-benne', value: 'Camion-benne'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Tracteur routier', value: 'Tracteur routier'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Remorque', value: 'Remorque'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Semi-remorque', value: 'Semi-remorque'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Pick-up', value: 'Pick-up'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Motocyclette', value: 'Motocyclette'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Quad', value: 'Quad'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Tracteur', value: 'Tracteur'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camion-bâché', value: 'Camion-bâché'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camion à benne basculante',
          value: 'Camion à benne basculante'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Voiture électrique', value: 'Voiture électrique'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Bus électrique', value: 'Bus électrique'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Vélo électrique', value: 'Vélo électrique'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Scooter électrique', value: 'Scooter électrique'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Fourgon réfrigéré', value: 'Fourgon réfrigéré'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camion plateau', value: 'Camion plateau'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Van', value: 'Van'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camping-car', value: 'Camping-car'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Bus scolaire', value: 'Bus scolaire'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Tuk-tuk', value: 'Tuk-tuk'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Roulotte', value: 'Roulotte'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Ambulance', value: 'Ambulance'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camion de pompiers', value: 'Camion de pompiers'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Dépanneuse', value: 'Dépanneuse'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camionnette', value: 'Camionnette'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Remorque citerne', value: 'Remorque citerne'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Bus articulé', value: 'Bus articulé'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camion surbaissé', value: 'Camion surbaissé'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Camion porte-conteneurs',
          value: 'Camion porte-conteneurs')
    ];
  }

  static List<SearchFieldAutoCompleteItem<String>> get getAgriculturalProducts {
  return const [
    
    SearchFieldAutoCompleteItem<String>(searchKey: 'Blé', value: 'Blé'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Riz', value: 'Riz'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Maïs', value: 'Maïs'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Orge', value: 'Orge'),
     SearchFieldAutoCompleteItem<String>(searchKey: 'Lait', value: 'Lait'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage', value: 'Fromage'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Beurre', value: 'Beurre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Yaourt', value: 'Yaourt'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de boeuf', value: 'Viande de boeuf'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de poulet', value: 'Viande de poulet'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de porc', value: 'Viande de porc'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande d\'agneau', value: 'Viande d\'agneau'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Œufs', value: 'Œufs'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Miel', value: 'Miel'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de chèvre', value: 'Lait de chèvre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de dinde', value: 'Viande de dinde'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de canard', value: 'Viande de canard'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de brebis', value: 'Lait de brebis'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de lapin', value: 'Viande de lapin'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Crème', value: 'Crème'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage de chèvre', value: 'Fromage de chèvre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de veau', value: 'Viande de veau'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage de brebis', value: 'Fromage de brebis'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de mouton', value: 'Viande de mouton'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Charcuterie', value: 'Charcuterie'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait concentré', value: 'Lait concentré'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait en poudre', value: 'Lait en poudre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Foie gras', value: 'Foie gras'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Kéfir', value: 'Kéfir'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage blanc', value: 'Fromage blanc'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande séchée', value: 'Viande séchée'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait fermenté', value: 'Lait fermenté'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait ribot', value: 'Lait ribot'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de soja', value: 'Lait de soja'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait d\'amande', value: 'Lait d\'amande'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de coco', value: 'Lait de coco'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait d\'avoine', value: 'Lait d\'avoine'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de riz', value: 'Lait de riz'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Yaourt de soja', value: 'Yaourt de soja'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage fondu', value: 'Fromage fondu'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage frais', value: 'Fromage frais'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage à pâte dure', value: 'Fromage à pâte dure'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage à pâte molle', value: 'Fromage à pâte molle'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage bleu', value: 'Fromage bleu'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage de chèvre frais', value: 'Fromage de chèvre frais'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage de brebis frais', value: 'Fromage de brebis frais'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage râpé', value: 'Fromage râpé'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage en tranche', value: 'Fromage en tranche'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait sans lactose', value: 'Lait sans lactose'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Crème fouettée', value: 'Crème fouettée'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Crème glacée', value: 'Crème glacée'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande hachée', value: 'Viande hachée'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Avoine', value: 'Avoine'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Sorgho', value: 'Sorgho'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Soja', value: 'Soja'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Haricot', value: 'Haricot'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pois', value: 'Pois'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lentille', value: 'Lentille'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pois chiche', value: 'Pois chiche'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Luzerne', value: 'Luzerne'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Foin', value: 'Foin'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pomme de terre', value: 'Pomme de terre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Carotte', value: 'Carotte'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Betterave', value: 'Betterave'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Banane', value: 'Banane'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pomme', value: 'Pomme'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Chou', value: 'Chou'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Tomate', value: 'Tomate'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Oignon', value: 'Oignon'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Ail', value: 'Ail'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Piment', value: 'Piment'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Poivron', value: 'Poivron'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Courgette', value: 'Courgette'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Concombre', value: 'Concombre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Laitue', value: 'Laitue'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Épinard', value: 'Épinard'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Brocoli', value: 'Brocoli'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Chou-fleur', value: 'Chou-fleur'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Radis', value: 'Radis'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Navet', value: 'Navet'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Melon', value: 'Melon'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pastèque', value: 'Pastèque'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pasteque', value: 'Pasteque'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pomme', value: 'Pomme'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Poire', value: 'Poire'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Cerise', value: 'Cerise'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fraise', value: 'Fraise'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Framboise', value: 'Framboise'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Mûre', value: 'Mûre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Groseille', value: 'Groseille'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Raisin', value: 'Raisin'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pêche', value: 'Pêche'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Abricot', value: 'Abricot'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Prune', value: 'Prune'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Olive', value: 'Olive'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Amande', value: 'Amande'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Noisette', value: 'Noisette'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Noix', value: 'Noix')
  ];
}

static List<SearchFieldAutoCompleteItem<String>> get getProcessedProducts {
    return const [
      SearchFieldAutoCompleteItem<String>(searchKey: 'Farine', value: 'Farine'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Pain', value: 'Pain'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Pâtes', value: 'Pâtes'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Huile', value: 'Huile'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture', value: 'Confiture'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Jus de fruits', value: 'Jus de fruits'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Conserves', value: 'Conserves'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Sauces', value: 'Sauces'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Chocolat', value: 'Chocolat'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Café', value: 'Café'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Biscuits', value: 'Biscuits'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Céréales', value: 'Céréales'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Biscottes', value: 'Biscottes'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Pain de mie', value: 'Pain de mie'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Pain complet', value: 'Pain complet'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Pain aux céréales', value: 'Pain aux céréales'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Pain aux graines', value: 'Pain aux graines'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Pain sans gluten', value: 'Pain sans gluten'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Farine de blé', value: 'Farine de blé'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Farine de maïs', value: 'Farine de maïs'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Farine de riz', value: 'Farine de riz'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Farine d\'épeautre', value: 'Farine d\'épeautre'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Farine de sarrasin', value: 'Farine de sarrasin'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Farine de seigle', value: 'Farine de seigle'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Farine de châtaigne', value: 'Farine de châtaigne'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Farine de coco', value: 'Farine de coco'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Huile d\'olive', value: 'Huile d\'olive'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Huile de tournesol', value: 'Huile de tournesol'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Huile de colza', value: 'Huile de colza'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Huile de noix', value: 'Huile de noix'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Huile de sésame', value: 'Huile de sésame'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Huile de lin', value: 'Huile de lin'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Huile de pépins de raisin',
          value: 'Huile de pépins de raisin'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture de fraises', value: 'Confiture de fraises'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture d\'abricots', value: 'Confiture d\'abricots'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture de cerises', value: 'Confiture de cerises'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture de framboises',
          value: 'Confiture de framboises'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture de mûres', value: 'Confiture de mûres'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture de myrtilles', value: 'Confiture de myrtilles'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture de pêches', value: 'Confiture de pêches'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture de prunes', value: 'Confiture de prunes'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Confiture de figues', value: 'Confiture de figues'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Compote de pommes', value: 'Compote de pommes'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Compote de poires', value: 'Compote de poires'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Compote de pêches', value: 'Compote de pêches'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Compote d\'abricots', value: 'Compote d\'abricots')
    ];
  }

static List<SearchFieldAutoCompleteItem<String>> get getTransformer{
  return const [
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait', value: 'Lait'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage', value: 'Fromage'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Beurre', value: 'Beurre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Yaourt', value: 'Yaourt'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Miel', value: 'Miel'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de chèvre', value: 'Lait de chèvre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de dinde', value: 'Viande de dinde'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de canard', value: 'Viande de canard'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande ', value: 'Viande de canard'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de brebis', value: 'Lait de brebis'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de lapin', value: 'Viande de lapin'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Crème', value: 'Crème'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage de chèvre', value: 'Fromage de chèvre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage de brebis', value: 'Fromage de brebis'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage', value: 'Fromage'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Charcuterie', value: 'Charcuterie'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait concentré', value: 'Lait concentré'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait en poudre', value: 'Lait en poudre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Foie gras', value: 'Foie gras'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Kéfir', value: 'Kéfir'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage blanc', value: 'Fromage blanc'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage ', value: 'Fromage'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande séchée', value: 'Viande séchée'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait fermenté', value: 'Lait fermenté'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait ribot', value: 'Lait ribot'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de soja', value: 'Lait de soja'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait d\'amande', value: 'Lait d\'amande'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de coco', value: 'Lait de coco'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait d\'avoine', value: 'Lait d\'avoine'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de riz', value: 'Lait de riz'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Yaourt de soja', value: 'Yaourt de soja'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Yaourt', value: 'Yaourt'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage fondu', value: 'Fromage fondu'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage frais', value: 'Fromage frais'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage à pâte dure', value: 'Fromage à pâte dure'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage à pâte molle', value: 'Fromage à pâte molle'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage bleu', value: 'Fromage bleu'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage de chèvre frais', value: 'Fromage de chèvre frais'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage de brebis frais', value: 'Fromage de brebis frais'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage râpé', value: 'Fromage râpé'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage en tranche', value: 'Fromage en tranche'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait sans lactose', value: 'Lait sans lactose'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Crème fouettée', value: 'Crème fouettée'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Crème', value: 'Crème'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Crème glacée', value: 'Crème glacée'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande hachée', value: 'Viande hachée')
  ];
}
static List<SearchFieldAutoCompleteItem<String>> get getElevage{
  return const [
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait', value: 'Lait'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Poisson', value: 'Poisson'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Crevette', value: 'Crevette'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fruit de mer', value: 'Fruit de mer'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fromage', value: 'Fromage'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Beurre', value: 'Beurre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de boeuf', value: 'Viande de boeuf'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de poulet', value: 'Viande de poulet'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de porc', value: 'Viande de porc'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande d\'agneau', value: 'Viande d\'agneau'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Œufs', value: 'Œufs'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Miel', value: 'Miel'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de chèvre', value: 'Lait de chèvre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de dinde', value: 'Viande de dinde'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de canard', value: 'Viande de canard'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande ', value: 'Viande de canard'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lait de brebis', value: 'Lait de brebis'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de lapin', value: 'Viande de lapin'),
   
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande de mouton', value: 'Viande de mouton'),
   
    SearchFieldAutoCompleteItem<String>(searchKey: 'Foie gras', value: 'Foie gras'),
 
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande séchée', value: 'Viande séchée'),
  
    SearchFieldAutoCompleteItem<String>(searchKey: 'Viande hachée', value: 'Viande hachée')
  ];
}

static List<SearchFieldAutoCompleteItem<String>> get getFruitsAndVegetables {
  return const [
    SearchFieldAutoCompleteItem<String>(searchKey: 'Banane', value: 'Banane'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pomme', value: 'Pomme'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Tomate', value: 'Tomate'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Carotte', value: 'Carotte'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Laitue', value: 'Laitue'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Épinard', value: 'Épinard'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Brocoli', value: 'Brocoli'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fraise', value: 'Fraise'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Cerise', value: 'Cerise'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Raisin', value: 'Raisin'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Poire', value: 'Poire'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Abricot', value: 'Abricot'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pêche', value: 'Pêche'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Melon', value: 'Melon'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pastèque', value: 'Pastèque'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Orange', value: 'Orange'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Mandarine', value: 'Mandarine'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Citron', value: 'Citron'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pamplemousse', value: 'Pamplemousse'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Kiwi', value: 'Kiwi'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Ananas', value: 'Ananas'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Mangue', value: 'Mangue'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Papaye', value: 'Papaye'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Cassis', value: 'Cassis'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Groseille', value: 'Groseille'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Myrtille', value: 'Myrtille'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Framboise', value: 'Framboise'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Mûre', value: 'Mûre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pomme de terre', value: 'Pomme de terre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Oignon', value: 'Oignon'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Ail', value: 'Ail'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Poivron', value: 'Poivron'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Courgette', value: 'Courgette'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Concombre', value: 'Concombre'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Chou', value: 'Chou'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Chou-fleur', value: 'Chou-fleur'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Radis', value: 'Radis'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Navet', value: 'Navet'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Betterave', value: 'Betterave'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Artichaut', value: 'Artichaut'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Asperge', value: 'Asperge'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Céleri', value: 'Céleri'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Poireau', value: 'Poireau'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Haricot vert', value: 'Haricot vert'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Petit pois', value: 'Petit pois'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fève', value: 'Fève'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pois chiche', value: 'Pois chiche')
  ];
}

  static List<SearchFieldAutoCompleteItem<String>> get getAgriculturalInputs {
  return const [
    SearchFieldAutoCompleteItem<String>(searchKey: 'Engrais', value: 'Engrais'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Engrais azoté', value: 'Engrais azoté'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Engrais phosphaté', value: 'Engrais phosphaté'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Engrais potassique', value: 'Engrais potassique'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Engrais organique', value: 'Engrais organique'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fumier', value: 'Fumier'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Compost', value: 'Compost'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Tourbe', value: 'Tourbe'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lime', value: 'Lime'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Calcaire', value: 'Calcaire'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Dolomie', value: 'Dolomie'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Superphosphate', value: 'Superphosphate'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Sulphate d\'ammonium', value: 'Sulphate d\'ammonium'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Nitrate de potassium', value: 'Nitrate de potassium'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Nitrate de calcium', value: 'Nitrate de calcium'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Nitrate ', value: 'Nitrate'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Herbicide', value: 'Herbicide'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Insecticide', value: 'Insecticide'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Fongicide', value: 'Fongicide'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pesticide', value: 'Pesticide'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Régulateur de croissance', value: 'Régulateur de croissance'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Amendement calcique', value: 'Amendement calcique'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Amendement magnésien', value: 'Amendement magnésien'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Semences', value: 'Semences'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Plantules', value: 'Plantules'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Bulbes', value: 'Bulbes'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Racines nues', value: 'Racines nues'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Plantes en pot', value: 'Plantes en pot'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Sachets de plantation', value: 'Sachets de plantation'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pots de culture', value: 'Pots de culture'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Serres', value: 'Serres'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Systèmes d\'irrigation', value: 'Systèmes d\'irrigation'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pompes à eau', value: 'Pompes à eau'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pulvérisateurs', value: 'Pulvérisateurs'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Tuyaux d\'arrosage', value: 'Tuyaux d\'arrosage'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Goutteurs', value: 'Goutteurs'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Aspersoirs', value: 'Aspersoirs'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Bâches de paillage', value: 'Bâches de paillage'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Filets de protection', value: 'Filets de protection'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Clôtures', value: 'Clôtures'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Ruches', value: 'Ruches'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Nourriture pour animaux', value: 'Nourriture pour animaux'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Vaccins vétérinaires', value: 'Vaccins vétérinaires'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Médicaments vétérinaires', value: 'Médicaments vétérinaires'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Vitamines pour animaux', value: 'Vitamines pour animaux'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Additifs alimentaires', value: 'Additifs alimentaires'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Systèmes de traite', value: 'Systèmes de traite'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Réservoirs de lait', value: 'Réservoirs de lait'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Matériel de nettoyage', value: 'Matériel de nettoyage')
  ];
}

  static List<SearchFieldAutoCompleteItem<String>> get getMateriels {
  return const [
  
    SearchFieldAutoCompleteItem<String>(searchKey: 'Lime', value: 'Lime'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pots de culture', value: 'Pots de culture'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Serres', value: 'Serres'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Systèmes d\'irrigation', value: 'Systèmes d\'irrigation'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pompes à eau', value: 'Pompes à eau'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Pulvérisateurs', value: 'Pulvérisateurs'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Tuyaux d\'arrosage', value: 'Tuyaux d\'arrosage'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Réservoirs de lait', value: 'Réservoirs de lait'),
    SearchFieldAutoCompleteItem<String>(searchKey: 'Matériel de nettoyage', value: 'Matériel de nettoyage'),
     SearchFieldAutoCompleteItem<String>(
          searchKey: 'Pulvérisateur à dos', value: 'Pulvérisateur à dos'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Semoir à main', value: 'Semoir à main'),
           SearchFieldAutoCompleteItem<String>(
          searchKey: 'Filets de protection', value: 'Filets de protection'),
      SearchFieldAutoCompleteItem<String>(
          searchKey: 'Clôtures', value: 'Clôtures'),
      SearchFieldAutoCompleteItem<String>(searchKey: 'Ruches', value: 'Ruches'),
  ];
}

}
