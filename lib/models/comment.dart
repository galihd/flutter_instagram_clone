import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/appuser_repo.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';

enum TargetType { post, comment }

class Comment {
  Comment(this.commentId, this.targetId, this.appUserId, this.appUser, this.comment, this.targetType, this.likesCount,
      this.replyCount, this.createdAt, this.targetCommentId);

  String commentId;
  String targetId;
  String appUserId;
  AppUser? appUser;
  String comment;
  TargetType targetType;
  String? targetCommentId;
  int likesCount;
  int replyCount;
  Timestamp createdAt;

  Comment.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options)
      : commentId = snapshot.id,
        targetId = snapshot.data()?['targetId'],
        appUserId = snapshot.data()?['appUserId'],
        comment = snapshot.data()?['comment'],
        targetType = TargetType.values.byName(snapshot.data()?['targetType']),
        targetCommentId = snapshot.data()?['targetCommentId'],
        likesCount = snapshot.data()?['likesCount'],
        replyCount = snapshot.data()?['replyCount'],
        createdAt = snapshot.data()?['createdAt'];

  static Map<String, dynamic> toFireStore(Comment value, SetOptions? options) => {
        'commentId': value.commentId,
        'targetId': value.targetId,
        'appUserId': value.appUser!.appUserId,
        'comment': value.comment,
        'targetType': value.targetType.name,
        'targetCommentId': value.targetCommentId,
        'likesCount': value.likesCount,
        'replyCount': value.replyCount,
        'createdAt': value.createdAt
      };

  static Future<Comment> withDownloadableUrl(DocumentSnapshot<Comment> snapshot) async => Comment(
      snapshot.data()!.commentId,
      snapshot.data()!.targetId,
      snapshot.data()!.appUserId,
      await AppUsersRepo.findAppUserById(snapshot.data()!.appUserId),
      snapshot.data()!.comment,
      snapshot.data()!.targetType,
      snapshot.data()!.likesCount,
      snapshot.data()!.replyCount,
      snapshot.data()!.createdAt,
      snapshot.data()!.targetCommentId);

  String get getCommentId => commentId;

  set setCommentId(String newCommentId) {
    commentId = newCommentId;
  }

  String get gettargetId => targetId;

  set settargetId(String newtargetId) {
    targetId = newtargetId;
  }

  AppUser? get getAppUser => appUser;

  set setAppUser(AppUser newAppUser) {
    appUser = newAppUser;
  }

  String get getComment => comment;

  set setComment(String newComment) {
    comment = newComment;
  }

  TargetType get getTargetType => targetType;

  set setTargetType(TargetType newTargetType) {
    targetType = newTargetType;
  }

  String? get getTargetCommentId => targetCommentId;

  set setTargetCommentId(String newTargetCommentId) {
    targetCommentId = newTargetCommentId;
  }

  int get getLikesCount => likesCount;

  set setLikesCount(int newLikesCount) {
    likesCount = newLikesCount;
  }

  int get getReplyCount => replyCount;

  set setReplyCount(int newReplyCount) {
    replyCount = newReplyCount;
  }

  Timestamp get getCreatedAt => createdAt;

  set setCreatedAt(Timestamp newCreatedAt) {
    createdAt = newCreatedAt;
  }
}
