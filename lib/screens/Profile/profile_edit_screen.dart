import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/gallery_picker_controller.dart';
import 'package:flutter_instagram_clone/app_navigations/constants.dart';
import 'package:flutter_instagram_clone/components/custom_loading_indicator.dart';
import 'package:flutter_instagram_clone/components/gallery_picker.dart';
import 'package:flutter_instagram_clone/models/app_user.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final appUserController = Get.find<AppUserController>();
  AssetEntity? newAvatar;

  final userNameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();

  saveProfile() async {
    CustomIndicator.show(context, "Saving profile");
    appUserController
        .updateUser(
            AppUser(
                appUserController.appUser.value.appUserId,
                appUserController.appUser.value.email,
                appUserController.appUser.value.avatarUrl,
                userNameController.text,
                phoneController.text,
                bioController.text),
            await newAvatar!.file)
        .then((value) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  openGallery() async {
    final result = await Navigator.pushNamed(context, MainStackRoutes.profileEditGallery);

    if (!mounted) return;

    if (result != null) {
      setState(() {
        newAvatar = result as AssetEntity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: saveProfile,
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: newAvatar == null
                      ? NetworkImage(appUserController.appUser.value.avatarUrl)
                      : AssetEntityImageProvider(newAvatar!) as ImageProvider,
                ),
                TextButton(onPressed: openGallery, child: const Text("Change profile photo"))
              ]),
            ),
            editProfileInput("Name", userNameController),
            editProfileInput("Phone number", phoneController),
            editProfileInput("Bio", bioController),
            TextButton(
              onPressed: () {},
              child: const Text("Switch to Professional account"),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Create Avatar"),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Personal information settings"),
            ),
          ],
        ),
      ),
    );
  }

  Widget editProfileInput(String hint, TextEditingController textController) {
    return TextFormField(
      maxLines: null,
      controller: textController,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class ProfileEditGalleryScreen extends GetView<GalleryPickerController> {
  const ProfileEditGalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Gallery"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              controller.selectFileHandler(controller.assets[0]);
              Navigator.pop(context, controller.selectedFiles[0]);
            },
          )
        ],
      ),
      body: const GalleryPicker(showUtility: false),
    );
  }
}
