import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/caregiver_home/widgets/progress_card.dart';
import 'package:takecare/features/elderly_home/components/action_button.dart';
import 'package:takecare/features/camera/camera_screen.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/auth/models/user_model.dart';
import 'package:takecare/features/food_alarm/providers/food_analysis_provider.dart';
import 'package:takecare/features/food_alarm/screens/food_analysis_screen.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/constants/enum.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProgressCard(
            label: 'Progress',
            valueText: '50%',
            sublabel: '4/5 doses taken',
            progress: 0.5,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            label: "เช็กอาหาร",
            icon: "assets/icons/food.png",
            iconColor: AppTheme.primaryColor,
            bgColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraScreen(
                    isLoading: false,
                    onSubmit: (imgBase64, imageFilePath) async {
                      final user = context.read<AuthProvider>().user;
                      final diseases = user is ElderUser 
                          ? user.ncdConditions ?? <Diseases>[] 
                          : <Diseases>[];

                      await context.read<FoodAnalysisProvider>().analysisFood(
                        imgBase64,
                        imageFilePath,
                        diseases,
                      );
                      
                      if (!context.mounted) return;
                      
                      final provider = context.read<FoodAnalysisProvider>();
                      if (provider.result != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodAnalysisScreen(
                              analysisResult: provider.result!,
                              img: File(imageFilePath),
                              showShareButton: false, // ซ่อนปุ่มแชร์เมื่อกดจากปุ่มเช็กอาหาร
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
