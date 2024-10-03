import 'package:flutter/material.dart';

class ParametreRegroupePage extends StatefulWidget {
  const ParametreRegroupePage({super.key});

  @override
  State<ParametreRegroupePage> createState() => _ParametreRegroupePageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);


class _ParametreRegroupePageState extends State<ParametreRegroupePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: d_colorGreen,
        centerTitle: true,
        toolbarHeight: 75,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
        title: Text(
          "Parametre regroupée",
          style: TextStyle(
              color: d_colorGreen,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showDialog();
            },
            icon: const Icon(
              Icons.add,
              color: d_colorGreen,
              size: 30,
            ),
          )
        ],
      ),
    );
  }

  void _showDialog() {}
}
