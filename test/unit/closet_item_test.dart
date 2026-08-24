import 'package:flutter_test/flutter_test.dart';
import 'package:fitlens/features/closet/domain/entities/closet_item_entity.dart';

void main() {
  group('ClosetItemEntity Unit Tests', () {
    test('instantiates with valid properties', () {
      final now = DateTime.now();
      final item = ClosetItemEntity(
        id: 'item_1',
        userId: 'user_123',
        imageUrl: 'https://r2.fitlens.app/item_1.jpg',
        category: 'Tops',
        color: 'Burgundy',
        season: 'Winter',
        dateAdded: now,
      );

      expect(item.id, equals('item_1'));
      expect(item.userId, equals('user_123'));
      expect(item.category, equals('Tops'));
      expect(item.color, equals('Burgundy'));
      expect(item.season, equals('Winter'));
      expect(item.dateAdded, equals(now));
    });
  });
}
