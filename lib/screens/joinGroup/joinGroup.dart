
import 'package:fire_station_inz_app/models/userModel.dart';
import 'package:fire_station_inz_app/screens/root/root.dart';
import 'package:fire_station_inz_app/services/dbFuture.dart';
import 'package:fire_station_inz_app/widgets/shadowContainer.dart';
import 'package:flutter/material.dart';

class JoinGroup extends StatefulWidget {
  final UserModel userModel;

  JoinGroup({this.userModel});
  @override
  _JoinGroupState createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  void _joinGroup(BuildContext context, String groupId) async {
    UserModel _currentUser = widget.userModel;
    print("helo heolo");
    print(widget.userModel.notifToken);
    String _returnString = await DBFuture().joinGroup(groupId, _currentUser);
    if (_returnString == "success") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OurRoot(),
          ),
              (route) => false);
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(_returnString),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  TextEditingController _groupIdController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[BackButton()],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ShadowContainer(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _groupIdController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.group),
                      hintText: "Id grupy",
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 100),
                      child: Text(
                        "Dołącz",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      _joinGroup(context, _groupIdController.text);
                    },
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}