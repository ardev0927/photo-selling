import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/competition_model.dart';
import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/screens/AddPost/add_post_screen.dart';
import 'package:image_contest_flutter_app/screens/HomeFeed/enlarge_image_view.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/packages_screen.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/photo_gallery_screen.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/web_view_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/constant_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../application_localizations.dart';

class CompetitionDetailScreen extends StatefulWidget {
  final CompetitionModel competition;
  final VoidCallback refreshPreviousScreen;

  const CompetitionDetailScreen(this.competition, {required this.refreshPreviousScreen});

  @override
  CompetitionDetailState createState() => CompetitionDetailState(competition);
}

class CompetitionDetailState extends State<CompetitionDetailScreen> {
  CompetitionDetailState(this.model);
  final CompetitionModel model;
  int signedInUser = 0;
  int coin = 0;

  @override
  void initState() {
    super.initState();
    SharedPrefs().getUser().then((value) {
      setState(() {
        signedInUser = value.id;
        coin = value.coins ?? 0;
      });
    });
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
            ApplicationLocalizations.of(context).translate('competition_text'),
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          leading: InkWell(
              onTap: () => NavigationService.instance.goBack(),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black)),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => NavigationService.instance.navigateToRouteWithScale(
                      ScaleRoute(
                          page: WebViewScreen(
                              ApplicationLocalizations.of(context)
                                  .translate('disclaimer_text'),
                              ConstantUtil.disclaimerUrl))),
                  child: Center(
                    child: Text(
                        ApplicationLocalizations.of(context)
                            .translate('disclaimer_text'),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ),
                ))
          ]),
      body: SizedBox(
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
                        margin: const EdgeInsets.only(bottom: 30),
                        child: CachedNetworkImage(
                          imageUrl: model.photo,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          placeholder: (context, url) =>
                              AppUtil.addProgressIndicator(context),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )),
                    applyShader(),
                    Positioned(
                        bottom: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Text(model.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Container(
                              height: 60.0,
                              width: MediaQuery.of(context).size.width - 20,
                              margin: const EdgeInsets.only(left: 10, right: 10),
                              padding: const EdgeInsets.only(left: 10, right: 10),
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
                                          const Icon(Icons.wine_bar_outlined),
                                          Text(
                                              model.awardPrice == 0
                                                  ? '${model.awardCoin} ${ApplicationLocalizations.of(context).translate('rewardCoin_text')}'
                                                  : '\$${model.awardPrice} ${ApplicationLocalizations.of(context).translate('inReward_text')}',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400)),
                                        ]),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.watch_later_outlined),
                                          Text(model.timeLeft,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400))
                                        ]),
                                    InkWell(
                                      onTap: () {
                                        NavigationService.instance.navigateToRouteWithScale(
                                            ScaleRoute(
                                                page: PhotoGalleryScreen(
                                                    model.posts)));
                                      },
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.photo_library_outlined),
                                            Text(
                                                '${model.posts.length} ${ApplicationLocalizations.of(context).translate('photos_text')}',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ]),
                                    ),
                                  ]),
                            )
                          ],
                        )),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            ApplicationLocalizations.of(context)
                                .translate('description_text'),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text(model.description),
                      ],
                    )),
                addPhotoGrid(),
              ])),
          addBottomActionButton()
        ]),
      ),
    );
  }

  addPhotoGrid() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      model.exampleImages.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(ApplicationLocalizations.of(context)
                  .translate('examplePhotos_text')))
          : Container(),
      MasonryGridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        itemCount: model.exampleImages.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) => InkWell(
            onTap: () async {
              File path = await AppUtil.findPath(model.exampleImages[index]);
              NavigationService.instance.navigateToRouteWithScale(
                  ScaleRoute(page: EnlargeImageViewScreen(null, path, handler: (){})));
            },
            child: ClipRRect(
                child: CachedNetworkImage(
              imageUrl: model.exampleImages[index],
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  AppUtil.addProgressIndicator(context),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ))),
        // staggeredTileBuilder: (int index) => new StaggeredTile.count(1, 1),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
      const SizedBox(height: 65)
    ]);
  }

  applyShader() {
    return Container(
        height: 270.0,
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
              stops: const [
                0.0,
                1.0
              ]),
        ));
  }

  addBottomActionButton() {
    String title;
    var loggedInUserPost =
        model.posts.where((element) => element.userId == signedInUser).toList();
    if (model.isJoined == 1) {
      title = loggedInUserPost.isNotEmpty
          ? ApplicationLocalizations.of(context)
              .translate('viewSubmission_text')
          : ApplicationLocalizations.of(context).translate('postPhoto_text');
    } else {
      title =
          "${ApplicationLocalizations.of(context).translate('join_text')} (Fee: ${model.joiningFee} coins)";
    }

    return Positioned(
      bottom: 0,
      child: InkWell(
          onTap: () async {
            if (model.isJoined == 1) {
              //Already Joined Mission
              if (loggedInUserPost.isNotEmpty) {
                //User have already published post for this competition
                PostModel postModel = loggedInUserPost.first;
                File path = await AppUtil.findPath(postModel.gallery.first.filePath);
                NavigationService.instance.navigateToRouteWithScale(
                    ScaleRoute(
                        page: EnlargeImageViewScreen(postModel, path,
                            handler: () {
                      setState(() {});
                    })));
              } else {
                widget.refreshPreviousScreen();
                NavigationService.instance.navigateToRouteWithScale(
                    ScaleRoute(page: AddPostScreen(model.id.toString())));
              }
            } else {
              if (coin > model.joiningFee) {
                widget.refreshPreviousScreen();
                joinCompetitionApiCall();
              } else {
                NavigationService.instance.navigateToRouteWithScale(ScaleRoute(
                  page: PackagesScreen((newCoins) {
                    setState(() {
                      coin += newCoins;
                    });
                  }),
                ));
              }
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            color: ColorsUtil.appThemeColor,
            child: Center(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          )),
    );
  }

  void joinCompetitionApiCall() {
    AppUtil.checkInternet().then((value) {
      if (value) {
        AppUtil.showLoader(context);
        ApiController().joinCompetitionApi(model.id).then((response) async {
          Navigator.of(context).pop();
          AppUtil.showToast(response.message, context);
          model.isJoined = 1;
          setState(() {});
        });
      } else {
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('noInternet_text'),
            context);
      }
    });
  }
}
