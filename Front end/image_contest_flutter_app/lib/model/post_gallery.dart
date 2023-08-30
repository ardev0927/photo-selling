class PostGallery{
  int id;
  int postId;
  String filePath;
  String? videoPath;
  int mediaType;
  int type;

  PostGallery({required this.id,
    required this.filePath,
    required this.postId,
    required this.mediaType,
    required this.type,
    this.videoPath});

  factory PostGallery.fromJson(dynamic json) {
    PostGallery galleryPost = PostGallery(
        id: json['id'],
        filePath: json['filenameUrl'],
        postId: json['post_id'],
        mediaType: json['media_type'],
        type: json['type'],
        videoPath: json['videoThumbUrl']);

    return galleryPost;
  }

}