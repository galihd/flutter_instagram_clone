import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/navigation_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/app_navigations/stacknavigator_home.dart';
import 'package:flutter_instagram_clone/app_navigations/stacknavigator_profile.dart';
import 'package:flutter_instagram_clone/components/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

class MainNavigation extends GetView<NavigationController> {
  MainNavigation({Key? key}) : super(key: key);

  final userController = Get.find<AppUserController>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => controller.backButtonHandler(context),
        child: SafeArea(
            child: Obx(() => Scaffold(
                  body: IndexedStack(
                    index: controller.currentBottomTab.value.index,
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
                    currentIndex: controller.currentBottomTab.value.index,
                    onTap: controller.selectTabHandler,
                  ),
                ))));
  }
}
