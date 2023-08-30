import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/screens/HomeFeed/comments_screen.dart';
import 'package:image_contest_flutter_app/screens/HomeFeed/enlarge_image_view.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/profile_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import '../../application_localizations.dart';

class WinnerDetailScreen extends StatefulWidget {
  final PostModel winnerPost;
  WinnerDetailScreen(this.winnerPost);

  @override
  WinnerDetailState createState() => WinnerDetailState(winnerPost);
}

class WinnerDetailState extends State<WinnerDetailScreen> {
  final PostModel model;
  WinnerDetailState(this.model);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          title: Text(
            ApplicationLocalizations.of(context).translate('winner_text'),
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          leading: InkWell(
              onTap: () => NavigationService.instance.goBack(),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black)),
        ),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            addUserInfo(),
            Padding(
                padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                child: Text(model.title,
                    style: new TextStyle(color: Colors.black))),
            Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 15),
                child: Text(model.tags.join(' '),
                    style: new TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700))),
            InkWell(
                onTap: () async {
                  File path = await AppUtil.findPath(model.gallery.first.filePath);
                  NavigationService.instance.navigateToRouteWithScale(
                      ScaleRoute(
                          page:
                              EnlargeImageViewScreen(model, path, handler: () {
                        setState(() {});
                      })));
                },
                child: Container(
                    height: 300.0,
                    child: CachedNetworkImage(
                      imageUrl: model.gallery.first.filePath,
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width,
                      placeholder: (context, url) =>
                          AppUtil.addProgressIndicator(context),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ))),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () => likeUnlikeApiCall(),
                              child: Icon(
                                  model.isLike ? Icons.star : Icons.star_border,
                                  color: ColorsUtil.appThemeColor,
                                  size: 25)),
                          Text(
                              model.totalLike > 1
                                  ? '${model.totalLike} ${ApplicationLocalizations.of(context).translate('likes_text')}'
                                  : '${model.totalLike} ${ApplicationLocalizations.of(context).translate('like_text')}',
                              style: TextStyle(fontWeight: FontWeight.w700))
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () => openComments(),
                              child: Icon(Icons.comment_outlined,
                                  color: ColorsUtil.appThemeColor)),
                          InkWell(
                            onTap: () => openComments(),
                            child: Text(
                                model.totalComment > 1
                                    ? '${model.totalComment} ${ApplicationLocalizations.of(context).translate('comments_text')}'
                                    : '${model.totalComment} ${ApplicationLocalizations.of(context).translate('comment_text')}',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          )
                        ])
                  ]),
            ),
          ]),
        ));
  }

  addUserInfo() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: InkWell(
          onTap: () => openProfile(),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(color: ColorsUtil.appThemeColor)),
              child: model != null && model.userPicture != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: CachedNetworkImage(
                        imageUrl: model.userPicture!,
                        fit: BoxFit.fill,
                        placeholder: (context, url) =>
                            AppUtil.addProgressIndicator(context),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ))
                  : Icon(Icons.person, color: Colors.grey.shade600, size: 40),
            ),
            SizedBox(width: 5),
            Text(
                model != null && model.username != null
                    ? model.username
                    : ApplicationLocalizations.of(context)
                        .translate('username_text'),
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
          ]),
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
}
