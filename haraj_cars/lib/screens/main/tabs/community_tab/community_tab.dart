import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import '../../../../main/tabs/community_tab/comminity_post_card.dart';
import '../../../../../tools/Palette/theme.dart' as custom_theme;

class CommunityTab extends StatefulWidget {
  final bool isAdmin;

  const CommunityTab({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      final response = await Supabase.instance.client.from('posts').select('''
            *,
            comments:comments(id, user_id, comment, likes, created_at)
          ''').order('created_at', ascending: false);

      setState(() {
        _posts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _likePost(String postId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to like posts'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get current post data
      final response = await Supabase.instance.client
          .from('posts')
          .select('liked_by')
          .eq('id', postId)
          .single();

      List<dynamic> likedBy = List<dynamic>.from(response['liked_by'] ?? []);

      if (likedBy.contains(user.id)) {
        // User already liked, remove like
        likedBy.remove(user.id);
      } else {
        // User hasn't liked, add like
        likedBy.add(user.id);
      }

      // Update the post with new liked_by array
      await Supabase.instance.client.from('posts').update({
        'liked_by': likedBy,
        'likes': likedBy.length,
      }).eq('id', postId);

      _loadPosts(); // Refresh posts to get updated like count
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error liking post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _likeComment(String commentId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to like comments'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get current comment data
      final response = await Supabase.instance.client
          .from('comments')
          .select('liked_by')
          .eq('id', commentId)
          .single();

      List<dynamic> likedBy = List<dynamic>.from(response['liked_by'] ?? []);

      if (likedBy.contains(user.id)) {
        // User already liked, remove like
        likedBy.remove(user.id);
      } else {
        // User hasn't liked, add like
        likedBy.add(user.id);
      }

      // Update the comment with new liked_by array
      await Supabase.instance.client.from('comments').update({
        'liked_by': likedBy,
        'likes': likedBy.length,
      }).eq('id', commentId);

      _loadPosts(); // Refresh posts to get updated like count
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error liking comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addComment(String postId, String comment) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to comment'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await Supabase.instance.client.from('comments').insert({
        'post_id': postId,
        'user_id': user.id,
        'comment': comment,
      });

      _loadPosts(); // Refresh posts to show new comment
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addPost(String text, List<String> imageUrls) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to add posts'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await Supabase.instance.client.from('posts').insert({
        'text': text,
        'images': imageUrls,
        'created_by': user.id,
      });

      _loadPosts(); // Refresh posts to show new post
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddPostDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPostDialog(
        onPostAdded: (text, imageUrls) {
          _addPost(text, imageUrls);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: theme.brightness == Brightness.dark
          ? colorScheme.background
          : Colors.white,
      child: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Content (full screen, content scrolls under floating elements)
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                    : _isError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load posts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.error,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _loadPosts,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _posts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.post_add,
                                      size: 64,
                                      color: colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No posts yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadPosts,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 100, // Space for floating header
                                    bottom:
                                        100, // Space for floating bottom nav
                                  ),
                                  itemCount: _posts.length,
                                  itemBuilder: (context, index) {
                                    final post = _posts[index];
                                    return PostCard(
                                      post: post,
                                      onLikePost: _likePost,
                                      onLikeComment: _likeComment,
                                      onAddComment: _addComment,
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),

          // Floating Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFloatingHeader(theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[700]!.withOpacity(0.3)
                  : custom_theme.light.shade100.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : colorScheme.onSurface,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadPosts,
                  icon: Icon(
                    Icons.refresh,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : colorScheme.primary,
                  ),
                ),
                if (widget.isAdmin) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _showAddPostDialog,
                    icon: Icon(
                      Icons.add,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : colorScheme.primary,
                    ),
                    tooltip: 'Add Post',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddPostDialog extends StatefulWidget {
  final Function(String text, List<String> imageUrls) onPostAdded;

  const AddPostDialog({
    Key? key,
    required this.onPostAdded,
  }) : super(key: key);

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  final TextEditingController _textController = TextEditingController();
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text for your post'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> imageUrls = [];

      // Upload images to Supabase storage
      for (XFile image in _selectedImages) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final fileBytes = await image.readAsBytes();

        final response = await Supabase.instance.client.storage
            .from('posts-images')
            .uploadBinary(fileName, fileBytes);

        if (response.isNotEmpty) {
          final imageUrl = Supabase.instance.client.storage
              .from('posts-images')
              .getPublicUrl(fileName);
          imageUrls.add(imageUrl);
        }
      }

      widget.onPostAdded(_textController.text.trim(), imageUrls);

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.brightness == Brightness.dark
              ? colorScheme.surface
              : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? colorScheme.primary.withOpacity(0.1)
                    : custom_theme.light.shade100.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.post_add,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add New Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : colorScheme.onSurface,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.7)
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Input
                    TextField(
                      controller: _textController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark
                            ? colorScheme.surfaceVariant.withOpacity(0.3)
                            : custom_theme.light.shade100.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Images Section
                    Text(
                      'Images (${_selectedImages.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : colorScheme.onSurface,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Selected Images List
                    if (_selectedImages.isNotEmpty)
                      Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: theme.brightness ==
                                                  Brightness.dark
                                              ? colorScheme.surfaceVariant
                                              : custom_theme.light.shade200,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: theme.brightness ==
                                                    Brightness.dark
                                                ? colorScheme.onSurface
                                                    .withOpacity(0.5)
                                                : custom_theme.light.shade600,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Add Image Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _addImage,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Add Image'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : colorScheme.primary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _addMultipleImages,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Add Multiple'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : colorScheme.primary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitPost,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Post'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
