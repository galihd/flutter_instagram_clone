import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/gallery_picker_controller.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPicker extends GetView<GalleryPickerController> {
  const GalleryPicker({Key? key, required this.showUtility}) : super(key: key);
  final bool showUtility;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomScrollView(
        slivers: <Widget>[
          Obx(() => (controller.previewFile.value != null)
              ? SliverToBoxAdapter(
                  child: Image(
                  image: AssetEntityImageProvider(controller.previewFile.value!),
                  fit: BoxFit.fill,
                  height: 350,
                ))
              : const SliverToBoxAdapter()),
          if (showUtility)
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: CircleAvatar(
                      backgroundColor: controller.allowMutiple.isTrue
                          ? Theme.of(context).toggleableActiveColor
                          : Theme.of(context).toggleButtonsTheme.disabledColor,
                      child: IconButton(
                        icon: const Icon(Icons.photo_library),
                        onPressed: controller.allowMultipleHandler,
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).toggleableActiveColor,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: (() {}),
                      ),
                    ))
              ],
            ),
          SliverGrid.count(
              crossAxisCount: 4,
              children: controller.assets
                  .map((asset) => GestureDetector(
                      key: ValueKey(asset.id),
                      onTap: () => controller.selectFileHandler(asset),
                      child: controller.selectedFiles.contains(asset)
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.color),
                              child: AssetEntityImage(
                                asset,
                                fit: BoxFit.cover,
                              ))
                          : AssetEntityImage(
                              asset,
                              fit: BoxFit.cover,
                            )))
                  .toList())
        ],
      ),
    );
  }
}
