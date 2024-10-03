import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:koumi/models/Conseil.dart';
import 'package:koumi/widgets/PlayerWidget.dart';
import 'package:readmore/readmore.dart';
import 'package:video_player/video_player.dart';

class DetailConseil extends StatefulWidget {
  final Conseil conseil;
  const DetailConseil({super.key, required this.conseil});

  @override
  State<DetailConseil> createState() => _DetailConseilState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _DetailConseilState extends State<DetailConseil> {
  late Conseil conseils;
  late AudioPlayer player = AudioPlayer();
  FlickManager? flickManager;

  @override
  void initState() {
    super.initState();
    conseils = widget.conseil;

    verifyAudioSource();
    verifyVideoSource();
  }

  void verifyAudioSource() {
    try {
      if (conseils.audioConseil != null && conseils.audioConseil!.isNotEmpty) {
        player = AudioPlayer();

        // Set the release mode to keep the source after playback has completed.
        player.setReleaseMode(ReleaseMode.stop);

        // Start the player as soon as the app is displayed.
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          String audioPath =
              'https://koumi.ml/api-koumi/conseil/${conseils.idConseil}/audio';

          await player.play(UrlSource(audioPath));
          await player.pause();
        });
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Text("Audio non disponible"),
            ],
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void verifyVideoSource() {
    try {
      if (conseils.videoConseil != null && conseils.videoConseil!.isNotEmpty) {
        flickManager = FlickManager(
          autoPlay: false,
          videoPlayerController: VideoPlayerController.networkUrl(
            Uri.parse(
                'https://koumi.ml/api-koumi/conseil/${conseils.idConseil}/video'),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Text("Video non disponible"),
            ],
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose the player.
    player.dispose();

    // Check if flickManager is not null before disposing.
    flickManager?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
            backgroundColor: d_colorOr,
            centerTitle: true,
            toolbarHeight: 75,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'Détail conseil',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            conseils.photoConseil != null && !conseils.photoConseil!.isEmpty
                ? CachedNetworkImage(
                    width: double.infinity,
                    height: 200,
                    imageUrl:
                        'https://koumi.ml/api-koumi/conseil/${conseils.idConseil}/image',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/default_image.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    "assets/images/default_image.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Titre conseil',
                style: const TextStyle(
                    color: d_colorGreen,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                conseils.titreConseil,
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 18),
              ),
            ),
            conseils.videoConseil != null && conseils.videoConseil!.isNotEmpty
                ? _videoBuild()
                : Container(),
            _descriptionBuild(),
            conseils.audioConseil != null && conseils.audioConseil!.isNotEmpty
                ? _audioBuild()
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _videoBuild() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Vidéo',
            style: TextStyle(
              color: d_colorGreen,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FlickVideoPlayer(
                  flickManager: flickManager!,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _videoBuild() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Text(
  //           'Vidéo',
  //           style: TextStyle(
  //             color: d_colorGreen,
  //             fontWeight: FontWeight.w500,
  //             fontSize: 20,
  //           ),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: AspectRatio(
  //           aspectRatio: 18 / 10,
  //           child: FlickVideoPlayer(flickManager: flickManager!),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _descriptionBuild() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Description',
            style: TextStyle(
              color: d_colorGreen,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: ReadMoreText(
              colorClickableText: Colors.orange,
              trimLines: 2,
              trimMode: TrimMode.Line,
              trimCollapsedText: "Lire plus",
              trimExpandedText: "Lire moins",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              conseils.descriptionConseil),
        ),
      ],
    );
  }

  Widget _audioBuild() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Vocal',
            style: TextStyle(
              color: d_colorGreen,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PlayerWidget(player: player),
        ),
      ],
    );
  }
}
