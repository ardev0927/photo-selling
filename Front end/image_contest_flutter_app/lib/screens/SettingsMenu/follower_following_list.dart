import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';

import '../../application_localizations.dart';
import 'profile_screen.dart';

class FollowerFollowingList extends StatefulWidget {
  final bool isFollowersList;
  final List<UserModel> usersList;
  FollowerFollowingList(this.isFollowersList, this.usersList);

  @override
  FollowerFollowingState createState() => FollowerFollowingState();
}

class FollowerFollowingState extends State<FollowerFollowingList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          title:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
                onTap: () => NavigationService.instance.goBack(),
                child: Icon(Icons.arrow_back_ios, color: Colors.black87)),
            Center(
                child: Text(
                  widget.isFollowersList
                      ? ApplicationLocalizations.of(context)
                      .translate('followerSmall_text')
                      : ApplicationLocalizations.of(context)
                      .translate('followingSmall_text'),
                  style: TextStyle(color: Colors.black, fontSize: 18),
                )),
            Container()
          ])),
      body: widget.usersList.length == 0
          ? Center(
          child: Text(
              ApplicationLocalizations.of(context).translate('noData_text'),
              style: TextStyle(
                  color: ColorsUtil.appThemeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)))
          : ListView.builder(
          itemCount: widget.usersList.length,
          itemBuilder: (context, index) {
            return UserCard(widget.usersList[index]);
          }),
    );
  }
}

class UserCard extends StatefulWidget {
  final UserModel model;

  UserCard(this.model);

  @override
  UserCardState createState() => UserCardState(model);
}

class UserCardState extends State<UserCard> {
  final UserModel model;
  UserCardState(this.model);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 5),
        child: InkWell(
          onTap: () => NavigationService.instance.navigateToRouteWithScale(ScaleRoute(page: ProfileScreen(model.id))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black54),
                ),
                child: model.picture == null
                    ? Icon(Icons.error)
                    : ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: CachedNetworkImage(
                      imageUrl: model.picture!,
                      fit: BoxFit.fill,
                      placeholder: (context, url) =>
                          AppUtil.addProgressIndicator(context),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    )),
              ),
              SizedBox(width: 10),
              Text(
                model.name,
                style: new TextStyle(color: ColorsUtil.appThemeColor),
              ),
            ],
          ),
        ));
  }
}
