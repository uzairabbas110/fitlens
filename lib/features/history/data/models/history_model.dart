import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/history_entity.dart';

/// Data-layer representation of [HistoryEntity].
///
/// Adds Firestore (de)serialization and entity conversion, which the
/// domain entity itself must remain free of. This keeps parsing
/// concerns isolated to the data layer, in line with Clean Architecture.
class HistoryModel extends HistoryEntity {
  const HistoryModel({
    required super.id,
    required super.userId,
    required super.feature,
    super.userImagePath,
    super.clothingImagePath,
    required super.skinTone,
    required super.estimatedSize,
    required super.recommendedSize,
    required super.sizeMatchScore,
    required super.colorMatchScore,
    required super.clothingTexture,
    required super.clothingQuality,
    required super.qualityScore,
    required super.buyAdvice,
    required super.reasoning,
    required super.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      feature: json['feature'] as String,
      userImagePath: json['userImagePath'] as String?,
      clothingImagePath: json['clothingImagePath'] as String?,
      skinTone: json['skinTone'] as String,
      estimatedSize: json['estimatedSize'] as String,
      recommendedSize: json['recommendedSize'] as String,
      sizeMatchScore: json['sizeMatchScore'] as int,
      colorMatchScore: json['colorMatchScore'] as int,
      clothingTexture: json['clothingTexture'] as String,
      clothingQuality: json['clothingQuality'] as String,
      qualityScore: json['qualityScore'] as int,
      buyAdvice: json['buyAdvice'] as String,
      reasoning: json['reasoning'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'feature': feature,
      'userImagePath': userImagePath,
      'clothingImagePath': clothingImagePath,
      'skinTone': skinTone,
      'estimatedSize': estimatedSize,
      'recommendedSize': recommendedSize,
      'sizeMatchScore': sizeMatchScore,
      'colorMatchScore': colorMatchScore,
      'clothingTexture': clothingTexture,
      'clothingQuality': clothingQuality,
      'qualityScore': qualityScore,
      'buyAdvice': buyAdvice,
      'reasoning': reasoning,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory HistoryModel.fromEntity(HistoryEntity entity) {
    return HistoryModel(
      id: entity.id,
      userId: entity.userId,
      feature: entity.feature,
      userImagePath: entity.userImagePath,
      clothingImagePath: entity.clothingImagePath,
      skinTone: entity.skinTone,
      estimatedSize: entity.estimatedSize,
      recommendedSize: entity.recommendedSize,
      sizeMatchScore: entity.sizeMatchScore,
      colorMatchScore: entity.colorMatchScore,
      clothingTexture: entity.clothingTexture,
      clothingQuality: entity.clothingQuality,
      qualityScore: entity.qualityScore,
      buyAdvice: entity.buyAdvice,
      reasoning: entity.reasoning,
      createdAt: entity.createdAt,
    );
  }

  HistoryEntity toEntity() {
    return HistoryEntity(
      id: id,
      userId: userId,
      feature: feature,
      userImagePath: userImagePath,
      clothingImagePath: clothingImagePath,
      skinTone: skinTone,
      estimatedSize: estimatedSize,
      recommendedSize: recommendedSize,
      sizeMatchScore: sizeMatchScore,
      colorMatchScore: colorMatchScore,
      clothingTexture: clothingTexture,
      clothingQuality: clothingQuality,
      qualityScore: qualityScore,
      buyAdvice: buyAdvice,
      reasoning: reasoning,
      createdAt: createdAt,
    );
  }
}