import 'package:flutter/material.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final PaymentTransaction transaction;

  const PaymentSuccessDialog({
    super.key,
    required this.transaction,
  });

  static Future<void> show(BuildContext context, PaymentTransaction transaction) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentSuccessDialog(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Checkmark Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF10B981), width: 2),
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 44),
            ),
            const SizedBox(height: 16),

            // Header
            Text(
              'Payment Successful!',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your FitLens VIP membership is now active with unlimited AI Sizing & Styling.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Receipt Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Plan', transaction.planTitle, colorScheme),
                  const Divider(height: 16),
                  _buildReceiptRow('Amount Paid', 'Rs. ${transaction.amountPkr.toStringAsFixed(0)}', colorScheme, isBold: true),
                  const Divider(height: 16),
                  _buildReceiptRow('Payment Method', _getMethodLabel(transaction.method), colorScheme),
                  const Divider(height: 16),
                  _buildReceiptRow('Account / Card', transaction.accountOrCardMasked, colorScheme),
                  const Divider(height: 16),
                  _buildReceiptRow('Transaction Ref', transaction.transactionId, colorScheme, isMonospace: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E3B50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium, color: Color(0xFFC5A267), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Access VIP Features Now',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, ColorScheme colorScheme, {bool isBold = false, bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontFamily: isMonospace ? 'monospace' : null,
            color: isBold ? const Color(0xFF7E3B50) : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getMethodLabel(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.easypaisa:
        return '🟢 Easypaisa Wallet';
      case PaymentMethodType.jazzcash:
        return '🔴 JazzCash Wallet';
      case PaymentMethodType.card:
        return '💳 Debit / Credit Card';
    }
  }
}
