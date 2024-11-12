import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AddProfileScreen.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({Key? key}) : super(key: key);

  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  Map<String, dynamic>? _userProfile;

  Future<String?> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> _fetchProfile() async {
    String? userId = await _getUserId();
    if (userId != null) {
      DocumentSnapshot documentSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (documentSnapshot.exists) {
        setState(() {
          _userProfile = documentSnapshot.data() as Map<String, dynamic>;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _editProfile() {
    if (_userProfile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddProfileScreen(
            existingProfile: _userProfile!,
          ),
        ),
      ).then((_) => _fetchProfile());
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[400]!, Colors.blue[800]!],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                _userProfile!['name'][0].toUpperCase(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userProfile!['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userProfile!['email'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue[800], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue[800],
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editProfile,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        title: 'Phone Number',
                        value: _userProfile!['phone'],
                        icon: Icons.phone,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        title: 'Date of Birth',
                        value: _userProfile!['dob'],
                        icon: Icons.cake,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        title: 'Country',
                        value: _userProfile!['country'],
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        title: 'Gender',
                        value: _userProfile!['gender'],
                        icon: Icons.person,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}