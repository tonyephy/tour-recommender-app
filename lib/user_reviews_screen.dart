import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago; // Add this package for human-readable timestamps

class UserReviewsScreen extends StatefulWidget {
  const UserReviewsScreen({Key? key}) : super(key: key);

  @override
  _UserReviewsScreenState createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  final TextEditingController _placeVisitedController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  final CollectionReference _reviewsCollection =
  FirebaseFirestore.instance.collection('reviews');
  bool _isExpanded = false;

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return timeago.format(timestamp.toDate());
  }

  void _submitReview() async {
    String placeVisited = _placeVisitedController.text;
    String reviewText = _reviewController.text;

    if (placeVisited.isNotEmpty || reviewText.isNotEmpty || _rating > 0) {
      Map<String, dynamic> reviewData = {
        'place_visited': placeVisited,
        'text': reviewText,
        'rating': _rating,
        'created_at': FieldValue.serverTimestamp(),
      };

      await _reviewsCollection.add(reviewData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Review submitted successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      _placeVisitedController.clear();
      _reviewController.clear();
      setState(() {
        _rating = 0;
        _isExpanded = false;
      });
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
          'Reviews & Experiences',
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                children: [
                  ListTile(
                    title: Text(
                      _isExpanded ? 'Cancel Review' : 'Write a Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      _isExpanded ? Icons.close : Icons.rate_review,
                      color: Colors.blue,
                    ),
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                  if (_isExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _placeVisitedController,
                            decoration: InputDecoration(
                              labelText: 'Place Visited',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.place),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _reviewController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Your Experience',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 64),
                                child: Icon(Icons.comment),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Rating',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _rating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() => _rating = index + 1);
                                },
                              );
                            }),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitReview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Submit Review',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _reviewsCollection
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60, color: Colors.red[300]),
                        SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final reviews = snapshot.data?.docs ?? [];

              if (reviews.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_outlined,
                            size: 60, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No reviews yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final reviewData =
                      reviews[index].data() as Map<String, dynamic>;
                      final timestamp = reviewData['created_at'] as Timestamp?;

                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.place,
                                      size: 20, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      reviewData['place_visited'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _getTimeAgo(timestamp),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              if (reviewData['rating'] != null) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < reviewData['rating']
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                ),
                              ],
                              SizedBox(height: 12),
                              Text(
                                reviewData['text'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: reviews.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}