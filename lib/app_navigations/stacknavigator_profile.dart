import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/navigation_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/screens/PostCreator/createpost_details.dart';
import 'package:flutter_instagram_clone/screens/PostCreator/createpost_index.dart';
import 'package:flutter_instagram_clone/screens/Profile/profile_edit_screen.dart';
import 'package:flutter_instagram_clone/screens/Profile/profile_post_screen.dart';
import 'package:flutter_instagram_clone/screens/Profile/profile_relation_screen.dart';
import 'package:flutter_instagram_clone/screens/Profile/profile_screen.dart';
import 'package:get/get.dart';

class ProfileStack extends GetView<NavigationController> {
  ProfileStack({Key? key, required this.navigatorKey}) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey;
  final userController = Get.find<AppUserController>();
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) => PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          controller.profileStackRoute.value = settings.name!;
          switch (settings.name) {
            case MainStackRoutes.profile:
              return ProfileScreen(
                appUserId: (settings.arguments as String?) ?? userController.appUser.value.appUserId,
                showActions: true,
              );

            case MainStackRoutes.profileEdit:
              return const ProfileEditScreen();

            case MainStackRoutes.profileEditGallery:
              return const ProfileEditGalleryScreen();

            case MainStackRoutes.profilePost:
              var args = settings.arguments as PostFeedsArguments;
              return ProfilePostScreen(userPosts: args.userPosts);

            case MainStackRoutes.profileRelation:
              var args = settings.arguments as ProfileRelationArguments;
              return ProfileRelationScreen(args: args);

            case MainStackRoutes.createPost:
              return const CreatePostIndex();

            case MainStackRoutes.createPostDetails:
              return CreatePostDetails();
            default:
              return ProfileScreen(
                appUserId: userController.appUser.value.appUserId,
                showActions: true,
              );
          }
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Animation<Offset> slideToLeftEnterAnimation = Tween<Offset>(begin: rightEdge, end: onScreen).animate(animation);
          Animation<Offset> slideUpEnterAnimation = Tween<Offset>(begin: belowEdge, end: onScreen).animate(animation);
          if (settings.name!.contains(MainStackRoutes.profileEdit) || settings.name!.contains(MainStackRoutes.createPost)) {
            if (settings.name == MainStackRoutes.createPostDetails) return child;
            return SlideTransition(
              position: slideUpEnterAnimation,
              child: child,
            );
          } else {
            return SlideTransition(
              position: slideToLeftEnterAnimation,
              child: child,
            );
          }
        },
      ),
    );
  }
}
