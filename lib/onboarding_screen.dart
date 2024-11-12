import 'package:flutter/material.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to Tour Recommender!',
      subtitle: 'Your journey to unforgettable adventures starts here.',
      image: 'assets/welcome.png',
      backgroundColor: Color(0xFF6C63FF),
      textColor: Colors.white,
    ),
    OnboardingData(
      title: 'Explore Features',
      subtitle: 'Get the most out of Tour Recommender',
      image: 'assets/features.jpg',
      backgroundColor: Color(0xFF00BFA6),
      textColor: Colors.white,
    ),
    OnboardingData(
      title: 'Personalized for You',
      subtitle: 'Customize your experience',
      image: 'assets/personalized.png',
      backgroundColor: Color(0xFFFF6584),
      textColor: Colors.white,
    ),
    OnboardingData(
      title: 'Stay Connected',
      subtitle: 'Never miss an update',
      image: 'assets/connected.jpg',
      backgroundColor: Color(0xFF4A90E2),
      textColor: Colors.white,
    ),
    OnboardingData(
      title: 'Ready to Dive In?',
      subtitle: 'Lets get you set up',
    image: 'assets/get_started.jpeg',
      backgroundColor: Color(0xFF7C4DFF),
      textColor: Colors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentIndex < _pages.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], index == _pages.length - 1);
            },
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildIndicator(),
                SizedBox(height: 32),
                _buildActionButton(context),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/welcome');
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  color: _pages[_currentIndex].textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data, bool isLastPage) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      color: data.backgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Hero(
                tag: 'onboarding_image_${data.image}',
                child: Image.asset(
                  data.image,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: data.textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      data.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: data.textColor.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentIndex == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _pages[_currentIndex].textColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _currentIndex == _pages.length - 1 ? 200 : 160,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (_currentIndex < _pages.length - 1) {
              _pageController.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              );
            } else {
              Navigator.pushReplacementNamed(context, '/welcome');
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: _pages[_currentIndex].backgroundColor, backgroundColor: _pages[_currentIndex].textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Text(
            _currentIndex < _pages.length - 1 ? 'Next' : 'Get Started',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String image;
  final Color backgroundColor;
  final Color textColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.backgroundColor,
    required this.textColor,
  });
}