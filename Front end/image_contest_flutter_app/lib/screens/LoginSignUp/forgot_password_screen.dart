import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/BouncingWidget.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/form_validator.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';

import '../../application_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordScreen> {
  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.only(top: 40, bottom: 50),
              child: InkWell(
                  onTap: () => NavigationService.instance.goBack(),
                  child:
                      Icon(Icons.arrow_back, color: ColorsUtil.appThemeColor))),
          Row(children: [
            Icon(Icons.photo_camera, color: ColorsUtil.appThemeColor, size: 28),
            SizedBox(width: 8),
            Text(ApplicationLocalizations.of(context).translate('forgotP_text'),
                style: TextStyle(
                  color: ColorsUtil.appThemeColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ))
          ]),
          Padding(
              padding: EdgeInsets.only(top: 30, bottom: 25),
              child: addTextField()),
          addSubmitBtn(),
        ]),
      ),
    ));
  }

  addTextField() {
    return TextField(
      controller: email,
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.left,
      style: TextStyle(color: Colors.black),
      maxLength: 40,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(left: 10.0, right: 10),
          // isDense: true,
          counterText: "",
          hintText: ApplicationLocalizations.of(context).translate('email_text')),
    );
  }

  addSubmitBtn() {
    return BouncingWidget(
      duration: Duration(milliseconds: 100),
      scaleFactor: 1.5,
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        callForgotPasswordApi();
      },
      child: Container(
          height: 40,
          color: ColorsUtil.appThemeColor,
          child: Center(
              child: Text(
                ApplicationLocalizations.of(context).translate('submit_text'),
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ))),
    );
  }

  void callForgotPasswordApi() {
    if (FormValidator().isTextEmpty(email.text)) {
      AppUtil.showToast(
          ApplicationLocalizations.of(context).translate('enterEmail_text'),
          context);
    } else if (FormValidator().isNotValidEmail(email.text)) {
      AppUtil.showToast(
          ApplicationLocalizations.of(context).translate('validEmail_text'),
          context);
    } else {
      AppUtil.checkInternet().then((value) {
        if (value) {
          AppUtil.showLoader(context);
          ApiController().forgotPasswordApi(email.text).then((response) async {
            Navigator.of(context).pop();
            AppUtil.showToast(response.message, context);
            if (response.success) {
              NavigationService.instance.goBack();
            }
          });
        } else {
          AppUtil.showToast(ApplicationLocalizations.of(context).translate('noInternet_text'), context);
        }
      });
    }
  }
}
