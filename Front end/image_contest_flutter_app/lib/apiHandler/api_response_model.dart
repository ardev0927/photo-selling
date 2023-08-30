import 'package:image_contest_flutter_app/model/comment_model.dart';
import 'package:image_contest_flutter_app/model/competition_model.dart';
import 'package:image_contest_flutter_app/model/country_model.dart';
import 'package:image_contest_flutter_app/model/package_model.dart';
import 'package:image_contest_flutter_app/model/payment_model.dart';
import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/util/constant_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';

import '../application_localizations.dart';

class ApiResponseModel {
  bool success = true;
  String message = "";
  bool isInvalidLogin = true;
  String? authKey;
  String? postImagePath;
  String? token;

  UserModel? user;
  List<UserModel> popularUser = [];

  List<CompetitionModel> competitions = [];
  List<PostModel> posts = [];
  List<CommentModel> comments = [];
  List<PackageModel> packages = [];
  List<CountryModel> countries = [];
  List<PaymentModel> payments = [];

  ApiResponseModel();

  factory ApiResponseModel.fromJson(dynamic json) {
    ApiResponseModel model = ApiResponseModel();
    model.success = json['status'] == 200;
    dynamic data = json['data'];
    model.isInvalidLogin = json['isInvalidLogin'] == null ? false : true;

    print('parsing response from api');

    print(json);

    print('response');

    if (model.success) {
      model.message = json['message'];
      if (data != null && data.length > 0) {
        if (data['user'] != null) {
          model.user = UserModel.fromJson(data['user']);
          model.authKey = data['auth_key'];
        } else if (data['competition'] != null) {
          var items = data['competition']['items'];
          if (items != null && items.length > 0) {
            model.competitions = List<CompetitionModel>.from(
                items.map((x) => CompetitionModel.fromJson(x)));
          }
        }
        else if (data['token'] != null) {
          model.token =  data['token'] as String;
        }
        else if (data['filename'] != null) {
          model.postImagePath =  data['filename'] as String;
        }
        else if (data['post'] != null) {
          model.posts = [];
          var items = data['post']['items'];
          if (items != null && items.length > 0) {
            model.posts =
            List<PostModel>.from(items.map((x) => PostModel.fromJson(x)));
          }
        } else if (data['comment'] != null) {
          model.comments = [];
          var items = data['comment']['items'];
          if (items != null && items.length > 0) {
            model.comments = List<CommentModel>.from(
                items.map((x) => CommentModel.fromJson(x)));
          }
        } else if (data['package'] != null) {
          model.packages = [];
          var packagesArr = data['package'];
          if (packagesArr != null && packagesArr.length > 0) {
            model.packages = List<PackageModel>.from(
                packagesArr.map((x) => PackageModel.fromJson(x)));
          }
        } else if (data['country'] != null && data['country'].length > 0) {
          model.countries = List<CountryModel>.from(
              data['country'].map((x) => CountryModel.fromJson(x)));
        } else if (data['payment'] != null && data['payment'].length > 0) {
          model.payments = List<PaymentModel>.from(
              data['payment'].map((x) => PaymentModel.fromJson(x)));
        }
      }
    } else {
      if (data['token'] != null) {
        model.token =  data['token'] as String;
      }

      Map errors = data['errors'];
      var errorsArr = errors[errors.keys.first] ?? [];
      String error = errorsArr.first ??
          ApplicationLocalizations.of(
              NavigationService.instance.getCurrentStateContext())
              .translate('serverError_text');
      model.message = error;
    }
    return model;
  }

  factory ApiResponseModel.fromUsersJson(dynamic json) {
    ApiResponseModel model = ApiResponseModel();
    model.success = json['status'] == 200;
    dynamic data = json['data'];

    if (model.success) {
      model.message = json['message'];
      if (data != null && data.length > 0) {
        if (data['user'] != null && data['user'].length > 0) {
          model.popularUser = List<UserModel>.from(
              data['user'].map((x) => UserModel.fromJson(x)));
        }
      }
    } else {
      Map errors = data['errors'];
      var errorsArr = errors[errors.keys.first] ?? [];
      String error = errorsArr.first ??
          ApplicationLocalizations.of(
              NavigationService.instance.getCurrentStateContext())
              .translate('serverError_text');
      model.message = error;
    }
    return model;
  }

  factory ApiResponseModel.fromErrorJson(dynamic json) {
    ApiResponseModel model = ApiResponseModel();
    model.success = false;
    model.message = json['message'];
    return model;
  }
}
