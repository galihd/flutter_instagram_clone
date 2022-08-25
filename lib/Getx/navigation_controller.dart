import 'package:flutter/cupertino.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/custom_snackbar.dart';
import 'package:get/get.dart';

final navigatorKeys = {
  MainNavRoutes.home: GlobalKey<NavigatorState>(),
  MainNavRoutes.explore: GlobalKey<NavigatorState>(),
  MainNavRoutes.reels: GlobalKey<NavigatorState>(),
  MainNavRoutes.shop: GlobalKey<NavigatorState>(),
  MainNavRoutes.profile: GlobalKey<NavigatorState>()
};

class NavigationController extends GetxController {
  final currentBottomTab = MainNavRoutes.home.obs;
  final shouldPop = false.obs;

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

  void redirectToHome() {
    if (currentBottomTab.value != MainNavRoutes.home) {
      selectTabHandler(0);
    }
    navigatorKeys[currentBottomTab.value]!.currentState!.popUntil((route) => route.isFirst);
  }

  void selectTabHandler(int index) {
    if (MainNavRoutes.values[index] == currentBottomTab.value) {
      navigatorKeys[currentBottomTab]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      currentBottomTab.value = MainNavRoutes.values[index];
    }
  }

  Future<bool> backButtonHandler(BuildContext context) async {
    final isOnTabFirstRoute = !await navigatorKeys[currentBottomTab]!.currentState!.maybePop();
    void showSnackbar() {
      MySnackbar.show(context, "Press once again to exit app", true);
    }

    if (isOnTabFirstRoute) {
      if (currentBottomTab.value != MainNavRoutes.home) {
        selectTabHandler(0);

        return false;
      } else if (shouldPop.isTrue) {
        return true;
      } else {
        showSnackbar();
        //shouldpop=true;
        return false;
      }
    } else {
      print("not on first route");
    }

    return isOnTabFirstRoute;
  }
}
