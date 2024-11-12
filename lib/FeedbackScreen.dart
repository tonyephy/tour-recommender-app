import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final CollectionReference _feedbackCollection = FirebaseFirestore.instance.collection('feedback');
  double _rating = 0.0;
  bool _isExpanded = false;

  void _submitFeedback() async {
    String feedbackText = _feedbackController.text.trim();

    if (feedbackText.isNotEmpty && _rating > 0) {
      Map<String, dynamic> feedbackData = {
        'feedback': feedbackText,
        'rating': _rating,
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await _feedbackCollection.add(feedbackData);
        _showSnackbar('Feedback submitted successfully!');
        _feedbackController.clear();
        setState(() {
          _rating = 0.0;
          _isExpanded = false;
        });
      } catch (error) {
        _showSnackbar('Error submitting feedback. Please try again later.');
      }
    } else {
      _showSnackbar('Please provide feedback and a rating.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Feedback',
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
                      _isExpanded ? 'Cancel Feedback' : 'Give Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      _isExpanded ? Icons.close : Icons.feedback,
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
                            controller: _feedbackController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Your Feedback',
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
                            'Your Rating:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Center(
                            child: RatingBar.builder(
                              initialRating: _rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _rating = rating;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitFeedback,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Submit Feedback',
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
            stream: _feedbackCollection.orderBy('createdAt', descending: true).snapshots(),
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
                        Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
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

              final feedbacks = snapshot.data?.docs ?? [];

              if (feedbacks.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feedback_outlined, size: 60, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No feedback yet',
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
                      final feedbackData = feedbacks[index].data() as Map<String, dynamic>;
                      final timestamp = feedbackData['createdAt'] as Timestamp?;

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
                                  Icon(Icons.feedback, size: 20, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feedbackData['feedback'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              if (feedbackData['rating'] != null) ...[
                                RatingBarIndicator(
                                  rating: feedbackData['rating'].toDouble(),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 20,
                                  direction: Axis.horizontal,
                                ),
                                SizedBox(height: 8),
                              ],
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
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: feedbacks.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return timeago.format(timestamp.toDate());
  }
}
