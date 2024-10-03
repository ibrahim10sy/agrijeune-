import 'dart:async';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Alertes.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/AlerteService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';

class UpdateAlerted extends StatefulWidget {
  final Alertes alertes;
  const UpdateAlerted({super.key, required this.alertes});

  @override
  State<UpdateAlerted> createState() => _UpdateAlertedState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _UpdateAlertedState extends State<UpdateAlerted> {
  TextEditingController _titreController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool isRecorderReady = false;
  late Acteur acteur = Acteur();
  bool _isLoading = false;
  String? imageSrc;
  File? photoUploaded;
  File? _videoUploaded;
  late String videoSrc;
  File? audiosUploaded;
  final _tokenTextController = TextEditingController();
  final _tokenAudioController = TextEditingController();
  final _tokenImageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  double _progressValue = 0;
  bool _hasUploadStarted = false;
  late Alertes alerte;
  String selectedCountry = "";
  String selectedCountryCode = "";
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isRecording = false, isPlaying = false;
  String? recordingPath;
  Timer? _timer;
  int _elapsedSeconds = 0;

  void setProgress(double value) async {
    setState(() {
      _progressValue = value;
    });
  }

  Future<void> _showAudioSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: const Text('Choisir une source'),
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    _recordingButton();
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.mic, size: 40),
                      Text('Enregistrer'),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    // _pickAudio(); // Appel à la fonction pour sélectionner un fichier audio
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.audiotrack, size: 40),
                      Text('Sélectionner un fichier'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(imagePath);
    final images = File('${directory.path}/$name');
    return images;
  }

  Future<void> _pickVideo(ImageSource source) async {
    final video = await ImagePicker().pickVideo(source: source);
    if (video == null) return;

    final videoFile = File(video.path);
    setState(() {
      _videoUploaded = videoFile;
      _tokenTextController.text = _videoUploaded!.path.toString();
      videoSrc = videoFile.path;
      _hasUploadStarted = true;
    });

    // Mocking upload progress
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(Duration(milliseconds: 40));
      setProgress(i / 100);
    }

    setState(() {
      _hasUploadStarted = false;
    });
  }

  Future<void> _showVideoSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: const Text('Choisir une source'),
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    _pickVideo(ImageSource.camera);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.videocam, size: 40),
                      Text('Camera'),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    _pickVideo(ImageSource.gallery);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.video_library, size: 40),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final images = await getImage(source);
    if (images != null) {
      setState(() {
        photoUploaded = images;
        _tokenImageController.text = photoUploaded!.path.toString();

        imageSrc = images.path;
      });
    }
  }

  Future<File?> getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;

    return File(image.path);
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: const Text('Choisir une source'),
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    _pickImage(ImageSource.camera);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.camera_alt, size: 40),
                      Text('Camera'),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    _pickImage(ImageSource.gallery);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.image, size: 40),
                      Text('Galerie photo'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startTimer() {
    _elapsedSeconds = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (!isRecording) {
        timer.cancel();
      } else {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    alerte = widget.alertes;
    _titreController.text = alerte.titreAlerte!;
    _descriptionController.text = alerte.descriptionAlerte!;
    _tokenAudioController.text = alerte.audioAlerte!;
    _tokenImageController.text = alerte.photoAlerte!;
    _tokenTextController.text = alerte.videoAlerte!;
    selectedCountry = alerte.pays != null ? alerte.pays! : "";
    selectedCountryCode = alerte.codePays != null ? alerte.codePays! : "";
  }

  Map<String, String> countryTranslations = {
    'Afghanistan': 'Afghanistan',
    'Albania': 'Albanie',
    'Algeria': 'Algérie',
    'Andorra': 'Andorre',
    'Angola': 'Angola',
    'Argentina': 'Argentine',
    'Armenia': 'Arménie',
    'Australia': 'Australie',
    'Austria': 'Autriche',
    'Azerbaijan': 'Azerbaïdjan',
    'Bahamas': 'Bahamas',
    'Bahrain': 'Bahreïn',
    'Bangladesh': 'Bangladesh',
    'Barbados': 'Barbade',
    'Belarus': 'Biélorussie',
    'Belgium': 'Belgique',
    'Belize': 'Belize',
    'Benin': 'Bénin',
    'Bhutan': 'Bhoutan',
    'Bolivia': 'Bolivie',
    'Bosnia and Herzegovina': 'Bosnie-Herzégovine',
    'Botswana': 'Botswana',
    'Brazil': 'Brésil',
    'Brunei': 'Brunéi',
    'Bulgaria': 'Bulgarie',
    'Burkina Faso': 'Burkina Faso',
    'Burundi': 'Burundi',
    'Cabo Verde': 'Cap-Vert',
    'Cambodia': 'Cambodge',
    'Cameroon': 'Cameroun',
    'Canada': 'Canada',
    'Central African Republic': 'République centrafricaine',
    'Chad': 'Tchad',
    'Chile': 'Chili',
    'China': 'Chine',
    'Colombia': 'Colombie',
    'Comoros': 'Comores',
    'Congo': 'Congo Brazzaville',
    'Costa Rica': 'Costa Rica',
    'Croatia': 'Croatie',
    'Cuba': 'Cuba',
    'Cyprus': 'Chypre',
    'Czechia (Czech Republic)': 'Tchéquie (République tchèque)',
    'Congo, The Democratic Republic of the Congo':
        'République démocratique du Congo',
    'Denmark': 'Danemark',
    'Djibouti': 'Djibouti',
    'Dominica': 'Dominique',
    'Dominican Republic': 'République dominicaine',
    'Ecuador': 'Équateur',
    'Egypt': 'Égypte',
    'El Salvador': 'El Salvador',
    'Equatorial Guinea': 'Guinée équatoriale',
    'Eritrea': 'Érythrée',
    'Estonia': 'Estonie',
    'Eswatini': 'Eswatini',
    'Ethiopia': 'Éthiopie',
    'Fiji': 'Fidji',
    'Finland': 'Finlande',
    'France': 'France',
    'Gabon': 'Gabon',
    'Gambia': 'Gambie',
    'Georgia': 'Géorgie',
    'Germany': 'Allemagne',
    'Ghana': 'Ghana',
    'Greece': 'Grèce',
    'Grenada': 'Grenade',
    'Guatemala': 'Guatemala',
    'Guinea': 'Guinée',
    'Guinea-Bissau': 'Guinée-Bissau',
    'Guyana': 'Guyana',
    'Haiti': 'Haïti',
    'Honduras': 'Honduras',
    'Hungary': 'Hongrie',
    'Iceland': 'Islande',
    'India': 'Inde',
    'Indonesia': 'Indonésie',
    'Iran': 'Iran',
    'Iraq': 'Irak',
    'Ireland': 'Irlande',
    'Israel': 'Israël',
    'Italy': 'Italie',
    'Ivory Coast': 'Côte d\'Ivoire',
    'Jamaica': 'Jamaïque',
    'Japan': 'Japon',
    'Jordan': 'Jordanie',
    'Kazakhstan': 'Kazakhstan',
    'Kenya': 'Kenya',
    'Kiribati': 'Kiribati',
    'Kuwait': 'Koweït',
    'Kyrgyzstan': 'Kirghizistan',
    'Laos': 'Laos',
    'Latvia': 'Lettonie',
    'Lebanon': 'Liban',
    'Lesotho': 'Lesotho',
    'Liberia': 'Libéria',
    'Libya': 'Libye',
    'Liechtenstein': 'Liechtenstein',
    'Lithuania': 'Lituanie',
    'Luxembourg': 'Luxembourg',
    'Madagascar': 'Madagascar',
    'Malawi': 'Malawi',
    'Malaysia': 'Malaisie',
    'Maldives': 'Maldives',
    'Mali': 'Mali',
    'Malta': 'Malte',
    'Marshall Islands': 'Îles Marshall',
    'Mauritania': 'Mauritanie',
    'Mauritius': 'Maurice',
    'Mexico': 'Mexique',
    'Micronesia': 'Micronésie',
    'Moldova': 'Moldavie',
    'Monaco': 'Monaco',
    'Mongolia': 'Mongolie',
    'Montenegro': 'Monténégro',
    'Morocco': 'Maroc',
    'Mozambique': 'Mozambique',
    'Myanmar (Burma)': 'Myanmar (Birmanie)',
    'Namibia': 'Namibie',
    'Nauru': 'Nauru',
    'Nepal': 'Népal',
    'Netherlands': 'Pays-Bas',
    'New Zealand': 'Nouvelle-Zélande',
    'Nicaragua': 'Nicaragua',
    'Niger': 'Niger',
    'Nigeria': 'Nigeria',
    'North Korea': 'Corée du Nord',
    'North Macedonia': 'Macédoine du Nord',
    'Norway': 'Norvège',
    'Oman': 'Oman',
    'Pakistan': 'Pakistan',
    'Palau': 'Palaos',
    'Palestine State': 'État de Palestine',
    'Panama': 'Panama',
    'Papua New Guinea': 'Papouasie-Nouvelle-Guinée',
    'Paraguay': 'Paraguay',
    'Peru': 'Pérou',
    'Philippines': 'Philippines',
    'Poland': 'Pologne',
    'Portugal': 'Portugal',
    'Qatar': 'Qatar',
    'Romania': 'Roumanie',
    'Russia': 'Russie',
    'Rwanda': 'Rwanda',
    'Saint Kitts and Nevis': 'Saint-Kitts-et-Nevis',
    'Saint Lucia': 'Sainte-Lucie',
    'Saint Vincent and the Grenadines': 'Saint-Vincent-et-les-Grenadines',
    'Samoa': 'Samoa',
    'San Marino': 'Saint-Marin',
    'Sao Tome and Principe': 'Sao Tomé-et-Principe',
    'Saudi Arabia': 'Arabie saoudite',
    'Senegal': 'Sénégal',
    'Serbia': 'Serbie',
    'Seychelles': 'Seychelles',
    'Sierra Leone': 'Sierra Leone',
    'Singapore': 'Singapour',
    'Slovakia': 'Slovaquie',
    'Slovenia': 'Slovénie',
    'Solomon Islands': 'Îles Salomon',
    'Somalia': 'Somalie',
    'South Africa': 'Afrique du Sud',
    'South Korea': 'Corée du Sud',
    'South Sudan': 'Soudan du Sud',
    'Spain': 'Espagne',
    'Sri Lanka': 'Sri Lanka',
    'Sudan': 'Soudan',
    'Suriname': 'Suriname',
    'Sweden': 'Suède',
    'Switzerland': 'Suisse',
    'Syria': 'Syrie',
    'Taiwan': 'Taïwan',
    'Tajikistan': 'Tadjikistan',
    'Tanzania': 'Tanzanie',
    'Thailand': 'Thaïlande',
    'Timor-Leste': 'Timor oriental',
    'Togo': 'Togo',
    'Tonga': 'Tonga',
    'Trinidad and Tobago': 'Trinité-et-Tobago',
    'Tunisia': 'Tunisie',
    'Turkey': 'Turquie',
    'Turkmenistan': 'Turkménistan',
    'Tuvalu': 'Tuvalu',
    'Uganda': 'Ouganda',
    'Ukraine': 'Ukraine',
    'United Arab Emirates': 'Émirats arabes unis',
    'United Kingdom': 'Royaume-Uni',
    'United States of America': 'États-Unis d\'Amérique',
    'Uruguay': 'Uruguay',
    'Uzbekistan': 'Ouzbékistan',
    'Vanuatu': 'Vanuatu',
    'Vatican City': 'Vatican',
    'Venezuela': 'Venezuela',
    'Vietnam': 'Vietnam',
    'Yemen': 'Yémen',
    'Zambia': 'Zambie',
    'Zimbabwe': 'Zimbabwe',
  };

  @override
  void dispose() {
    super.dispose();
    _tokenTextController.dispose();
    _tokenAudioController.dispose();
    _tokenImageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 250, 250, 250),
            appBar: AppBar(
                backgroundColor: d_colorGreen,
                centerTitle: true,
                toolbarHeight: 75,
                leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    )),
                title: const Text(
                  "Modification",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            body: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     SizedBox(
                      height: 10,
                    ),
                    Form(
                        key: formkey,
                        child: Column(children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Titre Alerte",
                                style: TextStyle(
                                    color: (Colors.black), fontSize: 18),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez remplir les champs";
                                }
                                return null;
                              },
                              controller: _titreController,
                              decoration: InputDecoration(
                                hintText: "titre Alerte",
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Description",
                                style: TextStyle(
                                    color: (Colors.black), fontSize: 18),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez remplir les champs";
                                }
                                return null;
                              },
                              controller: _descriptionController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: "Description",
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Pays Alerte",
                                style: TextStyle(
                                    color: (Colors.black), fontSize: 18),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                  color:
                                      Colors.black26, // Couleur de la bordure
                                  width: 2, // Largeur de la bordure
                                ),
                              ),
                              child: CountryCodePicker(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                backgroundColor: Colors
                                    .transparent, // Fond transparent pour le picker
                                onChanged: (CountryCode countryCode) {
                                  setState(() {
                                    selectedCountry = countryCode.name!;
                                    selectedCountryCode = countryCode.code!;
                                    selectedCountry = countryTranslations[
                                            countryCode.name.toString()] ??
                                        countryCode.name.toString();
                                    print('Country Origin : ' +
                                        countryCode.name.toString());
                                    print('Country changed to: ' +
                                        selectedCountry!);
                                    print("Pays : $selectedCountry");
                                  });
                                },
                                showDropDownButton: true,
                                initialSelection:
                                    selectedCountry, // Set initial selection based on detected country code
                                showCountryOnly: true,
                                showOnlyCountryWhenClosed: true,
                                alignLeft: true,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _tokenTextController.text.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 22,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Video Source",
                                      style: TextStyle(
                                          color: (Colors.black), fontSize: 18),
                                    ),
                                  ),
                                )
                              : Container(),
                          _tokenTextController.text.isNotEmpty
                              ? _videoUploade()
                              : Container(),
                          _tokenImageController.text.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 22,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Image Source",
                                      style: TextStyle(
                                          color: (Colors.black), fontSize: 18),
                                    ),
                                  ),
                                )
                              : Container(),
                          _tokenImageController.text.isNotEmpty
                              ? _imageUploade()
                              : Container(),
                          _tokenAudioController.text.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 22,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Audio Source",
                                      style: TextStyle(
                                          color: (Colors.black), fontSize: 18),
                                    ),
                                  ),
                                )
                              : Container(),
                          _tokenAudioController.text.isNotEmpty
                              ? _audioUploade()
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          isRecording
                              ? Text(
                                  'Durée: ${_elapsedSeconds}s',
                                  style: TextStyle(fontSize: 20),
                                )
                              : Container(),
                          _hasUploadStarted
                              ? LinearProgressIndicator(
                                  color: d_colorGreen,
                                  backgroundColor: d_colorGreen,
                                  value: _progressValue,
                                )
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.camera,
                                  size: 30,
                                ),
                                onPressed: _showImageSourceDialog,
                              ),
                              IconButton(
                                  onPressed: _showVideoSourceDialog,
                                  icon: Icon(
                                    Icons.video_camera_front_rounded,
                                    size: 30,
                                  )),
                              _recordingButton()
                            ],
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                if (formkey.currentState!.validate()) {
                                  final String titre = _titreController.text;
                                  final String description =
                                      _descriptionController.text;
                                  final String videoFile =
                                      _tokenTextController.text;
                                  try {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    if (_videoUploaded != null ||
                                        photoUploaded != null ||
                                        audiosUploaded != null) {
                                      await AlertesService()
                                          .updateAlertes(
                                              idAlerte: alerte.idAlerte!,
                                              titreAlerte: titre,
                                              descriptionAlerte: description,
                                              pays: selectedCountry,
                                              codePays:
                                                  selectedCountryCode.isNotEmpty
                                                      ? selectedCountryCode
                                                      : "ML",
                                              videoAlerte: _videoUploaded,
                                              photoAlerte: photoUploaded,
                                              audioAlerte: audiosUploaded)
                                          .then((value) => {
                                                _titreController.clear(),
                                                _descriptionController.clear(),
                                                _tokenTextController.clear(),
                                                _tokenAudioController.clear(),
                                                _tokenImageController.clear(),
                                                setState(() {
                                                  _videoUploaded = null;
                                                  photoUploaded = null;
                                                  audiosUploaded = null;
                                                  _isLoading = false;
                                                }),
                                                Provider.of<AlertesService>(
                                                        context,
                                                        listen: false)
                                                    .applyChange(),
                                                Navigator.of(context).pop()
                                              })
                                          .catchError((onError) => {
                                                setState(() {
                                                  _isLoading = false;
                                                }),
                                                print("Error: " +
                                                    onError.toString()),
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Text(
                                                          "Une erreur est survenu lors de la modification",
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ],
                                                    ),
                                                    duration:
                                                        Duration(seconds: 5),
                                                  ),
                                                )
                                              });
                                    } else {
                                      await AlertesService()
                                          .updateAlertes(
                                              idAlerte: alerte.idAlerte!,
                                              titreAlerte: titre,
                                              pays: selectedCountry,
                                              codePays:
                                                  selectedCountryCode.isNotEmpty
                                                      ? selectedCountryCode
                                                      : "ML",
                                              descriptionAlerte: description)
                                          .then((value) => {
                                                _titreController.clear(),
                                                _descriptionController.clear(),
                                                _tokenTextController.clear(),
                                                setState(() {
                                                  _isLoading = false;
                                                }),
                                                Provider.of<AlertesService>(
                                                        context,
                                                        listen: false)
                                                    .applyChange(),
                                                Navigator.of(context).pop()
                                              })
                                          .catchError((onError) => {
                                                setState(() {
                                                  _isLoading = false;
                                                }),
                                                print("Error: " +
                                                    onError.toString()),
                                              });
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    print("Error: " + e.toString());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Text(
                                              "Une erreur est survenu lors de la modification",
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.orange, // Orange color code
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                minimumSize: const Size(290, 45),
                              ),
                              child: Text(
                                "Modifier",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ))
                        ]))
                  ]),
            )));
  }

  Widget _recordingButton() {
    return IconButton(
      icon: Icon(
        isRecording ? Icons.stop : Icons.mic,
        size: 30,
      ),
      onPressed: () async {
        if (isRecording) {
          String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filePath;
              audiosUploaded = File(filePath);
              print("My Audio path : ${audiosUploaded}");
              _tokenAudioController.text = filePath;
            });
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocumentsDir =
                await getApplicationDocumentsDirectory();
            final String filePath =
                path.join(appDocumentsDir.path, "recording.wav");
            await audioRecorder.start(const RecordConfig(), path: filePath);
            setState(() {
              isRecording = true;
              recordingPath = null;
            });
            _startTimer();
          }
        }
      },
    );
  }

  Widget _videoUploade() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        cursorColor: d_colorGreen,
        decoration: InputDecoration(
          hintText: "video upload",
          enabled: false,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        controller: _tokenTextController,
      ),
    );
  }

  Widget _imageUploade() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        cursorColor: d_colorGreen,
        decoration: InputDecoration(
          hintText: "Image upload",
          enabled: false,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        controller: _tokenImageController,
      ),
    );
  }

  Widget _audioUploade() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        cursorColor: d_colorGreen,
        decoration: InputDecoration(
          hintText: "Audio upload",
          enabled: false,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        controller: _tokenAudioController,
      ),
    );
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 60),
        showCloseIcon: true);
  }

  void showSnackBar(BuildContext context, String message,
      {Color? backgroundColor,
      Duration duration = const Duration(seconds: 4),
      bool showCloseIcon = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        showCloseIcon: showCloseIcon,
      ),
    );
  }
}
