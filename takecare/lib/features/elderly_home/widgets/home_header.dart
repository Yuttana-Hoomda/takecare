import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import '/utils/greeting.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final url = auth.user?.profilePictureUrl ?? '';
        return Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
              child: url.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${GreetingHelper.getGreeting()},',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  auth.user?.displayName ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}