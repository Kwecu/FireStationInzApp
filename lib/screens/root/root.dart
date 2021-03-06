import 'dart:io';


import 'package:fire_station_inz_app/models/authModel.dart';
import 'package:fire_station_inz_app/models/groupModel.dart';
import 'package:fire_station_inz_app/models/userModel.dart';
import 'package:fire_station_inz_app/screens/inGroup/inGroup.dart';
import 'package:fire_station_inz_app/screens/noGroup/noGroup.dart';
import 'package:fire_station_inz_app/screens/login/login.dart';
import 'package:fire_station_inz_app/services/dbStream.dart';
import 'package:fire_station_inz_app/splashScreen/splashScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_responsive_screen/flutter_responsive_screen.dart';
import 'package:provider/provider.dart';

enum AuthStatus { unknown, notLoggedIn, loggedIn }

class OurRoot extends StatefulWidget {
  @override
  _OurRootState createState() => _OurRootState();
}

class _OurRootState extends State<OurRoot> {
  AuthStatus _authStatus = AuthStatus.unknown;
  String currentUid;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
      _firebaseMessaging.onIosSettingsRegistered.listen((event) {
        print("IOS Registered");
      });
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        
      },
    );
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    AuthModel _authStream = Provider.of<AuthModel>(context);
    if (_authStream != null) {
      setState(() {
        _authStatus = AuthStatus.loggedIn;
        currentUid = _authStream.uid;
      });
    } else {
      setState(() {
        _authStatus = AuthStatus.notLoggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget retVal;

    switch (_authStatus) {
      case AuthStatus.unknown:
        retVal = SplashScreen();
        break;
      case AuthStatus.notLoggedIn:
        retVal = Login();
        break;
      case AuthStatus.loggedIn:
        retVal = StreamProvider<UserModel>.value(
          value: DBStream().getCurrentUser(currentUid),
          child: LoggedIn(),
        );
        break;
      default:
    }
    return retVal;
  }
}

class LoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel _userStream = Provider.of<UserModel>(context);
    //GroupModel _group = Provider.of<GroupModel>(context);
    Widget retVal;
    if (_userStream != null) {
      if (_userStream.groupId != null) {
        retVal = StreamProvider<GroupModel>.value(
          value: DBStream().getCurrentGroup(_userStream.groupId),
          child: InGroup(),
        );
      } else {
        retVal = NoGroup();
      }
    } else {
      retVal = SplashScreen();
    }

    return retVal;
  }
}