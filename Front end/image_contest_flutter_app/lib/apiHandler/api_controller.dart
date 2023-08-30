import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_contest_flutter_app/apiHandler/api_param_model.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';
import 'api_response_model.dart';
import 'network_constant.dart';
import 'package:http_parser/http_parser.dart';

class ApiController {
  final JsonDecoder _decoder = const JsonDecoder();

  Future<ApiResponseModel> loginApi(String email, String password) async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.login;
    dynamic param = ApiParamModel().getLoginParam(email, password);
    print(url);
    print(param);

    return http.post(Uri.parse(url), body: param).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> socialLoginApi(
      String name, String socialType, String socialId, String email) async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.socialLogin;
    dynamic param =
    ApiParamModel().getSocialLoginParam(name, socialType, socialId, email);
    print(param);
    print(url);
    return http.post(Uri.parse(url), body: param).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> registerUserApi(
      String name, String email, String password) async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.register;
    dynamic param = ApiParamModel().getSignUpParam(name, email, password);
    return http.post(Uri.parse(url), body: param).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> checkUsernameApi(
      String username) async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.checkUserName;
    dynamic param = ApiParamModel().getCheckUsernameParam(username);
    return http.post(Uri.parse(url), body: param).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> forgotPasswordApi(String emailOrPhone) async {
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.forgotPassword;

    dynamic param = ApiParamModel().getForgotpwdParam(emailOrPhone,'','');

    return http
        .post(Uri.parse(url), body: param).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> resetPasswordApi(String password,String token) async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.resetPassword;
    dynamic param = ApiParamModel().getResetPwdParam(token, password);
    return http
        .post(Uri.parse(url), body: param).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> resendOTPApi(String token) async {
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.resendOTP;

    dynamic param = ApiParamModel().getResendOTPParam(token);
    print('param');
    print(param);
    return http
        .post(Uri.parse(url), body: param).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> verifyOTPApi( bool isRegistration, String OTP,String token) async {
    var url = NetworkConstantsUtil.baseUrl + (isRegistration == true ? NetworkConstantsUtil.verifyRegistrationOTP : NetworkConstantsUtil.verifyFwdPWDOTP);

    dynamic param = ApiParamModel().getVerifyOTPParam(token,OTP);
    print(param);
    return http
        .post(Uri.parse(url), body: param).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> getPostsApi(
      String? userId, int isPopular, int isFollowing, int isMine) async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.searchPost;
    if (userId != null) {
      url = url + '&user_id=$userId';
    }
    url = url +
        '&is_popular_post=$isPopular&is_following_user_post=$isFollowing&is_my_post=$isMine';

    return await http
        .get(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}).then(
            (http.Response response) async {
          final ApiResponseModel parsedResponse = await getResponse(response.body);
          return parsedResponse;
        });
  }

  Future<ApiResponseModel> likeUnlikeApi(bool isLiked, int postId) async {
    var url = NetworkConstantsUtil.baseUrl +
        (isLiked
            ? NetworkConstantsUtil.unlikePost
            : NetworkConstantsUtil.likePost);
    String authKey = await SharedPrefs().getAuthorizationKey();

    return http.post(Uri.parse(url), headers: {
      "Authorization": "Bearer $authKey"
    }, body: {
      "post_id": postId.toString()
    }).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> getCommentsApi(int postId) async {
    var url = NetworkConstantsUtil.baseUrl +
        NetworkConstantsUtil.getComments +
        '?expand=user&post_id=$postId';
    String authKey = await SharedPrefs().getAuthorizationKey();

    return http.get(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}).then(
            (http.Response response) async {
          final ApiResponseModel parsedResponse = await getResponse(response.body);
          return parsedResponse;
        });
  }

  Future<ApiResponseModel> postCommentsApi(int postId, String comment) async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.addComment;
    String authKey = await SharedPrefs().getAuthorizationKey();

    return http.post(Uri.parse(url), headers: {
      "Authorization": "Bearer $authKey"
    }, body: {
      "post_id": postId.toString(),
      'comment': comment
    }).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> reportPostApi(int postId) async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.reportPost;
    String authKey = await SharedPrefs().getAuthorizationKey();

    return http.post(Uri.parse(url), headers: {
      "Authorization": "Bearer $authKey"
    }, body: {
      "post_id": postId.toString()
    }).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> getOtherUserApi(String userId) async {
    var url = NetworkConstantsUtil.baseUrl +
        NetworkConstantsUtil.otherUser +
        userId +
        '?expand=following.followingUserDetail,follower,follower.followerUserDetail,totalPost';
    String authKey = await SharedPrefs().getAuthorizationKey();

    return http.get(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}).then(
            (http.Response response) async {
          final ApiResponseModel parsedResponse = await getResponse(response.body);
          return parsedResponse;
        });
  }

