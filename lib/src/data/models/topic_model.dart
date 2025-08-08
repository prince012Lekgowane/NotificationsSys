
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/topic_entity.dart';

part 'topic_model.g.dart';

@JsonSerializable()
class TopicModel extends TopicEntity {
  const TopicModel({
    required super.id,
    required super.name,
    required super.displayName,
    super.description = '',
    super.category = 'general',
    super.isActive = true,
    super.isPublic = true,
    super.subscriberCount = 0,
    required super.createdAt,
    required super.updatedAt,
    super.settings = const {},
    super.tags = const [],
    super.metadata = const {},
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) =>
      _$TopicModelFromJson(json);

  Map<String, dynamic> toJson() => _$TopicModelToJson(this);

  factory TopicModel.fromEntity(TopicEntity entity) {
    return TopicModel(
      id: entity.id,
      name: entity.name,
      displayName: entity.displayName,
      description: entity.description,
      category: entity.category,
      isActive: entity.isActive,
      isPublic: entity.isPublic,
      subscriberCount: entity.subscriberCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      settings: entity.settings,
      tags: entity.tags,
      metadata: entity.metadata,
    );
  }

  TopicEntity toEntity() {
    return TopicEntity(
      id: id,
      name: name,
      displayName: displayName,
      description: description,
      category: category,
      isActive: isActive,
      isPublic: isPublic,
      subscriberCount: subscriberCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      settings: settings,
      tags: tags,
      metadata: metadata,
    );
  }

  @override
  TopicModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    String? category,
    bool? isActive,
    bool? isPublic,
    int? subscriberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return TopicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }
}