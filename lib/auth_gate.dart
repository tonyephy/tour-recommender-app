import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // new
import 'package:flutter/material.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              // Check the correct usage of GoogleProvider or use the appropriate class if the name has changed
              // Ensure you have the correct package version and usage as per documentation
              // GoogleProvider(clientId: "3338264763-u0shs1b210id3vlkngan68js6dkdd8oh.apps.googleusercontent.com"), // new
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/logo2.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to Tour recommender App, Please fill in your details to sign in!')
                    : const Text('Welcome to Tour recommender App, Please  fill in your details to sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/logo2.png'),
                ),
              );
            },
          );
        }

        return HomeScreen(userId: snapshot.data!.uid);
      },
    );
  }
}
