import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/gallery_picker_controller.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class GalleryPicker extends GetView<GalleryPickerController> {
  const GalleryPicker({Key? key, required this.showUtility}) : super(key: key);
  final bool showUtility;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return CustomScrollView(
          slivers: <Widget>[
            if (controller.previewFile.value != null)
              controller.previewFile.value!.type == AssetType.image
                  ? SliverToBoxAdapter(
                      child: Image(
                      image: AssetEntityImageProvider(controller.previewFile.value!),
                      fit: BoxFit.fill,
                      height: 350,
                    ))
                  : SliverToBoxAdapter(
                      child: FutureBuilder(
                      future: controller.previewFile.value!.file,
                      builder: (BuildContext context, AsyncSnapshot<File?> snapshot) =>
                          snapshot.connectionState == ConnectionState.done
                              ? FutureBuilder(
                                  future: controller.videoPlayerController.initialize(),
                                  builder: (context, snapshot) => SizedBox(
                                    height: 350,
                                    child: snapshot.connectionState == ConnectionState.done
                                        ? GestureDetector(
                                            onTap: () => controller.videoPlayerController.value.isPlaying
                                                ? controller.videoPlayerController.pause()
                                                : controller.videoPlayerController.play(),
                                            child: VideoPlayer(controller.videoPlayerController),
                                          )
                                        : const Center(child: CircularProgressIndicator()),
                                  ),
                                )
                              : const Center(
                                  child: Text('Media Error'),
                                ),
                    )),
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
                        child: ColorFiltered(
                            colorFilter: controller.selectedFiles.contains(asset)
                                ? const ColorFilter.mode(Colors.red, BlendMode.color)
                                : const ColorFilter.mode(Colors.transparent, BlendMode.color),
                            child: asset.type == AssetType.image
                                ? AssetEntityImage(
                                    asset,
                                    fit: BoxFit.cover,
                                  )
                                : Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      AssetEntityImage(
                                        asset,
                                        fit: BoxFit.cover,
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
                                  ))))
                    .toList())
          ],
        );
      },
    );
  }
}
