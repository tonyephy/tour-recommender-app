import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navigation_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesScreen extends StatefulWidget {
  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  String? _selectedFilter;
  bool _showOnlyOpen = false;
  final TextEditingController _searchController = TextEditingController();

  // Helper function to safely convert to double
  double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Calculate match score based on selected activities
  double _calculateMatchScore(List<dynamic> parkActivities, List<String> selectedActivities) {
    int matchingActivities = selectedActivities
        .where((activity) => parkActivities.contains(activity))
        .length;
    return (matchingActivities / selectedActivities.length) * 100;
  }

  // Check if a park is currently open
  bool _isParkOpen(Map<String, dynamic> place) {
    if (!_showOnlyOpen) return true;
    // Add your opening hours logic here
    return true; // Placeholder
  }

  @override
  Widget build(BuildContext context) {
    final List<String> selectedActivities =
        (ModalRoute.of(context)!.settings.arguments as List<dynamic>?)?.cast<String>() ?? [];

    if (selectedActivities.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text('Error', style: TextStyle(color: Colors.black)),
        ),
        body: Center(child: Text('No activities selected.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Recommended Parks',
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search places...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 16),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text('Open Now'),
                        selected: _showOnlyOpen,
                        onSelected: (selected) {
                          setState(() {
                            _showOnlyOpen = selected;
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      ...selectedActivities.map((activity) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(activity),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          labelStyle: TextStyle(color: Colors.blue),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('places')
                  .where('activities', arrayContainsAny: selectedActivities)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                        SizedBox(height: 16),
                        Text('Something went wrong'),
                      ],
                    ),
                  );
                }

                var places = snapshot.data!.docs;

                // Apply search filter
                if (_searchController.text.isNotEmpty) {
                  places = places.where((doc) {
                    final place = doc.data() as Map<String, dynamic>;
                    return place['name'].toString().toLowerCase()
                        .contains(_searchController.text.toLowerCase());
                  }).toList();
                }

                // Filter by open status
                places = places.where((doc) {
                  final place = doc.data() as Map<String, dynamic>;
                  return _isParkOpen(place);
                }).toList();

                if (places.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text('No places found matching your criteria'),
                      ],
                    ),
                  );
                }

                // Sort places by match score
                places.sort((a, b) {
                  final placeA = a.data() as Map<String, dynamic>;
                  final placeB = b.data() as Map<String, dynamic>;
                  final scoreA = _calculateMatchScore(
                      List<String>.from(placeA['activities'] ?? []),
                      selectedActivities);
                  final scoreB = _calculateMatchScore(
                      List<String>.from(placeB['activities'] ?? []),
                      selectedActivities);
                  return scoreB.compareTo(scoreA);
                });

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index].data() as Map<String, dynamic>;
                    final location = place['location'] as Map<String, dynamic>;
                    final matchScore = _calculateMatchScore(
                        List<String>.from(place['activities'] ?? []),
                        selectedActivities);

                    final double? lat = _parseDouble(location['lat']);
                    final double? lng = _parseDouble(location['lng']);

                    if (lat == null || lng == null) {
                      return Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Invalid location data for ${place['name']}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final LatLng destination = LatLng(lat, lng);

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                if (place['imageURL'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      place['imageURL'],
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey[400],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${matchScore.toStringAsFixed(0)}% Match',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place['name'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (place['description'] != null) ...[
                                    SizedBox(height: 8),
                                    Text(
                                      place['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 16),
                                  // Available activities
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (place['activities'] as List<dynamic>)
                                        .map((activity) {
                                      final isSelected = selectedActivities
                                          .contains(activity);
                                      return Chip(
                                        label: Text(activity.toString()),
                                        backgroundColor: isSelected
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.grey[200],
                                        labelStyle: TextStyle(
                                          color: isSelected
                                              ? Colors.blue[700]
                                              : Colors.grey[700],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 16),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NavigationScreen(
                                            placeName: place['name'],
                                            location: place['location'],
                                            destinationLatLng: destination,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.navigation_outlined,
                                          size: 18,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Get Directions',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}