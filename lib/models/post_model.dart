class Post {
  final int id;
  final String title;
  final String content;
  final String author;
  final String? imageUrl; // Nouveau champ pour l'URL de l'image

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    this.imageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      author: json['author'],
      title: json['title'],
      content: json['content'],
    );
  }
}