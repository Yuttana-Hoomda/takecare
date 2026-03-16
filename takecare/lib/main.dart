import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/food_alarm/providers/food_analysis_provider.dart';
import 'package:takecare/features/automated_alarm/services/alarm_scheduler.dart';
import 'package:takecare/features/task/providers/task_provider.dart';
import 'package:takecare/features/link_family/providers/link_family_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/auth/screens/AuthWrapper.dart';
import 'features/auth/providers/auth_provider.dart';
import 'package:takecare/features/elderly_history/provider/history_provider.dart';

//  navigatorKey สำหรับ push AlarmScreen จากนอก widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ init AlarmScheduler ด้วย navigatorKey
  AlarmScheduler.instance.init(navigatorKey);

  runApp(Main(cameras: cameras));
}

class Main extends StatelessWidget {
  const Main({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => LinkFamilyProvider()),
        ChangeNotifierProvider(create: (_) => FoodAnalysisProvider()),
        Provider.value(
          value: cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.first,
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // ✅ ผูก key
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}
