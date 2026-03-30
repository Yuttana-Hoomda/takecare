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
            label: 'ความคืบหน้า',
            valueText: '50%',
            sublabel: '1/2 ทำแล้ว',
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
                  builder: (context) {
                    // 1. Use StatefulBuilder to manage the loading state locally
                    bool isAnalyzing = false;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return CameraScreen(
                          isLoading: isAnalyzing, // Pass the dynamic variable
                          onSubmit: (imgBase64, imageFilePath) async {
                            // 2. Start Loading
                            setState(() {
                              isAnalyzing = true;
                            });

                            try {
                              final user = context.read<AuthProvider>().user;
                              final diseases = user is ElderUser
                                  ? user.ncdConditions ?? <Diseases>[]
                                  : <Diseases>[];

                              // Wait for API
                              await context.read<FoodAnalysisProvider>().analysisFood(
                                imgBase64,
                                imageFilePath,
                                diseases,
                              );

                              if (!context.mounted) return;

                              final provider = context.read<FoodAnalysisProvider>();

                              if (provider.result != null) {
                                // 3. Use pushReplacement instead of push!
                                // This prevents the user from going "back" to a dead camera preview
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodAnalysisScreen(
                                      analysisResult: provider.result!,
                                      img: File(imageFilePath),
                                      showShareButton: false,
                                    ),
                                  ),
                                );
                              } else {
                                // 4. Handle Null Result
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ไม่สามารถวิเคราะห์อาหารได้ กรุณาลองใหม่')),
                                );
                              }
                            } catch (e) {
                              // 5. Handle Network/API Errors
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                                );
                              }
                            } finally {
                              // 6. Stop Loading (whether it succeeded or failed)
                              if (context.mounted) {
                                setState(() {
                                  isAnalyzing = false;
                                });
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
