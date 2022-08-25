import 'package:flutter_instagram_clone/Firebase/FireStore/_firebase_collections.dart';
import 'package:flutter_instagram_clone/models/follow.dart';

class FollowsRepo {
  static Future<Follow> addFollow(Follow followData) async {
    var docRef = FirebaseCollections.followsCollection.doc();
    await docRef.set(followData);
    followData.followId = docRef.id;
    return followData;
  }

  static Future<List<Follow>> findAllFollowersByUserId(String userId) => FirebaseCollections.followsCollection
      .where("toUserId", isEqualTo: userId)
      .get()
      .then((qresult) => qresult.docs.map((e) => e.data()))
      .then((value) => value.toList());

  static Future<List<Follow>> findAllFollowingByUserId(String userId) => FirebaseCollections.followsCollection
      .where("fromUserId", isEqualTo: userId)
      .get()
      .then((qresult) => qresult.docs.map((e) => e.data()))
      .then((value) => value.toList());

  static Future<void> deleteFollowbyId(String followId) => FirebaseCollections.followsCollection.doc(followId).delete();
}
