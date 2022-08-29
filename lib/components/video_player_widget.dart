import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/Getx/feeds_controller.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({Key? key, required this.videoUrl, required this.autoPlay}) : super(key: key);
  final String videoUrl;
  final bool autoPlay;
  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final feedsController = Get.find<FeedsController>();
  late VideoPlayerController videoPlayerController = VideoPlayerController.network('');

  void onVisibleHandler(VisibilityInfo info) {
    if ((info.visibleFraction * 100) > 50 && widget.autoPlay) {
      videoPlayerController.play();
    } else {
      videoPlayerController.pause();
    }
  }

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.network(widget.videoUrl);

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("dispose");
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: videoPlayerController.initialize(),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
            ? Obx(() {
                if (feedsController.isMuted.isTrue) {
                  videoPlayerController.setVolume(0.0);
                } else {
                  videoPlayerController.setVolume(1.0);
                }
                return VisibilityDetector(
                    key: widget.key!, onVisibilityChanged: onVisibleHandler, child: VideoPlayer(videoPlayerController));
              })
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
