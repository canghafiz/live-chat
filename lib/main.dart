import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Device Orientation Just Potrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Init Firebase
  await Firebase.initializeApp();
  // Env
  await dotenv.load(fileName: "assets/.env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<AuthCubitCubit>(create: (_) => AuthCubitCubit()),
        BlocProvider<PasswordCubit>(create: (_) => PasswordCubit()),
        BlocProvider<BackendCubit>(create: (_) => BackendCubit()),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
        BlocProvider<TagCubit>(create: (_) => TagCubit()),
        BlocProvider<ChatCubit>(create: (_) => ChatCubit()),
        BlocProvider<GroupCubit>(create: (_) => GroupCubit()),
        BlocProvider<CallCubit>(create: (_) => CallCubit()),
        BlocProvider<AgoraCubit>(create: (_) => AgoraCubit()),
        ChangeNotifierProvider<TimerService>(create: (_) => TimerService()),
      ],
      child: Sizer(
        builder: (_, __, ___) => FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            bool value =
                snapshot.data!.getBool(VariableConst.keyTheme) ?? false;

            // Update State
            ThemeCubitHandle.watch(context).setTheme(value);

            return MaterialApp(
              title: VariableConst.appName,
              debugShowCheckedModeBanner: false,
              theme: (value)
                  ? ThemeConfig.darkTheme(context)
                  : ThemeConfig.lightTheme(context),
              home: const LandingPage(),
            );
          },
        ),
      ),
    );
  }
}
