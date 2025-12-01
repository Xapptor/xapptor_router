import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_router/model/user_session.dart';
import 'package:xapptor_db/xapptor_db.dart';

/// Saves the current screen view to Firebase Analytics and Firestore.
///
/// This function:
/// 1. Logs a screen view event to Firebase Analytics
/// 2. Saves the session to the user's document in Firestore
/// 3. Cleans up old sessions if count exceeds 10
///
/// Only runs if a user is authenticated.
///
/// ## Parameters
///
/// - [screen_name]: The route name being viewed
///
/// ## Example
///
/// ```dart
/// save_user_session_v2("home/courses");
/// ```
Future<void> save_user_session_v2(String screen_name) async {
  User? current_user = FirebaseAuth.instance.currentUser;

  if (current_user != null) {
    // Log to Firebase Analytics
    FirebaseAnalytics.instance.logScreenView(
      screenClass: screen_name,
      screenName: screen_name,
    );

    // Save to Firestore
    UserSession xapptor_session = UserSession(
      screen_name: screen_name,
      date: Timestamp.now(),
    );

    XapptorDB.instance.collection("users").doc(current_user.uid).update({
      "last_sessions": FieldValue.arrayUnion([xapptor_session.to_json()]),
    });

    // Clean up old sessions on key screens
    if (screen_name == "login" || screen_name == "home") {
      _clean_user_sessions_v2(screen_name, current_user);
    }
  }
}

/// Cleans up old user sessions, keeping only the last 10.
Future<void> _clean_user_sessions_v2(String screen_name, User current_user) async {
  DocumentSnapshot doc_snap =
      await XapptorDB.instance.collection("users").doc(current_user.uid).get();

  if (doc_snap.get("last_sessions") != null) {
    UserSessionList last_sessions =
        UserSessionList.from_snapshot(doc_snap.get("last_sessions"));

    if (last_sessions.items.length > 10) {
      int index = last_sessions.items.length - 10;
      last_sessions.items = last_sessions.items.sublist(index);

      XapptorDB.instance.collection("users").doc(current_user.uid).update({
        "last_sessions": last_sessions.to_json(),
      });
    }
  }
}
