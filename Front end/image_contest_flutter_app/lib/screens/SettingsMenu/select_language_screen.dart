import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/constant_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';
import '../../application_localizations.dart';

class SelectLanguageScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelectLanguageState();
  }
}

class SelectLanguageState extends State<SelectLanguageScreen> {
  List<String> languages = ['English', 'Arabic'];

  @override
  void initState() {
    super.initState();
    fetchSettings();
  }

  void fetchSettings() async {
    ConstantUtil.selectedLanguage = await SharedPrefs().getLanguageCode();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 4.0,
          title: Text(
            ApplicationLocalizations.of(context).translate('selLang_text'),
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          leading: InkWell(
              onTap: () => NavigationService.instance.goBack(),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black))),
      body: ListView.builder(
          itemCount: languages.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => showApplyLanguageAlert(languages[index]),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Container(
                          height: 60,
                          child: Center(
                              child: Text(languages[index],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)))),
                      Container(
                        height: 1,
                        color: ColorsUtil.separatorLightColor,
                      )
                    ],
                  )),
            );
          }),
    );
  }

  void showApplyLanguageAlert(String selLang) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            title: Text(ConstantUtil.projectName,
                style: TextStyle(color: ColorsUtil.appThemeColor)),
            content: Text(ApplicationLocalizations.of(context)
                .translate('selectLanguage_text')),
            actions: [
              TextButton(
                child: Text(
                    ApplicationLocalizations.of(context).translate('yes_text'),
                    style: TextStyle(color: ColorsUtil.appThemeColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  changeLanguageAction(selLang);
                },
              ),
              TextButton(
                child: Text(
                    ApplicationLocalizations.of(context).translate('no_text'),
                    style: TextStyle(color: Colors.black87)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void changeLanguageAction(String selLang) async {
    await SharedPrefs().setLanguageCode(selLang == 'English' ? 'en' : 'ar');
    ConstantUtil.selectedLanguage = selLang == 'English' ? 'en' : 'ar';
    Phoenix.rebirth(context);
  }
}
