import 'package:flutter/cupertino.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:flutter_instagram_clone/models/follow.dart';
import 'package:flutter_instagram_clone/models/post.dart';

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
  static const String profileRelation = "/profile/relation";
  static const String profileEdit = "/profile/edit";
  static const String profileEditGallery = "/profile/edit/gallery";

  static const String createPost = "/createPost";
  static const String createPostDetails = "/createPost/details";
  static const String directMessage = "/messages";
}

class PostFeedsArguments {
  final List<Post> userPosts;
  final int scrollToIndex;
  const PostFeedsArguments(this.userPosts, this.scrollToIndex);
}

class ProfileRelationArguments {
  final AppUser userData;
  final List<Follow> following;
  final List<Follow> followers;
  final int initialIndex;
  const ProfileRelationArguments(this.initialIndex, this.userData, this.followers, this.following);
}
