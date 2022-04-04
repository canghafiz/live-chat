import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';

class PhotoBottomWidget extends StatelessWidget {
  const PhotoBottomWidget({
    Key? key,
    required this.dbUpdate,
  }) : super(key: key);
  final Function(File) dbUpdate;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            onTap: () {
              // Call Image
              ImageService.getImageFromGallery().then(
                (xfile) {
                  if (xfile != null) {
                    ImageService.imageCrop(File(xfile.path)).then(
                      (file) {
                        if (file != null) {
                          // Call Db
                          dbUpdate.call(file);
                        }
                      },
                    );
                  }
                },
              );
            },
            title: Text(
              "From gallery",
              style: FontConfig.medium(
                size: 14,
                color: (isDark) ? Colors.white : ColorConfig.colorDark,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: (isDark) ? Colors.white : ColorConfig.colorDark,
            ),
          ),
          ListTile(
            onTap: () {
              // Call Permission
              PermissionService.camera().then(
                (allow) {
                  if (allow) {
                    // Call Image
                    ImageService.getImageFromCamera().then(
                      (xfile) {
                        if (xfile != null) {
                          ImageService.imageCrop(File(xfile.path)).then(
                            (file) {
                              if (file != null) {
                                // Call Db
                                dbUpdate.call(file);
                              }
                            },
                          );
                        }
                      },
                    );
                  }
                },
              );
            },
            title: Text(
              "From camera",
              style: FontConfig.medium(
                size: 14,
                color: (isDark) ? Colors.white : ColorConfig.colorDark,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: (isDark) ? Colors.white : ColorConfig.colorDark,
            ),
          ),
        ],
      ),
    );
  }
}
