import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPickerController extends GetxController {
  final assets = <AssetEntity>[].obs;
  final previewFile = Rxn<AssetEntity>();
  final allowMutiple = false.obs;
  final selectedFiles = <AssetEntity>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    loadAllMediaFiles();
    super.onInit();
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
