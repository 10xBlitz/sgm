import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';

class UserUserAvatar extends StatelessWidget {
  final UserWithProjectsRow? userWithProjectsRow;
  final UserRow? userRow;
  final double size;

  const UserUserAvatar({
    super.key,
    this.userWithProjectsRow,
    this.userRow,
    this.size = 50,
  }) : assert(userWithProjectsRow != null || userRow != null);

  @override
  Widget build(BuildContext context) {
    final String? name = userWithProjectsRow?.name ?? userRow?.name;
    final String? profileImage =
        userWithProjectsRow?.profileImage ?? userRow?.profileImage;

    final fallbackText =
        (name?.isNotEmpty ?? false) ? name!.substring(0, 1).toUpperCase() : '?';

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
