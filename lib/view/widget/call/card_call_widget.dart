import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class CardCallWidget extends StatelessWidget {
  const CardCallWidget({
    Key? key,
    required this.callId,
    required this.yourId,
    required this.call,
  }) : super(key: key);
  final String yourId, callId;
  final Call call;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => StreamBuilder<DocumentSnapshot>(
        stream: FirebaseUtils.dbUser(call.userId!).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }
          // Object
          final User user =
              User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return ListTile(
            onTap: () {
              // Navigate
              RouteHandle.toDetailCall(
                context: context,
                callId: callId,
                call: call,
                yourId: yourId,
              );
            },
            leading: SizedBox(
              width: 36,
              child: PhotoProfileWidget(userId: call.userId!, size: 36),
            ),
            title: Text(
              user.name ?? "No Name",
              style: FontConfig.medium(
                size: 14,
                color: (isDark) ? Colors.white : ColorConfig.colorDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.call_received,
                  color: (call.answer!) ? Colors.green : Colors.red,
                  size: 12,
                ),
                Text(
                  FunctionUtils.timeCalculate(
                    call.time!,
                  ),
                  style: FontConfig.light(
                    size: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              (call.type == VariableConst.callTypeVoice)
                  ? Icons.call
                  : Icons.videocam,
              color: ColorConfig.colorPrimary,
            ),
          );
        },
      ),
    );
  }
}
