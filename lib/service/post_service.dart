import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';
import 'image_service.dart';

class PostsService {
  static const String baseUrl = 'http://localhost:8080'; // Pour l'émulateur Android
  final ImageService _imageService = ImageService();
  // Utilisez 'http://localhost:8080' pour le web

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/all'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Raw API Response: ${response.body}'); // Add this
        final List<dynamic> postsJson = data['data'];
        final posts = postsJson.map((json) => Post.fromJson(json)).toList();
        print('Parsed Posts: $posts'); // Add this
        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deletePost(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/post/delete/$id'),
      );

      if (response.statusCode == 200) {
        print('Post supprimé avec succès.');
      } else {
        print('Erreur lors de la suppression : ${response.statusCode}, ${response.body}');
        throw Exception('Échec de la suppression du post. Statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du post: $e');
    }
  }


  Future<Post> createPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/post/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': post.title,
          'author': post.author,
          'content': post.content,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Post.fromJson(responseData['data']);
      } else {
        throw Exception('Échec de la création du post');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du post: $e');
    }
  }

  Future<Post> updatePost(Post post) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/post/update/${post.postId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': post.title,
          'author': post.author,
          'content': post.content,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Post.fromJson(responseData['data']);
      } else {
        print('Erreur lors de la mise à jour : ${response.statusCode}, ${response.body}');
        throw Exception('Échec de la mise à jour du post. Statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du post: $e');
    }
  }

  // Création d'un post avec images
  Future<Post> createPostWithImages(Post post, List<File> images) async {
    try {
      // 1. Créer d'abord le post
      final createdPost = await createPost(post);

      // 2. Si des images sont fournies, les upload
      if (images.isNotEmpty) {
        final uploadedImages = await _imageService.uploadImages(
            images,
            createdPost.postId
        );

        // 3. Retourner le post avec les images
        return Post(
          postId: createdPost.postId,
          title: createdPost.title,
          content: createdPost.content,
          author: createdPost.author,
          images: uploadedImages,
        );
      }

      return createdPost;
    } catch (e) {
      throw Exception('Error creating post with images: $e');
    }
  }


  Future<Post> updatePostWithImages(Post post, List<File> newImages, List<int> imageIdsToDelete) async {
    try {
      // 1. Supprimer les images marquées pour suppression
      for (var imageId in imageIdsToDelete) {
        await _imageService.deleteImage(imageId);
      }

      // 2. Upload les nouvelles images (s'il y en a)
      if (newImages.isNotEmpty) {
        await _imageService.uploadImages(newImages, post.postId);
      }

      // 3. Mettre à jour le post
      return updatePost(post);
    } catch (e) {
      throw Exception('Error updating post with images: $e');
    }
  }


}