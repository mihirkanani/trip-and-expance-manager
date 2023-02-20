import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:expense_manager/Bloc/Bloc/splash_bloc.dart';
import 'package:expense_manager/Bloc/Event/splash_event.dart';
import 'package:expense_manager/Bloc/State/splash_state.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/image_utils.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/text_style_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: Center(
        child: BlocBuilder<SplashBloc, SplashState>(
          builder: (context, state) {
            if(state is TimerInitial){
              context.read<SplashBloc>().add(TimerStarted(context));
            }
            return Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ShakeAnimatedWidget(
                    enabled: true,
                    duration: const Duration(milliseconds: 10000),
                    shakeAngle: Rotation.deg(
                      z: 200,
                    ),
                    curve: Curves.linear,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2.8,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            ImageConstant.logoImage,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Expense Book',
                        textStyle: TextStyleConstant.colorizeTextStyle,
                        colors: ColorConstant.colorizeColors,
                      ),
                    ],
                    isRepeatingAnimation: true,
                    onTap: () {
                      if (kDebugMode) {
                        print("Tap Event");
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
