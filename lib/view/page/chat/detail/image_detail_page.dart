import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'dart:io';

class ImageDetailPage extends StatelessWidget {
  const ImageDetailPage({
    Key? key,
    required this.url,
    required this.file,
  }) : super(key: key);
  final String? url;
  final File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: ColorConfig.colorPrimary),
      body: InteractiveViewer(
        child: (file != null)
            ? FutureBuilder<Uint8List>(
                future: file!.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image:
                          DecorationImage(image: MemoryImage(snapshot.data!)),
                    ),
                  );
                },
              )
            : CachedNetworkImage(
                imageUrl: url!,
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
