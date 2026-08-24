import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentGatewayService {
  static final PaymentGatewayService _instance = PaymentGatewayService._internal();
  factory PaymentGatewayService() => _instance;
  PaymentGatewayService._internal();

  /// Returns plan details including PKR pricing
  static Map<String, dynamic> getPlanDetails(String planKey) {
    switch (planKey.toLowerCase()) {
      case 'annual':
        return {
          'key': 'annual',
          'title': 'Annual VIP Membership',
          'amountPkr': 2899.0,
          'originalAmountPkr': 5799.0,
          'discount': '50% OFF',
          'duration': '12 Months',
          'usdText': '\$9.99 / yr',
        };
      case 'monthly':
        return {
          'key': 'monthly',
          'title': 'Monthly VIP Pass',
          'amountPkr': 1499.0,
          'originalAmountPkr': 1499.0,
          'discount': null,
          'duration': '1 Month',
          'usdText': '\$4.99 / mo',
        };
      case 'lifetime':
        return {
          'key': 'lifetime',
          'title': 'Lifetime Perpetual VIP',
          'amountPkr': 9999.0,
          'originalAmountPkr': 19999.0,
          'discount': 'VIP SPECIAL',
          'duration': 'Unlimited Lifetime',
          'usdText': '\$29.99 once',
        };
      default:
        return {
          'key': 'annual',
          'title': 'Annual VIP Membership',
          'amountPkr': 2899.0,
          'originalAmountPkr': 5799.0,
          'discount': '50% OFF',
          'duration': '12 Months',
          'usdText': '\$9.99 / yr',
        };
    }
  }

  /// Processes transaction across Easypaisa, JazzCash, or Debit/Credit Cards
  /// Communicates with backend checkout endpoint to verify and elevate VIP privileges server-side.
  Future<PaymentTransaction> processPayment({
    required PaymentMethodType method,
    required String planKey,
    required String accountOrCardNumber,
    String? cnicOrOtp,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
  }) async {
    // 1. Validate inputs based on method
    _validateInputs(
      method: method,
      accountOrCard: accountOrCardNumber,
      cnicOrOtp: cnicOrOtp,
      expiryDate: expiryDate,
      cvv: cvv,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to purchase a VIP plan.');
    }

    final idToken = await user.getIdToken();
    final url = Uri.parse('${ApiConstants.backendBaseUrl}/api/payment/checkout');

    final payload = {
      'planKey': planKey,
      'method': method.name,
      'accountOrCardNumber': accountOrCardNumber.replaceAll(RegExp(r'\s+'), '').trim(),
      if (cnicOrOtp != null && cnicOrOtp.isNotEmpty) 'cnicOrOtp': cnicOrOtp.trim(),
      if (cardHolderName != null && cardHolderName.isNotEmpty) 'cardHolderName': cardHolderName.trim(),
      if (expiryDate != null && expiryDate.isNotEmpty) 'expiryDate': expiryDate.trim(),
      if (cvv != null && cvv.isNotEmpty) 'cvv': cvv.trim(),
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final resData = jsonDecode(response.body) as Map<String, dynamic>;
      
      final transaction = PaymentTransaction(
        transactionId: resData['transactionId'] as String? ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        method: method,
        planKey: resData['planKey'] as String? ?? planKey,
        planTitle: resData['planTitle'] as String? ?? 'VIP Membership',
        amountPkr: (resData['amountPkr'] as num?)?.toDouble() ?? 2899.0,
        timestamp: DateTime.now(),
        accountOrCardMasked: resData['accountOrCardMasked'] as String? ?? _maskAccount(accountOrCardNumber),
        status: resData['status'] as String? ?? 'Completed',
      );

      // Update local storage cache
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('cached_is_premium', true);
        await prefs.setString('cached_premium_plan', planKey);
      } catch (_) {}

      return transaction;
    } else {
      String errorMessage = 'Payment processing failed.';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        } else if (errorData is Map && errorData['error'] != null) {
          errorMessage = errorData['error'] as String;
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  void _validateInputs({
    required PaymentMethodType method,
    required String accountOrCard,
    String? cnicOrOtp,
    String? expiryDate,
    String? cvv,
  }) {
    final cleanNum = accountOrCard.replaceAll(RegExp(r'\s+'), '').trim();

    switch (method) {
      case PaymentMethodType.easypaisa:
      case PaymentMethodType.jazzcash:
        if (cleanNum.length < 11 || !RegExp(r'^(03|\+923)[0-9]{9}$').hasMatch(cleanNum)) {
          throw Exception('Please enter a valid 11-digit Pakistani mobile number (e.g. 03001234567).');
        }
        break;

      case PaymentMethodType.card:
        if (cleanNum.length < 15 || cleanNum.length > 19) {
          throw Exception('Please enter a valid 16-digit Debit/Credit Card number.');
        }
        if (expiryDate == null || expiryDate.trim().isEmpty || !expiryDate.contains('/')) {
          throw Exception('Please enter card expiry date (MM/YY).');
        }
        if (cvv == null || cvv.trim().length < 3) {
          throw Exception('Please enter a valid 3 or 4 digit CVV security code.');
        }
        break;
    }
  }

  String _maskAccount(String raw) {
    final clean = raw.replaceAll(RegExp(r'\s+'), '').trim();
    if (clean.length <= 4) return clean;
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• •••• $last4';
  }
}
