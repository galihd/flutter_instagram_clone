import 'package:cloud_firestore/cloud_firestore.dart';

class Follow {
  String followId;
  String fromUserId;
  String toUserId;

  Follow(this.followId, this.fromUserId, this.toUserId);

  Follow.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options)
      : followId = snapshot.id,
        fromUserId = snapshot.data()?['fromUserId'],
        toUserId = snapshot.data()?['toUserId'];
  static Map<String, dynamic> toFireStore(Follow value, SetOptions? options) =>
      {
        'followId': value.followId,
        'fromUserId': value.fromUserId,
        'toUserId': value.toUserId
      };

  String get getFollowId => followId;

  set setFollowId(String newFollowId) {
    followId = newFollowId;
  }

  String get getFromUserId => fromUserId;

  set setFromUserId(String newFromUserId) {
    fromUserId = newFromUserId;
  }

  String get getToUserId => toUserId;

  set setToUserId(String newToUserId) {
    toUserId = newToUserId;
  }
}
