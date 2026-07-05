// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  studentId: json['student_id'] as String?,
  phoneNumber: json['phone_number'] as String?,
  role: json['role'] as String? ?? 'student',
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'full_name': instance.fullName,
  'student_id': instance.studentId,
  'phone_number': instance.phoneNumber,
  'role': instance.role,
};
