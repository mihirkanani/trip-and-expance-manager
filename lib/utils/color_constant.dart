import 'package:flutter/material.dart';

class ColorConstant {
  static List<MaterialColor> colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  // static Color primaryColor = const Color(0xff900c3f);
  static Color primaryColor = const Color(0xffFE7317);
  static Color whiteColor = Colors.white;
  static Color blackColor = Colors.black;

  static Color bgColor = HexColor('#E1DEFF');
  static Color lightGreyColor = HexColor('#EEEEEE');

  static Color greenColor = HexColor('#1FAC08');
  static Color redColor = HexColor('#FF0000');

  static Color selectedNavBgColor = HexColor('#471187');
  static Color lightPurple = HexColor('#5E2F96').withOpacity(0.6);
  var txtPurpleColor = HexColor('#4C1391');
  var shadowColor = HexColor('#0D0D0D').withOpacity(0.1);
  var gridLabelColor = HexColor('#FE2D66').withOpacity(0.5);
  var pinkColor = HexColor('#FE2D66');
  static Color  lightBlackColor = Colors.black54;
}
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}