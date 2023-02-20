library collapsible_sidebar;
import 'dart:core';
import 'dart:math' as math show pi;
import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_avatar.dart';
import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_container.dart';
import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_item.dart';
import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_item_selection.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import '../Bloc/Bloc/dash_board_bloc.dart';
import 'custom_show_case.dart';
export 'package:collapsible_sidebar/collapsible_sidebar/collapsible_item.dart';

class CustomCollapsibleSidebar extends StatefulWidget {
  const CustomCollapsibleSidebar({
    Key? key,
    required this.items,
    this.title = 'Lorem Ipsum',
    this.titleStyle,
    this.titleBack = false,
    this.titleBackIcon = Icons.arrow_back,
    this.onHoverPointer = SystemMouseCursors.click,
    this.textStyle,
    this.toggleTitleStyle,
    this.toggleTitle = 'Collapse',
    this.avatarImg,
    this.height = double.infinity,
    this.minWidth = 80,
    this.maxWidth = 270,
    this.borderRadius = 15,
    this.iconSize = 40,
    this.toggleButtonIcon = Icons.chevron_right,
    this.backgroundColor = const Color(0xff2B3138),
    this.selectedIconBox = const Color(0xff2F4047),
    this.selectedIconColor = const Color(0xff4AC6EA),
    this.selectedTextColor = const Color(0xffF3F7F7),
    this.unselectedIconColor = const Color(0xff6A7886),
    this.unselectedTextColor = const Color(0xffC0C7D0),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastLinearToSlowEaseIn,
    this.screenPadding = 4,
    this.showToggleButton = true,
    this.topPadding = 0,
    this.bottomPadding = 0,
    this.fitItemsToBottom = false,
    required this.body,
    this.onTitleTap,
    // this.isCollapsed = true,
    this.sidebarBoxShadow = const [
      BoxShadow(
        color: Colors.blue,
        blurRadius: 10,
        spreadRadius: 0.01,
        offset: Offset(3, 3),
      ),
    ],
  }) : super(key: key);

  final String title, toggleTitle;
  final MouseCursor onHoverPointer;
  final TextStyle? titleStyle, textStyle, toggleTitleStyle;
  final bool titleBack;
  final IconData titleBackIcon;
  final Widget body;
  final dynamic avatarImg;
  final bool showToggleButton, fitItemsToBottom;

  //  isCollapsed;
  final List<CollapsibleItem> items;
  final double? height, minWidth, maxWidth, borderRadius, iconSize, padding = 10, itemPadding = 10, topPadding, bottomPadding, screenPadding;
  final IconData toggleButtonIcon;
  final Color backgroundColor, selectedIconBox, selectedIconColor, selectedTextColor, unselectedIconColor, unselectedTextColor;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTitleTap;
  final List<BoxShadow> sidebarBoxShadow;

  @override
  // ignore: library_private_types_in_public_api
  _CustomCollapsibleSidebarState createState() => _CustomCollapsibleSidebarState();
}

