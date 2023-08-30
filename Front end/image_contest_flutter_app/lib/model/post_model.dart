import 'package:image_contest_flutter_app/model/post_gallery.dart';

import 'package:timeago/timeago.dart' as timeago;

class PostModel {
  int id = 0;
  String title = '';

  int userId = 0;
  String username = '';
  String? userPicture = '';

  int? competitionId = 0;

  int totalView = 0;
  int totalLike = 0;
  int totalComment = 0;
  int totalShare = 0;
  int isWinning = 0;
  bool isLike = false;
  bool isReported = false;

  List<PostGallery> gallery = [];
  List<String> tags = [];
  String postTime = '';
  DateTime? createDate;

  PostModel();

  factory PostModel.fromJson(dynamic json) {
    PostModel model = PostModel();
    model.id = json['id'];
    model.title = json['title'] ?? 'No title';

    model.userId = json['user_id'];
    if (json['user'] != null) {
      model.username = json['user']['name'] ?? 'No name';
      model.userPicture = json['user']['picture'];
    }
    model.competitionId = json['competition_id'];
    model.totalView = json['total_view'];
    model.totalLike = json['total_like'] ?? 0;
    model.totalComment = json['total_comment'] ?? 0;
    model.totalShare = json['total_share'];
    model.isWinning = json['is_winning'];

    model.isLike = json['is_like'] == 1;
    model.isReported = json['is_reported'] == 1;

    // model.imageUrl = json['imageUrl'];
    model.tags = [];
    if (json['hashtags'] != null && json['hashtags'].length > 0) {
      model.tags = List<String>.from(json['hashtags'].map((x) => '#$x'));
    }

    if (json['postGallary'] != null && json['postGallary'].length > 0) {
      model.gallery = List<PostGallery>.from(json['postGallary'].map((x) => PostGallery.fromJson(x)));
    }

    model.createDate =
        DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000).toUtc();

    model.postTime = timeago.format(model.createDate!);

    // final days = model.createDate!.difference(DateTime.now()).inDays;
    // if (days == 0) {
    //   model.postTime = ApplicationLocalizations.of(
    //           NavigationService.instance.getCurrentStateContext())
    //       .translate('today_text');
    // } else if (days == 1) {
    //   model.postTime = ApplicationLocalizations.of(
    //           NavigationService.instance.getCurrentStateContext())
    //       .translate('yesterday_text');
    // } else {
    //   String dateString = DateFormat('MMM dd, yyyy').format(model.createDate!);
    //   String timeString = DateFormat('hh:ss a').format(model.createDate!);
    //   model.postTime =
    //       '$dateString ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('at_text')} $timeString';
    // }
    return model;
  }
}
