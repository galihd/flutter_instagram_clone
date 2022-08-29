import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/posts_repo.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/feeds_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/expandable_text.dart';
import 'package:flutter_instagram_clone/components/scale_animated.dart';
import 'package:flutter_instagram_clone/components/video_player_widget.dart';
import 'package:flutter_instagram_clone/models/comment.dart';
import 'package:flutter_instagram_clone/models/like.dart';
import 'package:flutter_instagram_clone/models/post.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Feeds extends GetView<FeedsController> {
  Feeds({Key? key, required this.postsList}) : super(key: key);
  final List<Post> postsList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: postsList
            .map((post) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostHeader(postData: post),
                    PostBody(postData: post),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class PostHeader extends StatelessWidget {
  PostHeader({Key? key, required this.postData}) : super(key: key);
  final Post postData;
  final userController = Get.find<AppUserController>();
  final feedsController = Get.find<FeedsController>();
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (() => Navigator.pushNamed(context, MainStackRoutes.profile, arguments: postData.appUserId)),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(postData.appUser!.avatarUrl),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(postData.appUser!.username),
                )
              ],
            ),
          ),
          IconButton(onPressed: () => showBottomDrawer(context), icon: const Icon(Icons.more_horiz))
        ],
      );

  showBottomDrawer(BuildContext context) {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                color: Theme.of(context).cardColor),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Container(
                  width: 75,
                  height: 7.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  circularDrawerButton(context, Icons.share, "Share", () => null),
                  circularDrawerButton(context, Icons.link, "Link", () => null),
                  circularDrawerButton(context, Icons.qr_code_scanner_rounded, "QR code", () => null),
                  if (postData.appUserId != userController.appUser.value.appUserId)
                    circularDrawerButton(context, CupertinoIcons.exclamationmark_bubble, "Report", () => null),
                ],
              ),
              Row(children: [
                Expanded(
                    child: Divider(
                  color: Colors.grey.shade600,
                ))
              ]),
              if (postData.appUserId == userController.appUser.value.appUserId) ...[
                GestureDetector(
                    onTap: () {},
                    child: Container(padding: const EdgeInsets.all(10), child: const Text('Post to other apps...'))),
                GestureDetector(
                    onTap: () {},
                    child: Container(padding: const EdgeInsets.all(10), child: const Text('Pin to your profile'))),
                GestureDetector(
                    onTap: () {}, child: Container(padding: const EdgeInsets.all(10), child: const Text('Archive'))),
                GestureDetector(
                    onTap: () => feedsController.deletePost(postData),
                    child: Container(padding: const EdgeInsets.all(10), child: const Text('Delete'))),
                GestureDetector(
                    onTap: () {}, child: Container(padding: const EdgeInsets.all(10), child: const Text('Edit'))),
                GestureDetector(
                    onTap: () {},
                    child: Container(padding: const EdgeInsets.all(10), child: const Text('Turn off commenting'))),
              ] else ...[
                GestureDetector(
                    onTap: () {},
                    child: Container(padding: const EdgeInsets.all(10), child: const Text('Add to favorites'))),
                GestureDetector(
                    onTap: () {}, child: Container(padding: const EdgeInsets.all(10), child: const Text('Hide'))),
                GestureDetector(
                    onTap: () {},
                    child: Container(padding: const EdgeInsets.all(10), child: const Text('About this account'))),
                GestureDetector(
                    onTap: () {}, child: Container(padding: const EdgeInsets.all(10), child: const Text('Unfollow'))),
              ]
            ])));
  }

  Widget circularDrawerButton(BuildContext context, IconData icon, String label, Function()? onPressed) => TextButton(
        onPressed: onPressed,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 0.5),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodyMedium)
          ],
        ),
      );
}

class PostBody extends StatelessWidget {
  PostBody({Key? key, required this.postData}) : super(key: key);

  final Post postData;
  ValueNotifier<int> activeIndex = ValueNotifier(0);
  ValueNotifier<bool> isAnimating = ValueNotifier(false);
  ValueNotifier<Like?> like = ValueNotifier(null);
  late ValueNotifier<int> likesCount = ValueNotifier(postData.likesCount);
  final CarouselController carouselController = CarouselController();
  final userController = Get.find<AppUserController>();
  final feedsController = Get.find<FeedsController>();

  void showComments(BuildContext context) {
    Navigator.pushNamed(context, MainStackRoutes.comments, arguments: postData);
  }

  void likePost() async {
    if (!isAnimating.value) {
      if (like.value == null) {
        postData.likesCount++;
        Like likeData = Like(
          '',
          TargetType.post,
          postData.postId,
          postData.appUserId,
          postData.appUser,
        );

        like.value = await PostsRepo.addLike(likeData);
        isAnimating.value = !isAnimating.value;
        likesCount.value++;
      } else {
        isAnimating.value = !isAnimating.value;
      }
    }
  }

