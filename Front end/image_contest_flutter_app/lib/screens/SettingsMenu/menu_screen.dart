import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/screens/LoginSignUp/tutorial_screen.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/select_language_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/constant_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:share/share.dart';

import '../../application_localizations.dart';
import 'edit_profile_screen.dart';
import 'packages_screen.dart';
import 'payment_withdrawal_screen.dart';
import 'payment_settings_screen.dart';
import 'profile_screen.dart';
import 'web_view_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  UserModel? model;
  int coin = 0;

  @override
  void initState() {
    super.initState();
    SharedPrefs().getUser().then((value) {
      setState(() {
        model = value;
        coin = value.coins ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0.0,
            title: Center(
                child: Text(
                  ApplicationLocalizations.of(context).translate('menu_text'),
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ))),
        body: ListView(
          children: [
            addProfileView(() async {
              var _ = await NavigationService.instance
                  .navigateToRouteWithScale(ScaleRoute(
                page: ProfileScreen(model!.id),
              ));
            }),
            addTileEvent(Icons.monetization_on_outlined,
                '${ApplicationLocalizations.of(context).translate('coins_text')} ($coin)',
                    () {
                  NavigationService.instance.navigateToRouteWithScale(
                      ScaleRoute(page: PackagesScreen((newCoins) {
                        setState(() {
                          coin += newCoins;
                        });
                      })));
                }),
            addTileEvent(
                Icons.watch_later_outlined,
                ApplicationLocalizations.of(context)
                    .translate('paymentSettings_text'), () {
              NavigationService.instance.navigateToRouteWithScale(
                  ScaleRoute(page: PaymentSettingsScreen()));
            }),
            addTileEvent(
                Icons.money,
                ApplicationLocalizations.of(context)
                    .translate('paymentWithdrawal_text'), () {
              NavigationService.instance.navigateToRouteWithScale(
                  ScaleRoute(page: PaymentWithdrawalScreen()));
            }),
            addTileEvent(Icons.policy_outlined,
                ApplicationLocalizations.of(context).translate('policy_text'),
                    () {
                  NavigationService.instance.navigateToRouteWithScale(ScaleRoute(
                      page: WebViewScreen(
                          ApplicationLocalizations.of(context)
                              .translate('policy_text'),
                          ConstantUtil.privacyPolicyUrl)));
                }),
            addTileEvent(Icons.article_outlined,
                ApplicationLocalizations.of(context).translate('terms_text'),
                    () {
                  NavigationService.instance.navigateToRouteWithScale(ScaleRoute(
                      page: WebViewScreen(
                          ApplicationLocalizations.of(context)
                              .translate('terms_text'),
                          ConstantUtil.termsUrl)));
                }),
            addTileEvent(Icons.contact_mail_outlined,
                ApplicationLocalizations.of(context).translate('aboutUs_text'),
                    () {
                  NavigationService.instance.navigateToRouteWithScale(ScaleRoute(
                      page: WebViewScreen(
                          ApplicationLocalizations.of(context)
                              .translate('aboutUs_text'),
                          ConstantUtil.aboutUs)));
                }),
            //addTileEvent(Icons.restore, 'Restore purchase', () {}),
            addTileEvent(Icons.language,
                ApplicationLocalizations.of(context).translate('selLang_text'),
                    () {
                  NavigationService.instance.navigateToRouteWithScale(
                      ScaleRoute(page: SelectLanguageScreen()));
                }),
            // addTileEvent(Icons.share_outlined,
            //     ApplicationLocalizations.of(context).translate('share_text'),
            //     () {
            //   Share.share(ConstantUtil.yourAppLinkForSharing);
            // }),
            addTileEvent(Icons.logout,
                ApplicationLocalizations.of(context).translate('logout_text'),
                    () {
                  AppUtil.logoutAction(context, () {
                    SharedPrefs().clearPreferences();
                    NavigationService.instance.navigateToReplacementWithScale(
                        ScaleRoute(page: TutorialScreen()));
                  });
                })
          ],
        ));
  }

  addProfileView(VoidCallback action) {
    return InkWell(
        onTap: action,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
            ),
            color: Colors.white,
          ),
          child: Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: ColorsUtil.appThemeColor,
                        child: model == null || model?.picture == null
                            ? Icon(Icons.person, color: Colors.white, size: 30)
                            : ClipRRect(
                            borderRadius: BorderRadius.circular(32.0),
                            child: CachedNetworkImage(
                              imageUrl: model!.picture!,
                              fit: BoxFit.cover,
                              height: 64.0,
                              width: 64.0,
                              placeholder: (context, url) =>
                                  AppUtil.addProgressIndicator(context),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )),
                      ),
                      SizedBox(width: 10),
                      Text(
                          model == null || model?.name == null ? '' : model!.name,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16))
                    ]),
                    InkWell(
                      onTap: () => NavigationService.instance
                          .navigateToRouteWithScale(
                          ScaleRoute(page: EditProfileScreen((newModel) {
                            setState(() {
                              model = newModel;
                            });
                          }))),
                      child: Container(
                          height: 35.0,
                          width: 90,
                          decoration: BoxDecoration(
                              border:
                              Border.all(color: ColorsUtil.appThemeColor)),
                          child: Center(
                            child: Text(
                                ApplicationLocalizations.of(context)
                                    .translate('edit_text'),
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 15)),
                          )),
                    ),
                  ])),
        ));
  }

  addTileEvent(IconData icon, String event, VoidCallback action) {
    return InkWell(
        onTap: action,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
            ),
            color: Colors.white,
          ),
          child: Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(children: [
                Icon(icon, color: Colors.grey.shade600),
                SizedBox(width: 10),
                Text(event,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16))
              ])),
        ));
  }
}
