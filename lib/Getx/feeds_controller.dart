import 'package:flutter_instagram_clone/Firebase/FireStore/posts_repo.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/models/comment.dart';
import 'package:flutter_instagram_clone/models/follow.dart';
import 'package:flutter_instagram_clone/models/post.dart';
import 'package:get/get.dart';

class FeedsController extends GetxController {
  final userController = Get.find<AppUserController>();
  final feedItems = <Post>[].obs;
  final userPosts = <Post>[].obs;
  final isMuted = false.obs;
  final createPostRequest = Rxn<Post>();
  final createCommentRequest = Rxn<Comment>();

  @override
  void onInit() {
    ever(
      userController.isAuthenticated,
      (callback) {
        print("called callback auth");
        if (userController.isAuthenticated.isTrue) {
          print("authenticated. ${userController.following.length}");
          initializeState(null);
        } else {
          print("not authenticated");
          feedItems.value = <Post>[];
          userPosts.value = <Post>[];
        }
      },
    );
    ever(
      createPostRequest,
      createPostRequestCallback,
    );
    ever(
      createCommentRequest,
      createCommentRequestCallBack,
    );
    once(
      userController.following,
      initializeState,
    );
    super.onInit();
  }

  Future<void> initializeState(List<Follow>? callback) async {
    if (userController.isAuthenticated.isTrue) {
      // List<Post> result = await PostsRepo.findAllPostsByAttributesWhereIn(
      //     "appUserId", [...userController.following.map((e) => e.toUserId), userController.appUser.value.appUserId]);
      List<Post> result = await PostsRepo.findAllPosts();
      feedItems.value = result;
      userPosts.value = result.where((element) => element.appUserId == userController.appUser.value.appUserId).toList();
    }
  }

  // POSTS
  void createNewPostRequest(Post postData) {
    createPostRequest.value = postData;
  }

  Future<void> createPostRequestCallback(Post? requestValue) async {
    if (requestValue != null) {
      var postResponse = await PostsRepo.addPost(requestValue);
      feedItems.insert(0, postResponse);
      userPosts.insert(0, postResponse);
      createPostRequest.value = null;
    }
  }

  Future<void> deletePost(Post postData) => PostsRepo.deletePostById(postData.postId).then((_) {
        userPosts.remove(postData);
        feedItems.remove(postData);
      });

  // COMMENTS
  Future<List<Comment>> loadPostComments(Post postData) =>
      PostsRepo.findAllCommentsByAttribute("targetId", postData.postId).then((response) {
        feedItems.where((post) => identical(post.postId, postData.postId)).first.commentCount = response.length;
        return response;
      });

  void createNewCommentRequest(Comment commentData) => createCommentRequest.value = commentData;
  Future<void> createCommentRequestCallBack(Comment? requestValue) async {
    if (requestValue != null) {
      await PostsRepo.addComment(requestValue);
      if (requestValue.targetType == TargetType.post) {
        int index = feedItems.indexWhere((post) => post.postId == requestValue.targetId);
        feedItems[index] = await PostsRepo.findPostById(requestValue.targetId);
        createCommentRequest.value = null;
      }
    } else {
      print("comment added.");
    }
  }
}
