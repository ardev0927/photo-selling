import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/apiHandler/api_response_model.dart';
import 'package:image_contest_flutter_app/model/competition_model.dart';
import 'package:image_contest_flutter_app/screens/Competitions/competition_card.dart';
import 'package:image_contest_flutter_app/screens/Competitions/competition_detail_screen.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';

import '../../application_localizations.dart';
import 'past_competition_detail.dart';

class CompetitionsScreen extends StatefulWidget {
  @override
  CompetitionsState createState() => CompetitionsState();
}

class CompetitionsState extends State<CompetitionsScreen> {
  List<String> competitionsArr = ['upcoming_text', 'ongoing_text', 'past_text'];
  List<CompetitionModel> upcoming = [];
  List<CompetitionModel> ongoing = [];
  List<CompetitionModel> past = [];
  late Future<dynamic> competitionResponse;

  @override
  void initState() {
    super.initState();
    competitionResponse = ApiController().getCompetitionsApi();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: competitionsArr.length,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0.0,
            title: Center(
                child: Text(
              ApplicationLocalizations.of(context)
                  .translate('competitions_text'),
              style: TextStyle(color: Colors.black, fontSize: 18),
            ))),
        body: Column(children: <Widget>[
          TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: ColorsUtil.appThemeColor,
            indicatorColor: ColorsUtil.appThemeColor,
            indicatorWeight: 2,
            tabs: List.generate(competitionsArr.length, (int index) {
              return Visibility(
                visible: true,
                child: Tab(
                  text: ApplicationLocalizations.of(context).translate(competitionsArr[index]),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          FutureBuilder(
            future: competitionResponse, // async work
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                ApiResponseModel apiResponse = snapshot.data;
                if (apiResponse.success) {
                  var allCompetitions = apiResponse.competitions;
                  upcoming = allCompetitions
                      .where((element) => element.isUpcoming)
                      .toList();
                  ongoing = allCompetitions
                      .where((element) => element.isOngoing)
                      .toList();
                  past = allCompetitions
                      .where((element) => element.isPast)
                      .toList();

                  return Expanded(
                      child: TabBarView(
                    children:
                        List.generate(competitionsArr.length, (int index) {
                      return index == 0
                          ? addCompetitionsList(upcoming)
                          : index == 1
                              ? addCompetitionsList(ongoing)
                              : addCompetitionsList(past);
                    }),
                  ));
                } else {
                  return Center(
                      child: Text(ApplicationLocalizations.of(context)
                          .translate('noData_text')));
                }
              } else {
                //Show Loader
                return Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorsUtil.appThemeColor)),
                );
              }
            },
          )
        ]),
      ),
    );
  }

  addCompetitionsList(List<CompetitionModel> arr) {
    return ListView.builder(
      itemCount: arr.length,
      itemBuilder: (context, index) {
        CompetitionModel model = arr[index];
        return CompetitionCard(model, () {
          model.isPast
              ? NavigationService.instance.navigateToRouteWithScale(
                  ScaleRoute(
                    page: PastCompetitionDetail(model),
                  ))
              : NavigationService.instance.navigateToRouteWithScale(
                  ScaleRoute(
                    page: CompetitionDetailScreen(model,
                        refreshPreviousScreen: () {
                      competitionResponse =
                          ApiController().getCompetitionsApi();
                      setState(() {});
                    }),
                  ));
        });
      },
    );
  }
}
