import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/BouncingWidget.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/form_validator.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';

import '../../application_localizations.dart';

class PaymentSettingsScreen extends StatefulWidget {
  @override
  PaymentSettingsState createState() => PaymentSettingsState();
}

class PaymentSettingsState extends State<PaymentSettingsScreen> {
  TextEditingController payPalId = TextEditingController();
  TextEditingController confirmPayPalId = TextEditingController();
  late UserModel model;

  @override
  void initState() {
    super.initState();
    SharedPrefs().getUser().then((value) {
      setState(() {
        model = value;
        payPalId.text = value.paypalId ?? '';
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
            elevation: 4.0,
            title: Text(
              ApplicationLocalizations.of(context)
                  .translate('paymentSettings_text'),
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            leading: InkWell(
                onTap: () => NavigationService.instance.goBack(),
                child:
                Icon(Icons.arrow_back_ios_rounded, color: Colors.black))),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(15, 40, 15, 5),
                        child: Column(
                          children: [
                            addTextField(
                                payPalId,
                                ApplicationLocalizations.of(context)
                                    .translate('paypalIdHint_text')),
                            SizedBox(height: 10),
                            addTextField(
                                confirmPayPalId,
                                ApplicationLocalizations.of(context)
                                    .translate('confirmPaypalIdHint_text')),
                            SizedBox(height: 30),
                            addUpdateBtn()
                          ],
                        )),
                  ]),
            )));
  }

  addTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.left,
      style: TextStyle(color: Colors.black),
      maxLength: 40,
      obscureText: false,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(left: 10, right: 10),
          counterText: "",
          hintText: hintText),
    );
  }

  addUpdateBtn() {
    return BouncingWidget(
      duration: Duration(milliseconds: 100),
      scaleFactor: 1.5,
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        validateAction();
      },
      child: Container(
          height: 40,
          color: ColorsUtil.appThemeColor,
          child: Center(
              child: Text(
                ApplicationLocalizations.of(context).translate('update_text'),
                style: TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              ))),
    );
  }

  void validateAction() {
    if (FormValidator().isTextEmpty(payPalId.text)) {
      AppUtil.showToast(
          ApplicationLocalizations.of(context).translate('enterPayPalId_text'),
          context);
    } else if (FormValidator().isNotValidEmail(payPalId.text)) {
      AppUtil.showToast(
          ApplicationLocalizations.of(context)
              .translate('enterValidPayPalId_text'),
          context);
    } else if (FormValidator().isTextEmpty(confirmPayPalId.text) ||
        FormValidator().isNotValidEmail(confirmPayPalId.text) ||
        payPalId.text != confirmPayPalId.text) {
      AppUtil.showToast(
          ApplicationLocalizations.of(context)
              .translate('confirmPayPalId_text'),
          context);
    } else {
      AppUtil.checkInternet().then((value) {
        if (value) {
          AppUtil.showLoader(context);
          ApiController()
              .updatePaymentDetailsApi(payPalId.text)
              .then((response) async {
            if (response.success) {
              model.paypalId = payPalId.text;
              SharedPrefs().saveUser(model);
            }

            Navigator.of(context).pop();
            AppUtil.showToast(response.message, context);
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
