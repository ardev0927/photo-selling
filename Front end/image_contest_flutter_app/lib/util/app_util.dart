import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import '../application_localizations.dart';
import 'colors_util.dart';
import 'constant_util.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppUtil {
  static Widget showToast(String message, BuildContext context) {
    return Flushbar(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(8),
      backgroundGradient: LinearGradient(
        colors: [
          ColorsUtil.appThemeColor,
          ColorsUtil.appThemeColor.withOpacity(0.7)
        ],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      // All of the previous Flushbars could be dismissed by swiping down
      // now we want to swipe to the sides
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      // The default curve is Curves.easeOut
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      title: ConstantUtil.projectName,
      message: message,
      duration: Duration(milliseconds: 750),
    )..show(context);
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static void showLoader(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
                backgroundColor: Colors.black12,
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorsUtil.appThemeColor)),
          );
        });
  }

  static Widget addProgressIndicator(BuildContext context) {
    return Center(
        child: SizedBox(
      width: 15,
      height: 15,
      child: CircularProgressIndicator(
          strokeWidth: 2.0,
          backgroundColor: Colors.black12,
          valueColor: AlwaysStoppedAnimation<Color>(ColorsUtil.appThemeColor)),
    ));
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

  static Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  static Future<File> findPath(String imageUrl) async {
    final cache = DefaultCacheManager();
    final file = await cache.getSingleFile(imageUrl);
    return file;
  }

  static void logoutAction(BuildContext cxt, VoidCallback handler) {
    showDialog(
      barrierDismissible: false,
      context: cxt,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(ConstantUtil.projectName,
              style: TextStyle(color: ColorsUtil.appThemeColor)),
          content: Text(ApplicationLocalizations.of(context)
              .translate('logoutMessage_text')),
          actions: [
            TextButton(
              child: Text(
                  ApplicationLocalizations.of(context)
                      .translate('yes_text'),
                  style: TextStyle(color: ColorsUtil.appThemeColor)),
              onPressed: () {
                Navigator.of(context).pop();
                handler();
              },
            ),
            TextButton(
              child: Text(
                  ApplicationLocalizations.of(context)
                      .translate('no_text'),
                  style: TextStyle(color: Colors.black87)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
