import 'package:flutter/widgets.dart';

class ScaleAnimatedComponent extends StatefulWidget {
  const ScaleAnimatedComponent({
    Key? key,
    required this.child,
    required this.isAnimatingState,
    required this.endAnimationCallback,
  }) : super(key: key);
  final Widget child;
  final bool isAnimatingState;
  final VoidCallback endAnimationCallback;
  @override
  State<ScaleAnimatedComponent> createState() => _ScaleAnimatedComponentState();
}

class _ScaleAnimatedComponentState extends State<ScaleAnimatedComponent> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animatedScale;
  @override
  void initState() {
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    animatedScale = Tween<double>(begin: 1, end: 1.2).animate(animationController);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ScaleAnimatedComponent oldWidget) {
    // TODO: implement didUpdateWidget
    if (widget.isAnimatingState != oldWidget.isAnimatingState) {
      animationController
          .forward()
          .then((value) => animationController.reverse())
          .then((value) => widget.endAnimationCallback());
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: animatedScale,
        child: widget.child,
      );
}
