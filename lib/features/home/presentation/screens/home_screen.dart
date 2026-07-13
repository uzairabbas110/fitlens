import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../widgets/feature_card.dart';
import '../widgets/welcome_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitLens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeHeader(),

            const SizedBox(height: 10),

            Text(
              user?.email ?? '',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            FeatureCard(
              title: "Analyze Outfit",
              subtitle: "Upload your outfit and get AI feedback",
              icon: Icons.camera_alt,
              onTap: () {
                context.go('/upload');
              },
            ),
            SizedBox(height: 15),

            const FeatureCard(
              title: "My Wardrobe",
              subtitle: "Manage your saved clothes",
              icon: Icons.checkroom,
            ),

            SizedBox(height: 15),

            const FeatureCard(
              title: "Style Recommendations",
              subtitle: "Get personalized outfit ideas",
              icon: Icons.auto_awesome,
            ),
          ],
        ),
      ),
    );
  }
}