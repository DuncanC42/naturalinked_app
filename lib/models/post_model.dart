import 'image_model.dart';

class Post {
  final int postId;
  final String title;
  final String content;
  final String author;
  final List<PostImage> images; // Nouvelle propriété

  Post({
    required this.postId,
    required this.title,
    required this.content,
    required this.author,
    this.images = const [], // Par défaut liste vide
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] ?? 0,
      author: json['author'] ?? 'Unknown',
      title: json['title'] ?? 'No Title',
      content: json['content'] ?? 'No Content',
      images: (json['images'] as List<dynamic>?)
          ?.map((imageJson) => PostImage.fromJson(imageJson))
          .toList() ?? [],
    );
  }
}
