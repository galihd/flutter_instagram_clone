import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/appuser_repo.dart';
import 'package:flutter_instagram_clone/Firebase/firebase_storage.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';

enum PostType { post, reels }

class Post {
  Post(this.postId, this.fileUrls, this.caption, this.appUserId, this.appUser, this.taggedPeople, this.location,
      this.commentCount, this.likesCount, this.createdAt, this.postType);

  String postId;
  List<String> fileUrls;
  String? caption;
  String appUserId;
  AppUser? appUser;
  List<AppUser>? taggedPeople;
  String? location;
  int commentCount;
  int likesCount;
  Timestamp createdAt;
  PostType postType;

  Post.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options)
      : postId = snapshot.id,
        fileUrls = List<String>.from(snapshot.data()?['fileUrls']),
        caption = snapshot.data()?['caption'],
        appUserId = snapshot.data()?['appUserId'],
        likesCount = snapshot.data()?['likesCount'],
        commentCount = snapshot.data()?['commentCount'],
        postType = PostType.values.byName(snapshot.data()?['postType']),
        createdAt = snapshot.data()?['createdAt'];

  static Map<String, dynamic> toFireStore(Post value, SetOptions? options) => {
        "postId": value.postId,
        "fileUrls": value.fileUrls,
        "caption": value.caption,
        "appUserId": value.appUser!.getAppUserId,
        "taggedPeople": value.taggedPeople,
        "location": value.location,
        "commentCount": value.commentCount,
        "likesCount": value.likesCount,
        "createdAt": value.createdAt,
        "postType": value.postType.name
      };

  static Future<Post> withDownloadableUrl(DocumentSnapshot<Post> snapshot) async {
    return Post(
        snapshot.data()!.postId,
        await FirebaseAppStorage.getMultipleDownloadableUrl(snapshot.data()!.fileUrls),
        snapshot.data()!.caption,
        snapshot.data()!.appUserId,
        await AppUsersRepo.findAppUserById(snapshot.data()!.appUserId),
        snapshot.data()!.taggedPeople,
        snapshot.data()!.location,
        snapshot.data()!.commentCount,
        snapshot.data()!.likesCount,
        snapshot.data()!.createdAt,
        snapshot.data()!.postType);
  }

  String get getPostId => postId;

  set setPostId(String newPostId) {
    postId = newPostId;
  }

  List<String> get getFileUrls => fileUrls;

  set setFileUrls(List<String> newFileUrls) {
    fileUrls = newFileUrls;
  }

  String? get getCaption => caption;

  set setCaption(String newCaption) {
    caption = newCaption;
  }

  AppUser? get getAppUser => appUser;

  set setAppUser(AppUser newAppUser) {
    appUser = newAppUser;
  }

  List<AppUser>? get getTaggedPeople => taggedPeople;

  set setTaggedPeople(List<AppUser> newTaggedPeople) {
    taggedPeople = newTaggedPeople;
  }

  String? get getLocation => location;

  set setLocation(String newLocation) {
    location = newLocation;
  }

  int get getCommentCount => commentCount;

  set setCommentCount(int newCommentCount) {
    commentCount = newCommentCount;
  }

  int get getLikesCount => likesCount;

  set setLikesCount(int newLikesCount) {
    likesCount = newLikesCount;
  }

  Timestamp get getCreatedAt => createdAt;

  set setCreatedAt(Timestamp newCreatedAt) {
    createdAt = newCreatedAt;
  }

  PostType get getPostType => postType;

  set setPostType(PostType newPostType) {
    postType = newPostType;
  }
}
