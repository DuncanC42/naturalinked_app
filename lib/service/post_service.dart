import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class PostsService {
  static const String baseUrl = 'http://localhost:8080'; // Pour l'émulateur Android
  // Utilisez 'http://localhost:8080' pour le web

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/all'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> postsJson = data['data'];
        return postsJson.map((json) => Post.fromJson(json)).toList();
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

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      throw Exception('Error deleting post: $e');
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
        Uri.parse('$baseUrl/posts/post/update/${post.id}'),
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
        throw Exception('Échec de la mise à jour du post');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du post: $e');
    }
  }
}





