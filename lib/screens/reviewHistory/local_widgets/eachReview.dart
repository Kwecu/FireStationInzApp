
import 'package:fire_station_inz_app/models/reviewModel.dart';
import 'package:fire_station_inz_app/models/userModel.dart';
import 'package:fire_station_inz_app/services/dbFuture.dart';
import 'package:fire_station_inz_app/widgets/shadowContainer.dart';
import 'package:flutter/material.dart';

class EachReview extends StatefulWidget {
  final ReviewModel review;

  EachReview({this.review});

  @override
  _EachReviewState createState() => _EachReviewState();
}

class _EachReviewState extends State<EachReview> {
  UserModel user;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    user = await DBFuture().getUser(widget.review.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ShadowContainer(
      child: Column(
        children: [
          Text(
            (user != null) ? user.fullName : "ładowanie...",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Ocena: " + widget.review.rating.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          (widget.review.review != null)
              ? Text(
            widget.review.review,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          )
              : Text(""),
        ],
      ),
    );
  }
}