import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class MyFavoriteParks extends StatefulWidget {
  const MyFavoriteParks({Key? key}) : super(key: key);

  @override
  _MyFavoriteParksState createState() => _MyFavoriteParksState();
}

class _MyFavoriteParksState extends State<MyFavoriteParks> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _favoritesCollection = FirebaseFirestore.instance.collection('favorites');
  String _sortOption = 'Alphabetical';
  bool _isDarkMode = false;
  List<String> _filteredFavorites = [];
  late AnimationController _animationController;
  bool _isAddingFavorite = false;

  User? get _currentUser => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addFavorite() async {
    if (_controller.text.isEmpty || _currentUser == null) return;

    setState(() => _isAddingFavorite = true);
    try {
      await _favoritesCollection.add({
        'name': _controller.text,
        'userID': _currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Park added to favorites'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add park'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isAddingFavorite = false);
    }
  }

  Stream<List<Map<String, dynamic>>> _getFavorites() {
    if (_currentUser == null) return Stream.value([]);

    return _favoritesCollection
        .where('userID', isEqualTo: _currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unnamed',
          'timestamp': data['timestamp'] ?? FieldValue.serverTimestamp(),
        };
      }).toList();
    });
  }

  void _editFavorite(String currentName, DocumentReference docRef) {
    final _editController = TextEditingController(text: currentName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Park Name',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _editController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Park Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await docRef.update({'name': _editController.text});
                        Navigator.pop(context);
                      },
                      child: Text('Update'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _sortFavorites(List<Map<String, dynamic>> favorites) {
    switch (_sortOption) {
      case 'Alphabetical':
        favorites.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
        break;
      case 'Most Recently Added':
        favorites.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        break;
    }
    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'My Favorite Parks',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a favorite park',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _isAddingFavorite
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : IconButton(
                  icon: Icon(Icons.add_circle),
                  color: theme.primaryColor,
                  onPressed: _addFavorite,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_filteredFavorites.length}',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.sort_rounded,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'Alphabetical',
                      child: Text('Alphabetical'),
                    ),
                    PopupMenuItem(
                      value: 'Most Recently Added',
                      child: Text('Most Recent'),
                    ),
                  ],
                  onSelected: (value) => setState(() => _sortOption = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getFavorites(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.park_outlined,
                          size: 64,
                          color: _isDarkMode ? Colors.grey[700] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No favorite parks yet',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final favorites = _sortFavorites(snapshot.data!);
                _filteredFavorites = favorites.map((f) => f['name'] as String).toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _editFavorite(
                              favorites[index]['name'],
                              _favoritesCollection.doc(favorites[index]['id']),
                            ),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (_) async {
                              await _favoritesCollection
                                  .doc(favorites[index]['id'])
                                  .delete();
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          title: Text(
                            favorites[index]['name'],
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.park_rounded,
                              color: theme.primaryColor,
                            ),
                          ),
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