import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';

class UserUserAvatar extends StatelessWidget {
  final UserWithProjectsRow user;
  final double size;

  const UserUserAvatar({super.key, required this.user, this.size = 50});

  @override
  Widget build(BuildContext context) {
    final fallbackText =
        (user.name?.isNotEmpty ?? false)
            ? user.name!.substring(0, 1).toUpperCase()
            : '?';
    final profileImage = user.profileImage;
    final hasImage = profileImage != null && profileImage.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
      ),
      child:
          hasImage
              ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: profileImage,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorWidget:
                      (context, url, error) => Center(
                        child: Text(
                          fallbackText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  placeholder:
                      (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                ),
              )
              : Center(
                child: Text(
                  fallbackText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
    );
  }
}
