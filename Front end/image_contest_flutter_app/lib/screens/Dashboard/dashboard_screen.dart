import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/screens/Competitions/competitions_screen.dart';
import 'package:image_contest_flutter_app/screens/HomeFeed/home_feed_screen.dart';
import 'package:image_contest_flutter_app/screens/Explore/explore_screen.dart';
import 'package:image_contest_flutter_app/screens/AddPost/add_post_screen.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/menu_screen.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';

import '../../application_localizations.dart';

class DashboardScreen extends StatefulWidget {
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<DashboardScreen> {
  int _currentIndex = 0;
  List<Widget> items = [];

  @override
  void initState() {
    super.initState();
    items = [
      HomeFeedScreen(),
      ExploreScreen(),
      Container(),
      CompetitionsScreen(),
      MenuScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: items[_currentIndex],
        floatingActionButton: Padding(
          padding: EdgeInsets.only(top: 25),
          child: SizedBox(
            height: 70,
            width: 70,
            child: FloatingActionButton(
              backgroundColor: ColorsUtil.appThemeColor,
              elevation: 0,
              onPressed: () {
                onTabTapped(2);
              },
              child: Icon(Icons.photo_camera, size: 36),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).viewPadding.bottom > 0 ? 88 : 65.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 5,
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            unselectedItemColor: Colors.grey,
            selectedItemColor: ColorsUtil.appThemeColor,
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.article_outlined),
                  label: ApplicationLocalizations.of(context)
                      .translate('home_text')),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: ApplicationLocalizations.of(context)
                    .translate('explore_text'),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.bookmark_border,
                  color: Colors.transparent,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights),
                label: ApplicationLocalizations.of(context)
                    .translate('competition_text'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label:
                    ApplicationLocalizations.of(context).translate('menu_text'),
              ),
            ],
          ),
        ));
  }

  void onTabTapped(int index) async {
    if (index == 2) {
      NavigationService.instance.navigateToRouteWithScale(ScaleRoute(
        page: AddPostScreen(null),
      ));
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
