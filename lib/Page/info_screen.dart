import 'package:expense_manager/Bloc/Bloc/info_bloc.dart';
import 'package:expense_manager/Bloc/Event/info_event.dart';
import 'package:expense_manager/Bloc/State/info_state.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/language/app_translations.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';

class InfoView extends StatelessWidget {
  const InfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoBloc, InfoState>(
      builder: (context, state) {
        PageDecoration pageDecoration = PageDecoration(
          titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          bodyTextStyle: TextStyleConstant.blackRegular14,
          footerPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          pageColor: Colors.white,
          imagePadding: const EdgeInsets.symmetric(horizontal: 50),
          imageFlex: 2,
        );

        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: ColorConstant.whiteColor),
            title: Text(
              AppTranslations.of(context)!.text("Introduction"),
              style: TextStyleConstant.blackBold16.copyWith(
                fontSize: 16,
                color: ColorConstant.whiteColor,
              ),
            ),
          ),
          body: IntroductionScreen(
            key: context.read<InfoBloc>().introKey,
            globalBackgroundColor: Colors.white,
            pages: [
              PageViewModel(
                title: AppTranslations.of(context)!.text("_TRACK_YOUR_EXPANSES_"),
                body: AppTranslations.of(context)!.text("_TRACK_YOUR_EXPANSES_SUBTITLE_"),
                image: _buildImage(ImageConstant.introImage1),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: AppTranslations.of(context)!.text("_SET_YOUR_BUDGET_"),
                body: AppTranslations.of(context)!.text("_SET_YOUR_BUDGET_SUBTITLE_"),
                image: _buildImage(ImageConstant.introImage2),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: AppTranslations.of(context)!.text("_MANAGE_YOUR_TRIP_EXPENSES_"),
                body: AppTranslations.of(context)!.text("_MANAGE_YOUR_TRIP_EXPENSES_SUBTITLE_"),
                image: _buildImage(ImageConstant.introImage3),
                decoration: pageDecoration,
              ),
            ],
            onDone: () => BlocProvider.of<InfoBloc>(context).add(InfoDoneEvent(context)),
            showSkipButton: true,
            skip: Text(
              AppTranslations.of(context)!.text("_SKIP_"),
              style: TextStyle(color: ColorConstant.primaryColor),
            ),
            next: Icon(Icons.arrow_forward, color: ColorConstant.primaryColor),
            done: Text(
              AppTranslations.of(context)!.text("_DONE_"),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ColorConstant.primaryColor,
              ),
            ),
            curve: Curves.fastLinearToSlowEaseIn,
            controlsMargin: const EdgeInsets.all(16),
            controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            dotsDecorator: DotsDecorator(
              size: const Size(10.0, 10.0),
              color: const Color(0xFFBDBDBD),
              activeSize: const Size(22.0, 10.0),
              activeColor: ColorConstant.primaryColor,
              activeShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
            dotsContainerDecorator: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String assetName) {
    return Image.asset(
      assetName,
    );
  }
}
