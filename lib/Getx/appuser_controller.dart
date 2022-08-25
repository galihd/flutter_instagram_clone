import 'dart:io';

import 'package:flutter_instagram_clone/Firebase/FireStore/appuser_repo.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/follows_repo.dart';
import 'package:flutter_instagram_clone/Firebase/firebase_storage.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:flutter_instagram_clone/models/follow.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppUserController extends GetxController {
  static const String ACTIVE_APPUSER_STORAGE = "active_appUser";
  static const String APPUSER_STORAGE = "appUser";

  final storage = GetStorage();
  final appUser = AppUser('', '', '', '', '', '').obs;
  final following = <Follow>[].obs;
  final followers = <Follow>[].obs;
  final isAuthenticated = false.obs;

  @override
  void onInit() {
    ever(isAuthenticated, authenticatedCallBack);
    AppUser? lastActiveUser = loadActiveUserDataFromStorage();
    if (lastActiveUser != null) {
      userLogin(lastActiveUser);
    }
    print("appUser INIT, ${lastActiveUser?.appUserId} ");
    super.onInit();
  }

  Future<void> authenticatedCallBack(bool isAuth) async {
    if (isAuth) {
      await setUserRelation(appUser.value.appUserId);
    } else {
      appUser.value = AppUser('', '', '', '', '', '');
      following.value = [];
      followers.value = [];
    }
  }

  Future<void> userLogin(AppUser userData) {
    appUser.value = userData;
    isAuthenticated.value = true;
    return storeUserDataToStorage(userData);
  }

  Future<void> switchUser(AppUser userData) async {
    isAuthenticated.value = false;
    return userLogin(userData);
  }

  Future<void> setUserRelation(String appUserId) async {
    following.value = await FollowsRepo.findAllFollowingByUserId(appUser.value.appUserId);
    followers.value = await FollowsRepo.findAllFollowersByUserId(appUser.value.appUserId);
  }

  Future<AppUser> registerUser(String email, String password) {
    AppUser userData = AppUser('', email, 'defaultUser.png', email.split('@')[0], '', '');

    return AppUsersRepo.addAppUser(userData);
  }

  AppUser? loadActiveUserDataFromStorage() {
    var userJson = storage.read<Map<String, dynamic>>(ACTIVE_APPUSER_STORAGE);
    if (userJson == null) return null;
    return AppUser.fromJson(userJson);
  }

  List<AppUser>? loadExistingUserDataFromStorage() =>
      storage.read<List<dynamic>>(APPUSER_STORAGE)?.map((e) => AppUser.fromJson(e)).toList();

  Future<void> storeUserDataToStorage(AppUser userData) {
    List<AppUser>? existingUser = loadExistingUserDataFromStorage();
    if (existingUser != null) {
      existingUser = existingUser.where((element) => element.appUserId != userData.appUserId).toList();
      existingUser.add(userData);

      storage.write(APPUSER_STORAGE, existingUser.map((e) => e.toJson()).toList());
    } else {
      storage.write(APPUSER_STORAGE, [userData.toJson()]);
    }
    return storage.write(ACTIVE_APPUSER_STORAGE, appUser.value);
  }

  Future<void> updateUser(AppUser userData, File? newAvatar) async {
    String newUrl = newAvatar == null ? userData.avatarUrl : await FirebaseAppStorage.updateAvatar(userData, newAvatar);
    userData.avatarUrl = newUrl;
    return AppUsersRepo.updateAppUser(userData).then((value) => appUser.value = value).then(storeUserDataToStorage);
  }

  Future<Follow> followUser(String targetId) async {
    Follow followData = await FollowsRepo.addFollow(Follow('', appUser.value.appUserId, targetId));
    following.add(followData);
    return followData;
  }

  Future<Follow> unFollowUser(String targetId) async {
    Follow followData = following.where((p0) => p0.toUserId == targetId).first;
    following.remove(followData);
    await FollowsRepo.deleteFollowbyId(followData.followId);
    return followData;
  }
}
