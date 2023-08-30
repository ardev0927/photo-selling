import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import '../application_localizations.dart';

class CompetitionModel {
  int id = 0;
  String title = '';
  String photo = '';
  String description = '';

  int awardPrice = 0;
  int awardCoin = 0;
  int joiningFee = 0;
  int isJoined = 0;

  bool isUpcoming = false;
  bool isOngoing = false;
  bool isPast = false;
  String timeLeft = '';

  List<String> exampleImages = [];
  List<PostModel> posts = [];

  String winnerId = '';
  List<PostModel> winnerPost = [];

  CompetitionModel();

  factory CompetitionModel.fromJson(dynamic json) {
    CompetitionModel model = CompetitionModel();
    model.id = json['id'];
    model.title = json['title'];
    model.photo = json['imageUrl'];
    model.description = json['description'] ?? '';

    model.awardPrice = json['award_type'] == 1 ? json['price'] : 0;
    model.awardCoin = json['award_type'] == 1 ? 0 : json['coin'];
    model.joiningFee = json['joining_fee'] ?? 0;
    model.isJoined = json['is_joined'];

    var startDate =
    DateTime.fromMillisecondsSinceEpoch(json['start_date'] * 1000).toUtc();
    var endDate =
    DateTime.fromMillisecondsSinceEpoch(json['end_date'] * 1000).toUtc();

    model.isUpcoming = startDate.isAfter(DateTime.now());
    model.isOngoing =
        startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());
    model.isPast = endDate.isBefore(DateTime.now());

    if (model.isUpcoming) {
      model.timeLeft =
      '${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('startingIn_text')} ${getCompetitionTimeString(startDate, DateTime.now())}';
    } else if (model.isOngoing) {
      model.timeLeft = getCompetitionTimeString(DateTime.now(), endDate) +
          ' ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('left_text')}';
    } else if (model.isPast) {
      model.timeLeft =
      '${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('ended_text')} ${getCompetitionTimeString(endDate, DateTime.now())} ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('ago_text')}';
    }

    model.exampleImages = [];
    if (json['expampleImages'] != null && json['expampleImages'].length > 0) {
      model.exampleImages =
      List<String>.from(json['expampleImages'].map((x) => x));
    }

    model.posts = [];
    if (json['post'] != null && json['post'].length > 0) {
      model.posts =
      List<PostModel>.from(json['post'].map((x) => PostModel.fromJson(x)));
    }

    model.winnerId =
    json['winner_id'] == null ? '' : json['winner_id'].toString();
    model.winnerPost = [];
    if (json['winnerPost'] != null && json['winnerPost'].length > 0) {
      model.winnerPost = List<PostModel>.from(
          json['winnerPost'].map((x) => PostModel.fromJson(x)));
    }
    return model;
  }
}

String getCompetitionTimeString(DateTime date1, DateTime date2) {
  DateTime earliest = date1.isBefore(date2) ? date1 : date2;
  DateTime latest = earliest == date1 ? date2 : date1;

  final days = latest.difference(earliest).inDays;
  if (days == 0) {
    final hours = latest.difference(earliest).inHours;
    if (hours == 0) {
      final minutes = latest.difference(earliest).inMinutes;
      return minutes == 0
          ? ApplicationLocalizations.of(
          NavigationService.instance.getCurrentStateContext())
          .translate('fewMinutes_text')
          : '$minutes ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('minutes_text')}';
    } else {
      return '$hours ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('hours_text')}';
    }
  } else {
    return '$days ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('days_text')}';
  }
}
