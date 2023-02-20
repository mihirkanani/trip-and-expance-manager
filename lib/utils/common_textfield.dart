import 'package:cr_calendar/cr_calendar.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'app_utils.dart';

class CommonTextfield extends StatelessWidget {
  const CommonTextfield({
    Key? key,
    this.labelText,
    required this.controller,
    required this.hintText,
    this.textInput = TextInputType.text,
    this.isSecure = false,
    this.maxLength,
    this.suffixWidget,
    // this.focus,
    this.emptyValidation = true,

  }) : super(key: key);

  final String? labelText;
  final TextEditingController controller;
  final TextInputType textInput;
  final String hintText;
  final int? maxLength;
  final bool isSecure;
  final bool emptyValidation;

  // final FocusNode focus;
  final Widget? suffixWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(labelText, style: blackRegular14),
          // SizedBox(
          //   height: 10.h,
          // ),
          TextFormField(
            controller: controller,
            keyboardType: textInput,
            textInputAction: TextInputAction.done,
            inputFormatters: textInput == TextInputType.number ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly] : null,
            // cursorColor: primaryColor,
            maxLength: maxLength,
            // focusNode: focus,
            obscureText: isSecure,
            textAlignVertical: TextAlignVertical.bottom,
            style: TextStyleConstant.blackRegular16,
            decoration: InputDecoration(
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: suffixWidget,
                ),
                filled: false,
                fillColor: Theme.of(context).focusColor,
                suffixIconConstraints: BoxConstraints(maxHeight: 15),
                counterText: "",
                hintText: hintText,
                hintStyle: TextStyleConstant.hintTextStyle,
                contentPadding: EdgeInsets.only(bottom: 11, top: 12, left: 15),
                isDense: true,
                border: InputBorder.none
                /*focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide(color: Theme.of(context).hintColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide(color: Theme.of(context).hintColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide(color: Theme.of(context).hintColor),
              ),*/
                ),
          ),
        ],
      ),
    );
  }
}

class CommonTextfieldRectangle extends StatelessWidget {
  const CommonTextfieldRectangle({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.hintText,
    this.textInput = TextInputType.text,
    this.isSecure = false,
    this.isDisabled = false,
    this.isDigitsOnly = false,
    required this.maxLength,
    required this.suffixWidget,
    required this.focus,
    required this.validation,
    this.emptyValidation = true,
    required this.nextFocus,
    required this.onChange,
    required this.maxLine,
  }) : super(key: key);

  final String labelText;
  final TextEditingController controller;
  final TextInputType textInput;
  final String hintText;
  final int maxLength;
  final bool isSecure;
  final bool isDisabled;
  final bool isDigitsOnly;
  final bool emptyValidation;
  final FocusNode focus;
  final Widget suffixWidget;
  final Function validation;
  final Function nextFocus;
  final Function onChange;
  final int maxLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(labelText, style: blackRegular14),
          // SizedBox(
          //   height: 10.h,
          // ),
          TextFormField(
            controller: controller,
            keyboardType: textInput,
            // inputFormatters: isDigitsOnly ? [WhitelistingTextInputFormatter.digitsOnly]: null,
            inputFormatters: isDigitsOnly
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      try {
                        final text = newValue.text;
                        if (text.isNotEmpty) double.parse(text);
                        return newValue;
                      } catch (e) {}
                      return oldValue;
                    }),
                  ]
                : null,
            // cursorColor: primaryColor,
            maxLength: maxLength,
            maxLines: maxLine,
            // focusNode: focus,
            obscureText: isSecure,
            enabled: !isDisabled,
            textAlignVertical: TextAlignVertical.bottom,
            style: TextStyleConstant.blackRegular16,
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: EdgeInsets.only(
                  right: 5,
                ),
                child: suffixWidget,
              ),
              filled: true,
              fillColor: Theme.of(context).focusColor,
              suffixIconConstraints: BoxConstraints(maxHeight: 15),
              counterText: "",
              hintText: hintText,
              hintStyle: TextStyleConstant.hintTextStyle,
              contentPadding: EdgeInsets.only(bottom: 11, top: 12, left: 15),
              isDense: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Theme.of(context).hintColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Theme.of(context).hintColor),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Theme.of(context).hintColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Theme.of(context).hintColor),
              ),
            ),
            validator: emptyValidation
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$hintText Required';
                    }
                    return null;
                  }
                : validation(),
            onEditingComplete: nextFocus(),
            onChanged: onChange(),
          ),
        ],
      ),
    );
  }
}

