import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/model/user_model.dart';
import 'package:image_contest_flutter_app/screens/SettingsMenu/choose_country_screen.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:image_contest_flutter_app/util/shared_prefs.dart';

import '../../application_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  final Function(UserModel) handler;
  EditProfileScreen(this.handler);

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfileScreen> {
  late UserModel user;
  late File pickedImage;
  final picker = ImagePicker();
  late String picture;

  TextEditingController name = TextEditingController();
  TextEditingController bio = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController country = TextEditingController();
  String countryCode = '';
  TextEditingController city = TextEditingController();
  late int gender;

  Future<bool> pop() async {
    widget.handler(user);
    return true;
  }

  @override
  void initState() {
    super.initState();
    SharedPrefs().getUser().then((value) {
      user = value;
      picture = value.picture ?? "";
      name.text = value.name ;
      bio.text = value.bio ?? "";
      phone.text = value.phone  ?? "";
      country.text = value.country  ?? "";
      countryCode = value.countryCode ?? "";
      city.text = value.city ?? "";
      gender = int.parse(value.gender ?? '1');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 4.0,
            title: Text(
              ApplicationLocalizations.of(context)
                  .translate('editProfile_text'),
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            leading: InkWell(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  widget.handler(user);
                  NavigationService.instance.goBack();
                },
                child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black)),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (name.text == '') {
                          AppUtil.showToast(
                              ApplicationLocalizations.of(context)
                                  .translate('enterName_text'),
                              context);
                        } else if (gender == -1) {
                          AppUtil.showToast(
                              ApplicationLocalizations.of(context)
                                  .translate('enterGender_text'),
                              context);
                        } else {
                          editProfileAction();
                        }
                      },
                      child: Icon(Icons.done, color: Colors.black)))
            ]),
        body: WillPopScope(
          onWillPop: pop,
          child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 30, bottom: 20),
                          child: Center(
                              child: InkWell(
                                onTap: () => openImagePickingPopup(),
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      border: Border.all(
                                          color: ColorsUtil.appThemeColor),
                                      color: Colors.white),
                                  child: pickedImage != null
                                      ? ClipRRect(
                                      borderRadius: BorderRadius.circular(60.0),
                                      child: Image.file(pickedImage,
                                          fit: BoxFit.cover))
                                      : picture != null
                                      ? ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(60.0),
                                      child: CachedNetworkImage(
                                        imageUrl: picture,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            AppUtil.addProgressIndicator(
                                                context),
                                        errorWidget:
                                            (context, url, error) =>
                                            Icon(Icons.error),
                                      ))
                                      : Icon(Icons.person,
                                      color: Colors.grey.shade600,
                                      size: 50),
                                ),
                              ))),
                      Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Column(
                            children: [
                              addTextField(
                                  name,
                                  ApplicationLocalizations.of(context)
                                      .translate('name_text')),
                              SizedBox(height: 10),
                              addTextField(
                                  bio,
                                  ApplicationLocalizations.of(context)
                                      .translate('bio_text')),
                              SizedBox(height: 10),
                              addPhoneTextField(
                                  phone,
                                  ApplicationLocalizations.of(context)
                                      .translate('phone_text')),
                              SizedBox(height: 10),
                              GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    NavigationService.instance.navigateToRouteWithScale(
                                        ScaleRoute(
                                            page: ChooseCountryScreen(true,
                                                    (countryName) {
                                                  setState(() {
                                                    country.text = countryName;
                                                  });
                                                })));
                                  },
                                  child: AbsorbPointer(
                                    child: addTextField(
                                        country,
                                        ApplicationLocalizations.of(context)
                                            .translate('country_text')),
                                  )),
                              SizedBox(height: 10),
                              addTextField(
                                  city,
                                  ApplicationLocalizations.of(context)
                                      .translate('city_text')),
                              SizedBox(height: 10),
                              Row(children: [
                                Container(
                                    width: (MediaQuery.of(context).size.width /
                                        2) -
                                        30,
                                    child: CheckboxListTile(
                                      activeColor: ColorsUtil.appThemeColor,
                                      contentPadding: EdgeInsets.only(left: 0),
                                      title: Text(
                                          ApplicationLocalizations.of(context)
                                              .translate('male_text')),
                                      value: (gender == -1 || gender != 1)
                                          ? false
                                          : true,
                                      onChanged: (newValue) {
                                        setState(() {
                                          gender = newValue == true ? 1 : -1;
                                        });
                                      },
                                      controlAffinity: ListTileControlAffinity
                                          .leading,
                                    )),
                                Container(
                                    width: (MediaQuery.of(context).size.width /
                                        2) -
                                        30,
                                    child: CheckboxListTile(
                                      activeColor: ColorsUtil.appThemeColor,
                                      contentPadding: EdgeInsets.only(left: 0),
                                      title: Text(
                                          ApplicationLocalizations.of(context)
                                              .translate('female_text')),
                                      value: (gender == -1 || gender != 2)
                                          ? false
                                          : true,
                                      onChanged: (newValue) {
                                        setState(() {
                                          gender = newValue == true ? 2 : -1;
                                        });
                                      },
                                      controlAffinity: ListTileControlAffinity
                                          .leading,
                                    ))
                              ]),
                            ],
                          )),
                    ]),
              )),
        ));
  }

  void openImagePickingPopup() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
          children: [
            Padding(
                padding: EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 25),
                child: Text(
                    ApplicationLocalizations.of(context)
                        .translate('addPhoto_text'),
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none))),
            ListTile(
                leading: new Icon(Icons.camera_alt_outlined,
                    color: Colors.black87),
                title: new Text(ApplicationLocalizations.of(context)
                    .translate('takePhoto_text')),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                  await picker.getImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    pickedImage = File(pickedFile.path);
                    setState(() {});
                    editProfileImageAction();
                  } else {
                    print('No image selected.');
                  }
                }),
            ListTile(
                leading: new Icon(Icons.wallpaper_outlined,
                    color: Colors.black87),
                title: new Text(ApplicationLocalizations.of(context)
                    .translate('chooseGallery_text')),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                  await picker.getImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    pickedImage = File(pickedFile.path);
                    setState(() {});
                    editProfileImageAction();
                  } else {
                    print('No image selected.');
                  }
                }),
            ListTile(
                leading: new Icon(Icons.close, color: Colors.black87),
                title: new Text(ApplicationLocalizations.of(context)
                    .translate('cancel_text')),
                onTap: () => Navigator.of(context).pop()),
          ],
        ));
  }

  addTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
      style: TextStyle(color: Colors.black),
      maxLength: 40,
      obscureText: false,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.all(15),
          counterText: "",
          hintText: hintText),
    );
  }

  addPhoneTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
      style: TextStyle(color: Colors.black),
      maxLength: 40,
      obscureText: false,
      decoration: InputDecoration(
          prefixIcon: InkWell(
              onTap: () {
                NavigationService.instance.navigateToRouteWithScale(
                    ScaleRoute(
                        page: ChooseCountryScreen(false, (countryCodeStr) {
                          setState(() {
                            countryCode = countryCodeStr;
                          });
                        })));
              },
              child: Padding(
                  padding: EdgeInsets.all(15), child: Text(countryCode))),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ColorsUtil.appThemeColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.all(15),
          counterText: "",
          hintText: hintText),
    );
  }

  void editProfileAction() {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        AppUtil.showLoader(context);
        user.name = name.text;
        user.bio = bio.text;
        user.phone = phone.text;
        user.countryCode = countryCode;
        user.country = country.text;
        user.city = city.text;
        user.gender = gender.toString();

        ApiController().updateUserProfileApi(user).then((response) async {
          Navigator.of(context).pop();
          AppUtil.showToast(response.message, context);
          if (response.success) {
            SharedPrefs().saveUser(user);
          }
        });
      } else {
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('noInternet_text'),
            context);
      }
    });
  }

  void editProfileImageAction() {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        AppUtil.showLoader(context);
        ApiController()
            .updateProfileImageApi(pickedImage)
            .then((response) async {
          Navigator.of(context).pop();
          AppUtil.showToast(response.message, context);
          ApiController().getUserProfileApi().then((response) async {
            if (response.success) {
              SharedPrefs().saveUser(response.user!);
            }
          });
        });
      } else {
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('noInternet_text'),
            context);
      }
    });
  }
}
