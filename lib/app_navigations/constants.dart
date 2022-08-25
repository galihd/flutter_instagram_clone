import 'package:flutter/cupertino.dart';

const leftEdge = Offset(-1.0, 0.0);
const rightEdge = Offset(1.0, 0.0);
const upperEdge = Offset(0.0, -1.0);
const belowEdge = Offset(0.0, 1.0);
const onScreen = Offset.zero;

enum MainNavRoutes {
  home("HOME"),
  explore("EXPLORE"),
  reels("REELS"),
  shop("SHOP"),
  profile("PROFILE");

  const MainNavRoutes(this.value);
  final String value;
}

enum SlideDirection { right, left, up, down, persist }

class MainStackRoutes {
  static const String home = "/";
  static const String comments = "/comments";
  static const String likes = "/likes";

  static const String profile = "/profile";
  static const String profilePost = "/profile/post";
  static const String profileEdit = "/profile/edit";
  static const String profileEditGallery = "/profile/edit/gallery";

  static const String createPost = "/createPost";
  static const String createPostDetails = "/createPost/details";
  static const String directMessage = "/messages";
}
