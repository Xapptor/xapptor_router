import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'model/user_session.dart';
import 'package:xapptor_db/xapptor_db.dart';

save_user_session(String screen_name) async {
  User? current_user = FirebaseAuth.instance.currentUser;

  if (current_user != null) {
    FirebaseAnalytics.instance.logScreenView(
      screenClass: screen_name,
      screenName: screen_name,
    );

    UserSession xapptor_session = UserSession(
      screen_name: screen_name,
      date: Timestamp.now(),
    );

    XapptorDB.instance.collection("users").doc(current_user.uid).update({
      "last_sessions": FieldValue.arrayUnion([xapptor_session.to_json()]),
    });

    if (screen_name == "login" || screen_name == "home") {
      clean_user_sessions(screen_name, current_user);
    }
  }
}

clean_user_sessions(String screen_name, User current_user) async {
  DocumentSnapshot doc_snap = await XapptorDB.instance.collection("users").doc(current_user.uid).get();

  if (doc_snap.get("last_sessions") != null) {
    UserSessionList last_sessions = UserSessionList.from_snapshot(doc_snap.get("last_sessions"));

    if (last_sessions.items.length > 10) {
      int index = last_sessions.items.length - 10;
      last_sessions.items = last_sessions.items.sublist(index);

      XapptorDB.instance.collection("users").doc(current_user.uid).update({
        "last_sessions": last_sessions.to_json(),
      });
    }
  }
}