  Future<ApiResponseModel> getUserProfileApi() async {
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.getUserProfile;
    String authKey = await SharedPrefs().getAuthorizationKey();

    return http.get(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}).then(
            (http.Response response) async {
          final ApiResponseModel parsedResponse = await getResponse(response.body);
          return parsedResponse;
        });
  }

  Future<ApiResponseModel> updateUserProfileApi(UserModel user) async {
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.updateUserProfile;
    String authKey = await SharedPrefs().getAuthorizationKey();

    return http.post(Uri.parse(url), headers: {
      "Authorization": "Bearer $authKey"
    }, body: {
      "name": user.name,
      "bio": user.bio,
      "country_code": user.countryCode,
      "phone": user.phone,
      "country": user.country,
      "city": user.city,
      "sex": user.gender,
    }).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> updateProfileImageApi(File imageFile) async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var postUri = Uri.parse(
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.updateProfileImage);
    var request = new http.MultipartRequest("POST", postUri);
    request.headers.addAll({"Authorization": "Bearer $authKey"});

    request.files.add(http.MultipartFile.fromBytes(
        'imageFile', await imageFile.readAsBytes(),
        filename: DateTime.now().toIso8601String() + '.jpg',
        contentType: new MediaType('image', 'jpg')));

    return request.send().then((response) async {
      final respStr = await response.stream.bytesToString();
      final ApiResponseModel parsedResponse = await getResponse(respStr);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> followUnFollowUserApi(
      bool isFollowing, String userId) async {
    var url = NetworkConstantsUtil.baseUrl +
        (isFollowing
            ? NetworkConstantsUtil.unfollowUser
            : NetworkConstantsUtil.followUser);
    String authKey = await SharedPrefs().getAuthorizationKey();

    return http.post(Uri.parse(url), headers: {
      "Authorization": "Bearer $authKey"
    }, body: {
      "user_id": userId,
    }).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> reportUserApi(int userId) async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.reportUser;
    String authKey = await SharedPrefs().getAuthorizationKey();

    return http.post(Uri.parse(url), headers: {
      "Authorization": "Bearer $authKey"
    }, body: {
      "report_to_user_id": userId.toString()
    }).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> addPostApi(String title, String imageFile,
      String hashTag, String? competitionId) async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var postUri = Uri.parse(NetworkConstantsUtil.baseUrl +
        (competitionId == null
            ? NetworkConstantsUtil.addPost
            : NetworkConstantsUtil.addCompetitionPost));
    var gallery = [{'filename': imageFile,'type':'1', 'media_type' :'1','is_default' :'1'}];

    return http.post(postUri, headers: {
      "Authorization": "Bearer $authKey"
    }, body: {
      "type": '1',
      "title":title,
      "hashtag": authKey,
      "gallary":gallery.toString()
    }).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });

  }

  Future<ApiResponseModel> uploadPostImage(filepath) async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.uploadPostImage;
    var request = http.MultipartRequest('POST', Uri.parse(url));
    String authKey = await SharedPrefs().getAuthorizationKey();
    print(authKey);
    request.headers.addAll({"Authorization": "Bearer $authKey"});
    request.files.add(await http.MultipartFile.fromPath('filenameFile', filepath));
    var res = await request.send();
    var responseData = await res.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);
    final ApiResponseModel parsedResponse = await getResponse(responseString);

    return parsedResponse;
  }

  Future<ApiResponseModel> getCompetitionsApi() async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.getCompetitions;

    return await http
        .get(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}).then(
            (http.Response response) async {
          final ApiResponseModel parsedResponse = await getResponse(response.body);
          return parsedResponse;
        });
  }

  Future<ApiResponseModel> joinCompetitionApi(int competitionId) async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.joinCompetition;

    return http.post(Uri.parse(url), headers: {
      "Authorization": "Bearer $authKey"
    }, body: {
      "competition_id": competitionId.toString()
    }).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> getPopularUsersApi() async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.searchUsers;
    var params = {
      "name": "",
      "is_popular_user": "1",
      "is_following_user": "0",
      "is_follower_user": "0"
    };

    return await http
        .post(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}, body: params)
        .then((http.Response response) async {
      final ApiResponseModel parsedResponse =
      await getArrayResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> getAllPackagesApi() async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.getPackages;

    return await http
        .get(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}).then(
            (http.Response response) async {
          final ApiResponseModel parsedResponse = await getResponse(response.body);
          return parsedResponse;
        });
  }

  Future<ApiResponseModel> subscribePackageApi(
      String packageId, String transactionId, String amount) async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.subscribePackage;

    return await http.post(Uri.parse(url), headers: {
      "Authorization": "Bearer $authKey"
    }, body: {
      "package_id": packageId,
      "transaction_id": transactionId,
      "amount": amount
    }).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> updatePaymentDetailsApi(String paypalId) async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.updatePaymentDetail;
    var params = {"paypal_id": paypalId};

    return await http
        .post(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}, body: params)
        .then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> getAllCountriesList() async {
    var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.getCountries;

    return await http.get(Uri.parse(url)).then((http.Response response) async {
      final ApiResponseModel parsedResponse = await getResponse(response.body);
      return parsedResponse;
    });
  }

  Future<ApiResponseModel> getWithdrawHistory() async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.withdrawHistory;

    return await http
        .get(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}).then(
            (http.Response response) async {
          final ApiResponseModel parsedResponse = await getResponse(response.body);
          return parsedResponse;
        });
  }

  Future<ApiResponseModel> performWithdrawalRequest() async {
    String authKey = await SharedPrefs().getAuthorizationKey();
    var url =
        NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.withdrawalRequest;

    return await http
        .post(Uri.parse(url), headers: {"Authorization": "Bearer $authKey"}).then(
            (http.Response response) async {
          final ApiResponseModel parsedResponse = await getResponse(response.body);
          return parsedResponse;
        });
  }

  Future<ApiResponseModel> getResponse(String res) async {
    try {
      dynamic data = _decoder.convert(res);
      if (data['status'] == 401 && data['data'] == null) {
        return ApiResponseModel.fromJson(
            {"message": data['message'], "isInvalidLogin": true});
      } else {
        return ApiResponseModel.fromJson(data);
      }
    } catch (e) {
      return ApiResponseModel.fromJson({"message": e.toString()});
    }
  }

  Future<ApiResponseModel> getArrayResponse(String res) async {
    try {
      dynamic data = _decoder.convert(res);
      if (data['status'] == 401 && data['data'] == null) {
        // SharedPrefs().clearPreferences();
        // NavigationService.instance
        //     .navigateToReplacementWithScale(ScaleRoute(page: TutorialScreen()));
        return ApiResponseModel.fromJson(
            {"message": data['message'], "isInvalidLogin": true});
      } else {
        return ApiResponseModel.fromUsersJson(data);
      }
    } catch (e) {
      return ApiResponseModel.fromJson({"message": e.toString()});
    }
  }
}
