import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/profile_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import '../../application_localizations.dart';
import 'comments_screen.dart';
import 'enlarge_image_view.dart';

class HomeFeedScreen extends StatefulWidget {
  @override
  HomeFeedState createState() => HomeFeedState();
}

class HomeFeedState extends State<HomeFeedScreen> {
  List<String> homeArr = ['following_text', 'me_text'];
  List<PostModel> followingPosts = [];
  List<PostModel> myPosts = [];

  @override
  void initState() {
    super.initState();
    getFollowingPosts();
    getMyPosts();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: homeArr.length,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0.0,
            title: Center(
                child: Text(
              ApplicationLocalizations.of(context).translate('home_text'),
              style: TextStyle(color: Colors.black, fontSize: 18),
            ))),
        body: Column(children: <Widget>[
              TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: ColorsUtil.appThemeColor,
                indicatorColor: ColorsUtil.appThemeColor,
                indicatorWeight: 2,
                tabs: List.generate(homeArr.length, (int index) {
                  return Visibility(
                    visible: true,
                    child: Tab(
                      text: ApplicationLocalizations.of(context)
                          .translate(homeArr[index]),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              Expanded(
                  child: TabBarView(
                children: List.generate(homeArr.length, (int index) {
                  return index == 0 ? addFollowingPostUI() : addMyPostUI();
                }),
              )),
            ]),
      ),
    );
  }

  addFollowingPostUI() {
    return followingPosts == null
        ? Center(
            child: CircularProgressIndicator(
                backgroundColor: Colors.black12,
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorsUtil.appThemeColor)),
          )
        : followingPosts.length == 0
            ? Center(
                child: Text(ApplicationLocalizations.of(context)
                    .translate('noData_text')))
            : RefreshIndicator(
                color: ColorsUtil.appThemeColor,
                child: ListView.builder(
                    itemCount: followingPosts.length,
                    itemBuilder: (context, index) {
                      PostModel model = followingPosts[index];
                      return PostCard(model);
                    }),
                onRefresh: () {
                  return Future.delayed(
                    Duration(seconds: 1),
                    () {
                      getFollowingPosts();
                    },
                  );
                },
              );
  }

  addMyPostUI() {
    return myPosts == null
        ? Center(
            child: CircularProgressIndicator(
                backgroundColor: Colors.black12,
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorsUtil.appThemeColor)),
          )
        : myPosts.length == 0
            ? Center(
                child: Text(ApplicationLocalizations.of(context)
                    .translate('noData_text')))
            : RefreshIndicator(
                color: ColorsUtil.appThemeColor,
                child: ListView.builder(
                    itemCount: myPosts.length,
                    itemBuilder: (context, index) {
                      PostModel model = myPosts[index];
                      return PostCard(model);
                    }),
                onRefresh: () {
                  return Future.delayed(
                    Duration(seconds: 1),
                    () {
                      getMyPosts();
                    },
                  );
                },
              );
  }

  // API Call 
  void getFollowingPosts() async {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController().getPostsApi(null, 0, 1, 0).then((response) async {
          followingPosts = [];
          followingPosts = response.success ? response.posts : [];
          setState(() {});
        });
      }
    });
  }

  void getMyPosts() async {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController().getPostsApi(null, 0, 0, 1).then((response) async {
          myPosts = [];
          myPosts = response.success ? response.posts : [];
          setState(() {});
        });
      }
    });
  }
}

class PostCard extends StatefulWidget {
  final PostModel model;
  PostCard(this.model);

  @override
  PostCardState createState() => PostCardState(model);
}

