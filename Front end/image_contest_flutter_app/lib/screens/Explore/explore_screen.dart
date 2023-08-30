import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/screens/HomeFeed/enlarge_image_view.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/profile_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import '../../application_localizations.dart';

class ExploreScreen extends StatefulWidget {
  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  List<UserModel> users = [];
  List<PostModel> explorePosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPopularUsersApi();
    getPopularFeedPosts();
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
            ApplicationLocalizations.of(context).translate('explore_text'),
            style: TextStyle(color: Colors.black, fontSize: 18),
          ))),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.black12,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ColorsUtil.appThemeColor)),
            )
          : ListView.builder(
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                return index == 0 ? addPhotographersList() : addPhotoGrid();
              }),
    );
  }

  addPhotographersList() {
    return Container(
        height: 135,
        margin: EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              ApplicationLocalizations.of(context)
                  .translate('bestPhotographer_text'),
              style: TextStyle(color: Color(0xFF757575))),
          SizedBox(height: 20),
          Expanded(
              child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(width: 20);
            },
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  InkWell(
                      onTap: () => NavigationService.instance.navigateToRouteWithScale(
                          ScaleRoute(page: ProfileScreen(users[index].id))),
                      child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: ColorsUtil.appThemeColor),
                          ),
                          child: users[index].picture != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(35.0),
                                  child: CachedNetworkImage(
                                    imageUrl: users[index].picture!,
                                    fit: BoxFit.fill,
                                    placeholder: (context, url) =>
                                        AppUtil.addProgressIndicator(context),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ))
                              : Icon(Icons.person,
                                  color: ColorsUtil.appThemeColor))),
                  SizedBox(height: 5),
                  Text(users[index].name)
                ],
              );
            },
          ))
        ]));
  }

  addPhotoGrid() {
    return MasonryGridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      itemCount: explorePosts.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) => InkWell(
        onTap: () async {
          File path = await AppUtil.findPath(
              explorePosts[index].gallery.first.filePath);
          NavigationService.instance.navigateToRouteWithScale(
              ScaleRoute(
                  page: EnlargeImageViewScreen(
                    explorePosts[index],
                    path,
                    handler: () {},
                  )));
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.grey),
            ),
            child: Stack(children: [
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: explorePosts[index].gallery.first.filePath,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        AppUtil.addProgressIndicator(context),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: FractionalOffset.bottomCenter,
                          end: FractionalOffset.topCenter,
                          colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                          stops: [
                        0.0,
                        1.0
                      ])),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: double.infinity,
                        height: 22,
                        child: Text(explorePosts[index].title,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white))),
                  )),
            ])),
      ),
      // staggeredTileBuilder: (int index) => new StaggeredTile.count(2, index.isEven ? 2 : 1),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  void getPopularUsersApi() {
    AppUtil.checkInternet().then((value) {
      if (value) {
        ApiController().getPopularUsersApi().then((response) async {
          users = response.success ? response.popularUser : [];
          isLoading = false;
          setState(() {});
          if (!response.success) {
            AppUtil.showToast(response.message, context);
          }
        });
      } else {
        isLoading = false;
        setState(() {});
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('noInternet_text'),
            context);
      }
    });
  }

  void getPopularFeedPosts() {
    AppUtil.checkInternet().then((value) {
      if (value) {
        ApiController().getPostsApi(null, 0, 1, 1).then((response) async {
          explorePosts = response.success ? response.posts : [];
          explorePosts = response.success
              ? response.posts
              .where((element) => element.gallery.length > 0)
              .toList()
              : [];
          print(explorePosts.length);
          setState(() {});
        });
      }
    });
  }
}
