import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';

class CardSameGroupWidget extends StatelessWidget {
  const CardSameGroupWidget({
    Key? key,
    required this.groupId,
  }) : super(key: key);
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseUtils.dbGroup(groupId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        // Object
        final Group group =
            Group.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        return Container(
          color: ColorConfig.colorPrimary,
          child: ListTile(
            onTap: () {},
            leading: SizedBox(
              width: 36,
              child: BasicPhotoProfile(size: 36, url: group.profile, color: Colors.white),
            ),
            title: Text(
              group.name!,
              style: FontConfig.medium(
                size: 14,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_sharp,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
