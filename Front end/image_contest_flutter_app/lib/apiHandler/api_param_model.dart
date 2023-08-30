import 'dart:io';

class ApiParamModel {
  dynamic getLoginParam(String email, String password) {
    return {
      "email": email,
      "password": password,
      "device_type": Platform.isAndroid ? '1' : '2',
      "device_token": "sfjf34872sdlkfjsu834dskfjisdaaaa"
    };
  }

  dynamic getSocialLoginParam(
      String name, String socialType, String socialId, String email) {
    return {
      "name": name,
      "username": "",
      "social_type": socialType,
      "social_id": socialId,
      "email": email,
      "device_type": Platform.isAndroid ? '1' : '2',
      "device_token": "sfjf34872sdlkfjsu834dskfjisdaaaa"
    };
  }

  dynamic getSignUpParam(String name, String email, String password) {
    return {
      "name": name,
      "username": email,
      "email": email,
      "password": password,
      "device_type": Platform.isAndroid ? '1' : '2',
      "device_token": "sfjf34872sdlkfjsu834dskfjisdaaaa",
      "country_id": "101"
    };
  }

  dynamic getForgotpwdParam(
      String email, String countyCode, String phoneNumber) {
    return {
      "verification_with": '1',
      "email": email,
      "country_code": countyCode,
      "phone" :phoneNumber
    };
  }

  dynamic getResetPwdParam(
      String token, String password) {
    return {
      "token": token,
      "password": password,
    };
  }

  dynamic getVerifyOTPParam(
      String token, String otp) {
    return {
      "otp": otp,
      "token": token,
    };
  }

  dynamic getCheckUsernameParam(
      String username) {
    return {
      "username": username,
    };
  }

  dynamic getResendOTPParam(
      String token) {
    return {
      "token": token,
    };
  }
}
