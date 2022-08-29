import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class GalleryPickerController extends GetxController {
  final assets = <AssetEntity>[].obs;
  final previewFile = Rxn<AssetEntity>();
  final allowMutiple = false.obs;
  final selectedFiles = <AssetEntity>[].obs;
  late VideoPlayerController videoPlayerController = VideoPlayerController.network("");

  @override
  void onInit() {
    // TODO: implement onInit
    loadAllMediaFiles();
    ever(previewFile, previewFileCallback);

    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    videoPlayerController.dispose();
    super.dispose();
  }

  void previewFileCallback(AssetEntity? callbackValue) {
    if (callbackValue != null) {
      if (videoPlayerController.value.isInitialized) {
        videoPlayerController.dispose();
      }
      if (callbackValue.type == AssetType.video) {
        callbackValue.file.then((value) {
          videoPlayerController = VideoPlayerController.file(value!);
          videoPlayerController.setLooping(true);
          videoPlayerController.play();
        });
      }
    }
  }

  void loadAllMediaFiles() async {
    final AssetPathEntity rootAlbums = (await PhotoManager.getAssetPathList(hasAll: true, onlyAll: true))[0];
    List<AssetEntity> allMediaFiles =
        await rootAlbums.assetCountAsync.then((value) => rootAlbums.getAssetListRange(start: 0, end: value));
    assets.value = allMediaFiles;
    selectFileHandler(allMediaFiles[0]);
  }

  void allowMultipleHandler() {
    allowMutiple.toggle();
  }

  void selectFileHandler(AssetEntity asset) {
    if (asset.mimeType!.contains("video")) {
      allowMutiple.value = false;
    }
    if (asset.mimeType!.contains("image") && allowMutiple.isTrue && selectedFiles.length < 5) {
      if (selectedFiles.contains(asset)) {
        selectedFiles.remove(asset);
      } else {
        selectedFiles.add(asset);
      }
    } else {
      selectedFiles.value = [asset];
    }
    previewFile.value = asset;
  }
}
