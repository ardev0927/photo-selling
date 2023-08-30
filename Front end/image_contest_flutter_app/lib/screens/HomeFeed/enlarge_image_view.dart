import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/profile_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';

import '../../application_localizations.dart';
import 'comments_screen.dart';

class EnlargeImageViewScreen extends StatefulWidget {
  final PostModel? model;
  final File file;
  final VoidCallback handler;

  EnlargeImageViewScreen(this.model, this.file, {required this.handler});

  @override
  EnlargeImageViewState createState() => EnlargeImageViewState(model, file);
}

class EnlargeImageViewState extends State<EnlargeImageViewScreen> {
  late PostModel? model;
  late File file;
  EnlargeImageViewState(this.model, this.file);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            centerTitle: true,
            elevation: 0.0,
            title: model == null ? Container() :InkWell(
                onTap: () => NavigationService.instance
                    .navigateToRouteWithScale(
                    ScaleRoute(page: ProfileScreen(model!.userId))),
                child: Text(
                  model!.username,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )),
            leading: InkWell(
                onTap: () => NavigationService.instance.goBack(),
                child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white)),
            actions: [
              model == null
                  ? Container()
                  : Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: InkWell(
                    onTap: () => openReportPostPopup(),
                    child: Center(
                      child: Text(
                          model!.isReported
                              ? ApplicationLocalizations.of(context)
                              .translate('reportedSmall_text')
                              : ApplicationLocalizations.of(context)
                              .translate('reportSmall_text'),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                    ),
                  ))
            ]),
        body: Stack(children: [
          PhotoView(imageProvider: Image.file(file).image),
          model == null
              ? Container()
              : Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () => likeUnlikeApiCall(),
                            child: Icon(
                                model!.isLike
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.white,
                                size: 25)),
                        Text(
                            model!.totalLike > 1
                                ? '${model!.totalLike} ${ApplicationLocalizations.of(context).translate('likes_text')}'
                                : '${model!.totalLike} ${ApplicationLocalizations.of(context).translate('like_text')}',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white))
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: () => openComments(),
                            child: Icon(Icons.comment_outlined,
                                color: Colors.white)),
                        InkWell(
                          onTap: () => openComments(),
                          child: Text(
                              model!.totalComment > 1
                                  ? '${model!.totalComment} ${ApplicationLocalizations.of(context).translate('comments_text')}'
                                  : '${model!.totalComment} ${ApplicationLocalizations.of(context).translate('comment_text')}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        )
                      ])
                ]),
          )
        ]));
  }

  void openReportPostPopup() {
    if (!model!.isReported) {
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

  void openComments() {
    NavigationService.instance.navigateToRouteWithScale(
        ScaleRoute(
          page: CommentsScreen(model!, () {
            if (widget.handler != null) {
              widget.handler();
            }
            setState(() {});
          }),
        ));
  }

  void likeUnlikeApiCall() {
    model!.isLike = !model!.isLike;
    model!.totalLike = model!.isLike ? model!.totalLike + 1 : model!.totalLike - 1;

    if (widget.handler != null) {
      widget.handler();
    }
    setState(() {});

    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController()
            .likeUnlikeApi(!model!.isLike, model!.id)
            .then((response) async {});
      } else {
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('noInternet_text'),
            context);
      }
    });
  }

  void reportPostApiCall() {
    model!.isReported = true;
    if (widget.handler != null) {
      widget.handler();
    }
    setState(() {});
    AppUtil.checkInternet().then((value) async {
      if (value) {
        AppUtil.showLoader(context);
        ApiController().reportPostApi(model!.id).then((response) async {
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
