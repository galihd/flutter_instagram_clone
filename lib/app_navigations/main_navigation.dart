import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/app_navigations/stacknavigator_home.dart';
import 'package:flutter_instagram_clone/app_navigations/stacknavigator_profile.dart';
import 'package:flutter_instagram_clone/components/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final userController = Get.find<AppUserController>();
  MainNavRoutes currentBottomTab = MainNavRoutes.home;
  late bool shouldPop = false;

  final navigatorKeys = {
    MainNavRoutes.home: GlobalKey<NavigatorState>(),
    MainNavRoutes.explore: GlobalKey<NavigatorState>(),
    MainNavRoutes.reels: GlobalKey<NavigatorState>(),
    MainNavRoutes.shop: GlobalKey<NavigatorState>(),
    MainNavRoutes.profile: GlobalKey<NavigatorState>()
  };

  void selectTabHandler(int index) {
    if (MainNavRoutes.values[index] == currentBottomTab) {
      navigatorKeys[currentBottomTab]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        currentBottomTab = MainNavRoutes.values[index];
      });
    }
  }

  Future<bool> backButtonHandler() async {
    final isOnTabFirstRoute = !await navigatorKeys[currentBottomTab]!.currentState!.maybePop();
    void showSnackbar() {
      MySnackbar.show(context, "Press once again to exit app", true);
    }

    if (isOnTabFirstRoute) {
      if (currentBottomTab != MainNavRoutes.home) {
        selectTabHandler(0);

        return false;
      } else if (shouldPop) {
        return true;
      } else {
        showSnackbar();
        //shouldpop=true;
        return false;
      }
    }

    return isOnTabFirstRoute;
  }

  @override
  void initState() {
    // TODO: implement initState
    initializeDateFormatting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: backButtonHandler,
        child: SafeArea(
            child: Obx(() => Scaffold(
                  body: IndexedStack(
                    index: currentBottomTab.index,
                    children: [
                      HomeStack(navigatorKey: navigatorKeys[MainNavRoutes.home]!),
                      ProfileStack(navigatorKey: navigatorKeys[MainNavRoutes.explore]!),
                      // ProfileStack(navigatorKey: _navigatorKeys[MainNavRoutes.reels]!),
                      // ProfileStack(navigatorKey: _navigatorKeys[MainNavRoutes.shop]!),
                      // ProfileStack(navigatorKey: _navigatorKeys[MainNavRoutes.profile]!),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    selectedIconTheme: Theme.of(context).iconTheme,
                    unselectedIconTheme: Theme.of(context).iconTheme,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    items: <BottomNavigationBarItem>[
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Explore'),
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.movie_outlined), activeIcon: Icon(Icons.movie), label: 'Reels'),
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Shop'),
                      BottomNavigationBarItem(
                          icon: (userController.appUser.value.avatarUrl == '')
                              ? const Icon(Icons.person_rounded)
                              : CircleAvatar(
                                  radius: 15,
                                  backgroundImage: NetworkImage(userController.appUser.value.avatarUrl),
                                ),
                          label: 'Profile')
                    ],
                    currentIndex: currentBottomTab.index,
                    onTap: selectTabHandler,
                  ),
                ))));
  }
}
