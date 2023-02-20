import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'app_utils.dart';

class CenterButton extends StatelessWidget {
  CenterButton({
    Key? key,
    required this.ontap,
    required this.text,
    this.bgColor = const Color(0xffFE7317),
    this.txtColor = Colors.white,
    this.isExpanded = false,
    this.margin = 0,
    this.radius = 25,
    this.isProgress = false,
    this.fontsize = 14,
  }) : super(key: key);

  final Function ontap;
  final String? text;
  final Color? bgColor;
  final Color? txtColor;
  final bool? isExpanded;
  final bool? isProgress;
  final double? margin;
  final double? fontsize;
  final double? radius;

  // final textStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap(),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          width: isExpanded! ? double.infinity : null,
          margin: margin! > 0 ? EdgeInsets.symmetric(horizontal: margin!) : null,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: const [
              BoxShadow(
                blurRadius: 2,
                color: Colors.black12,
                spreadRadius: 2,
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(radius!),
          ),
          child: isProgress!
              ? const SpinKitFadingCircle(
                  color: Colors.white,
                  size: 20,
                )
              : Text(
                  text!,
                  style: TextStyleConstant.whiteBold16.copyWith(color: txtColor, fontSize: fontsize),
                ),
        ),
      ),
    );
  }
}
//
// // class LongButton extends StatelessWidget {
// //   const LongButton({
// //     Key key,
// //     @required this.ontap,
// //     this.text,
// //     this.bgColor = primaryColor,
// //     this.txtColor = Colors.white,
// //   }) : super(key: key);
// //
// //   final Function ontap;
// //   final String text;
// //   final Color bgColor;
// //   final Color txtColor;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: ontap,
// //       child: Container(
// //         alignment: Alignment.center,
// //         margin: EdgeInsets.symmetric(horizontal: 50.w),
// //         padding: EdgeInsets.symmetric(vertical: 10.h),
// //         decoration: BoxDecoration(
// //           color: bgColor,
// //           borderRadius: BorderRadius.circular(10.r),
// //         ),
// //         child: Text(
// //           text,
// //           style: whiteBold14.copyWith(fontSize: 18.sp, color: txtColor),
// //         ),
// //       ),
// //     );
// //   }
// // }
