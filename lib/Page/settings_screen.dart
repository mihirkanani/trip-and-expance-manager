import 'dart:io';
import 'package:currency_picker/currency_picker.dart';
import 'package:expense_manager/Bloc/Bloc/settings_bloc.dart';
import 'package:expense_manager/Bloc/Event/settings_event.dart';
import 'package:expense_manager/Bloc/State/settings_state.dart';
import 'package:expense_manager/main.dart';

// import 'package:expense_manager/utils/RatingDialog.dart';
import 'package:expense_manager/utils/app_utils.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/language/app_translations.dart';
import 'package:expense_manager/utils/language/application.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:expense_manager/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsInitialState) {
          BlocProvider.of<SettingsBloc>(context).add(SettingsLoadingEvent(context));
          return Scaffold(
            body: Center(
              child: SpinKitDualRing(
                color: ColorConstant.primaryColor,
                size: 30,
                lineWidth: 3,
              ),
            ),
          );
        }
        if (state is SettingsDataLoaded) {
          return Scaffold(
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: Text(
                    "Version : 1.0.0",
                    style: TextStyleConstant.blackRegular14,
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Settings",
                    style: TextStyleConstant.blackBold16.copyWith(fontSize: 18),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showCurrencyName: true,
                      showCurrencyCode: true,
                      onSelect: (Currency currency) {
                        PreferenceUtils.setBool(key: isCurrencySelected, value: true);
                        PreferenceUtils.setString(key: selectedCurrency, value: currency.symbol);
                        context.read<SettingsBloc>().selectedCurrencyValue.value = currency.symbol;
                        print('Select currency: ${currency.name} ${currency.symbol} ${currency.flag}');
                      },
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black26,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: Row(
                        children: [
                          Icon(
                            Icons.paid,
                            color: ColorConstant.primaryColor,
                            size: 30,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(
                              "Currency",
                              style: TextStyleConstant.blackRegular16,
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: context.read<SettingsBloc>().selectedCurrencyValue,
                            builder: (BuildContext context, String counterValue, Widget? child) {
                              return Text(
                                "${context.read<SettingsBloc>().selectedCurrencyValue.value}",
                                style: TextStyleConstant.blackRegular16.copyWith(color: ColorConstant.primaryColor),
                              );
                            },
                          ),
                          SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {},
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black26,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: Row(
                        children: [
                          Icon(
                            Icons.privacy_tip,
                            color: ColorConstant.primaryColor,
                            size: 30,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(
                              "Privacy Policy",
                              style: TextStyleConstant.blackRegular16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // GestureDetector(
                //   onTap: () async {
                //     // await _checkAppReview();
                //     showModalBottomSheet(
                //       context: context,
                //       isScrollControlled: true,
                //       backgroundColor: Colors.transparent,
                //       isDismissible: true,
                //       enableDrag: false,
                //       builder: (context) {
                //         return Wrap(
                //           children: [
                //             RatingDialog(packageName: context.read<SettingsBloc>().packageName),
                //           ],
                //         );
                //       },
                //     );
                //   },
                //   child: Card(
                //     elevation: 5,
                //     shadowColor: Colors.black26,
                //     margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                //     child: Container(
                //       alignment: Alignment.center,
                //       padding: EdgeInsets.all(10),
                //       width: double.infinity,
                //       child: Row(
                //         children: [
                //           Icon(
                //             Icons.star_half_outlined,
                //             color: ColorConstant.primaryColor,
                //             size: 30,
                //           ),
                //           SizedBox(
                //             width: 20,
                //           ),
                //           Expanded(
                //             child: Text(
                //               "Add Your Rating ",
                //               style: TextStyleConstant.blackRegular16,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                GestureDetector(
                  onTap: () async {
                    if (Platform.isAndroid) {
                      print('https://play.google.com/store/apps/details?id=${context.read<SettingsBloc>().packageName}');
                      Share.share('https://play.google.com/store/apps/details?id=${context.read<SettingsBloc>().packageName}');
                    } else if (Platform.isIOS) {
                      Share.share('https://apps.apple.com/us/app/gallery-lockup/id1584133991');
                    }
                  },
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black26,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: Row(
                        children: [
                          Icon(
                            Icons.ios_share,
                            color: ColorConstant.primaryColor,
                            size: 30,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(
                              "Share with friends",
                              style: TextStyleConstant.blackRegular16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (Platform.isAndroid) {
                      print('https://play.google.com/store/apps/details?id=${context.read<SettingsBloc>().packageName}');
                      await launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=${context.read<SettingsBloc>().packageName}"));
                    } else if (Platform.isIOS) {}
                  },
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black26,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: Row(
                        children: [
                          Icon(
                            Icons.apps_outlined,
                            color: ColorConstant.primaryColor,
                            size: 30,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(
                              "Explore More Apps",
                              style: TextStyleConstant.blackRegular16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    showFancyCustomDialog(context);
                  },
                  child: Card(
                    elevation: 5,
                    shadowColor: Colors.black26,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: Row(
                        children: [
                          Icon(
                            Icons.language,
                            color: ColorConstant.primaryColor,
                            size: 30,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.read<SettingsBloc>().reminder == null
                                          ? AppTranslations.of(context)!.text("Select Language")
                                          : AppTranslations.of(context)!.text("Selected Language"),
                                      style: TextStyleConstant.blackRegular16,
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Visibility(
                                      visible: context.read<SettingsBloc>().reminder != null,
                                      child: Text(
                                        context.read<SettingsBloc>().reminder == null
                                            ? ""
                                            : AppTranslations.of(context)!.text("${context.read<SettingsBloc>().reminder}"),
                                        style: TextStyleConstant.blackRegular16,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.keyboard_arrow_down_outlined),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     showFancyCustomDialog(context);
                //   },
                //   child: Container(
                //     width: double.infinity,
                //     padding: EdgeInsets.only(
                //       bottom: 10, // Space between underline and text
                //     ),
                //     decoration: BoxDecoration(
                //       border: Border(
                //         bottom: BorderSide(
                //           color: Colors.grey,
                //           // Underline thickness
                //         ),
                //       ),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           context.read<SettingsBloc>().reminder == null
                //               ? AppTranslations.of(context)!.text("Select Language")
                //               : AppTranslations.of(context)!.text("${context.read<SettingsBloc>().reminder}"),
                //           style: TextStyleConstant.blackRegular14.copyWith(
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //         Icon(Icons.keyboard_arrow_down_outlined),
                //       ],
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   onTap: () async {
                //     await check().then(
                //       (internet) async {
                //         if (internet) {
                //           showDialog(
                //             barrierDismissible: false,
                //             context: context,
                //             builder: (context) {
                //               return WillPopScope(
                //                 onWillPop: () async => false,
                //                 child: Dialog(
                //                   insetPadding: EdgeInsets.all(0.2),
                //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                //                   child: Container(
                //                     decoration: BoxDecoration(
                //                       //color: Theme.of(context)overColor,
                //                       borderRadius: BorderRadius.circular(7),
                //                     ),
                //                     padding: EdgeInsets.all(15),
                //                     child: Column(
                //                       mainAxisSize: MainAxisSize.min,
                //                       children: [
                //                         SpinKitDualRing(
                //                           color: ColorConstant.primaryColor,
                //                           size: 40,
                //                           lineWidth: 3,
                //                         ),
                //                         SizedBox(
                //                           height: 10,
                //                         ),
                //                         Text(
                //                           "Exporting To Drive....",
                //                           style: TextStyleConstant.blackRegular14,
                //                         )
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               );
                //             },
                //           );
                //
                //           await dbHelper.exportDB();
                //           print("on tap  after called .....");
                //           Navigator.pop(context);
                //         } else {
                //           showToast("please check your internet connection");
                //         }
                //       },
                //     );
                //   },
                //   child: Card(
                //     elevation: 5,
                //     shadowColor: Colors.black26,
                //     margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                //     child: Container(
                //       alignment: Alignment.center,
                //       padding: EdgeInsets.all(10),
                //       width: double.infinity,
                //       child: Row(
                //         children: [
                //           Icon(
                //             Icons.add_to_drive,
                //             color: ColorConstant.primaryColor,
                //             size: 30,
                //           ),
                //           SizedBox(
                //             width: 20,
                //           ),
                //           Expanded(
                //             child: Text(
                //               "Export DataBase",
                //               style: TextStyleConstant.blackRegular16,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   onTap: () async {
                //     await check().then(
                //       (internet) async {
                //         if (internet) {
                //           showDialog(
                //             barrierDismissible: false,
                //             context: context,
                //             builder: (context) {
                //               return WillPopScope(
                //                 onWillPop: () async => false,
                //                 child: Dialog(
                //                   insetPadding: EdgeInsets.all(0.2),
                //                   shape: RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(15),
                //                   ),
                //                   child: Container(
                //                     decoration: BoxDecoration(
                //                       borderRadius: BorderRadius.circular(7),
                //                     ),
                //                     padding: EdgeInsets.all(15),
                //                     child: Column(
                //                       mainAxisSize: MainAxisSize.min,
                //                       children: [
                //                         SpinKitDualRing(
                //                           color: ColorConstant.primaryColor,
                //                           size: 40,
                //                           lineWidth: 3,
                //                         ),
                //                         SizedBox(
                //                           height: 10,
                //                         ),
                //                         Text(
                //                           "Importing From Drive....",
                //                           style: TextStyleConstant.blackRegular14,
                //                         )
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               );
                //             },
                //           );
                //           await dbHelper.loadDatabase(context);
                //           Navigator.pop(context);
                //         } else {
                //           showToast("please check your internet connection");
                //         }
                //       },
                //     );
                //   },
                //   child: Card(
                //     elevation: 5,
                //     shadowColor: Colors.black26,
                //     margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                //     child: Container(
                //       alignment: Alignment.center,
                //       padding: EdgeInsets.all(10),
                //       width: double.infinity,
                //       child: Row(
                //         children: [
                //           Icon(
                //             Icons.cloud_download_outlined,
                //             color: ColorConstant.primaryColor,
                //             size: 30,
                //           ),
                //           SizedBox(
                //             width: 20,
                //           ),
                //           Expanded(
                //             child: Text(
                //               "Import DataBase",
                //               style: TextStyleConstant.blackRegular16,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: SpinKitDualRing(
              color: ColorConstant.primaryColor,
              size: 30,
              lineWidth: 3,
            ),
          ),
        );
      },
    );
  }

  void showFancyCustomDialog(BuildContext context) {
    Dialog fancyDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: StatefulBuilder(
        builder: (context2, setState) {
          return Container(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    AppTranslations.of(context)!.text("Select Language"),
                    style: TextStyleConstant.blackBold16.copyWith(
                      color: ColorConstant.whiteColor,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context2, int index) {
                        return InkWell(
                          onTap: () {
                            context.read<SettingsBloc>().reminder = context.read<SettingsBloc>().languagesList[index];
                            PreferenceUtils.setString(key: "language", value: context.read<SettingsBloc>().languagesList[index]);
                            setState(() {
                              context.read<SettingsBloc>().selectedLocation = context.read<SettingsBloc>().languagesList[index];
                              application.onLocaleChanged!(
                                Locale(
                                  context.read<SettingsBloc>().languagesMap![context.read<SettingsBloc>().reminder],
                                ),
                              );
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppTranslations.of(context)!.text("${context.read<SettingsBloc>().languagesList[index]}"),
                            textAlign: TextAlign.center,
                            style: TextStyleConstant.blackRegular14,
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => Divider(),
                      itemCount: context.read<SettingsBloc>().languagesList.length,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => fancyDialog);
  }
}
