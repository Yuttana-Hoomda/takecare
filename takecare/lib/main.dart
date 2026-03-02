import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/task/providers/task_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/auth/screens/AuthWrapper.dart';
import 'features/auth/providers/auth_provider.dart';
import 'package:takecare/features/elderly_home/provider/history_provider.dart';
import 'package:takecare/features/link_family/providers/link_family_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => LinkFamilyProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}
