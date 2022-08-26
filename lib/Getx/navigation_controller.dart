import 'package:flutter/cupertino.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/custom_snackbar.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final homeStackRoute = MainStackRoutes.home.obs;
  final profileStackRoute = MainStackRoutes.profile.obs;

  final homeSlideDirection = SlideDirection.persist.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    ever(homeStackRoute, slideChangeCallBack);
    super.onInit();
  }

  slideChangeCallBack(String routes) {
    if (routes == MainStackRoutes.createPost || routes == MainStackRoutes.createPostDetails) {
      homeSlideDirection.value = SlideDirection.right;
    } else if (routes == MainStackRoutes.directMessage) {
      homeSlideDirection.value = SlideDirection.left;
    } else {
      homeSlideDirection.value = SlideDirection.persist;
    }
  }
}
