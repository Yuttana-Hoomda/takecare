import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/auth/providers/on_boarding_provider.dart';
import 'package:takecare/features/auth/screens/set_food_time_screen.dart';

class SelectNcdScreen extends StatelessWidget {
  const SelectNcdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onBoardingProvider = Provider.of<OnBoardingProvider>(context);
    debugPrint('diseases: ${onBoardingProvider.diseases}');
    final diseases = onBoardingProvider.diseases;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Expanded forces the button container to the bottom
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Texts
                      const Text(
                        'โรคประจำตัวของคุณ',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D232E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'กรุณาเลือกข้อมูลเพื่อการดูแลที่เหมาะสม',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 40),

                      // Disease Cards
                      _diseaseCard(
                        icon: Icons.favorite,
                        titleTh: 'ความดันสูง',
                        isSelected: diseases.contains(Diseases.hypertension),
                        onSelected: () {
                          onBoardingProvider.toggleDisease(Diseases.hypertension);
                        },
                      ),
                      const SizedBox(height: 16),
                      _diseaseCard(
                        icon: Icons.water_drop,
                        titleTh: 'เบาหวาน',
                        isSelected: diseases.contains(Diseases.diabetes),
                        onSelected: () {
                          onBoardingProvider.toggleDisease(Diseases.diabetes);
                        },
                      ),

                      // Divider space
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 32),

                      // Healthy Card
                      _diseaseCard(
                        icon: Icons.sentiment_satisfied_alt,
                        titleTh: 'สุขภาพแข็งแรงไม่มีโรค',
                        isSelected: onBoardingProvider.isHealthy,
                        onSelected: () {
                          onBoardingProvider.clearDisease();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: diseases.isNotEmpty || onBoardingProvider.isHealthy ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SetFoodTimeScreen(),
                    ),
                  ) : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'ถัดไป',
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _diseaseCard({
    required IconData icon,
    required String titleTh,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5F0FF) : Colors.white,
          borderRadius: BorderRadius.circular(30), // Large rounded corners
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF007AFF)
                    : const Color(0xFFE5F0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF007AFF),
                size: 26,
              ),
            ),
            const SizedBox(width: 20),

            // Text Container
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleTh,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D232E),
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark (Only shows when selected)
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF007AFF),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
