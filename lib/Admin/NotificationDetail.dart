import 'package:flutter/material.dart';
import 'package:koumi/models/MessageWa.dart';

class NotificationDetail extends StatefulWidget {
  final MessageWa messageWa;
  const NotificationDetail({Key? key, required this.messageWa})
      : super(key: key);

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _NotificationDetailState extends State<NotificationDetail> {
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
          "Détails",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   "ID Message: ${widget.messageWa.idMessage}",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // SizedBox(height: 10),
            // Text(
            //   "Code Message: ${widget.messageWa.codeMessage}",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // SizedBox(height: 10),
            // if (widget.messageWa.personneModif != null)
            //   Text(
            //     "Personne Modifiée: ${widget.messageWa.personneModif!}",
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
            // SizedBox(height: 10),
            Text(
              "Texte: ${widget.messageWa.text}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (widget.messageWa.dateAjout != null)
              Text(
                "Date : ${widget.messageWa.dateAjout!}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 10),
            // if (widget.messageWa.acteurConcerner != null)
            //   Text(
            //     "Acteur Concerné: ${widget.messageWa.acteurConcerner!}",
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //   ),
          ],
        ),
      ),
    );
  }
}
