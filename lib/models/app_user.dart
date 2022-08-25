import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram_clone/Firebase/firebase_storage.dart';

class AppUser {
  String appUserId;
  String email;
  String avatarUrl;
  String username;
  String phoneNumber;
  String bio;

  AppUser(this.appUserId, this.email, this.avatarUrl, this.username,
      this.phoneNumber, this.bio);
  AppUser.empty()
      : appUserId = '',
        avatarUrl = '',
        username = '',
        email = '',
        phoneNumber = '',
        bio = '';

  AppUser.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options)
      : appUserId = snapshot.id,
        avatarUrl = snapshot.data()?['avatarUrl'],
        email = snapshot.data()?['email'],
        username = snapshot.data()?['userName'],
        phoneNumber = snapshot.data()?['phoneNumber'],
        bio = snapshot.data()?['bio'];

  static Map<String, dynamic> toFireStore(AppUser value, SetOptions? options) =>
      {
        'email': value.email,
        'avatarUrl': value.avatarUrl,
        'userName': value.username,
        'phoneNumber': value.phoneNumber,
        'bio': value.bio
      };

  AppUser.fromJson(Map<String, dynamic>? json)
      : appUserId = json?['appUserId'],
        avatarUrl = json?['avatarUrl'],
        email = json?['email'],
        username = json?['userName'],
        phoneNumber = json?['phoneNumber'],
        bio = json?['bio'];

  Map<String, dynamic> toJson() => {
        'appUserId': appUserId,
        'email': email,
        'avatarUrl': avatarUrl,
        'userName': username,
        'phoneNumber': phoneNumber,
        'bio': bio
      };

  static Future<AppUser> withDownloadableUrl(
      DocumentSnapshot<AppUser> snapshot) {
    return FirebaseAppStorage.getDownloadableUrl(snapshot.data()!.avatarUrl)
        .then((avatarUrl) => AppUser(
            snapshot.data()!.appUserId,
            snapshot.data()!.email,
            avatarUrl,
            snapshot.data()!.username,
            snapshot.data()!.phoneNumber,
            snapshot.data()!.bio));
  }

  String get getAppUserId => appUserId;

  set setAppUserId(String newAppUserId) {
    appUserId = newAppUserId;
  }

  String get getEmail => email;

  set setEmail(String newEmail) {
    email = newEmail;
  }

  String get getAvatarUrl => avatarUrl;

  set setAvatarUrl(String newAvatarUrl) {
    avatarUrl = newAvatarUrl;
  }

  String get getUsername => username;

  set setUsername(String newUsername) {
    username = newUsername;
  }

  String? get getPhoneNumber => phoneNumber;

  set setPhoneNumber(String newPhoneNumber) {
    phoneNumber = newPhoneNumber;
  }

  String? get getBio => bio;

  set setBio(String newBio) {
    bio = newBio;
  }
}
