import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NavigationScreen extends StatefulWidget {
  final String placeName;
  final LatLng destinationLatLng;

  const NavigationScreen({
    Key? key,
    required this.placeName,
    required this.destinationLatLng, required location,
  }) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _distance = '';
  String _duration = '';
  List<Map<String, dynamic>> _directionSteps = [];

  // Google Maps API Key
  final String googleAPIKey = 'AIzaSyCag7sERFK8zMFo1OcpLaBdnjfrItTPW2k';

  // For storing polyline points
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _checkLocationPermission();
    await _getCurrentLocation();
    if (_currentPosition != null) {
      await _getDirections();
    }
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;

        // Add markers for current and destination positions
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentPosition!,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );

        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: widget.destinationLatLng,
            infoWindow: InfoWindow(title: widget.placeName),
          ),
        );
      });

      _moveCamera();
    } catch (e) {
      print('Error getting location: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getDirections() async {
    try {
      String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${_currentPosition!.latitude},${_currentPosition!.longitude}'
          '&destination=${widget.destinationLatLng.latitude},${widget.destinationLatLng.longitude}'
          '&mode=driving'
          '&key=$googleAPIKey';

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          // Get route details
          _distance = data['routes'][0]['legs'][0]['distance']['text'];
          _duration = data['routes'][0]['legs'][0]['duration']['text'];

          // Get steps for navigation
          List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];
          _directionSteps = steps.map((step) => {
            'instruction': step['html_instructions'],
            'distance': step['distance']['text'],
            'duration': step['duration']['text'],
          }).toList();

          // Draw polyline
          List<PointLatLng> points = polylinePoints.decodePolyline(
              data['routes'][0]['overview_polyline']['points']
          );

          polylineCoordinates.clear();
          for (var point in points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }

          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                points: polylineCoordinates,
                width: 5,
              ),
            );
          });
        }
      }
    } catch (e) {
      print('Error getting directions: $e');
    }
  }

  void _moveCamera() {
    if (mapController != null && _currentPosition != null) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _currentPosition!.latitude < widget.destinationLatLng.latitude
              ? _currentPosition!.latitude
              : widget.destinationLatLng.latitude,
          _currentPosition!.longitude < widget.destinationLatLng.longitude
              ? _currentPosition!.longitude
              : widget.destinationLatLng.longitude,
        ),
        northeast: LatLng(
          _currentPosition!.latitude > widget.destinationLatLng.latitude
              ? _currentPosition!.latitude
              : widget.destinationLatLng.latitude,
          _currentPosition!.longitude > widget.destinationLatLng.longitude
              ? _currentPosition!.longitude
              : widget.destinationLatLng.longitude,
        ),
      );

      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.placeName,
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              _moveCamera();
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? widget.destinationLatLng,
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
          ),
          if (_polylines.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.directions_car, color: Colors.blue),
                              const SizedBox(height: 4),
                              Text(_duration,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.map, color: Colors.blue),
                              const SizedBox(height: 4),
                              Text(_distance,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _directionSteps.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.arrow_right, color: Colors.blue),
                            title: Text(
                              _directionSteps[index]['instruction'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                                '${_directionSteps[index]['distance']} • ${_directionSteps[index]['duration']}'
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 220,
            right: 15,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black87),
              onPressed: () {
                _getCurrentLocation();
                _getDirections();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
