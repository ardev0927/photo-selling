import 'dart:io';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';
import 'package:image_contest_flutter_app/screens/Dashboard/dashboard_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/animatedWidgets/BouncingWidget.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/screens/LoginSignUp/forgot_password_screen.dart';
import 'package:image_contest_flutter_app/screens/LoginSignUp/sign_up_screen.dart';
import 'package:image_contest_flutter_app/util/form_validator.dart';
import '../../application_localizations.dart';
import 'forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
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
                        .translate('welcome_text'),
                    style: TextStyle(
                      color: ColorsUtil.appThemeColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ))
              ]),
              Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 15),
                  child: addTextField(
                      email,
                      ApplicationLocalizations.of(context)
                          .translate('email_text'))),
              addTextField(
                  password,
                  ApplicationLocalizations.of(context)
                      .translate('password_text')),
              Padding(
                  padding: EdgeInsets.only(top: 25, bottom: 15),
                  child: addLoginBtn()),
              addForgotPasswordBtn(),
              addSocialLoginUI(),
              addSignUpBtn()
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
              ApplicationLocalizations.of(context).translate('email_text')
          ? false
          : true,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(left: 10, right: 10),
          counterText: "",
          hintText: hintText),
    );
  }

  addLoginBtn() {
    return BouncingWidget(
      duration: Duration(milliseconds: 100),
      scaleFactor: 1.5,
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        validateLogin();
      },
      child: Container(
          height: 40,
          color: ColorsUtil.appThemeColor,
          child: Center(
              child: Text(
            ApplicationLocalizations.of(context).translate('login_text'),
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ))),
    );
  }

  addForgotPasswordBtn() {
    return BouncingWidget(
      duration: Duration(milliseconds: 100),
      scaleFactor: 1.5,
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        NavigationService.instance
            .navigateToRouteWithScale(ScaleRoute(page: ForgotPasswordScreen()));
      },
      child: Text(
        ApplicationLocalizations.of(context).translate('forgotPQ_text'),
        style: TextStyle(
            color: ColorsUtil.appThemeColor,
            fontSize: 15,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  addSocialLoginUI() {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              icon: Image.asset('assets/gmailicon.png'),
              onPressed: () => signInWithGoogle()),
          IconButton(
              icon: Image.asset('assets/fbicon.png'),
              onPressed: () => fbSignInAction()),
          Platform.isIOS
              ? IconButton(
                  icon: Image.asset('assets/appleSignIn.png'),
                  onPressed: () => appleSignInAction())
              : Container(),
        ]));
  }

  addSignUpBtn() {
    return Expanded(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom > 0 ? 30 : 10),
          child: RichText(
            text: new TextSpan(
              children: [
                TextSpan(
                  text: ApplicationLocalizations.of(context)
                      .translate('noAccount_text'),
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: ApplicationLocalizations.of(context)
                      .translate('signUp_text'),
                  style: new TextStyle(color: ColorsUtil.appThemeColor),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      NavigationService.instance.navigateToRouteWithScale(
                          ScaleRoute(page: SignUpScreen()));
                    },
                ),
              ],
            ),
          )),
    ));
  }

  void validateLogin() {
    if (FormValidator().isTextEmpty(email.text)) {
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
              .loginApi(email.text, password.text)
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

  void signInWithGoogle() async {
    FocusScope.of(context).requestFocus(FocusNode());
    GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

    GoogleSignInAuthentication? googleSignInAuthentication =
    await googleSignInAccount?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication?.accessToken,
      idToken: googleSignInAuthentication?.idToken,
    );

    UserCredential authResult = await _auth.signInWithCredential(credential);
    String name = authResult.user?.displayName ?? '';
    String socialId = authResult.user?.uid ?? '';
    String email = authResult.user?.email ?? '';

    if (socialId != null) {
      AppUtil.checkInternet().then((value) {
        if (value) {
          AppUtil.showLoader(context);
          ApiController()
              .socialLoginApi(name, 'google', socialId, email)
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
    } else {
      AppUtil.showToast(
          ApplicationLocalizations.of(context).translate('invalidLogin_text'),
          context);
    }
  }

  void fbSignInAction() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final facebookLogin = new FacebookLogin();
    facebookLogin.logOut();
    final result = await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (result.status) {
      case FacebookLoginStatus.success:
        // Get profile data
        final profile = await facebookLogin.getUserProfile();
        String name = profile?.name ?? '';
        String socialId = profile?.userId ?? '';
        final email = await facebookLogin.getUserEmail();

        if (socialId != null) {
          AppUtil.checkInternet().then((value) {
            if (value) {
              AppUtil.showLoader(context);
              ApiController()
                  .socialLoginApi(name, 'fb', socialId, email!)
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
                  ApplicationLocalizations.of(context)
                      .translate('noInternet_text'),
                  context);
            }
          });
        } else {
          AppUtil.showToast(
              ApplicationLocalizations.of(context)
                  .translate('invalidLogin_text'),
              context);
        }

        break;
      case FacebookLoginStatus.cancel:
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('cancelled_text'),
            context);
        break;
      case FacebookLoginStatus.error:
        AppUtil.showToast(result.error!.localizedDescription!, context);
        break;
    }
  }

  void appleSignInAction() async {
    FocusScope.of(context).requestFocus(FocusNode());
    // final AuthorizationResult result = await AppleSignIn.performRequests([
    //   AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    // ]);
    //
    // switch (result.status) {
    //   case AuthorizationStatus.authorized:
    //     print(result.credential.email);
    //     print(result.credential.user);
    //     dynamic param =
    //     result.credential.email == null || result.credential.email.isEmpty
    //         ? <String, Object>{'email': "", 'id': result.credential.user}
    //         : <String, Object>{
    //       'email': result.credential.email,
    //       'id': result.credential.user
    //     };
    //     //API Call
    //
    //     break;
    //
    //   case AuthorizationStatus.error:
    //     AlertUtil.internal().showAlert(
    //         context,
    //         ConstantsUtil.projectName,
    //         "Sign in failed: ${result.error.localizedDescription}",
    //         CustomAppAlertItem('Ok', () {}),
    //         null);
    //
    //     break;
    //
    //   case AuthorizationStatus.cancelled:
    //     print('User cancelled');
    //     break;
    // }
  }
}
