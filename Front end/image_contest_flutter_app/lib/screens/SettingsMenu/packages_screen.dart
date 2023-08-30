import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/package_model.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';
import 'dart:async';
import 'dart:io';

import '../../application_localizations.dart';

class PackagesScreen extends StatefulWidget {
  final Function(int) handler;
  PackagesScreen(this.handler);

  @override
  PackagesScreenState createState() => PackagesScreenState();
}

class PackagesScreenState extends State<PackagesScreen> {
  List<PackageModel> packages = [];
  late UserModel user;
  int coins = 0;

  bool _kAutoConsume = true;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  String selectedPurchaseId = '';
  int selectedPackage = 0;

  @override
  void initState() {
    super.initState();
    SharedPrefs().getUser().then((value) {
      user = value;
      setState(() {
        coins = value.coins ?? 0;
      });
    });
    AppUtil.checkInternet().then((value) {
      if (value) {
        ApiController().getAllPackagesApi().then((value) {
          if (value.success) {
            packages = value.packages;
            initStoreInfo();
            setState(() {});
          }
        });
      }
    });

    // final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    // _subscription = purchaseUpdated.listen((purchaseDetailsList) {
    //   _listenToPurchaseUpdated(purchaseDetailsList);
    // }, onDone: () {
    //   _subscription.cancel();
    // }, onError: (error) {
    //   // handle error here.
    // });
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
      });
      return;
    }

    //For Testing
    List<String> _kProductIds = ['android.test.purchased'];
    //For Real Time
    // List<String> _kProductIds = packages
    //     .map((e) =>
    //         Platform.isIOS ? e.inAppPurchaseIdIOS : e.inAppPurchaseIdAndroid)
    //     .toList();
    ProductDetailsResponse productDetailResponse =
    await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
      });
      return;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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
            ApplicationLocalizations.of(context).translate('packages_text'),
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          leading: InkWell(
              onTap: () => NavigationService.instance.goBack(),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black))),
      body: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${ApplicationLocalizations.of(context).translate('totalCoins_text')} $coins',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 40, mainAxisSpacing: 30),
                  padding: EdgeInsets.only(top: 20, left: 5, right: 5),
                  itemBuilder: (_, index) => InkWell(
                      onTap: () async {
                        if (_isAvailable) {
                          //Perform Purchase --------------->
                          //For Testing
                          selectedPurchaseId = 'android.test.purchased';
                          selectedPackage = index;
                          //For Real Time
                          // selectedPurchaseId = Platform.isIOS
                          //     ? packages[index].inAppPurchaseIdIOS
                          //     : packages[index].inAppPurchaseIdAndroid;
                          List<ProductDetails> matchedProductArr = _products
                              .where((element) => element.id == selectedPurchaseId)
                              .toList();
                          if (matchedProductArr.length > 0) {
                            ProductDetails matchedProduct = matchedProductArr.first;
                            PurchaseParam purchaseParam = PurchaseParam(
                                productDetails: matchedProduct,
                                applicationUserName: null);
                            _inAppPurchase.buyConsumable(
                                purchaseParam: purchaseParam,
                                autoConsume: _kAutoConsume || Platform.isIOS);
                          } else {
                            AppUtil.showToast(
                                ApplicationLocalizations.of(context)
                                    .translate('productNotAvailable_text'),
                                context);
                          }
                        } else {
                          AppUtil.showToast(
                              ApplicationLocalizations.of(context)
                                  .translate('storeNotAvailable_text'),
                              context);
                        }
                      },
                      child: Container(
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
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${packages[index].coin} ${ApplicationLocalizations.of(context).translate('coins_text')}',
                                style: TextStyle(color: Colors.black, fontSize: 18),
                              ),
                              SizedBox(height: 20),
                              Text(
                                '\$${packages[index].price}',
                                style: TextStyle(
                                    color: ColorsUtil.appThemeColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ]),
                      )),
                  itemCount: packages.length,
                )),
          ])),
    );
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //showPending error
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          //show error
          AppUtil.showToast(
              ApplicationLocalizations.of(context)
                  .translate('purchaseError_text'),
              context);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          //show success
          AppUtil.checkInternet().then((value) {
            if (value) {
              ApiController()
                  .subscribePackageApi(
                  packages[selectedPackage].id.toString(),
                  purchaseDetails.purchaseID!,
                  packages[selectedPackage].price.toString())
                  .then((response) {
                AppUtil.showToast(response.message, context);
                if (response.success) {
                  widget.handler(packages[selectedPackage].coin);
                  user.coins = packages[selectedPackage].coin;
                  SharedPrefs().saveUser(user);
                }
              });
            }
          });
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume &&
              purchaseDetails.productID == selectedPurchaseId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
            _inAppPurchase.getPlatformAddition<
                InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }
}