/*class CommonMobilefield extends StatelessWidget {
  const CommonMobilefield({
    Key key,
    @required this.labelText,
    @required this.controller,
    @required this.hintText,
    this.textInput = TextInputType.text,
    this.isSecure = false,
    this.autofocus = false,
    this.maxLength,
    this.focus,
    this.suffixWidget,
    this.nextFocus,
    // this.validation,
    // this.emptyValidation,
  }) : super(key: key);

  final String labelText;
  final TextEditingController controller;
  final TextInputType textInput;
  final String hintText;
  final int maxLength;
  final FocusNode focus;
  final bool isSecure;
  final bool autofocus;
  // final bool emptyValidation;
  final Widget suffixWidget;
  final Function nextFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText, style: primaryBold18),
          SizedBox(
            height: 10.h,
          ),
          TextFormField(
            autofocus: autofocus,
            controller: controller,
            keyboardType: textInput,
            cursorColor: primaryColor,
            maxLength: maxLength,
            obscureText: isSecure,
            focusNode: focus,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 10, top: 0),
                child: suffixWidget,
              ),
              suffixIconConstraints: BoxConstraints(maxHeight: 10.h),
              counterText: "",
              hintText: hintText,
              hintStyle: TextStyle(color: primaryColor),
              contentPadding:
                  EdgeInsets.only(bottom: 11.w, top: 12.w, left: 15.w),
              isDense: true,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide(color: primaryColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide(color: primaryColor)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide(color: primaryColor)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Field can\'t be empty';
              } else if (value.length < 10) {
                return 'Please enter valid number';
              }
              return null;
            },
            onEditingComplete: nextFocus,
          ),
        ],
      ),
    );
  }
}*/

class UnderlineTextfield extends StatelessWidget {
  UnderlineTextfield({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.hintText,
    this.textInput = TextInputType.text,
    this.isSecure = false,
    required this.maxLength,
    required this.suffixWidget,
    required this.focus,
    required this.validation,
    this.emptyValidation = true,
    required this.nextFocus,
    this.cursorcolor = Colors.black,
    this.textstyle,
    this.hintstyle,
    this.borderColor = Colors.black,
  }) : super(key: key);

  final String labelText;
  final TextEditingController controller;
  final TextInputType textInput;
  final String hintText;
  final int maxLength;
  final bool isSecure;
  final bool emptyValidation;
  final FocusNode focus;
  final Widget suffixWidget;
  final Function validation;
  final Function nextFocus;
  var textstyle;
  var hintstyle;
  var cursorcolor;
  var borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(labelText, style: blackRegular14),
          // SizedBox(
          //   height: 10.h,
          // ),
          TextFormField(
            controller: controller,
            keyboardType: textInput,
            cursorColor: cursorcolor,
            maxLength: maxLength,
            focusNode: focus,
            obscureText: isSecure,
            textAlignVertical: TextAlignVertical.bottom,
            style: textstyle,
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                ),
                child: suffixWidget,
              ),
              // filled: true,
              // fillColor: Theme.of(context).focusColor,
              suffixIconConstraints: BoxConstraints(maxHeight: 15),
              counterText: "",
              hintText: hintText,
              hintStyle: hintstyle ?? TextStyleConstant.hintTextStyle,
              contentPadding: EdgeInsets.only(bottom: 5, top: 12, left: 2),
              isDense: true,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              /* enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide(color: Theme.of(context).hintColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide(color: Theme.of(context).hintColor),
              ), */
            ),
            validator: emptyValidation
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$hintText Required';
                    }
                    return null;
                  }
                : validation(),
            onEditingComplete: nextFocus(),
          ),
        ],
      ),
    );
  }
}
