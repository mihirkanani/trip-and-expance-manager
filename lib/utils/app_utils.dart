//Category Images
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

showCategoryIcon(value) {
  switch (value) {
    case 0:
      return const Icon(Icons.book_online, color: Colors.white);
    case 1:
      return const Icon(Icons.local_activity, color: Colors.white);
    case 2:
      return const Icon(Icons.airplane_ticket, color: Colors.white);
    case 3:
      return const Icon(Icons.accessibility, color: Colors.white);
    case 4:
      return const Icon(Icons.production_quantity_limits, color: Colors.white);
    case 5:
      return const Icon(Icons.food_bank, color: Colors.white);
    case 6:
      return const Icon(Icons.card_travel, color: Colors.white);
    case 7:
      return const Icon(Icons.file_copy, color: Colors.white);
    case 8:
      return const Icon(Icons.phone, color: Colors.white);
    case 9:
      return const Icon(Icons.house_siding, color: Colors.white);
    case 10:
      return const Icon(Icons.sports_cricket, color: Colors.white);
    case 11:
      return const Icon(Icons.health_and_safety, color: Colors.white);
    case 12:
      return const Icon(Icons.cake, color: Colors.white);
    case 13:
      return const Icon(Icons.domain, color: Colors.white);
    case 14:
      return const Icon(Icons.luggage, color: Colors.white);
    case 15:
      return const Icon(Icons.emoji_food_beverage, color: Colors.white);
    case 16:
      return const Icon(Icons.add_moderator, color: Colors.white);
    case 17:
      return const Icon(Icons.post_add, color: Colors.white);
    case 18:
      return const Icon(Icons.weekend, color: Colors.white);
    case 19:
      return const Icon(Icons.auto_stories, color: Colors.white);
    default:
      return const Icon(Icons.book_online, color: Colors.white);
  }
}

final picker = ImagePicker();

Future getImage(String type) async {
  var pickedFile;
  if (type == "2") {
    pickedFile = await picker.pickImage(source: ImageSource.camera, maxHeight: 480, maxWidth: 640);
  } else {
    pickedFile = await picker.pickImage(source: ImageSource.gallery, maxHeight: 480, maxWidth: 640);
  }

  if (pickedFile != null) {
    return base64Encode(await pickedFile.readAsBytes());
  } else {
    return null;
  }
}

Future<bool> check() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

confirmDialog({onConfirm, title, content, context}) {
  showDialog(
    context: context,
    // barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    )),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyleConstant.whiteBold16,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: double.infinity,
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyleConstant.blackRegular14,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: Text(
                            "No",
                            style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: onConfirm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: Text(
                            "Yes",
                            style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      );
    },
  );
}

extension DateTimeExt on DateTime {
  String format(String formatPattern) => DateFormat(formatPattern).format(this);
}

const kAppBarDateFormat = 'MMMM yyyy';
const kMonthFormat = 'MMMM';
const kMonthFormatWidthYear = 'MMMM yyyy';
const kDateRangeFormat = 'dd MMM yyyy';
const kDateMonthFormate = 'dd MMM';

String parseDateRange(DateTime begin, DateTime end) {
  var start = DateTime(begin.year, begin.month, begin.day);
  var endDate = DateTime(end.year, end.month, end.day);
  if (start.isAtSameMomentAs(endDate)) {
    return begin.format(kDateRangeFormat);
  } else {
    return '${begin.format(kDateMonthFormate)} - ${end.format(kDateRangeFormat)}';
  }
}

showLoader(context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          insetPadding: EdgeInsets.all(150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              //color: Theme.of(context).hoverColor,
              borderRadius: BorderRadius.circular(7),
            ),
            width: 60,
            height: 60,
            child: SpinKitDualRing(
              color: ColorConstant.primaryColor,
              size: 40,
              lineWidth: 3,
            ),
          ),
        ),
      );
    },
  );
}

customDialog({onConfirm, title, content, context}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    )),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyleConstant.whiteBold16,
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  // decoration: BoxDecoration(
                  //     color: Color(0xffe8e3e3),
                  //     borderRadius: BorderRadius.circular(15.r)),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  width: double.infinity,
                  child: Text(
                    content,
                    textAlign: TextAlign.center,
                    style:TextStyleConstant. blackRegular14,
                  )),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text(
                        "OK",
                        style: TextStyleConstant.blackRegular14.copyWith(color: ColorConstant.primaryColor),
                      ),
                    ),
                  )),
              SizedBox(height: 15),
            ],
          ),
        ),
      );
    },
  );
}
