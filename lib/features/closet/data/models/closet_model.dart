import '../../domain/entities/closet_item_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClosetModel extends ClosetItemEntity {
  const ClosetModel({
    required super.id,
    required super.userId,
    required super.imageUrl,
    required super.category,
    required super.color,
    required super.season,
    required super.dateAdded,
  });

  factory ClosetModel.fromJson(Map<String, dynamic> json) {
    return ClosetModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      season: json['season'] as String? ?? '',
      dateAdded: (json['dateAdded'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'category': category,
      'color': color,
      'season': season,
      'dateAdded': Timestamp.fromDate(dateAdded),
    };
  }

  factory ClosetModel.fromEntity(ClosetItemEntity entity) {
    return ClosetModel(
      id: entity.id,
      userId: entity.userId,
      imageUrl: entity.imageUrl,
      category: entity.category,
      color: entity.color,
      season: entity.season,
      dateAdded: entity.dateAdded,
    );
  }
}
