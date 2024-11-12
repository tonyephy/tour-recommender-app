import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // Modern SliverAppBar with transparency effects
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Gallery',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
          ),
          // Gallery Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('gallery').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingGrid();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final images = snapshot.data!.docs;
                  return MasonryGridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final imageData = images[index].data() as Map<String, dynamic>;
                      return _GalleryItem(
                        imageUrl: imageData['image'],
                        title: imageData['title'],
                        heroTag: 'image_$index',
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[300],
          ),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
            ),
          ),
          TextButton(
            onPressed: () {
              // Add refresh functionality
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No images yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String heroTag;

  const _GalleryItem({
    required this.imageUrl,
    required this.title,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: heroTag,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey[400]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageDetailScreen(
          imageUrl: imageUrl,
          title: title,
          heroTag: heroTag,
        ),
      ),
    );
  }
}

class _ImageDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String heroTag;

  const _ImageDetailScreen({
    required this.imageUrl,
    required this.title,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Title and back button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 16,
                  16,
                  16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
}
