import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Your imports
import 'firebase_options.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/auth/providers/on_boarding_provider.dart';
import 'package:takecare/features/food_alarm/providers/food_analysis_provider.dart';
import 'package:takecare/features/food_alarm/screens/food_alarm_screen.dart';
import 'package:takecare/features/automated_alarm/services/alarm_scheduler.dart';
import 'package:takecare/features/task/providers/task_provider.dart';
import 'package:takecare/features/link_family/providers/link_family_provider.dart';
import 'package:takecare/features/task_submission/providers/task_submission_provider.dart';
import 'package:takecare/features/history/providers/history_provider.dart';
import 'package:takecare/features/elderly_home/screens/elderly_home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  final cameras = await availableCameras();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AlarmScheduler.instance.init(navigatorKey);

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
        ChangeNotifierProvider(create: (_) => OnBoardingProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => TaskSubmissionProvider()),
        ChangeNotifierProvider(create: (_) => LinkFamilyProvider()),
        ChangeNotifierProvider(create: (_) => FoodAnalysisProvider()),

        // Pass the camera to the widget tree
        Provider<CameraDescription?>.value(
          value: cameras.isNotEmpty
              ? cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.first,
          )
              : null,
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [elderlyHomeRouteObserver],
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Set your initial test screen here
        home: const FoodAlarmScreen(foodAlarmType: FoodAlarmType.breakfast),
      ),
    );
  }
}