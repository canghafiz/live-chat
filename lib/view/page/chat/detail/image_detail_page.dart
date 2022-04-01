import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';

class ImageDetailPage extends StatelessWidget {
  const ImageDetailPage({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: ColorConfig.colorPrimary),
      body: InteractiveViewer(
        child: CachedNetworkImage(
          imageUrl: url,
          imageBuilder: (context, image) => Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(image: image),
            ),
          ),
        ),
      ),
    );
  }
}
