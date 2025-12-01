// User Session Model.

import 'package:cloud_firestore/cloud_firestore.dart';

class UserSession {
  String screen_name;
  Timestamp date;

  UserSession({
    required this.screen_name,
    required this.date,
  });

  UserSession.from_snapshot(
    Map<String, dynamic> snapshot,
  )   : screen_name = snapshot['screen_name'],
        date = snapshot['date'];

  Map<String, dynamic> to_json() {
    return {
      'screen_name': screen_name,
      'date': date,
    };
  }
}

class UserSessionList {
  List<UserSession> items;

  UserSessionList({
    required this.items,
  });

  UserSessionList.from_snapshot(
    List list,
  ) : items =
            list.map((element) => UserSession.from_snapshot(element)).toList();

  List<Map<String, dynamic>> to_json() {
    return items.map((element) => element.to_json()).toList();
  }
}
