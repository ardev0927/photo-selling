import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/BouncingWidget.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/screens/LoginSignUp/login_screen.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/constant_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';

import '../../application_localizations.dart';

class TutorialScreen extends StatefulWidget {
  @override
  TutorialScreenState createState() => TutorialScreenState();
}

class TutorialScreenState extends State<TutorialScreen> {
  int _current = 0;
  List<String> imgList = [
    "assets/tutorial1.jpg",
    "assets/tutorial2.jpg",
    "assets/tutorial3.jpg",
    "assets/tutorial4.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0.0,
            title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                ConstantUtil.projectName,
                style: TextStyle(color: ColorsUtil.appThemeColor, fontSize: 18),
              ),
              SizedBox(width: 10),
              Icon(Icons.photo_camera, color: ColorsUtil.appThemeColor)
            ])),
        body: Column(children: [
          CarouselSlider(
            items: addImages(),
            options: CarouselOptions(
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                height: MediaQuery.of(context).size.height / 1.5,
                // aspectRatio: 0.7,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.map((url) {
              int index = imgList.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? ColorsUtil.appThemeColor
                      : Color.fromRGBO(0, 0, 0, 0.2),
                ),
              );
            }).toList(),
          ),
          addActionBtn()
        ]));
  }

  List<Widget> addImages() {
    return imgList
        .map((item) => Container(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Image.asset(item, fit: BoxFit.cover, width: 1000.0),
              ),
            ))
        .toList();
  }

  addActionBtn() {
    return BouncingWidget(
      duration: Duration(milliseconds: 100),
      scaleFactor: 1.5,
      onPressed: () {
        NavigationService.instance
            .navigateToRouteWithScale(ScaleRoute(page: LoginScreen()));
      },
      child: Container(
          width: MediaQuery.of(context).size.width - 60,
          height: 50,
          color: ColorsUtil.appThemeColor,
          child: Center(
              child: Text(
            ApplicationLocalizations.of(context).translate('continue_text'),
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ))),
    );
  }
}