class _CustomCollapsibleSidebarState extends State<CustomCollapsibleSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _widthAnimation;
  CurvedAnimation? _curvedAnimation;
  double? tempWidth;

  bool? _isCollapsed;
  double? _currWidth, _delta, _delta1By4, _delta3by4, _maxOffsetX, _maxOffsetY;
  int? _selectedItemIndex;

  final List<bool> _show = [false, false, false, false, false, false, false, false, false];

  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  final GlobalKey _six = GlobalKey();
  final GlobalKey _seven = GlobalKey();
  final GlobalKey _eight = GlobalKey();
  final GlobalKey _nine = GlobalKey();

  @override
  void initState() {
    assert(widget.items.isNotEmpty);

    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([_one, _two, _three, _four, _five, _six, _seven, _eight, _nine]));

    tempWidth = widget.maxWidth! > 270 ? 270 : widget.maxWidth;

    _currWidth = widget.minWidth;
    _delta = tempWidth! - widget.minWidth!;
    _delta1By4 = _delta! * 0.25;
    _delta3by4 = _delta! * 0.75;
    _maxOffsetX = widget.padding! * 2 + widget.iconSize!;
    _maxOffsetY = widget.itemPadding! * 2 + widget.iconSize!;
    for (var i = 0; i < widget.items.length; i++) {
      if (!widget.items[i].isSelected) continue;
      _selectedItemIndex = i;
      break;
    }

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _controller.addListener(() {
      if (kDebugMode) {
        print("Is Collapes is $_isCollapsed");
      }
      _currWidth = _widthAnimation!.value;
      if (_controller.isCompleted) _isCollapsed = _currWidth == widget.minWidth;
      setState(() {});
    });

    _isCollapsed = BlocProvider.of<DashBoardBloc>(context).isCustomCollapsible;
    // _isCollapsed = BlocProvider.of<HomeBloc>(context).isCustomCollapsible;
    var endWidth = _isCollapsed! ? widget.minWidth : tempWidth;
    _animateTo(endWidth!);
  }

  void _animateTo(double endWidth) {
    _widthAnimation = Tween<double>(
      begin: _currWidth,
      end: endWidth,
    ).animate(_curvedAnimation!);
    _controller.reset();
    _controller.forward();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null) {
      _currWidth = _currWidth! + details.primaryDelta!;
      if (_currWidth! > tempWidth!) {
        _currWidth = tempWidth;
      } else if (_currWidth! < widget.minWidth!) {
        _currWidth = widget.minWidth;
      } else {
        setState(() {});
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails _) {
    if (_currWidth == tempWidth) {
      setState(() => _isCollapsed = false);
    } else if (_currWidth == widget.minWidth) {
      setState(() => _isCollapsed = true);
    } else {
      var threshold = _isCollapsed! ? _delta1By4 : _delta3by4;
      var endWidth = _currWidth! - widget.minWidth! > threshold! ? tempWidth : widget.minWidth;
      _animateTo(endWidth!);
    }
  }

// //ToolTip Show
//   _toolTipShow(index) async {
//     await hideselectedIndex();
//     _show[index] = true;
//     setState(() {});
//     Timer(const Duration(seconds: 2), () {
//       _show[index] = false;
//       setState(() {});
//     });
//   }

  hideselectedIndex() {
    for (var i = 0; i <= widget.items.length; i++) {
      if (_show[i] == true) {
        _show[i] = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.minWidth! * 1.1),
          child: InkWell(
              onTap: () {
                if (kDebugMode) {
                  print("Click GHEre To CLick 4");
                }
                setState(() {
                  BlocProvider.of<DashBoardBloc>(context).isCustomCollapsible = true;
                  // BlocProvider.of<HomeBloc>(context).isCustomCollapsible = true;
                  _isCollapsed = true;
                });
              },
              child: widget.body),
        ),
        Padding(
          padding: EdgeInsets.all(widget.screenPadding!),
          child: GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: CollapsibleContainer(
              height: widget.height!,
              width: _currWidth!,
              padding: widget.padding!,
              borderRadius: widget.borderRadius!,
              color: widget.backgroundColor,
              sidebarBoxShadow: widget.sidebarBoxShadow,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _avatar,
                    SizedBox(
                      height: widget.topPadding,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        reverse: widget.fitItemsToBottom,
                        child: Stack(
                          children: [
                            CollapsibleItemSelection(
                              height: _maxOffsetY!,
                              offsetY: _maxOffsetY! * _selectedItemIndex!,
                              color: widget.selectedIconBox,
                              duration: widget.duration,
                              curve: widget.curve,
                            ),
                            Column(
                              children: _items,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: widget.bottomPadding,
                    ),
                    widget.showToggleButton
                        ? Divider(
                            color: widget.unselectedIconColor,
                            indent: 5,
                            endIndent: 5,
                            thickness: 1,
                          )
                        : const SizedBox(
                            height: 5,
                          ),
                    widget.showToggleButton
                        ? _toggleButton
                        : SizedBox(
                            height: widget.iconSize,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget get _avatar {
    return CollapsibleItemWidget(
      onHoverPointer: widget.onHoverPointer,
      padding: widget.itemPadding!,
      offsetX: _offsetX,
      scale: _fraction,
      leading: InkWell(
        onTap: widget.onTitleTap,
        child: Showcase1(
          key: _one,
          title: 'User',
          description: 'Click here to set your name',
          showcaseBackgroundColor: ColorConstant.primaryColor,
          textColor: Colors.white,radius: BorderRadius.circular(10),
          child: widget.titleBack
              ? Container(
                  height: 34,
                  width: 36,
                  margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: Icon(
                    widget.titleBackIcon,
                    size: widget.iconSize,
                    color: widget.unselectedIconColor,
                  ),
                )
              : CollapsibleAvatar(
                  backgroundColor: widget.unselectedIconColor,
                  avatarSize: widget.iconSize!,
                  name: widget.title,
                  avatarImg: widget.avatarImg,
                  textStyle: _textStyle(widget.backgroundColor, widget.titleStyle!),
                ),
        ),
      ),
      title: widget.title,
      textStyle: _textStyle(widget.unselectedTextColor, widget.titleStyle!),
      onTap: widget.onTitleTap,
    );
  }

  bool hideOnTap = false;

  List<Widget> get _items {
    return List.generate(widget.items.length, (index) {
      var item = widget.items[index];
      var iconColor = widget.unselectedIconColor;
      var textColor = widget.unselectedTextColor;
      if (item.isSelected) {
        iconColor = widget.selectedIconColor;
        textColor = widget.selectedTextColor;
      }

      return InkWell(
        onTap: () {
          _isCollapsed = true;
          var endWidth = _isCollapsed! ? widget.minWidth : tempWidth;
          _animateTo(endWidth!);
          if (item.isSelected) return;
          item.onPressed();
          item.isSelected = true;
          widget.items[_selectedItemIndex!].isSelected = false;
          setState(() => _selectedItemIndex = index);
        },
        child: Showcase1(
          key: index == 0
              ? _two
              : index == 1
                  ? _three
                  : index == 2
                      ? _four
                      : index == 3
                          ? _five
                          : index == 4
                              ? _six
                              : index == 5
                                  ? _seven
                                  : index == 6
                                      ? _eight
                                      : _nine,
          title: item.text,
          radius: BorderRadius.circular(10),
          description: 'Click here to see ${item.text}',
          showcaseBackgroundColor: ColorConstant.primaryColor,
          contentPadding: EdgeInsets.zero,
          textColor: Colors.white,
          child: SimpleTooltip(
            ballonPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            show: _show[index],
            tooltipDirection: TooltipDirection.right,
            hideOnTooltipTap: false,
            borderColor: Colors.white,
            backgroundColor: ColorConstant.primaryColor.withOpacity(0.8),
            minimumOutSidePadding: 0.0,
            content: Text(
              item.text,
              style: TextStyleConstant.whiteBold16.copyWith(
                letterSpacing: 0.5,
                fontSize: 16,
                fontFamily: 'Poppins',
                decoration: TextDecoration.none,
              ),
            ),
            // style: TextStyle(
            //   color: Colors.white,
            //   fontSize: 18,
            //   decoration: TextDecoration.none,
            // )),
            child: CollapsibleItemWidget(
              onHoverPointer: widget.onHoverPointer,
              padding: widget.itemPadding!,
              offsetX: _offsetX,
              scale: _fraction,
              leading: Container(
                height: MediaQuery.of(context).size.height / 24,
                width: 36,
                // color: Colors.black,/
                margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: Icon(
                  item.icon,
                  size: widget.iconSize,
                  color: iconColor,
                ),
              ),
              title: item.text,
              textStyle: _textStyle(textColor, widget.textStyle!),
              onTap: () {
                _isCollapsed = true;
                var endWidth = _isCollapsed! ? widget.minWidth : tempWidth;
                _animateTo(endWidth!);
                // _isCollapsed ? _toolTipShow(index) : Container();
                if (item.isSelected) return;
                item.onPressed();
                item.isSelected = true;
                widget.items[_selectedItemIndex!].isSelected = false;
                setState(() => _selectedItemIndex = index);
              },
            ),
          ),
        ),
      );
    });
  }

  Widget get _toggleButton {
    return CollapsibleItemWidget(
      onHoverPointer: widget.onHoverPointer,
      padding: widget.itemPadding!,
      offsetX: _offsetX,
      scale: _fraction,
      leading: Transform.rotate(
        angle: _currAngle,
        child: Icon(
          widget.toggleButtonIcon,
          size: widget.iconSize,
          color: widget.unselectedIconColor,
        ),
      ),
      title: widget.toggleTitle,
      textStyle: _textStyle(widget.unselectedTextColor, widget.toggleTitleStyle!),
      onTap: () {
        if (kDebugMode) {
          print("Click GHEre To CLick 2");
        }
        _isCollapsed = !_isCollapsed!;
        var endWidth = _isCollapsed! ? widget.minWidth : tempWidth;
        _animateTo(endWidth!);
      },
    );
  }

  double get _fraction => (_currWidth! - widget.minWidth!) / _delta!;

  double get _currAngle => -math.pi * _fraction;

  double get _offsetX => _maxOffsetX! * _fraction;

  TextStyle _textStyle(Color color, TextStyle style) {
    return style == null
        ? TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          )
        : style.copyWith(color: color);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

//

class CollapsibleItemWidget extends StatefulWidget {
  const CollapsibleItemWidget({Key? key,
    required this.onHoverPointer,
    required this.leading,
    required this.title,
    required this.textStyle,
    required this.padding,
    required this.offsetX,
    required this.scale,
    this.onTap,
  }) : super(key: key);

  final MouseCursor onHoverPointer;
  final Widget leading;
  final String title;
  final TextStyle textStyle;
  final double offsetX, scale, padding;
  final VoidCallback? onTap;

  @override
  // ignore: library_private_types_in_public_api
  _CollapsibleItemWidgetState createState() => _CollapsibleItemWidgetState();
}

class _CollapsibleItemWidgetState extends State<CollapsibleItemWidget> {
  bool _underline = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        if (kDebugMode) {
          print("Click GHEre To CLick 3");
        }
        setState(() {
          _underline = true && widget.onTap != null;
        });
      },
      onExit: (event) {
        if (kDebugMode) {
          print("Click GHEre To CLick 4");
        }
        setState(() {
          _underline = false;
        });
      },
      cursor: widget.onHoverPointer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(top: widget.padding, bottom: widget.padding),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              widget.leading,
              _title,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _title {
    return Opacity(
      opacity: widget.scale,
      child: Transform.translate(
        offset: Offset(widget.offsetX, 0),
        child: Transform.scale(
          scale: widget.scale,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              widget.title,
              style: _underline ? widget.textStyle.merge(const TextStyle(decoration: TextDecoration.underline)) : widget.textStyle,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ),
      ),
    );
  }
}
