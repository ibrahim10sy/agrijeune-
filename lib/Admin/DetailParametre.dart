import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koumi/models/ParametreFiche.dart';
import 'package:koumi/service/ParametreFicheService.dart';
import 'package:provider/provider.dart';

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class DetailParametre extends StatefulWidget {
  final ParametreFiche parametreFiche;

  const DetailParametre({Key? key, required this.parametreFiche})
      : super(key: key);

  @override
  State<DetailParametre> createState() => _DetailParametreState();
}

class _DetailParametreState extends State<DetailParametre> {
  bool _isEditing = false;
  TextEditingController _libelleController = TextEditingController();
  TextEditingController _classeController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  TextEditingController _listeController = TextEditingController();
  TextEditingController _valeurMaxController = TextEditingController();
  TextEditingController _valeurMinController = TextEditingController();
  TextEditingController _valeurObligatoireController = TextEditingController();
  TextEditingController _dateAController = TextEditingController();
  TextEditingController _dateMController = TextEditingController();
  TextEditingController _critereController = TextEditingController();
  TextEditingController _champController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _libelleController.text = widget.parametreFiche.libelleParametre;
    _classeController.text = widget.parametreFiche.classeParametre;
    _typeController.text = widget.parametreFiche.typeDonneeParametre;
    _listeController.text =
        widget.parametreFiche.listeDonneeParametre.join(', ');
    _valeurMaxController.text = widget.parametreFiche.valeurMax.toString();
    _champController.text = widget.parametreFiche.champParametre;
    _valeurMinController.text = widget.parametreFiche.valeurMin.toString();
    _valeurObligatoireController.text =
        widget.parametreFiche.valeurObligatoire.toString();
    _dateAController.text = widget.parametreFiche.dateAjout ?? 'N/A';
    _dateMController.text = widget.parametreFiche.dateModif ?? 'N/A';
    _critereController.text = widget.parametreFiche.critereChampParametre;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: d_colorGreen,
        centerTitle: true,
        toolbarHeight: 75,
        leading: _isEditing
            ? Container()
            : IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen),
              ),
        title: Text(
          'Détails paramètre',
          style: const TextStyle(
              color: d_colorGreen, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          _isEditing
              ? IconButton(
                  onPressed: () async {
                    setState(() {
                      _isEditing = false;
                    });
                    try {
                      final String classeParam = _classeController.text;
                      final String champParam = _champController.text;
                      final String libelle = _libelleController.text;
                      final String type = _typeController.text;
                      final String valeurM = _valeurMaxController.text;
                      final String valeurMi = _valeurMinController.text;
                      final String valeurOb = _valeurObligatoireController.text;
                      final String critere = _critereController.text;
                      final List<String> liste = _listeController.text
                          .split(',')
                          .map((e) => e.trim())
                          .toList();

                      await ParametreFicheService()
                          .updateParametre(
                              idParametreFiche:
                                  widget.parametreFiche.idParametreFiche,
                              classeParametre: classeParam,
                              champParametre: champParam,
                              libelleParametre: libelle,
                              typeDonneeParametre: type,
                              listeDonneeParametre: liste,
                              valeurMax: valeurM,
                              valeurMin: valeurMi,
                              valeurObligatoire: valeurOb,
                              critereChampParametre: critere)
                          .then((value) => {
                                print("Modifier avec succèss"),
                                Provider.of<ParametreFicheService>(context,
                                        listen: false)
                                    .applyChange(),
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Text("Modifier avec succèss "),
                                      ],
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                )
                              })
                          .catchError((onError) => {print(onError.toString())});
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  icon: Icon(Icons.check),
                )
              : IconButton(
                  onPressed: () async {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: Icon(Icons.edit),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableDetailItem('Libellé Paramètre:', _libelleController),
            _buildEditableDetailItem('Classe Paramètre:', _classeController),
            _buildEditableDetailItem('Champ Paramètre:', _champController),
            _buildEditableDetailItem(
                'Type Donnée Paramètre :', _typeController),
            _buildEditableDetailItem(
                'Liste Donnée Paramètre :', _listeController),
            _isEditing
                ? Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: d_colorGreen,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Valeur Max',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _valeurMaxController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black54,
                        ),
                        enabled: _isEditing,
                      ),
                    ],
                  )
                : _buildDetailItem(
                    'Valeur Max :', widget.parametreFiche.valeurMax.toString()),
            _isEditing
                ? Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: d_colorGreen,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Valeur Min',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _valeurMinController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black54,
                        ),
                        enabled: _isEditing,
                      ),
                    ],
                  )
                : _buildDetailItem(
                    'Valeur Min :', widget.parametreFiche.valeurMin.toString()),
            _isEditing
                ? Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: d_colorGreen,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Valeur Obligatoire ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _valeurObligatoireController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black54,
                        ),
                        enabled: _isEditing,
                      ),
                    ],
                  )
                : _buildDetailItem('Valeur Obligatoire :',
                    widget.parametreFiche.valeurObligatoire.toString()),
            // _buildEditableDetailItem(
            //     'Valeur Obligatoire :', _valeurObligatoireController),
            // _buildEditableDetailItem('Date Ajout :', _dateAController),
            // _buildEditableDetailItem('Date Modification :', _dateMController),
            _buildEditableDetailItem(
                'Critère Champ Paramètre :', _critereController),
            _buildDetailItem('Statut Paramètre:',
                widget.parametreFiche.statutParametre ? 'Actif' : 'Inactif'),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableDetailItem(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: d_colorGreen,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black54,
            ),
            enabled: _isEditing,
          ),
          // Divider(),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: d_colorGreen,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ), // Met en gras la valeur
          ),
          Divider(), // Ajoute un séparateur
        ],
      ),
    );
  }
}


  // _buildDetailItem('Statut Paramètre:',
  //               parametreFiche.statutParametre ? 'Actif' : 'Inactif'),