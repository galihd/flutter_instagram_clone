import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:flutter_instagram_clone/models/post.dart';

class FirebaseAppStorage {
  static final storage = FirebaseStorage.instance;

  static Reference userPostRef(Post postData) => storage.ref('${postData.appUser!.appUserId}/post/${postData.postId}');

  static Reference userAvatarRef(AppUser userData) => storage.ref('${userData.appUserId}/${userData.email}.jpg');

  static Future<String> getDownloadableUrl(String path) => storage.ref(path).getDownloadURL();

  static Future<List<String>> getMultipleDownloadableUrl(List<String> paths) =>
      Future.wait(paths.map((e) => getDownloadableUrl(e)));

  static Future<List<String>> uploadPostImages(Post postData) {
    List<Future<String>> fileUrls = postData.fileUrls.asMap().entries.map((url) async {
      int index = url.key;
      Reference uploadRef = identical(postData.postType, PostType.post)
          ? storage.ref('${userPostRef(postData).fullPath}/$index.jpg')
          : storage.ref('${userPostRef(postData).fullPath}/$index.mp4');
      // get image url from filesystem
      File file = File(url.value);
      // upload it
      await uploadRef.putFile(file);
      // return the reference path
      return uploadRef.fullPath;
    }).toList();
    return Future.wait(fileUrls);
  }

  static Future<String> updateAvatar(AppUser userData, File newAvatar) async {
    Reference uploadRef = userAvatarRef(userData);
    await uploadRef.putFile(newAvatar);
    return uploadRef.fullPath;
  }

  static void deletePost(Post postData) =>
      postData.fileUrls.asMap().entries.forEach((element) => storage.ref().child(element.value).delete());
}
