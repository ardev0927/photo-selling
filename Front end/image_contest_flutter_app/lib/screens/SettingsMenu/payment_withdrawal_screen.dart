import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/payment_model.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';
import '../../application_localizations.dart';

class PaymentWithdrawalScreen extends StatefulWidget {
  @override
  PaymentWithdrawalState createState() => PaymentWithdrawalState();
}

class PaymentWithdrawalState extends State<PaymentWithdrawalScreen> {
  String availableBalance = '';
  String payPalId = '';
  List<PaymentModel> payments = [];

  @override
  void initState() {
    super.initState();
    SharedPrefs().getUser().then((value) {
      setState(() {
        availableBalance = value.balance;
        payPalId = value.paypalId ?? '';
      });
      getUserProfileApi();
    });
    getWithdrawHistoryApi();
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
                  .translate('paymentWithdrawal_text'),
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            leading: InkWell(
                onTap: () => NavigationService.instance.goBack(),
                child:
                Icon(Icons.arrow_back_ios_rounded, color: Colors.black))),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          totalBalanceView(),
          Padding(
              padding: EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
              child: Text(
                ApplicationLocalizations.of(context)
                    .translate('withdrawalHistory_text'),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              )),
          Expanded(
            child: ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  PaymentModel paymentModel = payments[index];
                  return Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 15.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paymentModel.amount,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      paymentModel.createDate,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                    )
                                  ],
                                ),
                                Text(
                                  paymentModel.status == 1
                                      ? ApplicationLocalizations.of(context)
                                      .translate('pending_text')
                                      : paymentModel.status == 2
                                      ? ApplicationLocalizations.of(context)
                                      .translate('rejected_text')
                                      : ApplicationLocalizations.of(context)
                                      .translate('completed_text'),
                                  style: TextStyle(
                                      color: ColorsUtil.appThemeColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                )
                              ])),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                        color: ColorsUtil.separatorLightColor,
                      )
                    ],
                  );
                }),
          ),
        ]));
  }

  totalBalanceView() {
    return Container(
      margin: EdgeInsets.all(15.0),
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black54.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          ApplicationLocalizations.of(context)
              .translate('availableBalance_text'),
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            '\$$availableBalance',
            style: TextStyle(
                color: ColorsUtil.appThemeColor,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          InkWell(
            onTap: () {
              if (int.parse(availableBalance) < 50) {
                AppUtil.showToast(
                    ApplicationLocalizations.of(context)
                        .translate('minWithdrawal_text'),
                    context);
              } else if (payPalId.length == 0) {
                AppUtil.showToast(
                    ApplicationLocalizations.of(context)
                        .translate('providePayPalId_text'),
                    context);
              } else {
                withdrawalRequest();
              }
            },
            child: Container(
                height: 35.0,
                width: 90,
                color: ColorsUtil.appThemeColor,
                child: Center(
                  child: Text(
                      ApplicationLocalizations.of(context)
                          .translate('withdraw_text'),
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                )),
          )
        ])
      ]),
    );
  }

  void getUserProfileApi() {
    AppUtil.checkInternet().then((value) {
      if (value) {
        ApiController().getUserProfileApi().then((response) async {
          if (response.success) {
            SharedPrefs().saveUser(response.user!);
            setState(() {
              availableBalance = response.user!.balance;
            });
          }
        });
      }
    });
  }

  void getWithdrawHistoryApi() {
    AppUtil.checkInternet().then((value) {
      if (value) {
        ApiController().getWithdrawHistory().then((response) async {
          if (response.success) {
            setState(() {
              payments = response.payments;
            });
          }
        });
      }
    });
  }

  void withdrawalRequest() {
    AppUtil.checkInternet().then((value) {
      if (value) {
        AppUtil.showLoader(context);
        ApiController().performWithdrawalRequest().then((response) async {
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
