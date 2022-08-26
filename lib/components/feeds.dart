import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/posts_repo.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/feeds_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/expandable_text.dart';
import 'package:flutter_instagram_clone/components/scale_animated.dart';
import 'package:flutter_instagram_clone/models/comment.dart';
import 'package:flutter_instagram_clone/models/like.dart';
import 'package:flutter_instagram_clone/models/post.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Feeds extends StatefulWidget {
  const Feeds({Key? key, required this.postsList}) : super(key: key);

  @override
  State<Feeds> createState() => _FeedsState();
  final List<Post> postsList;
}

class _FeedsState extends State<Feeds> {
  late Post currentView;
  @override
  void initState() {
    currentView = widget.postsList[0];
    super.initState();
  }

  void onVisibleHandler(VisibilityInfo info) {
    if ((info.visibleFraction * 100) > 50) {
      // setState(() {
      //   currentView = widget.postsList[int.parse(info.key.toString())];
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 650,
      child: ListView.builder(
          itemCount: widget.postsList.length,
          itemBuilder: (context, index) => VisibilityDetector(
              key: Key(index.toString()),
              onVisibilityChanged: onVisibleHandler,
              child: PostItem(postData: widget.postsList[index]))),
    );
  }
}

class PostItem extends StatelessWidget {
  const PostItem({Key? key, required this.postData}) : super(key: key);
  final Post postData;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [PostHeader(postData: postData), PostBody(postData: postData)],
      );
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

class PostBody extends StatefulWidget {
  const PostBody({Key? key, required this.postData}) : super(key: key);

  final Post postData;
  @override
  State<PostBody> createState() => _PostBodyState();
}

class _PostBodyState extends State<PostBody> {
  int activeIndex = 0;
  late bool isAnimating = false;
  Like? like;
  final CarouselController carouselController = CarouselController();
  final userController = Get.find<AppUserController>();
  void showComments() {
    Navigator.pushNamed(context, MainStackRoutes.comments, arguments: widget.postData);
  }

  void likePost() async {
    if (!isAnimating) {
      if (like == null) {
        widget.postData.likesCount++;
        Like likeData = Like(
          '',
          TargetType.post,
          widget.postData.postId,
          widget.postData.appUserId,
          widget.postData.appUser,
        );
        likeData = await PostsRepo.addLike(likeData);
        setState(() {
          isAnimating = !isAnimating;
          like = likeData;
        });
      } else {
        setState(() {
          isAnimating = !isAnimating;
        });
      }
    }
  }

  void disLikePost() async {
    // deleteLike
    await PostsRepo.deleteLike(like!);
    setState(() {
      like = null;
    });
    widget.postData.likesCount--;
  }

  Future<void> getLike() =>
      PostsRepo.findLikeByTargetIdAndUserId(widget.postData.postId, userController.appUser.value.appUserId)
          .then((value) => setState(() => like = value));

  @override
  void initState() {
    // TODO: implement initState
    getLike();
    super.initState();
  }

  DateTime postCreatedDate() => DateTime.fromMillisecondsSinceEpoch(widget.postData.createdAt.millisecondsSinceEpoch);
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
              widget.postData.postType == PostType.post
                  ? widget.postData.fileUrls.length > 1
                      ? CarouselSlider(
                          items: widget.postData.fileUrls
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
                            onPageChanged: (index, reason) => setState(() => activeIndex = index),
                          ))
                      : GestureDetector(
                          onTap: () {},
                          onDoubleTap: likePost,
                          child: Image.network(
                            widget.postData.fileUrls[0],
                            height: 450,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        )
                  : Text("show vedeos"),
              Opacity(
                opacity: isAnimating ? 1 : 0,
                child: ScaleAnimatedComponent(
                    isAnimatingState: isAnimating,
                    endAnimationCallback: () => setState(() => isAnimating = false),
                    child: const Icon(
                      Icons.favorite,
                      size: 100,
                      color: Colors.white,
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
                        IconButton(
                          onPressed: like != null ? disLikePost : likePost,
                          icon: like == null
                              ? const Icon(Icons.favorite_border_outlined)
                              : const Icon(Icons.favorite, color: Colors.red),
                        ),
                        IconButton(onPressed: showComments, icon: const Icon(CupertinoIcons.chat_bubble)),
                        IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.paperplane)),
                      ],
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.bookmark))
                  ],
                ),
                // DOTS INDICATOR
                if (widget.postData.fileUrls.length > 1)
                  Positioned.fill(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: widget.postData.fileUrls
                        .asMap()
                        .entries
                        .map((entry) => Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2.5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black54
                                          : Colors.grey.shade900)
                                      .withOpacity(activeIndex == entry.key ? 0.9 : 0.4)),
                            ))
                        .toList(),
                  )),
              ],
            ),
          ),
          // CAPTION DETAILS
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              child: Text('${widget.postData.likesCount} likes')),
          ExpandableText(
            text: widget.postData.caption!,
            displayLength: 30,
            leadingText: widget.postData.appUser!.username,
          ),
          if (widget.postData.commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              child: GestureDetector(
                onTap: showComments,
                child: widget.postData.commentCount == 1
                    ? const Text("View 1 comment")
                    : Text("View all ${widget.postData.commentCount} comments"),
              ),
            ),

          Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5), child: Text(formattedDate())),
        ],
      );
}
