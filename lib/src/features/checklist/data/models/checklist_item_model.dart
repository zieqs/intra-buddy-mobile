import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/checklist_item.dart';

part 'checklist_item_model.g.dart';

@JsonSerializable()
class ChecklistItemModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'checklist_item_id')
  final int checklistItemId;

  final String title;
  final String? description;

  @JsonKey(name: 'is_completed')
  final bool isCompleted;

  @JsonKey(name: 'is_required')
  final bool isRequired;

  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  final String? phase;

  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @JsonKey(name: 'display_order')
  final int displayOrder;

  const ChecklistItemModel({
    required this.id,
    required this.checklistItemId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.isRequired = true,
    this.completedAt,
    this.phase,
    this.dueDate,
    required this.displayOrder,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChecklistItemModelToJson(this);

  ChecklistItem toEntity() => ChecklistItem(
    id: id,
    checklistItemId: checklistItemId,
    title: title,
    description: description,
    isCompleted: isCompleted,
    isRequired: isRequired,
    completedAt: completedAt,
    phase: phase,
    dueDate: dueDate,
    displayOrder: displayOrder,
  );
}
