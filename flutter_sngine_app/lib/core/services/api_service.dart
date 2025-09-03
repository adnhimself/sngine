import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/api_response.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: AppConfig.apiBaseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Authentication
  @POST('/users/signin.php')
  @FormUrlEncoded()
  Future<ApiResponse<UserModel>> login(
    @Field('username_email') String usernameEmail,
    @Field('password') String password,
  );

  @POST('/users/signup.php')
  @FormUrlEncoded()
  Future<ApiResponse<UserModel>> register(
    @Field('first_name') String firstName,
    @Field('last_name') String lastName,
    @Field('username') String username,
    @Field('email') String email,
    @Field('password') String password,
  );

  @POST('/users/session.php')
  Future<ApiResponse<UserModel>> refreshSession(
    @Field('access_token') String accessToken,
  );

  // Posts & Feed
  @GET('/posts/post.php')
  Future<ApiResponse<List<PostModel>>> getPosts(
    @Query('get') String get, // 'newsfeed', 'profile', 'group', etc.
    @Query('id') int? id,
    @Query('offset') int offset,
  );

  @POST('/posts/publisher.php')
  @FormUrlEncoded()
  Future<ApiResponse<PostModel>> createPost(
    @Field('message') String message,
    @Field('privacy') String privacy,
    @Field('photos[]') List<String>? photos,
    @Field('video') String? video,
  );

  @POST('/posts/reaction.php')
  @FormUrlEncoded()
  Future<ApiResponse<Map<String, dynamic>>> reactToPost(
    @Field('do') String action, // 'react'
    @Field('post_id') int postId,
    @Field('reaction') String reaction, // 'like', 'love', 'haha', etc.
  );

  @POST('/posts/comment.php')
  @FormUrlEncoded()
  Future<ApiResponse<Map<String, dynamic>>> addComment(
    @Field('do') String action, // 'add'
    @Field('post_id') int postId,
    @Field('comment') String comment,
  );

  // User Profile
  @GET('/users/profile.php')
  Future<ApiResponse<UserModel>> getUserProfile(
    @Query('do') String action, // 'get_profile'
    @Query('user_id') int userId,
  );

  @POST('/users/settings.php')
  @FormUrlEncoded()
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    @Field('edit') String edit, // 'basic', 'privacy', etc.
    @Body() Map<String, dynamic> data,
  );

  // Messages & Chat
  @GET('/chat/conversation.php')
  Future<ApiResponse<List<dynamic>>> getConversations(
    @Query('do') String action, // 'get_conversations'
  );

  @GET('/chat/conversation.php')
  Future<ApiResponse<List<dynamic>>> getMessages(
    @Query('do') String action, // 'get_messages'
    @Query('conversation_id') int conversationId,
    @Query('offset') int offset,
  );

  @POST('/chat/conversation.php')
  @FormUrlEncoded()
  Future<ApiResponse<Map<String, dynamic>>> sendMessage(
    @Field('do') String action, // 'send'
    @Field('conversation_id') int conversationId,
    @Field('message') String message,
  );

  // Notifications
  @GET('/core/notifications.php')
  Future<ApiResponse<List<dynamic>>> getNotifications(
    @Query('offset') int offset,
  );

  @POST('/core/notifications.php')
  @FormUrlEncoded()
  Future<ApiResponse<Map<String, dynamic>>> markNotificationRead(
    @Field('do') String action, // 'mark_as_read'
    @Field('notification_id') int notificationId,
  );

  // Search
  @GET('/users/autocomplete.php')
  Future<ApiResponse<List<dynamic>>> searchUsers(
    @Query('query') String query,
  );

  @GET('/data/search.php')
  Future<ApiResponse<List<dynamic>>> globalSearch(
    @Query('query') String query,
    @Query('type') String type, // 'users', 'posts', 'groups', etc.
  );

  // File Upload
  @POST('/core/upload.php')
  @MultiPart()
  Future<ApiResponse<Map<String, dynamic>>> uploadFile(
    @Part() File file,
    @Part() String type, // 'photo', 'video', 'document'
  );
}