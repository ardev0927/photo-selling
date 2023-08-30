import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:image_contest_flutter_app/screens/LoginSignUp/tutorial_screen.dart';
import 'package:image_contest_flutter_app/util/constant_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'util/shared_prefs.dart';
import 'screens/Dashboard/dashboard_screen.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'application_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConstantUtil.isLoggedIn = await SharedPrefs().isUserLoggedIn();
  ConstantUtil.selectedLanguage = await SharedPrefs().getLanguageCode();
  if (Platform.isAndroid) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  runApp(Phoenix(child: PhotoSellApp()));
}

class PhotoSellApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigationKey,
        home: ConstantUtil.isLoggedIn ? DashboardScreen() : TutorialScreen(),
        // List all of the app's supported locales here
        supportedLocales: [
          Locale('en', ''),
          Locale('ar', 'AE'),
        ],

        localizationsDelegates: [
          ApplicationLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocaleLanguage in supportedLocales) {
            String languageCode = ConstantUtil.selectedLanguage != null
                ? ConstantUtil.selectedLanguage!
                : locale?.languageCode ?? 'en';
            if (supportedLocaleLanguage.languageCode == languageCode) {
              return supportedLocaleLanguage;
            }
          }
          return supportedLocales.first;
        },
      );
    });
  }
}
