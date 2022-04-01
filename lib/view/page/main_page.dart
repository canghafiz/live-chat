import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    Key? key,
    required this.userId,
  }) : super(key: key);
  final String userId;

  @override
  Widget build(BuildContext context) {
    // Update State
    // NavigationCubitHandle.read(context).setNavigation(0);

    // Pages
    final pages = <Widget>[
      ChatPage(userId: userId),
      CallPage(userId: userId),
      ContactPage(userId: userId),
      ProfilePage(userId: userId),
    ];

    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) =>
          BlocSelector<NavigationCubit, NavigationState, int>(
        selector: (state) => state.index,
        builder: (context, selectedIndex) => Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              // Update State
              NavigationCubitHandle.read(context).setNavigation(index);
            },
            selectedItemColor:
                (isDark) ? Colors.white : ColorConfig.colorPrimary,
            unselectedItemColor: (isDark)
                ? Colors.white.withOpacity(0.35)
                : ColorConfig.colorPrimary.withOpacity(0.35),
            type: BottomNavigationBarType.fixed,
            elevation: 16,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: (isDark) ? ColorConfig.colorDark : Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.call), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.group), label: ''),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: '',
              ),
            ],
          ),
          body: pages.elementAt(selectedIndex),
        ),
      ),
    );
  }
}
