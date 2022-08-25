import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/gallery_picker_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/gallery_picker.dart';
import 'package:get/get.dart';

class CreatePostIndex extends GetView<GalleryPickerController> {
  const CreatePostIndex({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text('New Post'),
            actions: [
              controller.selectedFiles.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, MainStackRoutes.createPostDetails);
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ))
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      color: Colors.grey.shade600,
                      onPressed: () {},
                    )
            ]),
        body: const GalleryPicker(showUtility: true),
      ),
    );
  }
}
