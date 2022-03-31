import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BasicPhotoProfile extends StatelessWidget {
  const BasicPhotoProfile({
    Key? key,
    required this.size,
    required this.url,
    this.color,
  }) : super(key: key);
  final String? url;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return (url == null)
        ? Icon(Icons.account_circle, size: size + 6, color: color)
        : CachedNetworkImage(
            imageUrl: url!,
            imageBuilder: (_, url) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
  }
}
