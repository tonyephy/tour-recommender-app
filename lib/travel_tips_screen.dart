import 'package:flutter/material.dart';

class TravelTipsScreen extends StatefulWidget {
  const TravelTipsScreen({Key? key}) : super(key: key);

  @override
  _TravelTipsScreenState createState() => _TravelTipsScreenState();
}

class _TravelTipsScreenState extends State<TravelTipsScreen> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();

    // Create a list of animation controllers, one for each travel tip
    _controllers = List.generate(
      travelTips.length,
          (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500), // Animation duration
      )..forward(), // Start the animation immediately
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Tips'),
        backgroundColor: Color(0xFF87CEEB), // Sky Blue background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: travelTips.length,
          itemBuilder: (context, index) {
            final tip = travelTips[index];
            return AnimatedBuilder(
              animation: _controllers[index],
              builder: (context, child) {
                return Opacity(
                  opacity: _controllers[index].value,
                  child: child,
                );
              },
              child: buildTipCard(tip['title']!, tip['description']!),
            );
          },
        ),
      ),
    );
  }

  Widget buildTipCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  // List of travel tips
  final List<Map<String, String>> travelTips = [
    {'title': 'Stay Hydrated', 'description': 'Always carry a water bottle to stay hydrated while traveling.'},
    {'title': 'Pack Light', 'description': 'Bring only what you need to make your travels easier.'},
    {'title': 'Learn Basic Local Phrases', 'description': 'Knowing a few phrases in the local language can enhance your experience.'},
    {'title': 'Keep Important Documents Secure', 'description': 'Store copies of your important documents like passport and tickets.'},
    {'title': 'Respect Local Culture', 'description': 'Be mindful of local customs and practices to ensure a positive experience.'},
    {'title': 'Carry a First Aid Kit', 'description': 'A small kit with basic medicine and band-aids can be a lifesaver.'},
    {'title': 'Check Weather Forecasts', 'description': 'Stay updated with local weather conditions to plan your activities accordingly.'},
    {'title': 'Notify Your Bank of Travel Plans', 'description': 'Ensure your cards work abroad by informing your bank of your travels.'},
    {'title': 'Use Sunscreen', 'description': 'Protect your skin by applying sunscreen, especially in sunny locations.'},
    {'title': 'Backup Photos', 'description': 'Regularly back up your travel photos to avoid losing memories.'},
    {'title': 'Stay Flexible', 'description': 'Have a basic plan but be ready to adjust when things don’t go as expected.'},
    {'title': 'Get Travel Insurance', 'description': 'Travel insurance can provide coverage for unexpected incidents during your trip.'},
    {'title': 'Make Copies of Itinerary', 'description': 'Share your travel itinerary with friends or family for safety purposes.'},
    {'title': 'Wear Comfortable Shoes', 'description': 'Ensure that you wear appropriate and comfortable shoes for long walks.'},
    {'title': 'Know Local Emergency Numbers', 'description': 'Familiarize yourself with the local emergency contacts just in case.'},
  ];
}
