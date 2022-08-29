import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/appuser_repo.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/follows_repo.dart';
import 'package:flutter_instagram_clone/Firebase/FireStore/posts_repo.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/feeds_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/video_player_widget.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:flutter_instagram_clone/models/follow.dart';
import 'package:flutter_instagram_clone/models/post.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.appUserId, required this.showActions}) : super(key: key);
  final String appUserId;
  final bool showActions;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userController = Get.find<AppUserController>();
  final feedsController = Get.find<FeedsController>();
  AppUser userData = AppUser.empty();
  late List<Post> userPosts;
  late List<Follow> followers;
  late List<Follow> following;

  bool isRefreshing = true;
  late bool isMyProfile = userController.appUser.value.appUserId == widget.appUserId;
  late bool isFollowed = userController.following.map((e) => e.toUserId).toList().contains(widget.appUserId);

  void getUserData() async {
    var userResponse = isMyProfile ? userController.appUser.value : await AppUsersRepo.findAppUserById(widget.appUserId);
    var postResponse = isMyProfile
        ? feedsController.userPosts
        : await PostsRepo.findAllPostsByAttribute("appUserId", userResponse.appUserId);
    var followingResponse =
        isMyProfile ? userController.following : await FollowsRepo.findAllFollowingByUserId(widget.appUserId);
    var followersReponse =
        isMyProfile ? userController.followers : await FollowsRepo.findAllFollowersByUserId(widget.appUserId);

    setState(() {
      userData = userResponse;
      userPosts = postResponse;
      following = followingResponse;
      followers = followersReponse;
      isRefreshing = false;
    });
  }

  void followUser() => userController.followUser(userData.appUserId).then((value) => setState(() => followers.add(value)));
  void unFollowUser() =>
      userController.unFollowUser(userData.appUserId).then((value) => setState(() => followers.remove(value)));
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: !widget.showActions,
            title: widget.showActions
                ? Text.rich(TextSpan(
                    text: '${userData.username} ',
                    recognizer: TapGestureRecognizer()..onTap = showSwitchAccountDrawer,
                    children: [
                        WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            style: Theme.of(context).appBarTheme.titleTextStyle,
                            child: Icon(CupertinoIcons.chevron_down, size: Theme.of(context).textTheme.bodyMedium!.fontSize))
                      ]))
                : Text(userData.username),
            actions: isMyProfile
                ? [
                    IconButton(
                        onPressed: () => Navigator.pushNamed(context, MainStackRoutes.createPost),
                        icon: const Icon(Icons.add_box_outlined)),
                    if (widget.showActions) IconButton(onPressed: showBottomDrawer, icon: const Icon(Icons.menu))
                  ]
                : null),
        body: !isRefreshing
            ? DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(child: Obx(() {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(
                                      isMyProfile ? userController.appUser.value.avatarUrl : userData.avatarUrl),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                          onPressed: () {},
                                          child: Column(
                                            children: [
                                              Text(
                                                isMyProfile
                                                    ? feedsController.userPosts.length.toString()
                                                    : userPosts.length.toString(),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              Text(
                                                "Posts",
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              )
                                            ],
                                          )),
                                      TextButton(
                                          onPressed: () => Navigator.pushNamed(
                                                context,
                                                MainStackRoutes.profileRelation,
                                                arguments: ProfileRelationArguments(
                                                  0,
                                                  userData,
                                                  followers,
                                                  following,
                                                ),
                                              ),
                                          child: Column(
                                            children: [
                                              Text(
                                                isMyProfile
                                                    ? userController.followers.length.toString()
                                                    : followers.length.toString(),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              Text(
                                                "Followers",
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              )
                                            ],
                                          )),
                                      TextButton(
                                          onPressed: () => Navigator.pushNamed(
                                                context,
                                                MainStackRoutes.profileRelation,
                                                arguments: ProfileRelationArguments(
                                                  1,
                                                  userData,
                                                  followers,
                                                  following,
                                                ),
                                              ),
                                          child: Column(
                                            children: [
                                              Text(
                                                isMyProfile
                                                    ? userController.following.length.toString()
                                                    : following.length.toString(),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              Text(
                                                "Following",
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              )
                                            ],
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          //BIO CONTAINER
                          if (!isMyProfile)
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  userData.username,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .merge(const TextStyle(fontWeight: FontWeight.w700)),
                                )),
                          if (userData.bio.isNotEmpty)
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  userData.bio,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .merge(const TextStyle(fontWeight: FontWeight.w700)),
                                  softWrap: true,
                                )),
                          //PROFILE HEADER BUTTON CONTAINER
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: isMyProfile ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceAround,
                              children: isMyProfile
                                  ? [
                                      Expanded(
                                          flex: 4,
                                          child: ElevatedButton(
                                            onPressed: (() {
                                              Navigator.pushNamed(context, MainStackRoutes.profileEdit);
                                            }),
                                            child: const Text("Edit Profile"),
                                          )),
                                      Flexible(
                                          flex: 1,
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            child: const Icon(Icons.person_add),
                                          ))
                                    ]
                                  : [
                                      Flexible(
                                          fit: FlexFit.tight,
                                          flex: 3,
                                          child: isFollowed
                                              ? ElevatedButton(
                                                  onPressed: unFollowUser,
                                                  child: const Text("Following"),
                                                )
                                              : ElevatedButton(
                                                  onPressed: followUser,
                                                  child: const Text("Follow"),
                                                )),
                                      Flexible(
                                          fit: FlexFit.tight,
                                          flex: 3,
                                          child: ElevatedButton(
                                            onPressed: (() {}),
                                            child: const Text("Message"),
                                          )),
                                      Flexible(
                                          flex: 3,
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            child: const Icon(Icons.person_add),
                                          ))
                                    ],
                            ),
                          ),
                          TabBar(tabs: [
                            Icon(
                              Icons.window,
                              color: Theme.of(context).textTheme.bodyText1!.color,
                            ),
                            Icon(
                              Icons.movie_outlined,
                              color: Theme.of(context).textTheme.bodyText1!.color,
                            ),
                            Icon(
                              Icons.person_pin_outlined,
                              color: Theme.of(context).textTheme.bodyText1!.color,
                            ),
                          ]),
                        ],
                      );
                    }))
                  ],
                  body: TabBarView(children: [
                    //POST TAB
                    GridView.count(
                        crossAxisCount: 3,
                        children: (isMyProfile ? feedsController.userPosts : userPosts)
                            .map((post) => GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      MainStackRoutes.profilePost,
                                      arguments: PostFeedsArguments(
                                          userPosts, userPosts.indexWhere((element) => element.postId == post.postId)),
                                    );
                                  },
                                  child: post.postType == PostType.post
                                      ? Image.network(post.fileUrls[0])
                                      : Stack(
                                          children: [
                                            VideoPlayerWidget(
                                              // KEY TO PREVENT AUTO PLAY
                                              key: Key(post.fileUrls[0]),
                                              videoUrl: post.fileUrls[0],
                                              autoPlay: false,
                                            ),
                                            const Positioned(
                                                top: 5,
                                                right: 5,
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  size: 30,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        ),
                                ))
                            .toList()),

                    // REELS TAB
                    GridView.count(
                        crossAxisCount: 3,
                        children: userPosts
                            .where((element) => element.postType == PostType.reels)
                            .map((post) => GestureDetector(
                                  onTap: () {},
                                  child: Stack(
                                    children: [
                                      VideoPlayerWidget(
                                        // KEY TO PREVENT AUTO PLAY
                                        key: Key(post.fileUrls[0]),
                                        videoUrl: post.fileUrls[0],
                                        autoPlay: false,
                                      ),
                                      const Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Icon(
                                            Icons.play_arrow,
                                            size: 30,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ))
                            .toList()),
                    // USER TAGGED TAB
                    Text("tagged Tab"),
                  ]),
                ),
              )
            : Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ));
  }

  showSwitchAccountDrawer() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
            color: Theme.of(context).cardColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            ...userController
                .loadExistingUserDataFromStorage()!
                .map((e) => ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(e.avatarUrl),
                    ),
                    onTap: () => identical(e.appUserId, userController.appUser.value.appUserId)
                        ? null
                        : userController
                            .switchUser(e)
                            .then((value) => Navigator.of(context, rootNavigator: true).pushReplacementNamed("/")),
                    title: Text(e.username),
                    trailing: identical(e.appUserId, userController.appUser.value.appUserId)
                        ? Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(100)),
                            child: SizedBox.fromSize(
                              size: const Size.fromRadius(5),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(100)),
                              ),
                            ),
                          )
                        : null))
                .toList(),
            ListTile(
              leading: Icon(
                CupertinoIcons.add_circled,
                size: const Size.fromRadius(25).height,
              ),
              title: const Text("Add account"),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushNamed("/login");
              },
            ),
          ],
        ),
      ),
    );
  }

  showBottomDrawer() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
            color: Theme.of(context).cardColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text("Archive"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.timer),
              title: const Text("Activity"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.qrcode_viewfinder),
              title: const Text("QR code"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.bookmark),
              title: const Text("Saved"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.square_favorites),
              title: const Text("Close friends"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.star_border_outlined),
              title: const Text("Favourites"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.message_outlined),
              title: const Text("Messages"),
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
