import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/animatedWidgets/BouncingWidget.dart';
import 'package:image_contest_flutter_app/apiHandler/api_controller.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_contest_flutter_app/util/constant_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';

import '../../application_localizations.dart';

class AddPostScreen extends StatefulWidget {
  final String? competitionId;
  AddPostScreen(this.competitionId);

  @override
  AddPostState createState() => AddPostState();
}

class AddPostState extends State<AddPostScreen> {
  TextEditingController descriptionText = TextEditingController();
  TextEditingController tagsText = TextEditingController();

  late File? pickedImage;
  final picker = ImagePicker();
  String? imagePath;

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
                        .translate('addPost_text'),
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  )),
                  Container()
                ])),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 15),
                child: Center(
                    child: InkWell(
                  onTap: () => openImagePickingPopup(),
                  child: Container(
                      height: 100,
                      width: 100,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: pickedImage == null
                          ? Icon(Icons.add, color: Colors.grey)
                          : Image.file(pickedImage!, fit: BoxFit.cover)),
                ))),
            addDescriptionView(),
            Padding(
                padding: EdgeInsets.only(top: 15, bottom: 30),
                child: addTagsView()),
            BouncingWidget(
              duration: Duration(milliseconds: 100),
              scaleFactor: 1.5,
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                if (pickedImage == null) {
                  AppUtil.showToast(
                      ApplicationLocalizations.of(context)
                          .translate('addImage_text'),
                      context);
                } else if (descriptionText.text == '') {
                  AppUtil.showToast(
                      ApplicationLocalizations.of(context)
                          .translate('addTitle_text'),
                      context);
                } else if (tagsText.text == '') {
                  AppUtil.showToast(
                      ApplicationLocalizations.of(context)
                          .translate('addTag_text'),
                      context);
                } else {
                  publishAction();
                }
              },
              child: Container(
                  height: 40,
                  color: ColorsUtil.appThemeColor,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                      child: Text(
                    ApplicationLocalizations.of(context)
                        .translate('publish_text'),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ))),
            )
          ]),
        )));
  }

  Widget addDescriptionView() {
    return TextField(
        controller: descriptionText,
        keyboardType: TextInputType.multiline,
        style: TextStyle(fontWeight: FontWeight.w400),
        // minLines: 5, //Normal textInputField will be displayed
        maxLines: null, //
        // maxLength: 150, // when user presses enter it will adapt to it
        decoration: InputDecoration(
          labelText:
              ApplicationLocalizations.of(context).translate('writePost_text'),
          labelStyle: TextStyle(
              color: Colors.grey,
              fontSize:
                  15.0, //I believe the size difference here is 6.0 to account padding
              fontWeight: FontWeight.w400),
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.all(0.0),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ));
  }

  Widget addTagsView() {
    return TextField(
        controller: tagsText,
        keyboardType: TextInputType.multiline,
        style: TextStyle(fontWeight: FontWeight.w400),
        // minLines: 5, //Normal textInputField will be displayed
        maxLines: null, //
        // maxLength: 150, // when user presses enter it will adapt to it
        decoration: InputDecoration(
          labelText: ApplicationLocalizations.of(context)
              .translate('addTagsHint_text'),
          labelStyle: TextStyle(
              color: Colors.grey,
              fontSize:
                  15.0, //I believe the size difference here is 6.0 to account padding
              fontWeight: FontWeight.w400),
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.all(0.0),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
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
                        setState(() {
                          pickedImage = File(pickedFile.path);
                        });
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
                        setState(() {
                          pickedImage = File(pickedFile.path);
                        });
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

  void uploadPostImage(){
    AppUtil.checkInternet().then((value) async {
      if (value) {
        AppUtil.showLoader(context);
        ApiController()
            .uploadPostImage(pickedImage!.path)
            .then((response) async {
          imagePath = response.postImagePath;
          Navigator.of(context).pop();
          // postUpdatedDialog(response.message, () {
          //   if (response.success) {
          //     NavigationService.instance.goBack();
          //   }
          // });
        });
      } else {
        AppUtil.showToast(
            ApplicationLocalizations.of(context).translate('noInternet_text'),
            context);
      }
    });
  }


  void publishAction() {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        AppUtil.showLoader(context);
        ApiController()
            .addPostApi(descriptionText.text, imagePath!, tagsText.text,
                widget.competitionId)
            .then((response) async {
          Navigator.of(context).pop();
          postUpdatedDialog(response.message, () {
            if (response.success) {
              NavigationService.instance.goBack();
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

  void postUpdatedDialog(String message, VoidCallback handler) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(ConstantUtil.projectName,
              style: TextStyle(color: ColorsUtil.appThemeColor)),
          content: Text(message),
          actions: [
            TextButton(
              child:
                  Text('Ok', style: TextStyle(color: ColorsUtil.appThemeColor)),
              onPressed: () {
                Navigator.of(context).pop();
                handler();
              },
            )
          ],
        );
      },
    );
  }
}
