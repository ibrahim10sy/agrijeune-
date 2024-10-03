import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

   LoadingOverlay({
    required this.isLoading,
    required this.child,
     this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        isLoading
            ? Container(
                color: Colors.black.withOpacity(0.5), // Opacité pour l'arrière-plan
                child: Center(
                  child: CircularProgressIndicator(
                      backgroundColor: (Color.fromARGB(255, 245, 212, 169)),
          color: (Colors.orange),
                  ), 
                  // Indicateur de chargement
                ),
              )
            : SizedBox(), // Utilisé pour cacher l'indicateur de chargement
      ],
    );
  }
}







/*
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  LoadingOverlay({
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        isLoading
            ? Container(
                color: Colors.black.withOpacity(0.5), // Opacité pour l'arrière-plan
                child: Center(
                  child: SizedBox(
                    width: 200, // Largeur du cercle de chargement
                    height: 200, // Hauteur du cercle de chargement
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cercle de chargement
                        CircularProgressIndicator(
                          backgroundColor: (Color.fromARGB(255, 245, 212, 169)),
                          color: (Colors.orange),
                          strokeWidth: 4, // Épaisseur du cercle
                        ),
                        // Image centrée à l'intérieur du cercle de chargement
                        Container(
                          width: 40, // Largeur de l'image
                          height: 40, // Hauteur de l'image
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/logo.png', // Remplacez 'assets/loading_image.png' par le chemin de votre image
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(), // Utilisé pour cacher l'indicateur de chargement
      ],
    );
  }
}

*/