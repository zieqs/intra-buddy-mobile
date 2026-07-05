import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/job_application.dart';

part 'job_application_model.g.dart';

@JsonSerializable()
class JobApplicationModel {
  final int id;

  @JsonKey(name: 'company_name')
  final String companyName;

  final String? position;

  @JsonKey(name: 'application_date')
  final DateTime applicationDate;

  final String status;
  final String? notes;

  const JobApplicationModel({
    required this.id,
    required this.companyName,
    this.position,
    required this.applicationDate,
    required this.status,
    this.notes,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) =>
      _$JobApplicationModelFromJson(json);
  Map<String, dynamic> toJson() => _$JobApplicationModelToJson(this);

  JobApplication toEntity() => JobApplication(
    id: id,
    companyName: companyName,
    position: position,
    applicationDate: applicationDate,
    status: status,
    notes: notes,
  );
}
