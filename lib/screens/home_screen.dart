import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/feeds_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/feeds.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final feedsController = Get.find<FeedsController>();
  final userController = Get.find<AppUserController>();

  void createNewPost(BuildContext context) async {
    void navigateStack() => Navigator.pushNamed(context, MainStackRoutes.createPost);

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      // Granted.
      navigateStack();
    } else {
      // Limited(iOS) or Rejected, use `==` for more precise judgements.
      // You can call `PhotoManager.openSetting()` to open settings for further steps.
    }

    /*
    PermissionStatus result;
    // In Android we need to request the storage permission,
    // while in iOS is the photos permission
    if (Platform.isAndroid) {
      result = await Permission.storage.request();
    } else {
      result = await Permission.photos.request();
    }

    if (result.isGranted) {
      navigateStack();
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: IconButton(
          iconSize: 100,
          icon: Image.asset(
            'assets/images/Instagram_header.png',
            fit: BoxFit.contain,
          ),
          onPressed: (() {}),
        ),
        actions: <Widget>[
          IconButton(onPressed: () => createNewPost(context), icon: const Icon(Icons.add_box_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_outlined)),
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, MainStackRoutes.directMessage);
              },
              icon: const Icon(CupertinoIcons.paperplane)),
        ],
      ),
      body: Obx((() => Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: feedsController.feedItems.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (feedsController.createPostRequest.value != null)
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Image.file(File(feedsController.createPostRequest.value!.fileUrls[0]), height: 50, width: 50),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Finishing...'),
                        )
                      ],
                    )),
              feedsController.feedItems.isNotEmpty
                  ? Feeds(postsList: feedsController.feedItems)
                  : const Center(
                      child: CircularProgressIndicator(),
                    )
            ],
          ))),
    );
  }
}
