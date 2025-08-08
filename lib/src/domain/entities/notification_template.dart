import 'package:equatable/equatable.dart';

class NotificationTemplate extends Equatable {
  final String id;
  final String name;
  final String title;
  final String body;
  final Map<String, dynamic> defaultVariables;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationTemplate({
    required this.id,
    required this.name,
    required this.title,
    required this.body,
    this.defaultVariables = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        body,
        defaultVariables,
        createdAt,
        updatedAt,
      ];

  NotificationTemplate copyWith({
    String? id,
    String? name,
    String? title,
    String? body,
    Map<String, dynamic>? defaultVariables,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      body: body ?? this.body,
      defaultVariables: defaultVariables ?? this.defaultVariables,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}