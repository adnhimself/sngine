import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'user_id')
  final int userId;
  
  @JsonKey(name: 'user_name')
  final String username;
  
  @JsonKey(name: 'user_email')
  final String email;
  
  @JsonKey(name: 'user_firstname')
  final String firstName;
  
  @JsonKey(name: 'user_lastname')
  final String lastName;
  
  @JsonKey(name: 'user_fullname')
  final String? fullName;
  
  @JsonKey(name: 'user_gender')
  final String gender;
  
  @JsonKey(name: 'user_birthdate')
  final String? birthdate;
  
  @JsonKey(name: 'user_picture')
  final String? profilePicture;
  
  @JsonKey(name: 'user_cover')
  final String? coverPhoto;
  
  @JsonKey(name: 'user_verified')
  final bool isVerified;
  
  @JsonKey(name: 'user_biography')
  final String? biography;
  
  @JsonKey(name: 'user_website')
  final String? website;
  
  @JsonKey(name: 'user_relationship')
  final String? relationshipStatus;
  
  @JsonKey(name: 'user_registered')
  final String registeredDate;
  
  @JsonKey(name: 'user_privacy_chat')
  final String? chatPrivacy;
  
  @JsonKey(name: 'user_privacy_profile')
  final String? profilePrivacy;
  
  @JsonKey(name: 'user_subscribed')
  final bool isSubscribed;
  
  @JsonKey(name: 'package_name')
  final String? packageName;
  
  @JsonKey(name: 'package_color')
  final String? packageColor;
  
  // Computed properties
  String get displayName => fullName ?? '$firstName $lastName';
  String get profileImageUrl => profilePicture != null 
    ? '${AppConfig.baseUrl}/content/uploads/$profilePicture' 
    : '';
  String get coverImageUrl => coverPhoto != null 
    ? '${AppConfig.baseUrl}/content/uploads/$coverPhoto' 
    : '';

  const UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.fullName,
    required this.gender,
    this.birthdate,
    this.profilePicture,
    this.coverPhoto,
    required this.isVerified,
    this.biography,
    this.website,
    this.relationshipStatus,
    required this.registeredDate,
    this.chatPrivacy,
    this.profilePrivacy,
    required this.isSubscribed,
    this.packageName,
    this.packageColor,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  UserModel copyWith({
    int? userId,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? gender,
    String? birthdate,
    String? profilePicture,
    String? coverPhoto,
    bool? isVerified,
    String? biography,
    String? website,
    String? relationshipStatus,
    String? registeredDate,
    String? chatPrivacy,
    String? profilePrivacy,
    bool? isSubscribed,
    String? packageName,
    String? packageColor,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      profilePicture: profilePicture ?? this.profilePicture,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      isVerified: isVerified ?? this.isVerified,
      biography: biography ?? this.biography,
      website: website ?? this.website,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      registeredDate: registeredDate ?? this.registeredDate,
      chatPrivacy: chatPrivacy ?? this.chatPrivacy,
      profilePrivacy: profilePrivacy ?? this.profilePrivacy,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      packageName: packageName ?? this.packageName,
      packageColor: packageColor ?? this.packageColor,
    );
  }
}