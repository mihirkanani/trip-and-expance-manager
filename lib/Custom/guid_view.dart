import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:expense_manager/utils/color_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Showcase extends StatefulWidget {
  @override
  final GlobalKey key;
  final Widget child;
  final String? title;
  final String? description;
  final ShapeBorder? shapeBorder;
  final BorderRadius? radius;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final EdgeInsets contentPadding;
  final Color overlayColor;
  final double overlayOpacity;
  final Widget container;
  final Color showcaseBackgroundColor;
  final Color textColor;
  final bool showArrow;
  final double height;
  final double width;
  final Duration animationDuration;
  final VoidCallback? onToolTipClick;
  final VoidCallback? onTargetClick;
  final bool? disposeOnTap;
  final bool disableAnimation;
  final EdgeInsets overlayPadding;

  /// Defines blur value.
  /// This will blur the background while displaying showcase.
  ///
  /// If null value is provided,
  /// [ShowCaseWidget.defaultBlurValue] will be considered.
  ///
  final double? blurValue;

  const Showcase({
    required this.key,
    required this.child,
    this.title,
    required this.description,
    this.shapeBorder,
    this.overlayColor = Colors.black45,
    this.overlayOpacity = 0.75,
    this.titleTextStyle,
    this.descTextStyle,
    this.showcaseBackgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.showArrow = true,
    this.onTargetClick,
    this.disposeOnTap,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.disableAnimation = false,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.onToolTipClick,
    this.overlayPadding = EdgeInsets.zero,
    this.blurValue,
    this.radius,
    required this.container,
  })  : height = 0.0,
        width = 0.0,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0, "overlay opacity should be >= 0.0 and <= 1.0."),
        assert(onTargetClick == null ? true : (disposeOnTap == null ? false : true), "disposeOnTap is required if you're using onTargetClick"),
        assert(disposeOnTap == null ? true : (onTargetClick == null ? false : true), "onTargetClick is required if you're using disposeOnTap");

  const Showcase.withWidget({
    required this.key,
    required this.child,
    required this.container,
    required this.height,
    required this.width,
    this.title,
    this.description,
    this.shapeBorder,
    this.overlayColor = Colors.black45,
    this.radius,
    this.overlayOpacity = 0.75,
    this.titleTextStyle,
    this.descTextStyle,
    this.showcaseBackgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.onTargetClick,
    this.disposeOnTap,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.disableAnimation = false,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
    this.overlayPadding = EdgeInsets.zero,
    this.blurValue,
  })  : showArrow = false,
        onToolTipClick = null,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0, "overlay opacity should be >= 0.0 and <= 1.0.");

  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> with TickerProviderStateMixin {
  bool _showShowCase = false;
  Animation<double>? _slideAnimation;
  late AnimationController _slideAnimationController;
  Timer? timer;
  GetPosition? position;

  @override
  void initState() {
    super.initState();

    _slideAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _slideAnimationController.reverse();
        }
        if (_slideAnimationController.isDismissed) {
          if (!widget.disableAnimation) {
            _slideAnimationController.forward();
          }
        }
      });

    _slideAnimation = CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    position ??= GetPosition(
      key: widget.key,
      padding: widget.overlayPadding,
      screenWidth: MediaQuery.of(context).size.width,
      screenHeight: MediaQuery.of(context).size.height,
    );
    showOverlay();
  }

  ///
  /// show overlay if there is any target widget
  ///
  void showOverlay() {
    final activeStep = ShowCaseWidget.activeTargetWidget(context);
    setState(() {
      _showShowCase = activeStep == widget.key;
    });

    if (activeStep == widget.key) {
      _slideAnimationController.forward();
      if (ShowCaseWidget.of(context)!.autoPlay!) {
        timer = Timer(Duration(seconds: ShowCaseWidget.of(context)!.autoPlayDelay!.inSeconds), _nextIfAny);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      overlayBuilder: (context, rectBound, offset) {
        final size = MediaQuery.of(context).size;
        position = GetPosition(
          key: widget.key,
          padding: widget.overlayPadding,
          screenWidth: size.width,
          screenHeight: size.height,
        );
        return buildOverlayOnTarget(offset, rectBound.size, rectBound, size);
      },
      showOverlay: true,
      child: widget.child,
    );
  }

  void _nextIfAny() {
    if (timer != null && timer!.isActive) {
      if (ShowCaseWidget.of(context)!.autoPlayLockEnable!) {
        return;
      }
      timer!.cancel();
    } else if (timer != null && !timer!.isActive) {
      timer = null;
    }
    ShowCaseWidget.of(context)!.completed(widget.key);
    if (!widget.disableAnimation) {
      _slideAnimationController.forward();
    }
  }

  void _getOnTargetTap() {
    if (widget.disposeOnTap == true) {
      ShowCaseWidget.of(context)!.dismiss();
      widget.onTargetClick!();
    } else {
      (widget.onTargetClick ?? _nextIfAny).call();
    }
  }

  void _getOnTooltipTap() {
    if (widget.disposeOnTap == true) {
      ShowCaseWidget.of(context)!.dismiss();
    }
    widget.onToolTipClick?.call();
  }

  Widget buildOverlayOnTarget(
    Offset offset,
    Size size,
    Rect rectBound,
    Size screenSize,
  ) {
    var blur = widget.blurValue ?? (ShowCaseWidget.of(context)!.blurValue);

    // Set blur to 0 if application is running on web and
    // provided blur is less than 0.
    blur = kIsWeb && blur < 0 ? 0 : blur;

    return _showShowCase
        ? Stack(
            children: [
              GestureDetector(
                onTap: _nextIfAny,
                child: ClipPath(
                  clipper: RRectClipper(
                    area: rectBound,
                    isCircle: widget.shapeBorder == const CircleBorder(),
                    radius: widget.radius!,
                    overlayPadding: widget.overlayPadding,
                  ),
                  child: blur != 0
                      ? BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: widget.overlayColor,
                            ),
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: widget.overlayColor,
                          ),
                        ),
                ),
              ),
              _TargetWidget(
                offset: offset,
                size: size,
                onTap: _getOnTargetTap,
                shapeBorder: widget.shapeBorder!,
              ),
              ToolTipWidget(
                position: position!,
                offset: offset,
                screenSize: screenSize,
                title: widget.title!,
                description: widget.description!,
                animationOffset: _slideAnimation!,
                titleTextStyle: widget.titleTextStyle!,
                descTextStyle: widget.descTextStyle!,
                container: widget.container,
                tooltipColor: widget.showcaseBackgroundColor,
                textColor: widget.textColor,
                showArrow: widget.showArrow,
                contentHeight: widget.height,
                contentWidth: widget.width,
                onTooltipTap: _getOnTooltipTap,
                contentPadding: widget.contentPadding,
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class _TargetWidget extends StatelessWidget {
  final Offset offset;
  final Size? size;
  final VoidCallback? onTap;
  final ShapeBorder? shapeBorder;
  final BorderRadius? radius;

  const _TargetWidget({Key? key, required this.offset, this.size, this.onTap, this.shapeBorder, this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: size!.height + 16,
            width: size!.width + 16,
            decoration: ShapeDecoration(
              shape: radius != null
                  ? RoundedRectangleBorder(borderRadius: radius!)
                  : shapeBorder ??
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

//Get POsition /*

class GetPosition {
  final GlobalKey? key;
  final EdgeInsets padding;
  final double? screenWidth;
  final double? screenHeight;

  GetPosition({this.key, this.padding = EdgeInsets.zero, this.screenWidth, this.screenHeight});

  Rect getRect() {
    final box = key!.currentContext!.findRenderObject() as RenderBox;

    var boxOffset = box.localToGlobal(const Offset(0.0, 0.0));
    if (boxOffset.dx.isNaN || boxOffset.dy.isNaN) {
      return const Rect.fromLTRB(0, 0, 0, 0);
    }
    final topLeft = box.size.topLeft(boxOffset);
    final bottomRight = box.size.bottomRight(boxOffset);

    final rect = Rect.fromLTRB(
      topLeft.dx - padding.left < 0 ? 0 : topLeft.dx - padding.left,
      topLeft.dy - padding.top < 0 ? 0 : topLeft.dy - padding.top,
      bottomRight.dx + padding.right > screenWidth! ? screenWidth! : bottomRight.dx + padding.right,
      bottomRight.dy + padding.bottom > screenHeight! ? screenHeight! : bottomRight.dy + padding.bottom,
    );
    return rect;
  }

  ///Get the bottom position of the widget
  double getBottom() {
    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final boxOffset = box.localToGlobal(const Offset(0.0, 0.0));
    if (boxOffset.dy.isNaN) return padding.bottom;
    final bottomRight = box.size.bottomRight(boxOffset);
    return bottomRight.dy + padding.bottom - 76.0;
  }

  ///Get the top position of the widget
  double getTop() {
    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final boxOffset = box.localToGlobal(const Offset(0.0, 0.0));
    if (boxOffset.dy.isNaN) return 0 - padding.top;
    final topLeft = box.size.topLeft(boxOffset);
    return topLeft.dy - padding.top + 20.0;
  }

  ///Get the left position of the widget
  double getLeft() {
    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final boxOffset = box.localToGlobal(const Offset(0.0, 0.0));
    if (boxOffset.dx.isNaN) return 0 - padding.left;
    final topLeft = box.size.topLeft(boxOffset);
    return topLeft.dx - padding.left;
  }

  ///Get the right position of the widget
  double getRight() {
    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final boxOffset = box.localToGlobal(const Offset(0.0, 0.0));
    if (boxOffset.dx.isNaN) return padding.right;
    final bottomRight = box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
    return bottomRight.dx + padding.right;
  }

  double getHeight() {
    return getBottom() - getTop();
  }

  double getWidth() {
    return getRight() - getLeft();
  }

  double getCenter() {
    return (getLeft() + getRight()) / 0.7;
  }
}

//AnchoredOverlay

class AnchoredOverlay extends StatelessWidget {
  final bool showOverlay;
  final Widget Function(BuildContext, Rect anchorBounds, Offset anchor)? overlayBuilder;
  final Widget? child;

  const AnchoredOverlay({
    Key? key,
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OverlayBuilder(
          showOverlay: showOverlay,
          overlayBuilder: (overlayContext) {
            // To calculate the "anchor" point we grab the render box of
            // our parent Container and then we find the center of that box.
            final box = context.findRenderObject() as RenderBox;
            final topLeft = box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
            final bottomRight = box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
            Rect anchorBounds;
            anchorBounds = (topLeft.dx.isNaN || topLeft.dy.isNaN || bottomRight.dx.isNaN || bottomRight.dy.isNaN)
                ? const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)
                : Rect.fromLTRB(
                    topLeft.dx,
                    topLeft.dy,
                    bottomRight.dx,
                    bottomRight.dy,
                  );
            final anchorCenter = box.size.center(topLeft);
            return overlayBuilder!(overlayContext, anchorBounds, anchorCenter);
          },
          child: child!,
        );
      },
    );
  }
}

class OverlayBuilder extends StatefulWidget {
  final bool showOverlay;
  final Widget Function(BuildContext)? overlayBuilder;
  final Widget? child;

  const OverlayBuilder({
    Key? key,
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  }) : super(key: key);

  @override
  _OverlayBuilderState createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void dispose() {
    if (isShowingOverlay()) {
      hideOverlay();
    }

    super.dispose();
  }

  bool isShowingOverlay() => _overlayEntry != null;

  void showOverlay() {
    if (_overlayEntry == null) {
      // Create the overlay.
      _overlayEntry = OverlayEntry(
        builder: widget.overlayBuilder!,
      );
      addToOverlay(_overlayEntry!);
    } else {
      // Rebuild overlay.
      buildOverlay();
    }
  }

  void addToOverlay(OverlayEntry overlayEntry) async {
    if (ShowCaseWidget.of(context)?.context != null && Overlay.of(ShowCaseWidget.of(context)!.context) != null) {
      Overlay.of(ShowCaseWidget.of(context)!.context)!.insert(overlayEntry);
    } else {
      if (Overlay.of(context) != null) {
        Overlay.of(context)!.insert(overlayEntry);
      }
    }
  }

  void hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  void buildOverlay() async {
    WidgetsBinding.instance.addPostFrameCallback((_) => _overlayEntry?.markNeedsBuild());
  }

  @override
  Widget build(BuildContext context) {
    buildOverlay();

    return widget.child!;
  }
}

//

class RRectClipper extends CustomClipper<ui.Path> {
  final bool isCircle;
  final BorderRadius? radius;
  final EdgeInsets overlayPadding;
  final Rect area;

  RRectClipper({
    this.isCircle = false,
    this.radius,
    this.overlayPadding = EdgeInsets.zero,
    this.area = Rect.zero,
  });

  @override
  ui.Path getClip(ui.Size size) {
    final customRadius = isCircle ? Radius.circular(area.height) : const Radius.circular(3.0);

    final rect = Rect.fromLTRB(
      area.left - overlayPadding.left,
      area.top - overlayPadding.top,
      area.right + overlayPadding.right,
      area.bottom + overlayPadding.bottom,
    );

    return Path()
      ..fillType = ui.PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: (radius?.topLeft ?? customRadius),
          topRight: (radius?.topRight ?? customRadius),
          bottomLeft: (radius?.bottomLeft ?? customRadius),
          bottomRight: (radius?.bottomRight ?? customRadius),
        ),
      );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) =>
      oldClipper is RRectClipper &&
      (isCircle != oldClipper.isCircle || radius != oldClipper.radius || overlayPadding != oldClipper.overlayPadding || area != oldClipper.area);
}

// --------------------------------

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size? screenSize;
  final String? title;
  final String? description;
  final Animation<double>? animationOffset;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final Color? tooltipColor;
  final Color? textColor;
  final bool? showArrow;
  final double? contentHeight;
  final double? contentWidth;
  static bool? isArrowUp;
  final VoidCallback? onTooltipTap;
  final EdgeInsets? contentPadding;

  const ToolTipWidget(
      {this.position,
      this.offset,
      this.screenSize,
      this.title,
      this.description,
      this.animationOffset,
      this.titleTextStyle,
      this.descTextStyle,
      this.container,
      this.tooltipColor,
      this.textColor,
      this.showArrow,
      this.contentHeight,
      this.contentWidth,
      this.onTooltipTap,
      this.contentPadding = const EdgeInsets.symmetric(vertical: 8)});

  @override
  _ToolTipWidgetState createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget> {
  Offset? position;

  bool isCloseToTopOrBottom(Offset position) {
    var height = 120.0;
    height = widget.contentHeight ?? height;
    return (widget.screenSize!.height - position.dy) <= height;
  }

  String findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return 'ABOVE';
    } else {
      return 'BELOW';
    }
  }

  double _getTooltipWidth() {
    final titleStyle = widget.titleTextStyle ?? Theme.of(context).textTheme.headline6!.merge(TextStyle(color: widget.textColor));
    final descriptionStyle = widget.descTextStyle ?? Theme.of(context).textTheme.subtitle2!.merge(TextStyle(color: widget.textColor));
    final titleLength =
        widget.title == null ? 0 : _textSize(widget.title!, titleStyle).width + widget.contentPadding!.right + widget.contentPadding!.left;
    final descriptionLength = _textSize(widget.description!, descriptionStyle).width + widget.contentPadding!.right + widget.contentPadding!.left;
    var maxTextWidth = max(titleLength, descriptionLength);
    if (maxTextWidth > widget.screenSize!.width - 20) {
      return widget.screenSize!.width - 20;
    } else {
      return maxTextWidth + 15;
    }
  }

  bool _isLeft() {
    final screenWidth = widget.screenSize!.width / 3;
    return !(screenWidth <= widget.position!.getCenter());
  }

  bool _isRight() {
    final screenWidth = widget.screenSize!.width / 3;
    return ((screenWidth * 2) <= widget.position!.getCenter());
  }

  double? _getLeft() {
    if (_isLeft()) {
      var leftPadding = widget.position!.getCenter() - (_getTooltipWidth() * 0.1);
      if (leftPadding + _getTooltipWidth() > widget.screenSize!.width) {
        leftPadding = (widget.screenSize!.width - 20) - _getTooltipWidth();
      }
      if (leftPadding < 20) {
        leftPadding = 14;
      }
      return leftPadding;
    } else if (!(_isRight())) {
      return widget.position!.getCenter() - (_getTooltipWidth() * 0.5);
    } else {
      return null;
    }
  }

  double? _getRight() {
    if (_isRight()) {
      var rightPadding = widget.position!.getCenter() + (_getTooltipWidth() / 2);
      if (rightPadding + _getTooltipWidth() > widget.screenSize!.width) {
        rightPadding = 14;
      }
      return rightPadding;
    } else if (!(_isLeft())) {
      return widget.position!.getCenter() - (_getTooltipWidth() * 0.5);
    } else {
      return null;
    }
  }

  double _getSpace() {
    var space = widget.position!.getCenter() - (widget.contentWidth! / 2);
    if (space + widget.contentWidth! > widget.screenSize!.width) {
      space = widget.screenSize!.width - widget.contentWidth! - 8;
    } else if (space < (widget.contentWidth! / 2)) {
      space = 16;
    }
    return space;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    position = widget.offset;
    final contentOrientation = findPositionForContent(position!);
    final contentOffsetMultiplier = contentOrientation == "BELOW" ? 1.0 : -1.0;
    ToolTipWidget.isArrowUp = contentOffsetMultiplier == 1.0;

    final contentY = ToolTipWidget.isArrowUp!
        ? widget.position!.getBottom() + (contentOffsetMultiplier * 3)
        : widget.position!.getTop() + (contentOffsetMultiplier * 3);

    final num contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);

    var paddingTop = ToolTipWidget.isArrowUp! ? 22.0 : 0.0;
    var paddingBottom = ToolTipWidget.isArrowUp! ? 0.0 : 27.0;

    if (!widget.showArrow!) {
      paddingTop = 10;
      paddingBottom = 10;
    }

    // const arrowWidth = 18.0;
    const arrowHeight = 9.0;

    if (widget.container == null) {
      return Positioned(
        top: contentY,
        left: _getLeft(),
        right: _getRight(),
        child: FractionalTranslation(
          translation: Offset(0.0, contentFractionalOffset as double),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, contentFractionalOffset / 10),
              end: const Offset(0.0, 0.100),
            ).animate(widget.animationOffset!),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.only(
                  top: paddingTop - (ToolTipWidget.isArrowUp! ? arrowHeight : 0),
                  bottom: paddingBottom - (ToolTipWidget.isArrowUp! ? 0 : arrowHeight),
                ),
                child: Stack(
                  alignment: ToolTipWidget.isArrowUp!
                      ? Alignment.topLeft
                      : _getLeft() == null
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                  children: [
                    ToolTipWidget.isArrowUp!
                        ? Positioned(
                            left: -20.0,
                            top: 7.0,
                            child: Icon(
                              Icons.arrow_left,
                              size: 50,
                              color: ColorConstant.primaryColor,
                            ))
                        : Positioned(
                            left: -10.0,
                            bottom: -20.0,
                            child: Icon(
                              Icons.arrow_drop_down,
                              size: 50,
                              color: ColorConstant.primaryColor,
                            ),
                          ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: ToolTipWidget.isArrowUp! ? arrowHeight - 1 : 0,
                        bottom: ToolTipWidget.isArrowUp! ? 0 : arrowHeight - 1,
                        left: ToolTipWidget.isArrowUp! ? arrowHeight - 1 : 0,
                        right: ToolTipWidget.isArrowUp! ? 0 : arrowHeight - 1,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GestureDetector(
                          onTap: widget.onTooltipTap,
                          child: Container(
                            width: _getTooltipWidth(),
                            padding: widget.contentPadding,
                            color: widget.tooltipColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: widget.title != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                                  children: <Widget>[
                                    widget.title != null
                                        ? Text(
                                            widget.title!,
                                            style: widget.titleTextStyle ??
                                                Theme.of(context).textTheme.headline6!.merge(
                                                      TextStyle(
                                                        color: widget.textColor,
                                                      ),
                                                    ),
                                          )
                                        : const SizedBox(),
                                    Text(
                                      widget.description!,
                                      style: widget.descTextStyle ??
                                          Theme.of(context).textTheme.subtitle2!.merge(
                                                TextStyle(
                                                  color: widget.textColor,
                                                ),
                                              ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned(
            left: _getSpace(),
            top: contentY - 10,
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset as double),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: widget.showArrow! && ToolTipWidget.isArrowUp! ? const Offset(0.0, 0.0) : const Offset(0.0, 0.100),
                ).animate(widget.animationOffset!),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: widget.onTooltipTap,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: paddingTop,
                      ),
                      color: Colors.transparent,
                      child: Center(
                        child: MeasureSize(
                            onSizeChange: (size) {
                              setState(() {
                                var tempPos = position;
                                tempPos = Offset(position!.dx, position!.dy + size.height);
                                position = tempPos;
                              });
                            },
                            child: widget.container!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Size _textSize(String text, TextStyle style) {
    final textPainter = (TextPainter(
            text: TextSpan(text: text, style: style),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    return textPainter;
  }
}

// class _Arrow extends CustomPainter {
//   final Color strokeColor;
//   final PaintingStyle paintingStyle;
//   final double strokeWidth;
//   final bool isUpArrow;
//
//   _Arrow({this.strokeColor = Colors.black, this.strokeWidth = 3, this.paintingStyle = PaintingStyle.stroke, this.isUpArrow = true});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = strokeColor
//       ..strokeWidth = strokeWidth
//       ..style = paintingStyle;
//
//     canvas.drawPath(getTrianglePath(size.width, size.height), paint);
//   }
//
//   Path getTrianglePath(double x, double y) {
//     if (isUpArrow) {
//       return Path()
//         ..moveTo(0, y)
//         ..lineTo(x / 2, 0)
//         ..lineTo(x, y)
//         ..lineTo(0, y);
//     } else {
//       return Path()
//         ..moveTo(0, 0)
//         ..lineTo(x, 0)
//         ..lineTo(x / 2, y)
//         ..lineTo(0, 0);
//     }
//   }
//
//   @override
//   bool shouldRepaint(_Arrow oldDelegate) {
//     return oldDelegate.strokeColor != strokeColor || oldDelegate.paintingStyle != paintingStyle || oldDelegate.strokeWidth != strokeWidth;
//   }
// }
//

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onSizeChange;

  const MeasureSize({
    required this.onSizeChange,
    required this.child,
  });

  @override
  _MeasureSizeState createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  GlobalKey widgetKey = GlobalKey();
  Size? oldSize;

  void postFrameCallback(Duration timestamp) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onSizeChange(newSize!);
  }
}

//

class ShowCaseWidget extends StatefulWidget {
  final Builder builder;
  final VoidCallback? onFinish;
  final Function(int, GlobalKey)? onStart;
  final Function(int, GlobalKey)? onComplete;
  final bool autoPlay;
  final Duration autoPlayDelay;
  final bool autoPlayLockEnable;

  /// Default overlay blur used by showcase. if [Showcase.blurValue]
  /// is not provided.
  ///
  /// Default value is 0.
  final double blurValue;

  const ShowCaseWidget({
    required this.builder,
    this.onFinish,
    this.onStart,
    this.onComplete,
    this.autoPlay = false,
    this.autoPlayDelay = const Duration(milliseconds: 2000),
    this.autoPlayLockEnable = false,
    this.blurValue = 0,
  });

  static GlobalKey? activeTargetWidget(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedShowCaseView>()?.activeWidgetIds;
  }

  static ShowCaseWidgetState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<ShowCaseWidgetState>();
    if (state != null) {
      return context.findAncestorStateOfType<ShowCaseWidgetState>();
    } else {
      throw Exception('Please provide ShowCaseView context');
    }
  }

  @override
  ShowCaseWidgetState createState() => ShowCaseWidgetState();
}

class ShowCaseWidgetState extends State<ShowCaseWidget> {
  List<GlobalKey>? ids;
  int? activeWidgetId;
  bool? autoPlay;
  Duration? autoPlayDelay;
  bool? autoPlayLockEnable;

  /// Returns value of  [ShowCaseWidget.blurValue]
  double get blurValue => widget.blurValue;

  @override
  void initState() {
    super.initState();
    autoPlayDelay = widget.autoPlayDelay;
    autoPlay = widget.autoPlay;
    autoPlayLockEnable = widget.autoPlayLockEnable;
  }

  void startShowCase(List<GlobalKey> widgetIds) {
    if (mounted) {
      setState(() {
        ids = widgetIds;
        activeWidgetId = 0;
        _onStart();
      });
    }
  }

  void completed(GlobalKey id) {
    if (ids![activeWidgetId!] == id && mounted) {
      setState(() {
        _onComplete();
        activeWidgetId = activeWidgetId! + 1;
        _onStart();

        if (activeWidgetId! >= ids!.length) {
          _cleanupAfterSteps();
          if (widget.onFinish != null) {
            widget.onFinish!();
          }
        }
      });
    }
  }

  void dismiss() {
    if (mounted) {
      setState(_cleanupAfterSteps);
    }
  }

  void _onStart() {
    if (activeWidgetId! < ids!.length) {
      widget.onStart?.call(activeWidgetId!, ids![activeWidgetId!]);
    }
  }

  void _onComplete() {
    widget.onComplete?.call(activeWidgetId!, ids![activeWidgetId!]);
  }

  void _cleanupAfterSteps() {
    ids = null;
    activeWidgetId = null;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedShowCaseView(
      activeWidgetIds: ids!.elementAt(activeWidgetId!),
      child: widget.builder,
    );
  }
}

class _InheritedShowCaseView extends InheritedWidget {
  final GlobalKey activeWidgetIds;

  const _InheritedShowCaseView({
    required this.activeWidgetIds,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedShowCaseView oldWidget) => oldWidget.activeWidgetIds != activeWidgetIds;
}
