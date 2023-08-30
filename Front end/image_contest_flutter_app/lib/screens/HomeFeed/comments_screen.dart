import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/comment_model.dart';
import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/profile_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';

import '../../application_localizations.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel model;
  final VoidCallback handler;
  CommentsScreen(this.model, this.handler);

  @override
  CommentsScreenState createState() => CommentsScreenState();
}

class CommentsScreenState extends State<CommentsScreen> {
  List<CommentModel> comments = [];
  late UserModel user;

  TextEditingController textEditingController = TextEditingController();
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    SharedPrefs().getUser().then((value) => [user = value]);
    getCommentsApiCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0.0,
            automaticallyImplyLeading: false,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () => NavigationService.instance.goBack(),
                      child: Icon(Icons.arrow_back_ios, color: Colors.black87)),
                  Center(
                      child: Text(
                    ApplicationLocalizations.of(context)
                        .translate('comments_text'),
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  )),
                  Container()
                ])),
        body: Column(
          children: <Widget>[
            Flexible(
                child: ListView.builder(
                    itemCount: comments.length,
                    // reverse: true,
                    controller: _controller,
                    itemBuilder: (context, index) {
                      return CommentCard(comments[index]);
                    })),
            buildMessageTextField(),
          ],
        ));
  }

  Widget buildMessageTextField() {
    return Container(
      height: 50.0,
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: ApplicationLocalizations.of(context)
                  .translate('writeComment_text'),
              hintStyle: TextStyle(
                fontSize: 16.0,
                color: Color(0xffAEA4A3),
              ),
            ),
            textInputAction: TextInputAction.send,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
            onSubmitted: (_) {
              addNewMessage();
            },
            onTap: () {
              Timer(
                  Duration(milliseconds: 300),
                  () =>
                      _controller.jumpTo(_controller.position.maxScrollExtent));
            },
          )),
          Container(
            width: 50.0,
            child: InkWell(
              onTap: addNewMessage,
              child: Icon(
                Icons.send,
                color: ColorsUtil.appThemeColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  void addNewMessage() {
    if (textEditingController.text.trim().isNotEmpty) {
      CommentModel newMessage =
          CommentModel.fromNewMessage(textEditingController.text.trim(), user);
      newMessage.commentTime = ApplicationLocalizations.of(context)
          .translate('justNow_text');

      postCommentsApiCall(textEditingController.text.trim());
      comments.add(newMessage);
      textEditingController.text = '';
      widget.model.totalComment = comments.length;
      widget.handler();
      setState(() {});
      Timer(Duration(milliseconds: 500),
          () => _controller.jumpTo(_controller.position.maxScrollExtent));
    }
  }

  void getCommentsApiCall() {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController().getCommentsApi(widget.model.id).then((response) async {
          if (response.success) {
            comments = response.comments;
            widget.model.totalComment = comments.length;
            widget.handler();
            setState(() {});
          }
        });
      } else {
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('noInternet_text'),
            context);
      }
    });
  }

  void postCommentsApiCall(String comment) {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController().postCommentsApi(widget.model.id, comment);
      }
    });
  }
}

class CommentCard extends StatefulWidget {
  final CommentModel model;
  CommentCard(this.model);

  @override
  CommentCardState createState() => CommentCardState(model);
}

class CommentCardState extends State<CommentCard> {
  final CommentModel model;
  CommentCardState(this.model);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  child: InkWell(
                      onTap: () => NavigationService.instance.navigateToRouteWithScale(
                          ScaleRoute(page: ProfileScreen(model.userId))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black54),
                            ),
                            child: model.userPicture == null
                                ? Icon(Icons.error)
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: CachedNetworkImage(
                                      imageUrl: model.userPicture!,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) =>
                                          AppUtil.addProgressIndicator(context),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                model.userName,
                                style: new TextStyle(
                                    color: ColorsUtil.appThemeColor),
                              ),
                              Text(
                                model.comment,
                                style: new TextStyle(color: Colors.black),
                              )
                            ],
                          ))
                        ],
                      ))),
              Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(model.commentTime,
                      style: TextStyle(color: Colors.grey)))
            ]));
  }
}
