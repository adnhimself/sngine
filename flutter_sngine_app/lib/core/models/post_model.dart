import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  @JsonKey(name: 'post_id')
  final int postId;
  
  @JsonKey(name: 'user_id')
  final int userId;
  
  @JsonKey(name: 'user_type')
  final String userType;
  
  @JsonKey(name: 'in_group')
  final bool inGroup;
  
  @JsonKey(name: 'group_id')
  final int? groupId;
  
  @JsonKey(name: 'in_event')
  final bool inEvent;
  
  @JsonKey(name: 'event_id')
  final int? eventId;
  
  @JsonKey(name: 'post_type')
  final String postType;
  
  @JsonKey(name: 'post_text')
  final String? text;
  
  @JsonKey(name: 'post_link')
  final String? link;
  
  @JsonKey(name: 'post_privacy')
  final String privacy;
  
  @JsonKey(name: 'post_time')
  final String createdAt;
  
  @JsonKey(name: 'post_reactions')
  final int reactionsCount;
  
  @JsonKey(name: 'post_comments')
  final int commentsCount;
  
  @JsonKey(name: 'post_shares')
  final int sharesCount;
  
  @JsonKey(name: 'i_react')
  final bool iReacted;
  
  @JsonKey(name: 'i_save')
  final bool iSaved;
  
  @JsonKey(name: 'reaction_type')
  final String? myReactionType;
  
  // Media
  @JsonKey(name: 'photos')
  final List<PostPhoto>? photos;
  
  @JsonKey(name: 'video')
  final PostVideo? video;
  
  @JsonKey(name: 'audio')
  final PostAudio? audio;
  
  // User data (nested)
  final UserModel? author;
  
  // Comments (if loaded)
  final List<CommentModel>? comments;

  const PostModel({
    required this.postId,
    required this.userId,
    required this.userType,
    required this.inGroup,
    this.groupId,
    required this.inEvent,
    this.eventId,
    required this.postType,
    this.text,
    this.link,
    required this.privacy,
    required this.createdAt,
    required this.reactionsCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.iReacted,
    required this.iSaved,
    this.myReactionType,
    this.photos,
    this.video,
    this.audio,
    this.author,
    this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);
  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}

@JsonSerializable()
class PostPhoto {
  @JsonKey(name: 'photo_id')
  final int photoId;
  
  @JsonKey(name: 'source')
  final String source;
  
  @JsonKey(name: 'blur')
  final bool isBlurred;

  const PostPhoto({
    required this.photoId,
    required this.source,
    required this.isBlurred,
  });

  String get imageUrl => '${AppConfig.baseUrl}/content/uploads/$source';

  factory PostPhoto.fromJson(Map<String, dynamic> json) => _$PostPhotoFromJson(json);
  Map<String, dynamic> toJson() => _$PostPhotoToJson(this);
}

@JsonSerializable()
class PostVideo {
  @JsonKey(name: 'source')
  final String source;
  
  @JsonKey(name: 'thumbnail')
  final String? thumbnail;

  const PostVideo({
    required this.source,
    this.thumbnail,
  });

  String get videoUrl => '${AppConfig.baseUrl}/content/uploads/$source';
  String get thumbnailUrl => thumbnail != null 
    ? '${AppConfig.baseUrl}/content/uploads/$thumbnail' 
    : '';

  factory PostVideo.fromJson(Map<String, dynamic> json) => _$PostVideoFromJson(json);
  Map<String, dynamic> toJson() => _$PostVideoToJson(this);
}

@JsonSerializable()
class PostAudio {
  @JsonKey(name: 'source')
  final String source;

  const PostAudio({
    required this.source,
  });

  String get audioUrl => '${AppConfig.baseUrl}/content/uploads/$source';

  factory PostAudio.fromJson(Map<String, dynamic> json) => _$PostAudioFromJson(json);
  Map<String, dynamic> toJson() => _$PostAudioToJson(this);
}

@JsonSerializable()
class CommentModel {
  @JsonKey(name: 'comment_id')
  final int commentId;
  
  @JsonKey(name: 'comment')
  final String text;
  
  @JsonKey(name: 'comment_time')
  final String createdAt;
  
  @JsonKey(name: 'user_id')
  final int userId;
  
  final UserModel? author;

  const CommentModel({
    required this.commentId,
    required this.text,
    required this.createdAt,
    required this.userId,
    this.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => _$CommentModelFromJson(json);
  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}