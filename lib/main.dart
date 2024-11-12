import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tour_recommender/firebase_options.dart'; // Import your generated options file
import 'package:tour_recommender/splash_screen.dart';
import 'package:tour_recommender/onboarding_screen.dart' as onboarding;
import 'package:tour_recommender/welcome_screen.dart';
import 'package:tour_recommender/auth_gate.dart';
import 'package:tour_recommender/home_screen.dart' as home;
import 'package:tour_recommender/preference_screen.dart'; // Import the PreferenceScreen
import 'package:tour_recommender/places_screen.dart'; // Import the PlacesScreen


void main() async {
  // Ensure widgets are initialized before using Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(const TourRecommenderApp());
}

class TourRecommenderApp extends StatelessWidget {
  const TourRecommenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Recommender',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white, // Set scaffold background color here
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // Initial route
        '/onboarding': (context) => onboarding.OnboardingScreen(), // Onboarding screen route
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const AuthGate(),
        '/home': (context) => home.HomeScreen(userId: ''), // Home page route
        '/preferences': (context) => PreferenceScreen(), // Add the PreferenceScreen route
        '/places': (context) => PlacesScreen(), // Add the PlacesScreen route
      },
    );
  }
}
