import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/feeds_controller.dart';
import 'package:flutter_instagram_clone/Getx/gallery_picker_controller.dart';
import 'package:flutter_instagram_clone/Getx/navigation_controller.dart';
import 'package:flutter_instagram_clone/models/post.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class CreatePostDetails extends GetView<GalleryPickerController> {
  CreatePostDetails({Key? key}) : super(key: key);
  final captionController = TextEditingController();
  final feedsController = Get.find<FeedsController>();
  final appUserController = Get.find<AppUserController>();
  final navigationController = Get.find<NavigationController>();

  void createPostRequest(BuildContext context) async {
    void redirectToHome() => Navigator.of(context, rootNavigator: true).pushReplacementNamed("/");
    List<String> fileUrls =
        (await Future.wait(controller.selectedFiles.map((element) => element.file).toList())).map((e) => e!.path).toList();
    Post postData = Post(
      "",
      fileUrls,
      captionController.text,
      appUserController.appUser.value.appUserId,
      appUserController.appUser.value,
      [],
      "",
      0,
      0,
      Timestamp.fromDate(DateTime.now()),
      controller.selectedFiles[0].type == AssetType.image ? PostType.post : PostType.reels,
    );

    controller.selectFileHandler(controller.assets[0]);
    feedsController.createPostRequest(postData);
    controller.videoPlayerController.dispose();
    redirectToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(automaticallyImplyLeading: true, title: const Text('New Post'), actions: [
          IconButton(
            onPressed: () => createPostRequest(context),
            icon: const Icon(Icons.check),
            color: Colors.white,
          )
        ]),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AssetEntityImage(
                        controller.selectedFiles[0],
                        width: 100,
                        height: 100,
                      ),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextField(
                                maxLines: 4,
                                textAlignVertical: TextAlignVertical.bottom,
                                controller: captionController,
                                decoration: const InputDecoration(hintText: "Write a caption...", border: InputBorder.none),
                              )))
                    ],
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {},
                      child: const Text('Tag people')),
                  TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {},
                      child: const Text('Add location')),
                  TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {},
                      child: const Text('Add music')),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("Also post to"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Facebook'),
                      Switch(
                        value: false,
                        onChanged: (value) {},
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Twitter'),
                      Switch(
                        value: false,
                        onChanged: (value) {},
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tumblr'),
                      Switch(
                        value: false,
                        onChanged: (value) {},
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [Text('Advanced settings'), Icon(Icons.chevron_right)],
                      ),
                    ),
                  ),
                ])));
  }
}
