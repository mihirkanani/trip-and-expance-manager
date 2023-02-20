import 'package:expense_manager/Bloc/Bloc/info_bloc.dart';
import 'package:expense_manager/Bloc/Bloc/language_selection_bloc.dart';
import 'package:expense_manager/Bloc/Event/language_selection_event.dart';
import 'package:expense_manager/Bloc/State/language_selection_state.dart';
import 'package:expense_manager/Page/info_screen.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/language/app_translations.dart';
import 'package:expense_manager/utils/language/application.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

class LanguageSelectionView extends StatelessWidget {
  const LanguageSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageSelectionBloc, LanguageSelectionState>(
      builder: (context, state) {
        if (state is LanguageSelectionInitialState) {
          BlocProvider.of<LanguageSelectionBloc>(context).add(LanguageSelectionLoadEvent(context));

          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.chevron_left_outlined,
                  size: 28,
                ),
              ),
              title: Text(
                AppTranslations.of(context)!.text("Language Selection"),
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
            body: Center(
              child: SpinKitDualRing(
                color: ColorConstant.primaryColor,
                size: 30,
                lineWidth: 3,
              ),
            ),
          );
        }
        if (state is LanguageSelectionDataLoaded) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                AppTranslations.of(context)!.text("Language Selection"),
                style: TextStyleConstant.blackBold16.copyWith(
                  fontSize: 16,
                  color: ColorConstant.whiteColor,
                ),
              ),
            ),
            body: Container(
              padding: EdgeInsets.only(top: 100),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.of(context)!.text("_SELECT_YOUR_PREFERRED_LANGUAGE?_"),
                      style: TextStyleConstant.blackRegular16.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 40),
                    Center(
                      child: Lottie.asset(
                        '${ImageConstant.languageSelection}',
                        repeat: true,
                        width: 200,
                        height: 200,
                      ),
                    ),
                    SizedBox(height: 40),
                    Expanded(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    context.read<LanguageSelectionBloc>().reminder = "English";
                                    PreferenceUtils.setString(key: "language", value: "English");
                                    print("English");
                                    context.read<LanguageSelectionBloc>().selectedLocation = "English";
                                    application.onLocaleChanged!(
                                      Locale(
                                        context.read<LanguageSelectionBloc>().languagesMap[context.read<LanguageSelectionBloc>().reminder],
                                      ),
                                    );
                                    PreferenceUtils.setBool(key: "english", value: true);
                                    PreferenceUtils.setBool(key: "german", value: false);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider(
                                          create: (_) => InfoBloc(),
                                          child: const InfoView(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(0.0),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        border: PreferenceUtils.getBool(key: "english") == false
                                            ? Border.all(color: Colors.transparent, width: 2)
                                            : Border.all(color: Colors.blueAccent, width: 2),
                                        gradient: LinearGradient(
                                          colors: [Color(0xFFFE7317), Color(0xFFFFAA75)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "English",
                                          textAlign: TextAlign.center,
                                          style: TextStyleConstant.blackRegular16.copyWith(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: PreferenceUtils.getBool(key: "english") == false ? FontWeight.w400 : FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    context.read<LanguageSelectionBloc>().reminder = "German";
                                    PreferenceUtils.setString(key: "language", value: "German");
                                    print("German");
                                    context.read<LanguageSelectionBloc>().selectedLocation = "German";
                                    application.onLocaleChanged!(
                                      Locale(
                                        context.read<LanguageSelectionBloc>().languagesMap[context.read<LanguageSelectionBloc>().reminder],
                                      ),
                                    );
                                    PreferenceUtils.setBool(key: "english", value: false);
                                    PreferenceUtils.setBool(key: "german", value: true);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider(
                                          create: (_) => InfoBloc(),
                                          child: const InfoView(),
                                        ),
                                      ),
                                    );
                                    // Navigator.pushNamed(context, '/introduction');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(0.0),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        border: PreferenceUtils.getBool(key: "german") == false
                                            ? Border.all(color: Colors.transparent, width: 2)
                                            : Border.all(color: Colors.blueAccent, width: 2),
                                        gradient: LinearGradient(
                                          colors: [Color(0xFFFFAA75), Color(0xFFFE7317)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "German",
                                          textAlign: TextAlign.center,
                                          style: TextStyleConstant.blackRegular16.copyWith(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: PreferenceUtils.getBool(key: "english") == false ? FontWeight.w400 : FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.chevron_left_outlined,
                size: 28,
              ),
            ),
            title: Text(
              "Language Selection",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
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
}
