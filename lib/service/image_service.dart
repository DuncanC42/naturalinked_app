import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/image_model.dart';

class ImageService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<PostImage>> uploadImages(List<File> images, int postId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/images/upload'),
      );

      // Ajouter le postId
      request.fields['postId'] = postId.toString();

      // Ajouter chaque image
      for (var image in images) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();

        var multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: image.path
              .split('/')
              .last,
        );

        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var decodedResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        List<dynamic> imagesJson = decodedResponse['data'];
        return imagesJson.map((json) => PostImage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to upload images');
      }
    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }

  // Télécharge l'image en utilisant son ID
  Future<Uint8List> downloadImage(int imageId) async {
    final url = '$baseUrl/images/image/download/$imageId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes; // Retourne les données binaires de l'image
    } else {
      throw Exception(
          'Erreur lors du téléchargement de l\'image: ${response.statusCode}');
    }
  }



Future<void> deleteImage(int imageId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/images/image/$imageId/delete'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete image');
    }
  } catch (e) {
    throw Exception('Error deleting image: $e');
  }
}}