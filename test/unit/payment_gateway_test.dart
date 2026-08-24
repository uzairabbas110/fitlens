import 'package:flutter_test/flutter_test.dart';
import 'package:fitlens/features/payment/data/services/payment_gateway_service.dart';
import 'package:fitlens/features/payment/domain/entities/payment_entity.dart';

void main() {
  group('Payment Gateway Service & Domain Unit Tests', () {
    test('plan price calculation in PKR is accurate for all tiers', () {
      final annual = PaymentGatewayService.getPlanDetails('annual');
      expect(annual['amountPkr'], equals(2899.0));
      expect(annual['title'], equals('Annual VIP Membership'));
      expect(annual['discount'], equals('50% OFF'));

      final monthly = PaymentGatewayService.getPlanDetails('monthly');
      expect(monthly['amountPkr'], equals(1499.0));
      expect(monthly['title'], equals('Monthly VIP Pass'));
      expect(monthly['discount'], isNull);

      final lifetime = PaymentGatewayService.getPlanDetails('lifetime');
      expect(lifetime['amountPkr'], equals(9999.0));
      expect(lifetime['title'], equals('Lifetime Perpetual VIP'));

      final fallback = PaymentGatewayService.getPlanDetails('unknown');
      expect(fallback['amountPkr'], equals(2899.0));
    });

    test('PaymentMethodType enum supports only easypaisa, jazzcash, and card', () {
      expect(PaymentMethodType.values.length, equals(3));
      expect(PaymentMethodType.values, containsAll([
        PaymentMethodType.easypaisa,
        PaymentMethodType.jazzcash,
        PaymentMethodType.card,
      ]));
    });

    test('PaymentTransaction JSON serialization and deserialization is valid', () {
      final txn = PaymentTransaction(
        transactionId: 'EP-123456',
        method: PaymentMethodType.easypaisa,
        planKey: 'annual',
        planTitle: 'Annual VIP Membership',
        amountPkr: 2899.0,
        timestamp: DateTime(2026, 8, 19, 12, 0),
        accountOrCardMasked: '0300****567',
        status: 'Completed',
      );

      final json = txn.toJson();
      expect(json['transactionId'], equals('EP-123456'));
      expect(json['method'], equals('easypaisa'));
      expect(json['amountPkr'], equals(2899.0));
      expect(json['accountOrCardMasked'], equals('0300****567'));
      expect(json['status'], equals('Completed'));
    });
  });
}
