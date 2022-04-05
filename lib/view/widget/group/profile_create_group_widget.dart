import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';

class ProfileCreateGroupWidget extends StatelessWidget {
  const ProfileCreateGroupWidget({
    Key? key,
    required this.file,
    required this.isDark,
  }) : super(key: key);
  final File? file;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return (file == null)
        ? Icon(
            Icons.account_circle,
            size: 124 + 6,
            color: (isDark) ? Colors.white : ColorConfig.colorDark,
          )
        : FutureBuilder<Uint8List>(
            future: file!.readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {}
              return (snapshot.data == null)
                  ? Icon(
                      Icons.account_circle,
                      size: 124 + 6,
                      color: (isDark) ? Colors.white : ColorConfig.colorDark,
                    )
                  : Container(
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: MemoryImage(snapshot.data!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
            },
          );
  }
}
