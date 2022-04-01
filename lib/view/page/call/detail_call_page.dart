import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class DetailCallPage extends StatelessWidget {
  const DetailCallPage({
    Key? key,
    required this.yourId,
    required this.callId,
    required this.call,
  }) : super(key: key);
  final String yourId, callId;
  final Call call;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Call Info",
          style: FontConfig.medium(size: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate
              RouteHandle.toDetailPersonalChat(
                context: context,
                userId: call.userId!,
                yourId: yourId,
              );
            },
            icon: const Icon(
              Icons.chat,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: ColorConfig.colorPrimary,
      ),
      body: BlocSelector<ThemeCubit, ThemeState, bool>(
        selector: (state) => state.isDark,
        builder: (context, isDark) => StreamBuilder<DocumentSnapshot>(
          stream: FirebaseUtils.dbUser(call.userId!).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // Object
            final User user =
                User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

            return Column(
              children: [
                ListTile(
                  leading: PhotoProfileWidget(userId: call.userId!, size: 48),
                  title: Text(
                    user.name!,
                    style: FontConfig.medium(
                      size: 14,
                      color: (isDark) ? Colors.white : ColorConfig.colorDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    FunctionUtils.timeCalculate(call.time!),
                    style: FontConfig.light(size: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 72,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate
                            RouteHandle.toVoiceCall(
                              context: context,
                              userId: call.userId!,
                              yourId: yourId,
                              type: CallType.caller,
                            );
                          },
                          child: const Icon(
                            Icons.call,
                            color: ColorConfig.colorPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.videocam,
                            color: ColorConfig.colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.call_received_rounded,
                    color: (call.answer!) ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    (call.answer!) ? "Answered" : "Not Answered",
                    style: FontConfig.light(
                      size: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