class PostCardState extends State<PostCard> {
  final PostModel model;
  PostCardState(this.model);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      addPostUserInfo(),
      Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
          child: Text(model.title, style: new TextStyle(color: Colors.black))),
      Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 15),
          child: Text(model.tags.join(' '),
              style: new TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w700))),
      InkWell(
          onTap: () async {
            File path = await AppUtil.findPath(model.gallery.first.filePath);
            NavigationService.instance.navigateToRouteWithScale(
                ScaleRoute(
                    page: EnlargeImageViewScreen(model, path, handler: () {
                  setState(() {});
                })));
          },
          child: Container(
              height: 210.0,
              child: CachedNetworkImage(
                imageUrl: model.gallery.first.filePath,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
                placeholder: (context, url) =>
                    AppUtil.addProgressIndicator(context),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ))),
      Padding(
          padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              InkWell(
                  onTap: () => likeUnlikeApiCall(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(model.isLike ? Icons.star : Icons.star_border,
                            color: ColorsUtil.appThemeColor, size: 25),
                        Text(
                            model.totalLike > 1
                                ? '${model.totalLike} ${ApplicationLocalizations.of(context).translate('likes_text')}'
                                : '${model.totalLike} ${ApplicationLocalizations.of(context).translate('like_text')}',
                            style: TextStyle(fontWeight: FontWeight.w700))
                      ])),
              SizedBox(width: 10),
              InkWell(
                  onTap: () => openComments(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.comment_outlined,
                            color: ColorsUtil.appThemeColor),
                        Text(
                            model.totalComment > 1
                                ? '${model.totalComment} ${ApplicationLocalizations.of(context).translate('comments_text')}'
                                : '${model.totalComment} ${ApplicationLocalizations.of(context).translate('comment_text')}',
                            style: TextStyle(fontWeight: FontWeight.w700))
                      ]))
            ]),
            InkWell(
              onTap: () => openReportPostPopup(),
              child: Container(
                  height: 30.0,
                  width: 80,
                  color: ColorsUtil.appThemeColor,
                  child: Center(
                    child: Text(
                        model.isReported
                            ? ApplicationLocalizations.of(context)
                                .translate('reported_text')
                            : ApplicationLocalizations.of(context)
                                .translate('report_text'),
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  )),
            )
          ])),
      Container(
        width: MediaQuery.of(context).size.width,
        height: 1,
        color: ColorsUtil.separatorLightColor,
      )
    ]);
  }

  void openReportPostPopup() {
    if (!model.isReported) {
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
                        reportPostApiCall();
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

  addPostUserInfo() {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
                onTap: () => openProfile(),
                child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorsUtil.appThemeColor),
                    ),
                    child: model.userPicture != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: CachedNetworkImage(
                              imageUrl: model.userPicture!,
                              fit: BoxFit.fill,
                              placeholder: (context, url) =>
                                  AppUtil.addProgressIndicator(context),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ))
                        : Icon(Icons.person, color: ColorsUtil.appThemeColor))),
            SizedBox(width: 10),
            Flexible(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                InkWell(
                    onTap: () => openProfile(),
                    child: Text(
                      model.username,
                      style: new TextStyle(color: Colors.black),
                    )),
                Text(model.postTime, style: TextStyle(color: Colors.grey)),
              ],
            ))
          ],
        ));
  }

  void likeUnlikeApiCall() {
    setState(() {
      model.isLike = !model.isLike;
      model.totalLike =
          model.isLike ? model.totalLike + 1 : model.totalLike - 1;
    });
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController()
            .likeUnlikeApi(!model.isLike, model.id)
            .then((response) async {});
      } else {
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('noInternet_text'),
            context);
      }
    });
  }

  void openComments() {
    NavigationService.instance.navigateToRouteWithScale(
        ScaleRoute(
          page: CommentsScreen(model, () {
            setState(() {});
          }),
        ));
  }

  void openProfile() async {
    var _ = await NavigationService.instance.navigateToRouteWithScale(
        ScaleRoute(
          page: ProfileScreen(model.userId),
        ));
    setState(() {});
  }

  void reportPostApiCall() {
    setState(() {
      model.isReported = true;
    });
    AppUtil.checkInternet().then((value) async {
      if (value) {
        AppUtil.showLoader(context);
        ApiController().reportPostApi(model.id).then((response) async {
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
