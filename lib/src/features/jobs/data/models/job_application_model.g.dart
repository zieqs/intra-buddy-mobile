// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplicationModel _$JobApplicationModelFromJson(Map<String, dynamic> json) =>
    JobApplicationModel(
      id: (json['id'] as num).toInt(),
      companyName: json['company_name'] as String,
      position: json['position'] as String?,
      applicationDate: DateTime.parse(json['application_date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$JobApplicationModelToJson(
  JobApplicationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'company_name': instance.companyName,
  'position': instance.position,
  'application_date': instance.applicationDate.toIso8601String(),
  'status': instance.status,
  'notes': instance.notes,
};
