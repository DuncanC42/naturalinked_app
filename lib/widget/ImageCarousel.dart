import 'package:flutter/material.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Hauteur fixe pour les images
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Défilement horizontal
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Espace entre les images
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Coins arrondis pour chaque image
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover, // Redimensionne l'image pour qu'elle occupe tout l'espace
                width: 150, // Largeur fixe pour chaque image
              ),
            ),
          );
        },
      ),
    );
  }
}
