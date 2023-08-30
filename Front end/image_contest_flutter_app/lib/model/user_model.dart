class UserModel {
  int id = 0;
  String name = '';
  String? email = '';
  String? picture = '';
  String? bio = '';
  String? phone = '';
  String? country = '';
  String? countryCode = '';
  String? city = '';
  String? gender = ''; //sex : 1=male, 2=female, 3=others

  String? totalPost = '';
  int? coins = 0;
  bool? isReported = false;
  String? paypalId;
  String balance = '';

  List<UserModel> followers = [];
  List<UserModel> followings = [];

  UserModel();

  factory UserModel.fromJson(dynamic json) {
    UserModel model = UserModel();
    model.id = json['id'];
    model.name = json['username'] ?? '';
    model.email = json['email'];
    model.picture = json['picture'];
    model.bio = json['bio'];
    model.phone = json['phone'];
    model.country = json['country'];
    model.countryCode = json['country_code'];
    model.city = json['city'];
    model.gender = json['sex'] == null ? 'Male' : json['sex'].toString();

    model.totalPost = json['totalPost'];
    model.coins = json['available_coin'];
    model.isReported = json['is_reported'] == 1;
    model.paypalId = json['paypal_id'];
    model.balance = (json['available_balance'] ?? '').toString();

    List<dynamic>? followerList = json['follower'];
    model.followers = [];
    if (followerList != null && followerList.length > 0) {
      followerList = followerList.where((element) => element['followerUserDetail'] != null).toList();

      model.followers = List<UserModel>.from(
          followerList.map((x) => UserModel.fromJson(x['followerUserDetail'])));
    }

    List<dynamic>? followingList = json['following'];
    model.followings = [];
    if (followingList != null && followingList.length > 0) {
      followingList = followingList.where((element) => element['followingUserDetail'] != null).toList();

      model.followings = List<UserModel>.from(followingList
          .map((x) => UserModel.fromJson(x['followingUserDetail'])));
    }
    return model;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "picture": picture,
    "bio": bio,
    "phone": phone,
    "country": country,
    "country_code": countryCode,
    "city": city,
    "sex": gender,
    "totalPost": totalPost,
    "available_coin": coins,
    "is_reported": isReported,
    "paypal_id": paypalId,
    "available_balance": balance
  };
}
