import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/_firebase_collections.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';

class AppUsersRepo {
  static Future<AppUser> findAppUserById(String appUserId) =>
      FirebaseCollections.appUsersCollection
          .doc(appUserId)
          .get()
          .then(AppUser.withDownloadableUrl);

  static Future<List<AppUser>> findAllAppUserByIds(
          List<String> idArray) async =>
      Future.wait(await FirebaseCollections.appUsersCollection
          .where(FieldPath.documentId, whereIn: idArray)
          .get()
          .then((qresult) => qresult.docs.map(AppUser.withDownloadableUrl)));

  static Future<AppUser> findFirstAppUserByAttribute(
          String attribute, String value) =>
      FirebaseCollections.appUsersCollection
          .where(attribute, isEqualTo: value)
          .get()
          .then((r) => r.docs[0])
          .then(AppUser.withDownloadableUrl);

  static Future<List<AppUser>> findAllAppUsersByAttribute(
          String attribute, String value) async =>
      Future.wait(await FirebaseCollections.appUsersCollection
          .where(attribute, isEqualTo: value)
          .get()
          .then((result) => result.docs.map(AppUser.withDownloadableUrl)));

  static Future<AppUser> addAppUser(AppUser userData) async {
    var docRef = FirebaseCollections.appUsersCollection.doc();
    await docRef.set(userData);
    return docRef.get().then(AppUser.withDownloadableUrl);
  }

  static Future<AppUser> updateAppUser(AppUser userData) =>
      FirebaseCollections.appUsersCollection
          .doc(userData.appUserId)
          .update(AppUser.toFireStore(userData, null))
          .then((v) => findAppUserById(userData.appUserId));
}
