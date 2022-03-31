import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/utils/export_utils.dart';

class BottomContactWidget extends StatelessWidget {
  const BottomContactWidget({
    Key? key,
    required this.yourId,
  }) : super(key: key);
  final String yourId;

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
              Navigator.pop(context);
              // Navigate
              RouteHandle.toNewPersonalContactSearch(
                context: context,
                yourId: yourId,
              );
            },
            title: Text(
              "Add new contact",
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
              Navigator.pop(context);
              // Navigate
              RouteHandle.toCreateGroup(context: context, yourId: yourId);
            },
            title: Text(
              "Create new group",
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
              Navigator.pop(context);
              // Navigate
              RouteHandle.toNewGroupContactSearch(
                context: context,
                yourId: yourId,
              );
            },
            title: Text(
              "Join group",
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
