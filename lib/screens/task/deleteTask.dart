
import 'package:fire_station_inz_app/models/authModel.dart';
import 'package:fire_station_inz_app/models/groupModel.dart';
import 'package:fire_station_inz_app/models/taskModel.dart';
import 'package:fire_station_inz_app/models/userModel.dart';
import 'package:fire_station_inz_app/screens/inGroup/inGroup.dart';
import 'package:fire_station_inz_app/screens/inGroup/taskList.dart';
import 'package:fire_station_inz_app/screens/inGroup/userList.dart';
import 'package:fire_station_inz_app/screens/root/root.dart';
import 'package:fire_station_inz_app/services/dbFuture.dart';
import 'package:fire_station_inz_app/widgets/shadowContainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteTask extends StatefulWidget {

  final String userUid;
  final String taskUid;

  DeleteTask({@required this.userUid,this.taskUid});
  @override
  _DeleteTaskState createState() => _DeleteTaskState();


}

class _DeleteTaskState extends State<DeleteTask> {
  final rankKey = GlobalKey<ScaffoldState>();
  TextEditingController _reviewController = TextEditingController();
  String _dropdownValue;
  AuthModel _authModel;


  @override
  void didChangeDependencies() {
    _authModel = Provider.of<AuthModel>(context);
    super.didChangeDependencies();
  }
  void _TaskList(){
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(

        builder: (context) => UserList(
          groupId: group.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: rankKey,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text("Na pewno chcesz usunąć zadanie?", style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 80),
                        child: Text(
                          "Tak",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      onPressed: () {
                        DBFuture().deleteTask(widget.userUid,widget.taskUid);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskList(
                                  userId: widget.userUid,
                              ),
                            ),
                                (route) => false,
                          );

                        }

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