import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => Scaffold(
        backgroundColor: ColorConfig.colorPrimary,
        extendBody: true,
        appBar: AppBar(
          title: Text(
            "Profile",
            style: FontConfig.medium(size: 20, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                AuthService.signOut();
              },
              icon: const Icon(Icons.exit_to_app),
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            color: (isDark) ? ColorConfig.colorDark : Colors.white,
          ),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseUtils.dbUser(userId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              // Object
              final User user =
                  User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Photo Profile
                    Center(
                      child: SizedBox(
                        width: 124,
                        height: 124,
                        child: Stack(
                          children: [
                            // Photo
                            GestureDetector(
                              onTap: () {
                                if (user.profile != null) {
                                  // Navigate
                                  RouteHandle.toDetailImage(
                                    context: context,
                                    url: user.profile!,
                                    file: null,
                                  );
                                }
                              },
                              child: BasicPhotoProfile(
                                size: 124,
                                url: user.profile,
                              ),
                            ),
                            // Btn Take
                            GestureDetector(
                              onTap: () {
                                // Show Modal Bottom
                                FunctionUtils.showCustomBottomSheet(
                                  context: context,
                                  content: PhotoBottomWidget(
                                    imageNotNull: user.profile != null,
                                    delete: () {
                                      // Update Storage
                                      FirebaseStorageService.delete(
                                        user.profile!,
                                      ).then(
                                        (_) {
                                          Navigator.pop(context);
                                          // Update Db
                                          User.dbService.updatePhotoProfile(
                                            userId: userId,
                                            url: null,
                                          );
                                        },
                                      );
                                    },
                                    dbUpdate: (value) {
                                      // Update Storage
                                      FirebaseStorageService.uploadImage(
                                        folderName: User.profileUrl,
                                        fileName: userId,
                                        pickedFile: XFile(value.path),
                                      ).then(
                                        (url) {
                                          // Update Db
                                          User.dbService.updatePhotoProfile(
                                            userId: userId,
                                            url: url,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorConfig.colorPrimary,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Personal Data
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: VariableConst.margin,
                          ),
                          child: Text(
                            "Personal Data",
                            style: FontConfig.medium(
                              size: 14,
                              color: (isDark)
                                  ? Colors.white
                                  : ColorConfig.colorDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Name
                        Container(
                          color: ColorConfig.colorPrimary,
                          child: ListTile(
                            onTap: () {
                              // Show Modal Bottom
                              FunctionUtils.showCustomBottomSheet(
                                context: context,
                                content: EditFormWidget(
                                  inputFormater: null,
                                  inputType: null,
                                  intialValue: user.name!,
                                  title: "Name",
                                  onSubmit: (value) {
                                    Navigator.pop(context);
                                    // Call Db
                                    User.dbService
                                        .updateName(userId: userId, name: value)
                                        .then(
                                      (success) {
                                        if (success) {
                                          // show Snackbar
                                          showCustomSnackbar(
                                            context: context,
                                            text: "Success update name",
                                            color: Colors.green,
                                          );
                                          return;
                                        }
                                        // show Snackbar
                                        showCustomSnackbar(
                                          context: context,
                                          text: "Failed update name",
                                          color: Colors.red,
                                        );
                                        return;
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.person, color: Colors.white),
                              ],
                            ),
                            title: Text(
                              "Name",
                              style: FontConfig.light(
                                  size: 10, color: Colors.white),
                            ),
                            subtitle: Text(
                              user.name ?? "No Name",
                              style: FontConfig.medium(
                                  size: 12, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Email
                        Container(
                          color: ColorConfig.colorPrimary,
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.email, color: Colors.white),
                              ],
                            ),
                            title: Text(
                              "Email",
                              style: FontConfig.light(
                                  size: 10, color: Colors.white),
                            ),
                            subtitle: Text(
                              user.email ?? "Email not set",
                              style: FontConfig.medium(
                                  size: 12, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Settings
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: VariableConst.margin,
                          ),
                          child: Text(
                            "Settings",
                            style: FontConfig.medium(
                              size: 14,
                              color: (isDark)
                                  ? Colors.white
                                  : ColorConfig.colorDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Theme
                        Container(
                          color: ColorConfig.colorPrimary,
                          child: ListTile(
                            onTap: () {
                              // Show Dialog
                              showDialog(
                                context: context,
                                builder: (context) => justDialog(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Light
                                      RadioListTile<bool>(
                                        activeColor: ColorConfig.colorPrimary,
                                        title: Text(
                                          "Light",
                                          style: FontConfig.medium(
                                            size: 14,
                                            color: (isDark)
                                                ? Colors.white
                                                : ColorConfig.colorDark,
                                          ),
                                        ),
                                        value: false,
                                        groupValue: isDark,
                                        onChanged: (value) {
                                          //  Update Local Memory
                                          SharedPreferencesService.setTheme(
                                            value ?? false,
                                          );

                                          Navigator.pop(context);
                                        },
                                      ),
                                      // Dark
                                      RadioListTile<bool>(
                                        activeColor: ColorConfig.colorPrimary,
                                        title: Text(
                                          "Dark",
                                          style: FontConfig.medium(
                                            size: 14,
                                            color: (isDark)
                                                ? Colors.white
                                                : ColorConfig.colorDark,
                                          ),
                                        ),
                                        value: true,
                                        groupValue: isDark,
                                        onChanged: (value) {
                                          //  Update Local Memory
                                          SharedPreferencesService.setTheme(
                                            value ?? true,
                                          );

                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.brightness_7, color: Colors.white),
                              ],
                            ),
                            title: Text(
                              "Theme",
                              style: FontConfig.light(
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              (isDark) ? "Dark" : "Light",
                              style: FontConfig.medium(
                                  size: 12, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // About Developer
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: VariableConst.margin,
                          ),
                          child: Text(
                            "About Developer",
                            style: FontConfig.medium(
                              size: 14,
                              color: (isDark)
                                  ? Colors.white
                                  : ColorConfig.colorDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Link
                        Container(
                          color: ColorConfig.colorPrimary,
                          child: ListTile(
                            onTap: () {
                              // Navigate
                              RouteHandle.toWeb(context);
                            },
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.link, color: Colors.white),
                              ],
                            ),
                            title: Text(
                              "Visit Link",
                              style: FontConfig.light(
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              "www.hafizarrahman.com",
                              style: FontConfig.medium(
                                  size: 12, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
