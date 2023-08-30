import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/BouncingWidget.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';
import 'package:image_contest_flutter_app/screens/Dashboard/dashboard_screen.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/util/form_validator.dart';

import '../../application_localizations.dart';

class SignUpScreen extends StatefulWidget {
  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsets.only(top: 40, bottom: 50),
                  child: InkWell(
                      onTap: () => NavigationService.instance.goBack(),
                      child: Icon(Icons.arrow_back,
                          color: ColorsUtil.appThemeColor))),
              Row(children: [
                Icon(Icons.photo_camera,
                    color: ColorsUtil.appThemeColor, size: 28),
                SizedBox(width: 8),
                Text(
                    ApplicationLocalizations.of(context)
                        .translate('signUp_text'),
                    style: TextStyle(
                      color: ColorsUtil.appThemeColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ))
              ]),
              Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 20),
                  child: addTextField(
                      name,
                      ApplicationLocalizations.of(context)
                          .translate('name_text'))),
              addTextField(email,
                  ApplicationLocalizations.of(context).translate('email_text')),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 25),
                  child: addTextField(
                      password,
                      ApplicationLocalizations.of(context)
                          .translate('password_text'))),
              addSignUpBtn(),
            ]),
          )),
    ));
  }

  addTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      keyboardType: hintText ==
              ApplicationLocalizations.of(context).translate('email_text')
          ? TextInputType.emailAddress
          : TextInputType.text,
      textAlign: TextAlign.left,
      style: TextStyle(color: Colors.black),
      maxLength: 40,
      obscureText: hintText ==
              ApplicationLocalizations.of(context).translate('password_text')
          ? true
          : false,
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
          hintText: hintText),
    );
  }

  addSignUpBtn() {
    return BouncingWidget(
      duration: Duration(milliseconds: 100),
      scaleFactor: 1.5,
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        validateRegistration();
      },
      child: Container(
          height: 40,
          color: ColorsUtil.appThemeColor,
          child: Center(
              child: Text(
            ApplicationLocalizations.of(context).translate('signUp_text'),
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ))),
    );
  }

  void validateRegistration() {
    if (FormValidator().isTextEmpty(name.text)) {
      AppUtil.showToast(
          ApplicationLocalizations.of(context).translate('enterName_text'),
          context);
    } else if (FormValidator().isTextEmpty(email.text)) {
      AppUtil.showToast(
          ApplicationLocalizations.of(context).translate('enterEmail_text'),
          context);
    } else if (FormValidator().isNotValidEmail(email.text)) {
      AppUtil.showToast(
          ApplicationLocalizations.of(context).translate('validEmail_text'),
          context);
    } else if (FormValidator().isTextEmpty(password.text)) {
      AppUtil.showToast(
          ApplicationLocalizations.of(context).translate('enterPassword_text'),
          context);
    } else {
      AppUtil.checkInternet().then((value) {
        if (value) {
          AppUtil.showLoader(context);
          ApiController()
              .registerUserApi(name.text, email.text, password.text)
              .then((response) async {
            Navigator.of(context).pop();
            if (response.success) {
              SharedPrefs().setUserLoggedIn(true);
              SharedPrefs().saveUser(response.user!);
              SharedPrefs().setAuthorizationKey(response.authKey!);

              NavigationService.instance.navigateToReplacementWithScale(
                  ScaleRoute(page: DashboardScreen()));
            } else {
              AppUtil.showToast(response.message, context);
            }
          });
        } else {
          AppUtil.showToast(
              ApplicationLocalizations.of(context).translate('noInternet_text'),
              context);
        }
      });
    }
  }
}
