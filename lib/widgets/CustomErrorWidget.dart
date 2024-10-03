import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? errorMessage;

  CustomErrorWidget({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center(
            //     child: Image.asset(
            //   'assets/images/fav.png',
            //   height: 150,
            //   width: 150,
            // )),
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50.0,
            ),
            SizedBox(height: 10.0),
            Text(
              'Oups une erreur s\'est produite !',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            // SizedBox(height: 10.0),
            // Text(
            //   errorMessage!,
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 16.0),
            // ),
          ],
        ),
      ),
    );
  }
}
