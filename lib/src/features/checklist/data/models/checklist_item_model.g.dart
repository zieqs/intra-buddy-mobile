// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChecklistItemModel _$ChecklistItemModelFromJson(Map<String, dynamic> json) =>
    ChecklistItemModel(
      id: (json['id'] as num).toInt(),
      checklistItemId: (json['checklist_item_id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool,
      isRequired: json['is_required'] as bool? ?? true,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      phase: json['phase'] as String?,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      displayOrder: (json['display_order'] as num).toInt(),
    );

Map<String, dynamic> _$ChecklistItemModelToJson(ChecklistItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'checklist_item_id': instance.checklistItemId,
      'title': instance.title,
      'description': instance.description,
      'is_completed': instance.isCompleted,
      'is_required': instance.isRequired,
      'completed_at': instance.completedAt?.toIso8601String(),
      'phase': instance.phase,
      'due_date': instance.dueDate?.toIso8601String(),
      'display_order': instance.displayOrder,
    };
