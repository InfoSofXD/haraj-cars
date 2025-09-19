import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import '../../../../tools/Palette/theme.dart' as custom_theme;

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final Function(String postId) onLikePost;
  final Function(String commentId) onLikeComment;
  final Function(String postId, String comment) onAddComment;

  const PostCard({
    Key? key,
    required this.post,
    required this.onLikePost,
    required this.onLikeComment,
    required this.onAddComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.brightness == Brightness.dark
                    ? [
                        Colors.grey[800]!.withOpacity(0.9),
                        Colors.grey[700]!.withOpacity(0.8),
                      ]
                    : [
                        Colors.white.withOpacity(0.95),
                        Colors.grey[50]!.withOpacity(0.9),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : custom_theme.light.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.8),
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: theme.brightness == Brightness.dark
                          ? [
                              colorScheme.primary.withOpacity(0.1),
                              colorScheme.primary.withOpacity(0.05),
                            ]
                          : [
                              custom_theme.light.shade50,
                              custom_theme.light.shade100.withOpacity(0.5),
                            ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adminccc',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : colorScheme.onSurface,
                                fontSize: 16,
                                fontFamily: 'Tajawal',
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.6)
                                      : colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(post['created_at']),
                                  style: TextStyle(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.white.withOpacity(0.6)
                                        : colorScheme.onSurface
                                            .withOpacity(0.6),
                                    fontSize: 12,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : custom_theme.light.shade100,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.2)
                                : custom_theme.light.shade300,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () => onLikePost(post['id']),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      _isPostLikedByUser(post)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      key: ValueKey(_isPostLikedByUser(post)),
                                      color: _isPostLikedByUser(post)
                                          ? Colors.red
                                          : colorScheme.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${post['likes'] ?? 0}',
                                    style: TextStyle(
                                      color: _isPostLikedByUser(post)
                                          ? Colors.red
                                          : theme.brightness == Brightness.dark
                                              ? Colors.white.withOpacity(0.8)
                                              : colorScheme.onSurface
                                                  .withOpacity(0.8),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Post Images
                if (post['images'] != null &&
                    (post['images'] as List).isNotEmpty)
                  Container(
                    height: 220,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (post['images'] as List).length,
                      itemBuilder: (context, index) {
                        final imageUrl = (post['images'] as List)[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.network(
                                imageUrl,
                                width: 200,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors:
                                            theme.brightness == Brightness.dark
                                                ? [
                                                    colorScheme.surfaceVariant,
                                                    colorScheme.surfaceVariant
                                                        .withOpacity(0.8),
                                                  ]
                                                : [
                                                    custom_theme.light.shade200,
                                                    custom_theme.light.shade100,
                                                  ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          color: theme.brightness ==
                                                  Brightness.dark
                                              ? colorScheme.onSurface
                                                  .withOpacity(0.5)
                                              : custom_theme.light.shade600,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Failed to load',
                                          style: TextStyle(
                                            color: theme.brightness ==
                                                    Brightness.dark
                                                ? colorScheme.onSurface
                                                    .withOpacity(0.5)
                                                : custom_theme.light.shade600,
                                            fontSize: 12,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Post Text
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    post['text'] ?? '',
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : colorScheme.onSurface,
                      fontSize: 16,
                      height: 1.6,
                      fontFamily: 'Tajawal',
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                // Comments Section
                if (post['comments'] != null &&
                    (post['comments'] as List).isNotEmpty)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: theme.brightness == Brightness.dark
                            ? [
                                colorScheme.surfaceVariant.withOpacity(0.2),
                                colorScheme.surfaceVariant.withOpacity(0.1),
                              ]
                            : [
                                custom_theme.light.shade50,
                                custom_theme.light.shade100.withOpacity(0.3),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.1)
                            : custom_theme.light.shade200,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.7)
                                    : colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Comments (${(post['comments'] as List).length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : colorScheme.onSurface,
                                  fontSize: 14,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...((post['comments'] as List).take(3).map((comment) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.1)
                                      : custom_theme.light.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      comment['comment'] ?? '',
                                      style: TextStyle(
                                        color:
                                            theme.brightness == Brightness.dark
                                                ? Colors.white.withOpacity(0.9)
                                                : colorScheme.onSurface
                                                    .withOpacity(0.9),
                                        fontSize: 14,
                                        fontFamily: 'Tajawal',
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.1)
                                          : custom_theme.light.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () =>
                                            onLikeComment(comment['id']),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: Icon(
                                                  _isCommentLikedByUser(comment)
                                                      ? Icons.thumb_up
                                                      : Icons.thumb_up_outlined,
                                                  key: ValueKey(
                                                      _isCommentLikedByUser(
                                                          comment)),
                                                  size: 14,
                                                  color: _isCommentLikedByUser(
                                                          comment)
                                                      ? Colors.red
                                                      : colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${comment['likes'] ?? 0}',
                                                style: TextStyle(
                                                  color: _isCommentLikedByUser(
                                                          comment)
                                                      ? Colors.red
                                                      : theme.brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                              .withOpacity(0.7)
                                                          : colorScheme
                                                              .onSurface
                                                              .withOpacity(0.7),
                                                  fontSize: 12,
                                                  fontFamily: 'Tajawal',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()),
                          if ((post['comments'] as List).length > 3)
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  // TODO: Show all comments dialog
                                },
                                icon: Icon(
                                  Icons.expand_more,
                                  size: 16,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.7)
                                      : colorScheme.primary,
                                ),
                                label: Text(
                                  'View all comments',
                                  style: TextStyle(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.white.withOpacity(0.7)
                                        : colorScheme.primary,
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                // Add Comment Section
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: theme.brightness == Brightness.dark
                          ? [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.02),
                            ]
                          : [
                              custom_theme.light.shade50,
                              custom_theme.light.shade100.withOpacity(0.3),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : custom_theme.light.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary.withOpacity(0.1),
                              colorScheme.primary.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.person,
                            color: colorScheme.primary,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.grey[500],
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.2)
                                    : custom_theme.light.shade300,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.1)
                                    : custom_theme.light.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            filled: true,
                            fillColor: theme.brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white.withOpacity(0.7),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                          ),
                          onSubmitted: (comment) {
                            if (comment.trim().isNotEmpty) {
                              onAddComment(post['id'], comment.trim());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () {
                              // TODO: Show comment input dialog
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isPostLikedByUser(Map<String, dynamic> post) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final likedBy = List<dynamic>.from(post['liked_by'] ?? []);
    return likedBy.contains(user.id);
  }

  bool _isCommentLikedByUser(Map<String, dynamic> comment) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final likedBy = List<dynamic>.from(comment['liked_by'] ?? []);
    return likedBy.contains(user.id);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
