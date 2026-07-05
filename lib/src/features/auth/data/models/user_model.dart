import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'student_id')
  final String? studentId;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String role;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.studentId,
    this.phoneNumber,
    this.role = 'student',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(
    id: id,
    email: email,
    fullName: fullName,
    studentId: studentId,
    phoneNumber: phoneNumber,
    role: role,
  );

  factory UserModel.fromSupabaseUser(dynamic user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] ?? '',
      studentId: user.userMetadata?['student_id'],
      phoneNumber: user.userMetadata?['phone_number'],
      role: user.userMetadata?['role'] ?? 'student',
    );
  }
}
