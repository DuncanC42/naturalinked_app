import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naturalinked_app/models/post_model.dart';
import 'package:naturalinked_app/service/post_service.dart';
import '../service/image_service.dart';
import 'ImageCarousel.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}


class _PostDetailScreenState extends State<PostDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _contentController;
  final _postsService = PostsService();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  List<int> _imagesToDelete = [];
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _authorController = TextEditingController(text: widget.post.author);
    _contentController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Modifiez votre méthode _updatePost pour gérer les images
  Future<void> _updatePost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedPost = Post(
          postId: widget.post.postId,
          title: _titleController.text,
          author: _authorController.text,
          content: _contentController.text,
          images: widget.post.images,
        );

        await _postsService.updatePostWithImages(
          updatedPost,
          _selectedImages,
          _imagesToDelete,
        );

        if (mounted) {
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildReadOnlyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Par ${widget.post.author}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.post.content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          // Si le post a des images, affiche le carousel
          if (widget.post.images.isNotEmpty)
            ImageCarousel(
              imageUrls: widget.post.images
                  .map((img) => "http://localhost:8080" + img.downloadUrl)
                  .toList(),
            ),
        ],
      ),
    );
  }

  // Modifiez votre méthode _buildEditForm pour inclure la gestion des images
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Champs existants
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Auteur',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un auteur';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Contenu',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un contenu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Section des images existantes
            if (widget.post.images.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Images existantes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      // Afficher uniquement les images qui ne sont pas dans _imagesToDelete
                      itemCount: widget.post.images.length,
                      itemBuilder: (context, index) {
                        final image = widget.post.images[index];

                        // Vérifier si l'image est marquée pour suppression
                        if (_imagesToDelete.contains(image.imageId)) {
                          return const SizedBox.shrink(); // Ne rien afficher si l'image est marquée
                        }

                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FutureBuilder<Uint8List>(
                                future: ImageService().downloadImage(image.imageId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _imagesToDelete.add(image.imageId);  // Marquer pour suppression
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),


            // Section des nouvelles images
            if (_selectedImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nouvelles images:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.file(
                                _selectedImages[index],
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

            // Bouton pour ajouter des images
            ElevatedButton.icon(
              onPressed: _pickAndUploadImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Ajouter des images'),
            ),

            const SizedBox(height: 24),

            // Bouton de mise à jour
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePost,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Mettre à jour'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le post' : 'Détail du post'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Reset the controllers to original values when cancelling edit
                  _titleController.text = widget.post.title;
                  _authorController.text = widget.post.author;
                  _contentController.text = widget.post.content;
                }
              });
            },
          ),
        ],
      ),
      body: _isEditing ? _buildEditForm() : _buildReadOnlyView(),
    );
  }
  // Ajoutez cette méthode pour sélectionner des images
  Future<void> _pickAndUploadImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            selectedImages.map((xFile) => File(xFile.path)).toList(),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }





}

