import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/_firebase_collections.dart';
import 'package:flutter_instagram_clone/Firebase/firebase_storage.dart';
import 'package:flutter_instagram_clone/models/comment.dart';
import 'package:flutter_instagram_clone/models/like.dart';
import 'package:flutter_instagram_clone/models/post.dart';

class PostsRepo {
  // POST SECTION
  static Future<List<Post>> findAllPosts() async =>
      Future.wait(await FirebaseCollections.postsCollection.get().then((value) => value.docs.map(Post.withDownloadableUrl)));

  static Future<Post> findPostById(String postId) =>
      FirebaseCollections.postsCollection.doc(postId).get().then(Post.withDownloadableUrl);

  static Future<List<Post>> findAllPostsByIds(List<String> ids) async =>
      Future.wait(await FirebaseCollections.postsCollection
          .where(FieldPath.documentId, whereIn: ids)
          .get()
          .then((qresult) => qresult.docs.map(Post.withDownloadableUrl)));

  static Future<List<Post>> findAllPostsByAttribute(String attribute, String value) async =>
      Future.wait(await FirebaseCollections.postsCollection
          .where(attribute, isEqualTo: value)
          .get()
          .then((qresult) => qresult.docs.map(Post.withDownloadableUrl)));

  static Future<List<Post>> findAllPostsByAttributesWhereIn(String attributes, List<String> values) async =>
      Future.wait(await FirebaseCollections.postsCollection
          .where(attributes, whereIn: values)
          .get()
          .then((qresult) => qresult.docs.map(Post.withDownloadableUrl)));

  static Future<Post> addPost(Post postData) async {
    var docRef = FirebaseCollections.postsCollection.doc();
    postData.postId = docRef.id;
    postData.fileUrls = await FirebaseAppStorage.uploadPostImages(postData);
    await docRef.set(postData);
    return findPostById(docRef.id);
  }

  static Future<void> deletePostById(String postId) => FirebaseCollections.postsCollection.doc(postId).get().then((e) {
        // FirebaseAppStorage.deletePost(e.data()!);
        deleteAllCommentsByTargetId(postId);
        // deleteAllLikesByTargetId(postId);
        // FirebaseCollections.postsCollection.doc(postId).delete();
      });

  // COMMENTS SECTION
  static Future<Comment> addComment(Comment commentData) async {
    var docRef = FirebaseCollections.commentsCollection.doc();
    await docRef.set(commentData);
    commentData.commentId = docRef.id;
    commentData.targetType == TargetType.post
        ? await FirebaseCollections.postsCollection
            .doc(commentData.targetId)
            .update({"commentCount": FieldValue.increment(1)})
        : await FirebaseCollections.commentsCollection
            .doc(commentData.targetId)
            .update({"replyCount": FieldValue.increment(1)});
    return commentData;
  }

  static Future<Comment> findCommentById(String commentId) =>
      FirebaseCollections.commentsCollection.doc(commentId).get().then(Comment.withDownloadableUrl);

  static Future<List<Comment>> findAllCommentsByAttribute(String attribute, String value) async =>
      Future.wait(await FirebaseCollections.commentsCollection
          .where(attribute, isEqualTo: value)
          .get()
          .then((qresult) => qresult.docs.map(Comment.withDownloadableUrl)));

  static void deleteComment(Comment comment) => FirebaseCollections.commentsCollection.doc(comment.commentId).delete().then(
      (value) => comment.targetType == TargetType.post
          ? FirebaseCollections.postsCollection.doc(comment.targetId).update({'commentCount': FieldValue.increment(-1)})
          : FirebaseCollections.commentsCollection.doc(comment.targetId).update({'commentCount': FieldValue.increment(-1)}));

  static Future<void> deleteAllCommentsByTargetId(String targetId) async {
    var batch = FirebaseCollections.db.batch();

    await FirebaseCollections.commentsCollection.where("targetId", isEqualTo: targetId).get().then((qresult) {
      for (var document in qresult.docs) {
        deleteAllLikesByTargetId(document.id);
        batch.delete(document.reference);
        // delete all replies and its likes
        if (document.data().targetType == TargetType.comment) {
          deleteComment(document.data());
        }
      }
    });
    return batch.commit();
  }

  // Likes section
  static Future<Like?> findLikeByTargetIdAndUserId(String targetId, String userId) => FirebaseCollections.likesCollection
      .where('targetId', isEqualTo: targetId)
      .where('appUserId', isEqualTo: userId)
      .get()
      .then((qresult) => qresult.docs.isNotEmpty ? Like.withDownloadableUrl(qresult.docs[0]) : null);

  static Future<Like> addLike(Like likeData) async {
    var docRef = FirebaseCollections.likesCollection.doc();
    await docRef.set(likeData);
    likeData.setLikeId = docRef.id;

    (likeData.targetType == TargetType.post)
        ? await FirebaseCollections.postsCollection.doc(likeData.targetId).update({"likesCount": FieldValue.increment(1)})
        : await FirebaseCollections.commentsCollection
            .doc(likeData.targetId)
            .update({"likesCount": FieldValue.increment(1)});

    return likeData;
  }

  static Future<void> deleteLike(Like like) =>
      FirebaseCollections.likesCollection.doc(like.likeId).delete().then((_) => like.targetType == TargetType.post
          ? FirebaseCollections.postsCollection.doc(like.targetId).update({'likesCount': FieldValue.increment(-1)})
          : FirebaseCollections.commentsCollection.doc(like.targetId).update({'likesCount': FieldValue.increment(-1)}));

  static Future<void> deleteAllLikesByTargetId(String targetId) async {
    var batch = FirebaseCollections.db.batch();
    await FirebaseCollections.likesCollection.where("targetId", isEqualTo: targetId).get().then((qresult) {
      for (var document in qresult.docs) {
        batch.delete(document.reference);
      }
    });
    return batch.commit();
  }
}
