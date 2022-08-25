import 'package:flutter_instagram_clone/Getx/appuser_controller.dart';
import 'package:flutter_instagram_clone/Getx/feeds_controller.dart';
import 'package:flutter_instagram_clone/Getx/gallery_picker_controller.dart';
import 'package:flutter_instagram_clone/Getx/navigation_controller.dart';
import 'package:get/get.dart';

class GetXBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppUserController());
    Get.lazyPut(() => FeedsController());
    Get.lazyPut(() => GalleryPickerController());
    Get.lazyPut(() => NavigationController());
  }
}
