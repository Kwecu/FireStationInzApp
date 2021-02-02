import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_station_inz_app/models/EmergencyModel.dart';
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
DocumentSnapshot snapshot;
class EmergencyAlert extends StatefulWidget {

 //final String userUid;
  // final String taskUid;
  final String groupId;
  final String alertId;

  EmergencyAlert({@required this.groupId, this.alertId});
  @override
  _EmergencyAlertState createState() => _EmergencyAlertState();


}

class _EmergencyAlertState extends State<EmergencyAlert> {
  final emergencyKey = GlobalKey<ScaffoldState>();
  TextEditingController _reviewController = TextEditingController();
  String _dropdownValue;
  AuthModel _authModel;

  Future<EmergencyModel> _emergencyModel;
  Future<EmergencyModel> getData()async{
    return await DBFuture().getAlert1(widget.groupId, widget.alertId);
  }

  @override
  void didChangeDependencies() {
    _authModel = Provider.of<AuthModel>(context);
    super.didChangeDependencies();
    _emergencyModel=getData();
    print(widget.groupId+"   "+widget.alertId);

    print(_emergencyModel);
  }



  Widget build(BuildContext context) {
    return DefaultTextStyle(
      
      style: Theme.of(context).textTheme.headline2,
      textAlign: TextAlign.center,
      
      child: FutureBuilder<EmergencyModel>(
        future: _emergencyModel, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<EmergencyModel> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Result: ${snapshot.data.author}', style: TextStyle(color: Colors.white,)),
              )
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //         centerTitle: true,
  //         backgroundColor: Colors.amber,
  //         title: Text("",
  //             style: new TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 25.0,
  //             )),
  //         // leading: BackButton(
  //         //     color: Colors.black
  //         // ),
  //         leading: new IconButton(
  //           icon: new Icon(Icons.arrow_back, color: Colors.black),
  //           onPressed: () => Navigator.push(
  //               context, MaterialPageRoute(builder: (context) => OurRoot())),
  //         ),
  //       ),
  //     key: emergencyKey,
  //     body: Column(
  //       children: <Widget>[
  //         Padding(
  //           padding: const EdgeInsets.all(20.0),
            
  //         ),
  //         Spacer(),
  //         Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: ShadowContainer(
  //             child: Column(
  //               children: <Widget>[
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: <Widget>[
  //                     Text("Alarm!", style: TextStyle(
  //                       color: Colors.black,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 18.0,
  //                     ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 20.0,
  //                 ),
  //                 Container(
  //                   padding: EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       Text("Miejsce zdarzenia: ",style: TextStyle(
  //                         color: Colors.black,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 15.0,
  //                       ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       Text("Opis: ",style: TextStyle(
  //                         color: Colors.black,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 15.0,
  //                       ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       Text("Liczba poszkodowanych: ",style: TextStyle(
  //                         color: Colors.black,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 15.0,
  //                       ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: <Widget>[
  //                     Container(
  //                       padding: EdgeInsets.symmetric(
  //                           horizontal: 5.0, vertical: 10.0),
  //                       child: Text("Potrzebny czas na przybycie: ", style: TextStyle(
  //                         color: Colors.black,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 15.0,
  //                       ),
  //                       ),
  //                     ),
  //                     DropdownButton<String>(
  //                       value: _dropdownValue,
  //                       icon: Icon(Icons.arrow_downward),
  //                       iconSize: 24,
  //                       elevation: 16,
  //                       style: TextStyle(
  //                           color: Theme.of(context).secondaryHeaderColor),
  //                       underline: Container(
  //                         height: 2,
  //                         color: Theme.of(context).canvasColor,
  //                       ),
  //                       onChanged: (String newValue) {
  //                         setState(() {
  //                           _dropdownValue = newValue;
  //                         });
  //                       },
  //                       items: <String>["Na miejscu","~2 min.","~3 min.","~4 min.","~5 min.","~6 min.","~7 min.","~8 min.","~9 min.","+10 min."]
  //                           .map<DropdownMenuItem<String>>((String value) {
  //                         return DropdownMenuItem<String>(
  //                           value: value,
  //                           child: Text(value,style: TextStyle(
  //                             color: Colors.black,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 15.0,
  //                           ),),
  //                         );
  //                       }).toList(),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: <Widget>[
  //                     Container(
  //                       child: RaisedButton(
  //                           child: Padding(
  //                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //                             child: Text(
  //                               "Akceptuj",
  //                               style: TextStyle(
  //                                 color: Colors.green,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 20.0,
  //                               ),
  //                             ),
  //                           ),
  //                           onPressed: () {
  //                             if (_dropdownValue != null) {
  //                               _TaskList();

  //                               Navigator.pushAndRemoveUntil(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   //builder: (context) => (),
  //                                 ),
  //                                     (route) => false,
  //                               );
  //                             } else {
  //                               emergencyKey.currentState.showSnackBar(SnackBar(
  //                                 content: Text("Musisz uzupełnic informację"),
  //                               ));
  //                             }
  //                           },
  //                           ),
  //                     ),

  //                     Container(
  //                      child: RaisedButton(
  //                           child: Padding(
  //                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //                             child: Text(
  //                               "Odrzóć",
  //                               style: TextStyle(
  //                                 color: Colors.redAccent,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 20.0,
  //                               ),
  //                             ),
  //                           ),
  //                           onPressed: () {


  //                             Navigator.pushAndRemoveUntil(
  //                               context,
  //                               MaterialPageRoute(
  //                                 //builder: (context) => TaskList(),
  //                               ),
  //                                   (route) => false,
  //                             );

  //                           }

  //                       ),
  //                     ),
  //                   ]
  //                 ),


  //               ],
  //             ),
  //           ),
  //         ),
  //         Spacer(),
  //       ],
  //     ),
  //   );
  // }
}