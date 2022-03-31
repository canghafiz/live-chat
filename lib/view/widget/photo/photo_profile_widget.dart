import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';

class PhotoProfileWidget extends StatelessWidget {
  const PhotoProfileWidget({
    Key? key,
    required this.userId,
    required this.size,
  }) : super(key: key);
  final String userId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseUtils.dbUser(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return BasicPhotoProfile(size: size, url: null);
        }
        // Object
        final User user =
            User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        return Badge(
          position: const BadgePosition(top: 0, end: 0),
          badgeColor: (user.online!) ? Colors.green : Colors.grey,
          child: BasicPhotoProfile(size: size, url: user.profile),
        );
      },
    );
  }
}
