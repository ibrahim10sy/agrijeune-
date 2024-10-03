import 'package:flutter/material.dart';

class AlerteScreen extends StatefulWidget {
  const AlerteScreen({super.key});

  @override
  State<AlerteScreen> createState() => _AlerteScreenState();
}

class _AlerteScreenState extends State<AlerteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
            centerTitle: true,
            toolbarHeight: 100,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios)),
            title: const Text(
              "Panier",
            )));
  }
}