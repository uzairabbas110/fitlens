enum PaymentMethodType {
  easypaisa,
  jazzcash,
  card,
}

class PaymentMethodOption {
  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final String badge;
  final String iconName;

  const PaymentMethodOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.iconName,
  });
}

class PaymentTransaction {
  final String transactionId;
  final PaymentMethodType method;
  final String planKey;
  final String planTitle;
  final double amountPkr;
  final DateTime timestamp;
  final String accountOrCardMasked;
  final String status;

  const PaymentTransaction({
    required this.transactionId,
    required this.method,
    required this.planKey,
    required this.planTitle,
    required this.amountPkr,
    required this.timestamp,
    required this.accountOrCardMasked,
    this.status = 'Completed',
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'method': method.name,
      'planKey': planKey,
      'planTitle': planTitle,
      'amountPkr': amountPkr,
      'timestamp': timestamp.toIso8601String(),
      'accountOrCardMasked': accountOrCardMasked,
      'status': status,
    };
  }
}
