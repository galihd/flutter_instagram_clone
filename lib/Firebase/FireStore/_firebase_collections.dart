import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:flutter_instagram_clone/models/comment.dart';
import 'package:flutter_instagram_clone/models/follow.dart';
import 'package:flutter_instagram_clone/models/like.dart';
import 'package:flutter_instagram_clone/models/post.dart';

class FirebaseCollections {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final CollectionReference<AppUser> appUsersCollection = db
      .collection("AppUsers")
      .withConverter<AppUser>(
          fromFirestore: AppUser.fromFireStore,
          toFirestore: AppUser.toFireStore);

  static final CollectionReference<Post> postsCollection = db
      .collection("Posts")
      .withConverter<Post>(
          fromFirestore: Post.fromFireStore, toFirestore: Post.toFireStore);

  static final CollectionReference<Follow> followsCollection = db
      .collection("Follows")
      .withConverter(
          fromFirestore: Follow.fromFireStore, toFirestore: Follow.toFireStore);

  static final CollectionReference<Comment> commentsCollection = db
      .collection("Comments")
      .withConverter(
          fromFirestore: Comment.fromFireStore,
          toFirestore: Comment.toFireStore);

  static final CollectionReference<Like> likesCollection = db
      .collection("Likes")
      .withConverter(
          fromFirestore: Like.fromFireStore, toFirestore: Like.toFireStore);
}
