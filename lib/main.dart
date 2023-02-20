import 'package:expense_manager/Services/sqflite.dart';
import 'package:expense_manager/bloc_observer.dart';
import 'package:expense_manager/utils/color_constant.dart';
import 'package:expense_manager/utils/language/app_translations_delegate.dart';
import 'package:expense_manager/utils/language/application.dart';
import 'package:expense_manager/utils/pref_util.dart';
import 'package:expense_manager/utils/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final dbHelper = DatabaseHelper.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  await PreferenceUtils.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  static final List<String> languagesList = application.supportedLanguages;
  static final List<String> languageCodesList = application.supportedLanguagesCodes;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTranslationsDelegate? _newLocaleDelegate;

  final Map<dynamic, dynamic> languagesMap = {
    MyApp.languagesList[0]: MyApp.languageCodesList[0],
    MyApp.languagesList[1]: MyApp.languageCodesList[1],
  };

  @override
  void initState() {
    super.initState();
    _newLocaleDelegate = PreferenceUtils.getString(key: "language") == ""
        ? AppTranslationsDelegate(newLocale: null)
        : AppTranslationsDelegate(
            newLocale: Locale(
              languagesMap[PreferenceUtils.getString(key: "language")],
            ),
          );
    application.onLocaleChanged = onLocaleChange;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trip & Expense Manager',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: ColorConstant.primaryColor,
        primarySwatch: Colors.orange,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      onGenerateRoute: Routes.onGenerateRoute,
      initialRoute: "/splash",
      localizationsDelegates: [
        _newLocaleDelegate!,
        //provides localised strings
        GlobalMaterialLocalizations.delegate,
        //provides RTL support
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en", ""),
        const Locale("de", ""),
      ],
    );
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }
}