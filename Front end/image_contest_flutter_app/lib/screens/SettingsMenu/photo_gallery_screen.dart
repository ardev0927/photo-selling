import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_contest_flutter_app/animatedWidgets/ScaleRoute.dart';
import 'package:image_contest_flutter_app/model/post_model.dart';
import 'package:image_contest_flutter_app/screens/HomeFeed/enlarge_image_view.dart';
import 'package:image_contest_flutter_app/util/app_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';

import '../../application_localizations.dart';

class PhotoGalleryScreen extends StatefulWidget {
  final List<PostModel> posts;
  PhotoGalleryScreen(this.posts);

  @override
  PhotoGalleryState createState() => PhotoGalleryState();
}

class PhotoGalleryState extends State<PhotoGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          title: Text(
            ApplicationLocalizations.of(context).translate('photosCap_text'),
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          leading: InkWell(
              onTap: () => NavigationService.instance.goBack(),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black))),
      body: addPhotoGrid(),
    );
  }

  addPhotoGrid() {
    return MasonryGridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      itemCount: widget.posts.length,
      itemBuilder: (BuildContext context, int index) => InkWell(
          onTap: () async {
            File path = await AppUtil.findPath(widget.posts[index].gallery.first.filePath);
            NavigationService.instance.navigateToRouteWithScale(
                ScaleRoute(
                    page: EnlargeImageViewScreen(widget.posts[index], path, handler: (){},)));
          },
          child: Container(
            child: ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: widget.posts[index].gallery.first.filePath,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      AppUtil.addProgressIndicator(context),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
          )),
      // staggeredTileBuilder: (int index) => new StaggeredTile.count(1, 1),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }
}
