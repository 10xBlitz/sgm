import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgm/theme/theme.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initial;
  final double radius;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.initial,
    this.radius = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2.5,
        ),
        borderRadius: BorderRadius.circular(radius * 4),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage:
            imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImageProvider(imageUrl!)
                : initial == null
                ? CachedNetworkImageProvider(
                  "https://ctmirror-images.s3.amazonaws.com/wp-content/uploads/2021/01/dummy-man-570x570-1.png",
                )
                : null,
        child:
            imageUrl == null && initial != null
                ? Text(
                  initial![1],
                  style: TextStyle(
                    fontSize: radius / 2,
                    fontFamily: MaterialTheme.fontFamilyString.playfairDisplay,
                  ),
                )
                : null,
      ),
    );
  }
}
