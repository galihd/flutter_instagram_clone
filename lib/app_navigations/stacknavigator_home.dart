import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/navigation_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/models/post.dart';
import 'package:flutter_instagram_clone/screens/PostCreator/createpost_details.dart';
import 'package:flutter_instagram_clone/screens/PostCreator/createpost_index.dart';
import 'package:flutter_instagram_clone/screens/Profile/profile_post_screen.dart';
import 'package:flutter_instagram_clone/screens/Profile/profile_relation_screen.dart';
import 'package:flutter_instagram_clone/screens/comment_screen.dart';
import 'package:flutter_instagram_clone/screens/home_screen.dart';
import 'package:flutter_instagram_clone/screens/message_screen.dart';
import 'package:flutter_instagram_clone/screens/Profile/profile_screen.dart';
import 'package:get/get.dart';

class HomeStack extends GetView<NavigationController> {
  const HomeStack({Key? key, required this.navigatorKey}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            controller.homeStackRoute.value = settings.name!;
            switch (settings.name) {
              case MainStackRoutes.home:
                return const HomeScreen();

              case MainStackRoutes.profile:
                String appUserId = settings.arguments as String;
                return ProfileScreen(
                  appUserId: appUserId,
                  showActions: false,
                );

              case MainStackRoutes.profilePost:
                var args = settings.arguments as PostFeedsArguments;
                return ProfilePostScreen(userPosts: args.userPosts);

              case MainStackRoutes.profileRelation:
                var args = settings.arguments as ProfileRelationArguments;
                return ProfileRelationScreen(args: args);

              case MainStackRoutes.comments:
                Post postData = settings.arguments as Post;
                return CommentScreen(postData: postData);

              case MainStackRoutes.createPost:
                return const CreatePostIndex();

              case MainStackRoutes.directMessage:
                return const MessageScreen();

              case MainStackRoutes.createPostDetails:
                return CreatePostDetails();

              default:
                return const HomeScreen();
            }
          },
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Animation<Offset> slideToLeftEnterAnimation = Tween<Offset>(begin: rightEdge, end: onScreen).animate(animation);
            Animation<Offset> slideToLeftExitAnimation =
                Tween<Offset>(begin: onScreen, end: leftEdge).animate(secondaryAnimation);
            Animation<Offset> slideToRightEnterAnimation = Tween<Offset>(begin: leftEdge, end: onScreen).animate(animation);
            Animation<Offset> slideToRightExitAnimation =
                Tween<Offset>(begin: onScreen, end: rightEdge).animate(secondaryAnimation);

            if (settings.name == MainStackRoutes.createPost || settings.name == MainStackRoutes.createPostDetails) {
              return SlideTransition(
                position: slideToRightExitAnimation,
                child: SlideTransition(
                  position: slideToRightEnterAnimation,
                  child: child,
                ),
              );
            }
            if (settings.name == MainStackRoutes.directMessage) {
              return SlideTransition(
                position: slideToLeftEnterAnimation,
                child: child,
              );
            }
            if (settings.name == MainStackRoutes.home) {
              return controller.homeSlideDirection.value != SlideDirection.persist
                  ? SlideTransition(
                      position: controller.homeSlideDirection.value == SlideDirection.right
                          ? slideToRightExitAnimation
                          : slideToLeftExitAnimation,
                      child: child,
                    )
                  : child;
            }
            return SlideTransition(
              position: slideToLeftEnterAnimation,
              child: child,
            );
          },
        );
      },
    );
  }
}
