
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_station_inz_app/models/EmergencyModel.dart';
import 'package:fire_station_inz_app/models/emergencyDuringModel.dart';
import 'package:fire_station_inz_app/models/eventModel.dart';
import 'package:fire_station_inz_app/models/groupModel.dart';
import 'package:fire_station_inz_app/models/membersModel.dart';
import 'package:fire_station_inz_app/models/reviewModel.dart';
import 'package:fire_station_inz_app/models/taskModel.dart';
import 'package:fire_station_inz_app/models/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBFuture {
  // final FirebaseAuth auth1 = FirebaseAuth.instance;
  FirebaseUser user1;
  FirebaseAuth auth;
  Firestore _firestore = Firestore.instance;
  FirebaseMessaging _fcm = FirebaseMessaging();
  UserModel loggedInUser;

  FirebaseUser user;

  void inputData() async {
    final FirebaseUser userr = await auth.currentUser();
    final uuid = userr.uid;
  }

  Future<DocumentSnapshot> getData() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    return _firestore.collection("users").document(user.uid).get();
  }
  

  Future<String> createGroupBase(String groupName, UserModel user) async {
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();

    try {
      members.add(user.uid);
      tokens.add(user.notifToken);
      DocumentReference _docRef;
      if (user.notifToken != null) {
        _docRef = await _firestore.collection("groups").add({
          'name': groupName.trim(),
          'leader': user.uid,
          'members': members,
          'tokens': tokens,
          'groupCreated': Timestamp.now(),
          'nextEventId': "waiting",
          'indexPickingEvent': 0,
          'duringEmergency': false,
          'duringEvent': false,
        });
      } else {
        _docRef = await _firestore.collection("groups").add({
          'name': groupName.trim(),
          'leader': user.uid,
          'members': members,
          'groupCreated': Timestamp.now(),
          'nextEventId': "waiting",
          'indexPickingEvent': 0,
          'duringEmergency': false,
          'duringEvent': false,
        });
      }

      await _firestore.collection("users").document(user.uid).updateData({
        'groupId': _docRef.documentID,
        'rank': 'Dowódca',
      });
 
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> createGroup(


      String groupName,
      UserModel userModel,
      EventModel initialEvent) async {

    print("jestem tutaj");
    print(userModel.uid);
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();

  
    try {
      members.add(userModel.uid);
      tokens.add(userModel.notifToken);
      DocumentReference _docRef;
      if (userModel.notifToken != null) {
        _docRef = await _firestore.collection("groups").add({
          'name': groupName, //tu i w else .trim()
          'leader': userModel.uid,
          'members': members,
          'tokens': tokens,
          'groupCreated': Timestamp.now(),
          'nextEventId': "waiting",
          'indexPickingEvent': 0,
          'duringEmergency': false,
          'duringEvent': true,
        });
      } else {
        _docRef = await _firestore.collection("groups").add({
          'name': groupName,
          'leader': userModel.uid,
          'members': members,
          'groupCreated': Timestamp.now(),
          'nextEventId': "waiting",
          'indexPickingEvent': 0,
          'duringEmergency': false,
          'duringEvent': true,
        });
      }

      await _firestore.collection("users").document(userModel.uid).updateData({
        'groupId': _docRef.documentID,
      });

      //add a event

      addEvent(_docRef.documentID, initialEvent);

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> joinGroup(String groupId, UserModel userModel) async {
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();
    try {
      members.add(userModel.uid);
      tokens.add(userModel.notifToken);

      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayUnion(members),
        'tokens': FieldValue.arrayUnion(tokens),
      });

      await _firestore.collection("users").document(userModel.uid).updateData({
        'groupId': groupId.trim(),
      });

      retVal = "success";
    } on PlatformException catch (e) {
      retVal = "Upewnij się, czy wprowadziłeś właściwy identyfikator grupy!";
      print(e);
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> leaveGroup(String groupId, UserModel userModel) async {
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();
    try {
      members.add(userModel.uid);
      tokens.add(userModel.notifToken);

      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayRemove(members),
        'tokens': FieldValue.arrayRemove(tokens),
      });

      await _firestore.collection("users").document(userModel.uid).updateData({
        'groupId': null,
        'rank' : null,
      });
    } catch (e) {
      print(e);
    }

    return retVal;
  }
  Future<String> createEvent(String groupId, EventModel event) async {
    String retVal = "error";
    DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("eventsHistory")
          .add({
        'name': event.name.trim(),
        'author': event.author.trim(),
        'length': event.length,
        'dateCompleted': event.dateCompleted,
        "duringEvent": true,
      });

      await _firestore.collection("groups").document(groupId).updateData({
              "currentEventId": _docRef.documentID,
              "currentEventDue": event.dateCompleted,
              "duringEvent": true,
            });
    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("events")
          .add({
        'name': event.name.trim(),
        'author': event.author.trim(),
        'length': event.length,
        'dateCompleted': event.dateCompleted,
        "duringEvent": true,
      });
      await _firestore.collection("groups").document(groupId).updateData({
              "viewId": _docRef.documentID,
              
            });
        

 

      

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> addEvent(String groupId, EventModel event) async {
    String retVal = "error";
    DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("eventsHistory")
          .add({
        'name': event.name.trim(),
        'author': event.author.trim(),
        'length': event.length,
        'dateCompleted': event.dateCompleted,
      });

    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("events")
          .add({
        'name': event.name.trim(),
        'author': event.author.trim(),
        'length': event.length,
        'dateCompleted': event.dateCompleted,
      });
        


      await _firestore.collection("groups").document(groupId).updateData({
        "currentEventId": _docRef.documentID,
        "currentEventDue": event.dateCompleted,
        "duringEvent": true,
      });

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> addEventEmpty(String groupId) async {
    String retVal = "error";

    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("events")
          .add({
        'name': "...",
        'author': "...",
        'length': "111",
        'dateCompleted': null,
      });

      await _firestore.collection("groups").document(groupId).updateData({
        "currentEventId": null,
        "currentEventDue": null,
      });

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> addNextEvent(String groupId, EventModel event) async {
    String retVal = "error";

    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("events")
          .add({
        'name': event.name.trim(),
        'author': event.author.trim(),
        'length': event.length,
        'dateCompleted': event.dateCompleted,
      });

    

      await _firestore.collection("groups").document(groupId).updateData({
        "nextEventId": _docRef.documentID,
        "nextEventDue": event.dateCompleted,
      });

  
      DocumentSnapshot doc =
          await _firestore.collection("groups").document(groupId).get();
      createNotifications(List<String>.from(doc.data["tokens"]) ?? [],
          event.name, event.author);

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> addCurrentEvent(String groupId, EventModel event) async {
    String retVal = "error";

    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("events")
          .add({
        'name': event.name.trim(),
        'author': event.author.trim(),
        'length': event.length,
        'dateCompleted': event.dateCompleted,
      });

      await _firestore.collection("groups").document(groupId).updateData({
        "currentEventId": _docRef.documentID,
        "currentEventDue": event.dateCompleted,
      });

      
      DocumentSnapshot doc =
          await _firestore.collection("groups").document(groupId).get();
      createNotifications(List<String>.from(doc.data["tokens"]) ?? [],
          event.name, event.author);

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> addRank(String uid, String rank) async {
    String retVal = "error";

    try {
      await _firestore.collection("users").document(uid).updateData({
        'rank': rank,
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> addTask(
      String uid, String contents, String priority, String authorEmail) async {
    String retVal = "error";

    try {
      DocumentReference _docRef = await _firestore
          .collection("users")
          .document(uid)
          .collection("tasks")
          .add({
        'userUid': uid,
        'authorEmail': authorEmail,
        'priority': priority,
        'contents': contents,
      });

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }
  Future<String>createEmergencyHistory(
      String groupId, EmergencyModel emergencyModel, String author)async{
        String retVal = "error";
        try{
          DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("emergenciesHistory")
          .add({
         
        'place': emergencyModel.place,
        'description': emergencyModel.description,
        'injured': emergencyModel.injured,
        'author': author,
        'duringEmergency': emergencyModel.view,
        //'dataCreated': emergencyModel.dateCreated,

        
      });
        }catch (e) {
      print(e);
    }

    return retVal;
  }
  void deleteEvent(GroupModel group)async{
     try {


      await _firestore.collection('groups').document(group.id).collection("events").getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      };
    });

        
       await _firestore.collection("groups").document(group.id).updateData({
        "duringEvent": false,

        
      });


    } catch (e) {
      print(e);
    }
  }
  void deleteEmergencyAlert(String groupUid) async {

    try {
      // await _firestore
      //     .collection("groups")
      //     .document(groupUid)
      //     .collection("emergencies")
          
      //     .delete();

      await _firestore.collection('groups').document(groupUid).collection("emergencies").getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      };
    });

        
       await _firestore.collection("groups").document(groupUid).updateData({
        "duringEmergency": false,

        
      });


    } catch (e) {
      print(e);
    }
  }
  Future<String> emergencyAccept(String groupId, String emeId, String userName)async {
    //String place, String description, String injured
    String retVal = "error";
    //DocumentReference _docRef;
    List<String> membersYes = List();
  

 
      

    
    try {
      membersYes.add(userName);
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("emergencies")
          .document(emeId)
          .updateData({
            "accept": FieldValue.increment(1),
            'membersYes': FieldValue.arrayUnion(membersYes),

         
      });
             
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }
  Future<String> emergencyReject(String groupId, String emeId, String userName)async {
    //String place, String description, String injured
    String retVal = "error";
    //DocumentReference _docRef;
    List<String> membersNo = List();
    
    
    try {
      membersNo.add(userName);
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("emergencies")
          .document(emeId)
          .updateData({
            "noAccept": FieldValue.increment(1),
            'membersNo': FieldValue.arrayUnion(membersNo),
         
      });
             
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> createEmergency(
      String groupId, EmergencyModel emergencyModel, String author) async {
    //String place, String description, String injured
    String retVal = "error";
    //DocumentReference _docRef;
    List<String> members = List();
    List<String> tokens = List();
    List<String> membersYes = List();
    List<String> membersNo = List();
    
    
      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayUnion(members),
        'tokens': FieldValue.arrayUnion(tokens),
    
      });
    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("emergencies")
          .add({
         
        'place': emergencyModel.place,
        'description': emergencyModel.description,
        'injured': emergencyModel.injured,
        'author': author,
        'duringEmergency': emergencyModel.view,
        'accept' : 0,
        'noAccept': 0,
        'membersYes' : membersYes,
        'membersNo' : membersNo,
        
        //'dataCreated': emergencyModel.dateCreated,
        
        
      });
      await _firestore.collection("groups").document(groupId).updateData({
        "duringEmergency": emergencyModel.view,
        "alertsId": _docRef.documentID,
      });
     
      DocumentSnapshot doc =
          await _firestore.collection("groups").document(groupId).get();
      createNotificationsEmergency(
          List<String>.from(doc.data["tokens"]) ?? [],
          emergencyModel.description,
          emergencyModel.place,
          emergencyModel.injured,
          author);
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> createNotificationsEmergency(List<String> tokens,
      String description, String place, String injured, String author) async {
    String retVal = "error";

    try {
      await _firestore.collection("emergencies").add({
        'description': description,
        'place': place,
        'injured': injured,
        'tokens': tokens,
        'author': author,
        'sent': false,
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  void deleteTask(String userUid, String taskUid) async {
    try {
      await _firestore
          .collection("users")
          .document(userUid)
          .collection("tasks")
          .document(taskUid)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  Future<EventModel> getCurrentEvent(String groupId, String eventId) async {
    EventModel retVal;

    try {
      DocumentSnapshot _docSnapshot = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("events")
          .document(eventId)
          .get();
      retVal = EventModel.fromDocumentSnapshot(doc: _docSnapshot);
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<TaskModel> getTask(String userId, String taskId) async {
    TaskModel taskModel;

    try {
      DocumentSnapshot _docSnapshot = await _firestore
          .collection("users")
          .document(userId)
          .collection("tasks")
          .document(taskId)
          .get();
      taskModel = TaskModel.fromDocumentSnapshot(doc: _docSnapshot);
    } catch (e) {
      print(e);
    }

    return taskModel;
  }
  Future<List<EmergencyModel>> getAlert(String groupId) async {
    List<EmergencyModel> emergencyModel = List();

    try {
      QuerySnapshot query = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("emergencies")
          .getDocuments();

      query.documents.forEach((element) {
        emergencyModel.add(EmergencyModel.fromDocumentSnapshot(doc: element));
      });
    } catch (e) {
      print(e);
    }

    return emergencyModel;
  }
Future<EmergencyDuringModel> getAlert1(String groupId, String alertId) async {
    EmergencyDuringModel emergencyModel;

    try {
      DocumentSnapshot _docSnapshot = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("emergencies")
          .document(alertId).get();


        emergencyModel=(EmergencyDuringModel.fromDocumentSnapshot(doc: _docSnapshot));

    } catch (e) {
      print(e);
    }
    

    return emergencyModel;
  }

  Future<String> finishedEvent(
    String groupId,
    String eventId,
    String uid,
    int rating,
    String review,
  ) async {
    String retVal = "error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("eventsHistory")
          .document(eventId)
          .collection("reviews")
          .document(uid)
          .setData({
        'rating': rating,
        'review': review,
      });
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<bool> isUserDoneWithEvent(
      String groupId, String eventId, String uid) async {
    bool retVal = false;
    try {
      DocumentSnapshot _docSnapshot = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("events")
          .document(eventId)
          .collection("reviews")
          .document(uid)
          .get();

      if (_docSnapshot.exists) {
        retVal = true;
      }
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> createUser(UserModel user) async {
    String retVal = "error";

    try {
      await _firestore.collection("users").document(user.uid).setData({
        'fullName': user.fullName.trim(),
        'email': user.email.trim(),
        'accountCreated': Timestamp.now(),
        'notifToken': user.notifToken,
        'uid': user.uid,
        'photoUrl': user.photoUrl,
        'rank': "Strażak",
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<UserModel> getUser(String uid) async {
    UserModel retVal;

    try {
      DocumentSnapshot _docSnapshot =
          await _firestore.collection("users").document(uid).get();
      retVal = UserModel.fromDocumentSnapshot(doc: _docSnapshot);
    } catch (e) {
      print(e);
    }

    return retVal;
  }
  Future<UserModel> getAlertId(String alertId, String groupId) async {
    UserModel retVal;

    try {
      DocumentSnapshot _docSnapshot =
          await _firestore.collection("group").document(groupId).
          collection("emergencies").document(alertId).
          get();
      retVal = UserModel.fromDocumentSnapshot(doc: _docSnapshot);
    } catch (e) {
      print(e);
    }

    return retVal;
  }

 
  Future<List<UserModel>> getUsers(List<String> members) async {
    List<UserModel> retVal = [];
    for (var uid in members) {
      retVal.add(await getUser(uid));
    }
    return retVal;
  }
  //  Future<List<EmergencyDuringModel>> getMembersYes(List<String> members) async {
  //   List<EmergencyDuringModel> retVal = [];
  //   for (var uid in members) {
  //     retVal.add(await getMember(uid));
  //   }
  //   return retVal;
  // }
  Future<EmergencyDuringModel> getMember(String groupId, String emeId) async {
    EmergencyDuringModel retVal;

    try {
      DocumentSnapshot _docSnapshot =
          await _firestore.collection("groups").document(groupId).collection("emergencies").document(emeId).get();
      retVal = EmergencyDuringModel.fromDocumentSnapshot(doc: _docSnapshot);
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<List<MembersModel>> getMembers(String groupId) async {
    List<MembersModel> retVal = List();

    try {
      QuerySnapshot query = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("members")
          .getDocuments();

      query.documents.forEach((element) {
        retVal.add(MembersModel.fromDocumentSnapshot(doc: element));
      });
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<List<TaskModel>> getTasks(String userId) async {
    List<TaskModel> retVal = List();

    try {
      QuerySnapshot query = await _firestore
          .collection("users")
          .document(userId)
          .collection("tasks")
          .getDocuments();

      query.documents.forEach((element) {
        retVal.add(TaskModel.fromDocumentSnapshot(doc: element));
      });
    } catch (e) {
      print(e);
    }

    return retVal;
  }
  Future<List<EmergencyModel>> getAlertsHistory(String groupId) async {
    List<EmergencyModel> retVal = List();

    try {
      QuerySnapshot query = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("emergenciesHistory")
          .getDocuments();

      query.documents.forEach((element) {
        retVal.add(EmergencyModel.fromDocumentSnapshot(doc: element));
      });
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<GroupModel> getGroup(String groupId) async {
    GroupModel retVal;

    try {
      DocumentSnapshot _docSnapshot =
          await _firestore.collection("groups").document(groupId).get();
      retVal = GroupModel.fromDocumentSnapshot(doc: _docSnapshot);
    } catch (e) {
      print(e);
    }

    return retVal;
  }
 
  Future<String> createNotifications(
      List<String> tokens, String eventName, String author) async {
    String retVal = "error";

    try {
      await _firestore.collection("notifications").add({
        'eventName': eventName.trim(),
        'author': author.trim(),
        'tokens': tokens,
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<List<EventModel>> getEventHistory(String groupId) async {
    List<EventModel> retVal = List();

    try {
      QuerySnapshot query = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("eventsHistory")
          .orderBy("dateCompleted", descending: true)
          .getDocuments();

      query.documents.forEach((element) {
        retVal.add(EventModel.fromDocumentSnapshot(doc: element));
      });
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<List<ReviewModel>> getReviewHistory(
      String groupId, String eventId) async {
    List<ReviewModel> retVal = List();

    try {
      QuerySnapshot query = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("eventsHistory")
          .document(eventId)
          .collection("reviews")
          .getDocuments();

      query.documents.forEach((element) {
        retVal.add(ReviewModel.fromDocumentSnapshot(doc: element));
      });
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<void> saveTokenToDatabase(String token) async {
   

    final FirebaseUser userr = await auth.currentUser();
    String userId = userr.uid;
    await _firestore.collection('users').document(userId).updateData({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }

}
