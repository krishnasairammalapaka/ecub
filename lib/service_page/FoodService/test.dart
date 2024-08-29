import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewWidget extends StatefulWidget {
  final String productId;
  const ReviewWidget({Key? key, required this.productId}) : super(key: key);

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  double overallRating = 0.0;
  int totalReviews = 0;
  Map<int, double> starPercentages = {};

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .collection('reviews')
        .get();

    int totalRatings = 0;
    num totalStars = 0;

    for (final DocumentSnapshot doc in snapshot.docs) {
      totalRatings++;
      totalStars += doc['rating']!;
    }

    if (totalRatings > 0) {
      overallRating = totalStars / totalRatings;
    }

    // Calculate percentage of each star rating
    for (int i = 1; i <= 5; i++) {
      int count = snapshot.docs.where((doc) => doc['rating'] == i).length;
      starPercentages[i] = (count / totalRatings) * 100;
    }

    setState(() {
      totalReviews = totalRatings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              '$overallRating',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            for (int i = 0; i < overallRating.round(); i++)
              Icon(
                Icons.star,
                color: Colors.amber,
              ),
            for (int i = 0; i < 5 - overallRating.round(); i++)
              Icon(
                Icons.star_border,
                color: Colors.amber,
              ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          '$totalReviews Ratings and $totalReviews Reviews',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 10),
        for (int i = 5; i >= 1; i--)
          Row(
            children: [
              Text('${starPercentages[i]?.toStringAsFixed(1) ?? 0}%'),
              SizedBox(width: 10),
              Expanded(
                child: LinearProgressIndicator(
                  value: (starPercentages[i] ?? 0) / 100,
                ),
              ),
            ],
          ),
        SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .doc(widget.productId)
              .collection('reviews')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(doc['comment']),
                    );
                  },
                );
              } else {
                return Center(child: Text('No comments yet.'));
              }
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching comments.'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ],
    );
  }
}
