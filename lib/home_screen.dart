import 'package:flutter/material.dart';
import 'travel_tips_screen.dart';
import 'package:tour_recommender/FeedbackScreen.dart';
import 'user_reviews_screen.dart';
import 'gallery_screen.dart';
import 'package:tour_recommender/onboarding_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_recommender/MyFavoriteParks.dart';
import 'preference_screen.dart'; // Import PreferenceScreen

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyFavoriteParks()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue[200]!, Colors.lightBlue[50]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tour Recommender',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person, color: Colors.blueGrey),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.blueGrey),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => OnboardingScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(Icons.explore, 'Browse Destination', Colors.green, () {
                      // Navigate to Preference Screen
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PreferenceScreen()));
                    }),
                    _buildDashboardCard(Icons.rate_review, 'Reviews', Colors.purple, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserReviewsScreen()));
                    }),
                    _buildDashboardCard(Icons.tips_and_updates, 'Travel Tips', Colors.blue, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TravelTipsScreen()));
                    }),
                    _buildDashboardCard(Icons.photo, 'Photo Gallery', Colors.pink, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen()));
                    }),
                    _buildDashboardCard(Icons.feedback, 'Feedback', Colors.teal, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color.withOpacity(0.9)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}