import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/model/competition_model.dart';
import 'package:image_contest_flutter_app/screens/HomeFeed/enlarge_image_view.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/web_view_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/constant_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import '../../application_localizations.dart';
import 'winner_detail_dcreen.dart';

class PastCompetitionDetail extends StatefulWidget {
  final CompetitionModel competition;

  PastCompetitionDetail(this.competition);

  @override
  PastCompetitionDetailState createState() =>
      PastCompetitionDetailState(competition);
}

class PastCompetitionDetailState extends State<PastCompetitionDetail> {
  PastCompetitionDetailState(this.model);
  final CompetitionModel model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 4.0,
          title: Text(
            ApplicationLocalizations.of(context).translate('competition_text'),
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          leading: InkWell(
              onTap: () => NavigationService.instance.goBack(),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black)),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => NavigationService.instance
                      .navigateToRouteWithScale(ScaleRoute(
                          page: WebViewScreen(
                              ApplicationLocalizations.of(context)
                                  .translate('disclaimer_text'),
                              ConstantUtil.disclaimerUrl))),
                  child: Center(
                    child: Text(
                        ApplicationLocalizations.of(context)
                            .translate('disclaimer_text'),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ),
                ))
          ]),
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Stack(
                    children: [
                      Container(
                          height: 270.0,
                          margin: EdgeInsets.only(bottom: 30),
                          child: CachedNetworkImage(
                            imageUrl: model.photo,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            placeholder: (context, url) =>
                                AppUtil.addProgressIndicator(context),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )),
                      applyShader(),
                      Positioned(
                          bottom: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, bottom: 10),
                                child: Text(model.title,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                height: 60.0,
                                width: MediaQuery.of(context).size.width - 20,
                                margin: EdgeInsets.only(left: 10, right: 10),
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.wine_bar_outlined),
                                            Text(
                                                model.awardPrice == 0
                                                    ? '${model.awardCoin} ${ApplicationLocalizations.of(context).translate('rewardCoin_text')}'
                                                    : r"$" +
                                                        '${model.awardPrice} ${ApplicationLocalizations.of(context).translate('inReward_text')}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ]),
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.watch_later_outlined),
                                            Text(model.timeLeft,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w400))
                                          ]),
                                    ]),
                              )
                            ],
                          )),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 20, 10, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              ApplicationLocalizations.of(context)
                                  .translate('description_text'),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 6),
                          Text(model.description),
                        ],
                      )),
                  addPhotoGrid(),
                ])),
            addBottomActionButton()
          ])),
    );
  }

  addPhotoGrid() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      model.posts.length > 0
          ? Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(ApplicationLocalizations.of(context)
                  .translate('submittedPhotos_text')))
          : Container(),
      MasonryGridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        itemCount: model.posts.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) => InkWell(
            onTap: () async {
              File path = await AppUtil.findPath(model.posts[index].gallery.first.filePath);
              NavigationService.instance.navigateToRouteWithScale(
                  ScaleRoute(
                      page: EnlargeImageViewScreen(model.posts[index], path, handler: (){},)));
            },
            child: Container(
                child: ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: model.posts[index].gallery.first.filePath,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  AppUtil.addProgressIndicator(context),
              errorWidget: (context, url, error) => Icon(Icons.error),
            )))),
        // staggeredTileBuilder: (int index) => new StaggeredTile.count(1, 1),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
      SizedBox(height: 65)
    ]);
  }

  applyShader() {
    return Container(
        height: 270.0,
        margin: EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
              stops: [
                0.0,
                1.0
              ]),
        ));
  }

  addBottomActionButton() {
    return Positioned(
      bottom: 0,
      child: InkWell(
          onTap: () {
            if (model.winnerId != '') {
              NavigationService.instance.navigateToRouteWithScale(
                  ScaleRoute(page: WinnerDetailScreen(model.winnerPost.first)));
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            color: ColorsUtil.appThemeColor,
            child: Center(
              child: Text(
                  model.winnerId == ''
                      ? ApplicationLocalizations.of(context)
                          .translate('winnerAnnouncement_text')
                      : ApplicationLocalizations.of(context)
                          .translate('viewWinner_text'),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          )),
    );
  }
}
