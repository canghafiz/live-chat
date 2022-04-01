import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/utils/config/color.dart';
import 'package:live_chat/utils/config/font.dart';

class PersonalOrGroupTagWidget extends StatelessWidget {
  const PersonalOrGroupTagWidget({
    Key? key,
    required this.marginHor,
    required this.marginVer,
  }) : super(key: key);
  final double marginHor, marginVer;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TagCubit, TagState, TagType>(
        selector: (state) => state.type,
        builder: (context, selectedType) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: marginHor,
                vertical: marginVer,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorConfig.colorPrimary.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Update State
                          TagCubitHandle.read(context).setTag(TagType.personal);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: (selectedType == TagType.personal)
                                ? ColorConfig.colorPrimary
                                : Colors.transparent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                          ),
                          child: Center(
                            child: Text(
                              'Personal',
                              style: FontConfig.medium(
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Update State
                          TagCubitHandle.read(context).setTag(TagType.group);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: (selectedType == TagType.group)
                                ? ColorConfig.colorPrimary
                                : Colors.transparent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                          ),
                          child: Center(
                            child: Text(
                              'Group',
                              style: FontConfig.medium(
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
