import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/model/competition_model.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';

import '../../application_localizations.dart';

class CompetitionCard extends StatefulWidget {
  final CompetitionModel model;
  final VoidCallback handler;
  CompetitionCard(this.model, this.handler);

  @override
  CompetitionCardState createState() => CompetitionCardState(model);
}

class CompetitionCardState extends State<CompetitionCard> {
  final CompetitionModel model;
  CompetitionCardState(this.model);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => widget.handler(),
        child: Column(children: [
          Stack(
            children: [
              Container(
                  height: 210.0,
                  margin: EdgeInsets.only(bottom: 20),
                  child: CachedNetworkImage(
                    imageUrl: model.photo,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    placeholder: (context, url) =>
                        AppUtil.addProgressIndicator(context),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
              applyShader(),
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Text(model.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18))),
              Positioned(
                  bottom: 0,
                  child: Container(
                    height: 40.0,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              model.awardPrice == 0
                                  ? '${model.awardCoin} ${ApplicationLocalizations.of(context).translate('rewardCoin_text')}'
                                  : '\$${model.awardPrice} ${ApplicationLocalizations.of(context).translate('inReward_text')}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500)),
                          Text(model.timeLeft,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500))
                        ]),
                  ))
            ],
          ),
          Container(
              width: MediaQuery.of(context).size.width - 20,
              child: Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(model.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.left))),
        ]));
  }

  applyShader() {
    return Container(
        height: 210.0,
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
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
}
