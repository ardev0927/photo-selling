import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/screens/HomeFeed/enlarge_image_view.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/follower_following_list.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';

import '../../application_localizations.dart';
import 'edit_profile_screen.dart';
import 'photo_gallery_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  ProfileScreen(this.userId);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfileScreen> {
  late UserModel model;
  int signedInUserId = 0;
  List<PostModel> posts = [];
  List<PostModel> soldPosts = [];
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    SharedPrefs().getUser().then((value) {
      setState(() {
        signedInUserId = value.id;
      });
    });

    getOtherUserDetailApi();
    getOtherUserPosts();
  }

  Future<bool> pop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0.0,
            title: Text(
              ApplicationLocalizations.of(context).translate('profile_text'),
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            leading: InkWell(
                onTap: () => NavigationService.instance.goBack(),
                child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black)),
            actions: [
              signedInUserId != widget.userId
                  ? model == null
                  ? Container()
                  : Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: InkWell(
                    onTap: () => openReportUserPopup(),
                    child: Center(
                      child: Text(
                          model.isReported ?? false
                              ? ApplicationLocalizations.of(context)
                              .translate('reportedSmall_text')
                              : ApplicationLocalizations.of(context)
                              .translate('reportSmall_text'),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                    ),
                  ))
                  : InkWell(
                  onTap: () => NavigationService.instance.navigateToRouteWithScale(
                      ScaleRoute(page: EditProfileScreen((newModel) {
                        setState(() {
                          model = newModel;
                        });
                      }))),
                  child: Padding(
                      padding: EdgeInsets.only(right: 20),
                      child:
                      Icon(Icons.edit_outlined, color: Colors.black)))
            ]),
        body: WillPopScope(
          onWillPop: pop,
          child: SingleChildScrollView(
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              addUserInfo(),
              Padding(
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(model == null ? '0' : model.totalPost ?? '0',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text( ApplicationLocalizations.of(context)
                              .translate('photosCap_text'), style: TextStyle(fontSize: 15))
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          NavigationService.instance.navigateToRouteWithScale(
                              ScaleRoute(
                                  page: FollowerFollowingList(
                                      false, model.followings)));
                        },
                        child: Column(
                          children: [
                            Text(
                                model == null
                                    ? '0'
                                    : model.followings.length.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                                ApplicationLocalizations.of(context)
                                    .translate('followingSmall_text'),
                                style: TextStyle(fontSize: 15))
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          NavigationService.instance.navigateToRouteWithScale(
                              ScaleRoute(
                                  page: FollowerFollowingList(
                                      true, model.followers)));
                        },
                        child: Column(
                          children: [
                            Text(
                                model == null
                                    ? '0'
                                    : model.followers.length.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                                ApplicationLocalizations.of(context)
                                    .translate('followerSmall_text'),
                                style: TextStyle(fontSize: 15))
                          ],
                        ),
                      ),
                    ],
                  )),
              soldPosts.length == 0
                  ? Container()
                  : Container(
                  height: 50,
                  color: ColorsUtil.appThemeColor,
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  margin: EdgeInsets.only(bottom: 5),
                  child: InkWell(
                    onTap: () {
                      NavigationService.instance.navigateToRouteWithScale(
                          ScaleRoute(page: PhotoGalleryScreen(soldPosts)));
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "${soldPosts.length} ${ApplicationLocalizations.of(context).translate('photosSold_text')}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white)),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: Colors.white,
                            size: 20,
                          )
                        ]),
                  )),
              addPhotoGrid()
            ]),
          ),
        ));
  }

  void openReportUserPopup() {
    if (!model.isReported!) {
      showModalBottomSheet(
          context: context,
          builder: (context) => Wrap(
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 25),
                  child: Text(
                      ApplicationLocalizations.of(context)
                          .translate('reportThis_text'),
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none))),
              ListTile(
                  leading: new Icon(Icons.camera_alt_outlined,
                      color: Colors.black87),
                  title: new Text(ApplicationLocalizations.of(context)
                      .translate('reportSmall_text')),
                  onTap: () async {
                    Navigator.of(context).pop();
                    reportUserApiCall();
                  }),
              ListTile(
                  leading: new Icon(Icons.close, color: Colors.black87),
                  title: new Text(ApplicationLocalizations.of(context)
                      .translate('cancel_text')),
                  onTap: () => Navigator.of(context).pop()),
            ],
          ));
    }
  }

  addUserInfo() {
    return Padding(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(color: ColorsUtil.appThemeColor)),
                child: model != null && model.picture != null
                    ? ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: CachedNetworkImage(
                      imageUrl: model.picture!,
                      fit: BoxFit.fill,
                      placeholder: (context, url) =>
                          AppUtil.addProgressIndicator(context),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    ))
                    : Icon(Icons.person, color: Colors.grey.shade600, size: 40),
              ),
              SizedBox(height: 5),
              Text(
                  model != null && model.name != null
                      ? model.name
                      : ApplicationLocalizations.of(context)
                      .translate('username_text'),
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            ]),
            widget.userId == signedInUserId
                ? Container()
                : model == null
                ? Container()
                : InkWell(
              onTap: () => followUnFollowUserApi(),
              child: Container(
                  height: 35.0,
                  width: 90,
                  color: ColorsUtil.appThemeColor,
                  child: Center(
                    child: Text(
                        isFollowing
                            ? ApplicationLocalizations.of(context)
                            .translate('UnFollow_text')
                            : ApplicationLocalizations.of(context)
                            .translate('follow_text'),
                        style: TextStyle(
                            color: Colors.white, fontSize: 13)),
                  )),
            )
          ]),
        ));
  }

  addPhotoGrid() {
    return MasonryGridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      itemCount: posts.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) => InkWell(
        onTap: () async {
          File path = await AppUtil.findPath(posts[index].gallery.first.filePath);
          NavigationService.instance.navigateToRouteWithScale(
              ScaleRoute(page: EnlargeImageViewScreen(posts[index], path,handler: (){},)));
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
                    imageUrl: posts[index].gallery.first.filePath,
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
                        child: Text(posts[index].title,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white))),
                  )),
            ])),
      ),
      // staggeredTileBuilder: (int index) =>
      //     new StaggeredTile.count(2, index.isEven ? 2 : 1),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  void getOtherUserDetailApi() {
    AppUtil.checkInternet().then((value) {
      if (value) {
        ApiController()
            .getOtherUserApi(widget.userId.toString())
            .then((response) async {
          if (response.success) {
            model = response.user!;
            //Check if logged in user following the other user
            isFollowing = model.followers
                .where((element) => element.id == signedInUserId)
                .length >
                0;
            setState(() {});
          } else {
            AppUtil.showToast(response.message, context);
          }
        });
      }
    });
  }

  void getOtherUserPosts() {
    AppUtil.checkInternet().then((value) {
      if (value) {
        ApiController()
            .getPostsApi(widget.userId.toString(), 0, 0, 0)
            .then((response) async {
          if (response.success) {
            posts = response.posts;
            soldPosts =
                posts.where((element) => element.isWinning == 1).toList();
            setState(() {});
          } else {
            AppUtil.showToast(response.message, context);
          }
        });
      }
    });
  }

  void followUnFollowUserApi() {
    AppUtil.checkInternet().then((value) {
      if (value) {
        ApiController()
            .followUnFollowUserApi(isFollowing, signedInUserId.toString())
            .then((response) async {
          if (response.success) {
            setState(() {
              isFollowing = !isFollowing;
            });
          } else {
            AppUtil.showToast(response.message, context);
          }
        });
      }
    });
  }

  void reportUserApiCall() {
    setState(() {
      model.isReported = true;
    });
    AppUtil.checkInternet().then((value) async {
      if (value) {
        AppUtil.showLoader(context);
        ApiController().reportUserApi(model.id).then((response) async {
          Navigator.of(context).pop();
        });
      } else {
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('noInternet_text'),
            context);
      }
    });
  }
}
