import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/expandable_text.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:flutter_instagram_clone/models/post.dart';
import 'package:http/http.dart';
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
        children: [PostHeader(postOwner: postData.appUser!), PostBody(postData: postData)],
      );
}

class PostHeader extends StatelessWidget {
  const PostHeader({Key? key, required this.postOwner}) : super(key: key);
  final AppUser postOwner;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (() => Navigator.pushNamed(context, MainStackRoutes.profile, arguments: postOwner.appUserId)),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(postOwner.avatarUrl),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(postOwner.username),
                )
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                print("open drawer");
              },
              icon: const Icon(Icons.more_horiz))
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
                children: [],
              )
            ])));
  }
}

class PostBody extends StatefulWidget {
  const PostBody({Key? key, required this.postData}) : super(key: key);

  @override
  State<PostBody> createState() => _PostBodyState();
  final Post postData;
}

class _PostBodyState extends State<PostBody> {
  int current = 0;
  final CarouselController carouselController = CarouselController();
  @override
  Widget build(BuildContext context) => Column(
        children: [
          widget.postData.postType == PostType.post
              ? widget.postData.fileUrls.length > 1
                  ? CarouselSlider(
                      items: widget.postData.fileUrls
                          .map((e) => GestureDetector(
                              onTap: () {},
                              child: Image.network(
                                e,
                                fit: BoxFit.cover,
                              )))
                          .toList(),
                      carouselController: carouselController,
                      options: CarouselOptions(
                        viewportFraction: 1,
                        height: 450,
                        onPageChanged: (index, reason) => setState(() => current = index),
                      ))
                  : GestureDetector(
                      onTap: () {},
                      child: Image.network(
                        widget.postData.fileUrls[0],
                        height: 450,
                        fit: BoxFit.cover,
                      ),
                    )
              : Text("show vedeos"),
          PostDetails(postData: widget.postData, activeIndicatorIndex: current, carouselController: carouselController)
        ],
      );
}

class PostDetails extends StatelessWidget {
  const PostDetails({Key? key, required this.postData, required this.activeIndicatorIndex, required this.carouselController})
      : super(key: key);
  final Post postData;
  final int activeIndicatorIndex;
  final CarouselController carouselController;

  void showComments(BuildContext context) {
    Navigator.pushNamed(context, MainStackRoutes.comments, arguments: postData);
  }

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
                        IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_outlined)),
                        IconButton(onPressed: () => showComments(context), icon: const Icon(CupertinoIcons.chat_bubble)),
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
                        .map((entry) => Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2.5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black54
                                          : Colors.grey.shade900)
                                      .withOpacity(activeIndicatorIndex == entry.key ? 0.9 : 0.4)),
                            ))
                        .toList(),
                  )),
              ],
            ),
          ),
          // CAPTION DETAILS
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              child: Text('${postData.likesCount} likes')),
          ExpandableText(
            text: postData.caption!,
            displayLength: 30,
            leadingText: postData.appUser!.username,
          ),
          if (postData.commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              child: GestureDetector(
                onTap: () => showComments(context),
                child: postData.commentCount == 1
                    ? const Text("View 1 comment")
                    : Text("View ${postData.commentCount} comments"),
              ),
            ),

          Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5), child: Text(formattedDate())),
        ],
      );
}
