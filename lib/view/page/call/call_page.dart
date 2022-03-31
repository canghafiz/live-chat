import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';
import '../../../cubit/export_cubit.dart';

class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.userId}) : super(key: key);
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
            'Calls',
            style: FontConfig.medium(size: 20, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.white),
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseUtils.dbCalls(userId)
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return (snapshot.data!.docs.isEmpty)
                  ? const SizedBox()
                  : SingleChildScrollView(
                      child: Column(
                        children: snapshot.data!.docs.map(
                          (doc) {
                            // Object
                            final Call call = Call.fromMap(
                                doc.data() as Map<String, dynamic>);

                            return CardCallWidget(
                              callId: doc.id,
                              yourId: userId,
                              call: call,
                            );
                          },
                        ).toList(),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
