// post_screen.dart
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../service/post_service.dart';
import 'PostComponent.dart';
import 'new_post.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final PostsService _postsService = PostsService();
  late Future<List<Post>> _posts;

  void _refreshPosts() {
    setState(() {
      _posts = _postsService.fetchPosts();
    });
  }

  @override
  void initState() {
    super.initState();
    _posts = _postsService.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: FutureBuilder<List<Post>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshPosts();
            },
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final post = snapshot.data![index];
                return PostComponent(
                  post: post,
                  onRefresh: _refreshPosts,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );

          if (result == true) {
            setState(() {
              _posts = _postsService.fetchPosts();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}