import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/appuser_repo.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:flutter_instagram_clone/models/comment.dart';

class Like {
  Like(this.likeId, this.targetType, this.targetId, this.appUserId, this.appUser);
  String likeId;
  TargetType targetType;
  String targetId;
  AppUser? appUser;
  String appUserId;

  String get getLikeId => likeId;

  Like.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options)
      : likeId = snapshot.id,
        targetType = TargetType.values.byName(snapshot.data()?['targetType']),
        targetId = snapshot.data()?['targetId'],
        appUserId = snapshot.data()?['appUserId'];

  static Map<String, dynamic> toFireStore(Like value, SetOptions? options) => {
        'likeId': value.likeId,
        'targetType': value.targetType.name,
        'targetId': value.targetId,
        'appUserId': value.appUser!.appUserId
      };

  static Future<Like> withDownloadableUrl(DocumentSnapshot<Like> snapshot) async => Like(
      snapshot.data()!.likeId,
      snapshot.data()!.targetType,
      snapshot.data()!.targetId,
      snapshot.data()!.appUserId,
      await AppUsersRepo.findAppUserById(snapshot.data()!.appUserId));

  set setLikeId(String newLikeId) {
    likeId = newLikeId;
  }

  TargetType get getTargetType => targetType;

  set setTargetType(TargetType newTargetType) {
    targetType = newTargetType;
  }

  String get getTargetId => targetId;

  set setTargetId(String newTargetId) {
    targetId = newTargetId;
  }

  AppUser? get getAppUser => appUser;

  set setAppUser(AppUser newAppUser) {
    appUser = newAppUser;
  }
}
