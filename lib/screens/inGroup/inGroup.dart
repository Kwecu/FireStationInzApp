import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_station_inz_app/models/emergencyDuringModel.dart';
import 'package:fire_station_inz_app/models/groupModel.dart';
import 'package:fire_station_inz_app/models/userModel.dart';
import 'package:fire_station_inz_app/screens/Emergency/emegencyScren.dart';
import 'package:fire_station_inz_app/screens/Emergency/emergencyCreate.dart';
import 'package:fire_station_inz_app/screens/Emergency/emergencyInGroup.dart';
import 'package:fire_station_inz_app/screens/addEvent/addEvent.dart';
import 'package:fire_station_inz_app/screens/eventHistory/eventHistory.dart';
import 'package:fire_station_inz_app/screens/inGroup/taskList.dart';
import 'package:fire_station_inz_app/screens/inGroup/userList.dart';
import 'package:fire_station_inz_app/screens/root/root.dart';
import 'package:fire_station_inz_app/screens/task/task.dart';
import 'package:fire_station_inz_app/services/auth.dart';
import 'package:fire_station_inz_app/services/dbFuture.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'local_widgets/secondCard.dart';
import 'local_widgets/eachUser.dart';
import 'local_widgets/topCard.dart';

class InGroup extends StatefulWidget {

//bool group;
 


  InGroup();
  @override
  InGroupState createState() => InGroupState();

  

  FirebaseUser user;
}

class InGroupState extends State<InGroup> {
Future<GroupModel> groupModel1;

bool _isButtonDisabled;

GroupModel groupModel2;
bool view;


Firestore _firestore = Firestore.instance;


  final key = new GlobalKey<ScaffoldState>();
  bool boolRank;
  @override
  void didChangeDependencies() async{
    //checkRank(button);
    
    super.didChangeDependencies();
    
    final FirebaseUser userr = await auth.currentUser();
    //groupModel1=DBFuture().getGroup(widget.groupId);
    //_checkEvent();
    

  }
    bool checkRank(bool button){
      
      UserModel user = Provider.of<UserModel>(context, listen: false);
    print(user.rank+button.toString()+"            jestem tu już PPrzed");
    if(user.rank=="Dowódca"){
      button=false;
      

    }else{
      button=true;
    }
    print(user.rank+button.toString()+"            jestem tu już PO");
    return button;
  }
 

  void _signOut(BuildContext context) async {
    String _returnString = await Auth().signOut();
    if (_returnString == "success") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OurRoot(),
        ),
            (route) => false,
      );
    }
  }

  void _leaveGroup(BuildContext context) async {
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    UserModel user = Provider.of<UserModel>(context, listen: false);
    String _returnString = await DBFuture().leaveGroup(group.id, user);
    if (_returnString == "success") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OurRoot(),
        ),
            (route) => false,
      );
    }
  }

  void _copyGroupId(BuildContext context) {
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    Clipboard.setData(ClipboardData(text: group.id));
    key.currentState.showSnackBar(SnackBar(
      content: Text("Skopiowano do schowka!"),
    ));
  }

  void _goToEventHistory() {
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventHistory(
          groupId: group.id,
        ),
      ),
    );
  }
  void _userList(bool boolRank){
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    UserModel user = Provider.of<UserModel>(context, listen: false);
    boolRank=checkRank(boolRank);
    print("jestem w srodku wchodzenia do listy"+user.rank+" "+ boolRank.toString());
    Navigator.push(
      context,
      MaterialPageRoute(

        builder: (context) => UserList(
          groupId: group.id,
          userRank: boolRank,
        ),
      ),
    );
  }
  void _taskList(bool boolRank){
    UserModel user = Provider.of<UserModel>(context, listen: false);
   boolRank=checkRank(boolRank);
    Navigator.push(
      context,
      MaterialPageRoute(

        builder: (context) => TaskList(
          userId: user.uid,
          userRank: boolRank,
        ),
      ),
    );
  }
  void _emergency(){
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    UserModel user = Provider.of<UserModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(

        builder: (context) => Emergency(
          groupId: group.id,
          userName: user.fullName,
          userGroupId: user.groupId,
         
        ),
      ),
    );
  }
  void _emergencyScreen(){
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    UserModel user = Provider.of<UserModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(

        builder: (context) => EmergencyScreen(
          group: group.duringEmergency,
          groupId: group.id,
          userName: user.fullName,
          userGroupId: user.groupId,
          groupAlertId:group.alertsId,
          
        ),
      ),
    );
  }
  void _emergencyInGroup(){
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    UserModel user = Provider.of<UserModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(

        builder: (context) => EmergencyInGroup(
          
          groupId: group.id,
          
        ),
      ),
    );
  }
  void goToAddEvent(BuildContext context) {
    UserModel _currentUser = Provider.of<UserModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OurAddEvent(
          onGroupCreation: false,
          onError: true,
          currentUser: _currentUser,
        ),
      ),
    );
  }
 
  // bool DuringEvent(){
  //   GroupModel group = Provider.of<GroupModel>(context, listen: false);
  //   if (group.duringEmergency=="false") {
  //     return true;
  //   } else {
  //     return false;
  //   }
    
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      key: key,
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: IconButton(
                  onPressed: () => _signOut(context),
                  icon: Icon(Icons.exit_to_app),
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TopCard(),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(20.0),
          //   child: SecondCard(),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(20.0),
            
          //   child: MessagingWidget()
          // ),
            
          //   Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 40.0),
              
          //     child: RaisedButton(
          //     child: Text(
          //       "Lista alarmów",
          //       style: TextStyle(color: Colors.red),
          //     ),
              
          //     onPressed:  () => (_emergencyInGroup()),
          //   ),
            
          // ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            
            child: RaisedButton(
              
              child: Text(
                "System alarmów",
                style: TextStyle(color: Colors.white),
                
              ),
             
              onPressed: () => _emergencyScreen(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: RaisedButton(
              child: Text(
                "Stwórz nowe wydarzenie",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => goToAddEvent(context)
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: RaisedButton(
              child: Text(
                "Historia wydarzeń",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _goToEventHistory(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: RaisedButton(
              child: Text(
                "Lista osób",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _userList(boolRank),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: RaisedButton(
              child: Text(
                "Zadania",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _taskList(boolRank),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: RaisedButton(
              child: Text("Skopiuj id grupy"),
              onPressed: () => _copyGroupId(context),
              color: Theme.of(context).canvasColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: Theme.of(context).secondaryHeaderColor,
                  width: 2,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
            child: FlatButton(
              child: Text("Wyjdź z grupy"),
              onPressed: () => _leaveGroup(context),
              color: Theme.of(context).canvasColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            //child: ThirdCard(),
          ),
        ],
      ),
    );
  }
  


}
   