  void disLikePost() async {
    // deleteLike
    await PostsRepo.deleteLike(like.value!);
    like.value = null;
    likesCount.value--;
  }

  Future<void> getLike() => PostsRepo.findLikeByTargetIdAndUserId(postData.postId, userController.appUser.value.appUserId)
      .then((value) => like.value = value);

  DateTime postCreatedDate() => DateTime.fromMillisecondsSinceEpoch(postData.createdAt.millisecondsSinceEpoch);
  String formattedDate() => (DateTime.now().millisecondsSinceEpoch - postCreatedDate().millisecondsSinceEpoch) >
          (1000 * 60 * 60 * 24)
      ? (DateTime.now().millisecondsSinceEpoch - postCreatedDate().millisecondsSinceEpoch) < (1000 * 60 * 60 * 24 * 7)
          ? "${((DateTime.now().millisecondsSinceEpoch - postCreatedDate().millisecondsSinceEpoch) / (1000 * 60 * 60 * 24)).ceil()} days ago"
          : DateFormat("dd MMMM yyyy").format(postCreatedDate())
      : "${((DateTime.now().millisecondsSinceEpoch - postCreatedDate().millisecondsSinceEpoch) / (1000 * 60 * 60)).ceil()} hours ago";

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // POST IMAGE/THUMBNAIL
          Stack(
            alignment: Alignment.center,
            children: [
              (postData.fileUrls.length > 1 && postData.postType == PostType.post)
                  ? CarouselSlider(
                      items: postData.fileUrls
                          .map((e) => GestureDetector(
                              onTap: () {},
                              onDoubleTap: likePost,
                              child: Image.network(
                                e,
                                fit: BoxFit.cover,
                              )))
                          .toList(),
                      carouselController: carouselController,
                      options: CarouselOptions(
                        viewportFraction: 1,
                        height: 450,
                        onPageChanged: (index, reason) => activeIndex.value = index,
                      ))
                  : GestureDetector(
                      onTap: () {},
                      onDoubleTap: likePost,
                      child: postData.postType == PostType.post
                          ? Image.network(
                              postData.fileUrls[0],
                              height: 450,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            )
                          : SizedBox(
                              height: 450,
                              child: VideoPlayerWidget(
                                key: ValueKey(postData.postId),
                                videoUrl: postData.fileUrls[0],
                                autoPlay: true,
                              )),
                    ),
              ValueListenableBuilder(
                  valueListenable: isAnimating,
                  builder: (context, bool value, child) => Opacity(
                        opacity: value ? 1 : 0,
                        child: ScaleAnimatedComponent(
                            isAnimatingState: isAnimating.value,
                            endAnimationCallback: () => isAnimating.value = false,
                            child: const Icon(
                              Icons.favorite,
                              size: 100,
                              color: Colors.white,
                            )),
                      )),
              if (postData.postType == PostType.reels)
                Obx(
                  () => Positioned(
                      bottom: 15,
                      right: 15,
                      child: IconButton(
                        onPressed: feedsController.isMuted.toggle,
                        icon: Icon(feedsController.isMuted.isTrue ? Icons.volume_up : Icons.volume_off),
                      )),
                )
            ],
          ),
          // POST DETAILS
          SizedBox(
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              // BUTTON CONTAINER
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ValueListenableBuilder(
                            valueListenable: like,
                            builder: (context, value, child) => IconButton(
                                  onPressed: like.value != null ? disLikePost : likePost,
                                  icon: like.value == null
                                      ? const Icon(Icons.favorite_border_outlined)
                                      : const Icon(Icons.favorite, color: Colors.red),
                                )),
                        IconButton(onPressed: () => showComments, icon: const Icon(CupertinoIcons.chat_bubble)),
                        IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.paperplane)),
                      ],
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.bookmark))
                  ],
                ),
                // DOTS INDICATOR
                if (postData.fileUrls.length > 1)
                  Positioned.fill(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: postData.fileUrls
                        .asMap()
                        .entries
                        .map(
                          (entry) => ValueListenableBuilder(
                              valueListenable: activeIndex,
                              builder: (context, value, child) => Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2.5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (Theme.of(context).brightness == Brightness.dark
                                                ? Colors.black54
                                                : Colors.grey.shade900)
                                            .withOpacity(activeIndex.value == entry.key ? 0.9 : 0.4)),
                                  )),
                        )
                        .toList(),
                  )),
              ],
            ),
          ),
          // CAPTION DETAILS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
            child: ValueListenableBuilder(
                valueListenable: likesCount, builder: (context, int value, child) => Text('$value likes')),
          ),
          ExpandableText(
            text: postData.caption!,
            displayLength: 30,
            leadingText: postData.appUser!.username,
          ),
          if (postData.commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              child: GestureDetector(
                onTap: () => showComments,
                child: postData.commentCount == 1
                    ? const Text("View 1 comment")
                    : Text("View all ${postData.commentCount} comments"),
              ),
            ),

          Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5), child: Text(formattedDate())),
        ],
      );
}
