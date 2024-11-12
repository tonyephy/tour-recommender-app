import 'package:flutter/material.dart';

class PreferenceScreen extends StatefulWidget {
  @override
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  final List<Map<String, dynamic>> activities = [
    {'name': 'Hiking', 'icon': Icons.hiking},
    {'name': 'Bird Watching', 'icon': Icons.visibility},
    {'name': 'Swimming', 'icon': Icons.pool},
    {'name': 'Bush Meals', 'icon': Icons.restaurant}, // Landscape icon for nature watching
    {'name': 'Animal Watching', 'icon': Icons.pets},
    {'name': 'Camping', 'icon': Icons.campaign},
    {'name': 'Snake Watching', 'icon': Icons.pest_control},
    {'name': 'Photography', 'icon': Icons.camera_alt},
    {'name': 'Cycling', 'icon': Icons.directions_bike},
    {'name': 'Wildlife Safari', 'icon': Icons.landscape},
    {'name': 'Picnicking', 'icon': Icons.local_dining},
    {'name': 'Fishing', 'icon': Icons.pool},  // or Icons.sailing
    {'name': 'Cultural Visits', 'icon': Icons.account_balance},
    {'name': 'Guided Nature Walks', 'icon': Icons.nature_people},
    {'name': 'Beach Walks', 'icon': Icons.beach_access},
    {'name': 'Boat Riding', 'icon': Icons.directions_boat},
    {'name': 'Big Five', 'icon': Icons.pets}, // For representing wildlife
    {'name': 'Relaxation', 'icon': Icons.spa},
    {'name': 'Wildlife Tracking', 'icon': Icons.track_changes},
    {'name': 'Zip Lining', 'icon': Icons.airline_seat_flat_angled},
    {'name': 'Skydiving', 'icon': Icons.flight_takeoff},
    {'name': 'Canoeing', 'icon': Icons.directions_boat},
    {'name': 'Mountain Biking', 'icon': Icons.directions_bike},
    {'name': 'Stargazing', 'icon': Icons.nights_stay},
    {'name': 'Visit Lamu Island', 'icon': Icons.beach_access},
    // Add all activities as in your original list
  ];

  List<String> selectedActivities = [];
  String searchQuery = '';
  Set<String> searchHistory = {}; // Set to store unique search terms

  List<Map<String, dynamic>> get filteredActivities {
    return activities.where((activity) {
      return activity['name'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  List<String> get matchingHistory {
    return searchHistory
        .where((history) => history.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void updateSearchHistory(String query) {
    if (query.isNotEmpty) {
      searchHistory.add(query); // Add unique search term to history
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Choose Your Adventure',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              'What would you like to explore today?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
              onSubmitted: (query) {
                setState(() {
                  updateSearchHistory(query);
                  searchQuery = query;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Activities',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (matchingHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: matchingHistory.map((history) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        searchQuery = history;
                      });
                    },
                    child: Chip(
                      label: Text(history),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: filteredActivities.length,
                itemBuilder: (context, index) {
                  final activity = filteredActivities[index];
                  final isSelected = selectedActivities.contains(activity['name']);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedActivities.remove(activity['name']);
                        } else {
                          selectedActivities.add(activity['name']);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            activity['icon'],
                            size: 40,
                            color: isSelected ? Colors.white : Colors.blue,
                          ),
                          SizedBox(height: 12),
                          Text(
                            activity['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedActivities.isEmpty
                      ? null
                      : () {
                    Navigator.pushNamed(
                      context,
                      '/places', // Navigate with selected activities as arguments
                      arguments: selectedActivities,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'View Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
