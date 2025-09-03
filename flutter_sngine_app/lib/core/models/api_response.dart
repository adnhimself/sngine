import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool error;
  final String? message;
  final T? data;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.error,
    this.message,
    this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => 
      _$ApiResponseToJson(this, toJsonT);

  // Success factory
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      error: false,
      data: data,
      message: message,
    );
  }

  // Error factory
  factory ApiResponse.error(String message) {
    return ApiResponse<T>(
      error: true,
      message: message,
      data: null,
    );
  }

  bool get isSuccess => !error && data != null;
  bool get isError => error;
}