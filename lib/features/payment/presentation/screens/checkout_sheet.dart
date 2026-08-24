import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../domain/entities/payment_entity.dart';
import '../../data/services/payment_gateway_service.dart';
import '../widgets/payment_success_dialog.dart';
import '../widgets/payment_brand_logos.dart';

class CheckoutSheet extends ConsumerStatefulWidget {
  final String planKey;

  const CheckoutSheet({
    super.key,
    this.planKey = 'annual',
  });

  static Future<bool?> show(BuildContext context, {String planKey = 'annual'}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutSheet(planKey: planKey),
    );
  }

  @override
  ConsumerState<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<CheckoutSheet> {
  PaymentMethodType _selectedMethod = PaymentMethodType.easypaisa;
  bool _isProcessing = false;
  String? _errorMessage;

  // Controllers
  final _mobileController = TextEditingController();
  final _cnicController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _cnicController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      String accountOrCard = '';
      String? cnicOrOtp;
      String? expiry;
      String? cvv;
      String? holder;

      switch (_selectedMethod) {
        case PaymentMethodType.easypaisa:
        case PaymentMethodType.jazzcash:
          accountOrCard = _mobileController.text.trim();
          cnicOrOtp = _cnicController.text.trim();
          break;
        case PaymentMethodType.card:
          accountOrCard = _cardNumberController.text.replaceAll(' ', '').trim();
          expiry = _cardExpiryController.text.trim();
          cvv = _cardCvvController.text.trim();
          holder = _cardHolderController.text.trim();
          break;
      }

      final transaction = await PaymentGatewayService().processPayment(
        method: _selectedMethod,
        planKey: widget.planKey,
        accountOrCardNumber: accountOrCard,
        cnicOrOtp: cnicOrOtp,
        cardHolderName: holder,
        expiryDate: expiry,
        cvv: cvv,
      );

      // Upgrade Riverpod state immediately
      await ref.read(subscriptionProvider.notifier).upgradeToPremium(plan: widget.planKey);

      if (!mounted) return;
      setState(() => _isProcessing = false);
      Navigator.pop(context, true); // Close checkout sheet

      // Show digital receipt
      if (context.mounted) {
        PaymentSuccessDialog.show(context, transaction);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plan = PaymentGatewayService.getPlanDetails(widget.planKey);
    final amountPkr = (plan['amountPkr'] as double).toStringAsFixed(0);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E3B50).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: Color(0xFF7E3B50), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure Checkout',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '256-Bit Encrypted Payment Processing',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Plan Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7E3B50).withValues(alpha: 0.08),
                    const Color(0xFFC5A267).withValues(alpha: 0.14),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC5A267).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF7E3B50),
                            ),
                          ),
                          if (plan['discount'] != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC5A267),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                plan['discount'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Unlimited AI Sizing & VIP Stylist (${plan['duration']})',
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. $amountPkr',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF7E3B50),
                        ),
                      ),
                      Text(
                        plan['usdText'] as String,
                        style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Select Payment Gateway Title
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Payment Method Tabs
            Row(
              children: [
                _buildMethodSelector(
                  type: PaymentMethodType.easypaisa,
                  label: 'Easypaisa',
                  customLogo: const EasypaisaLogo(size: 20),
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFF00A859),
                ),
                const SizedBox(width: 8),
                _buildMethodSelector(
                  type: PaymentMethodType.jazzcash,
                  label: 'JazzCash',
                  customLogo: const JazzCashLogo(size: 20),
                  icon: Icons.phone_android,
                  color: const Color(0xFFE51937),
                ),
                const SizedBox(width: 8),
                _buildMethodSelector(
                  type: PaymentMethodType.card,
                  label: 'Debit / Card',
                  customLogo: const CardsLogo(size: 16),
                  icon: Icons.credit_card,
                  color: const Color(0xFF1A1F71),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Dynamic Form Fields
            _buildMethodForm(colorScheme),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: colorScheme.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E3B50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 2,
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text('Authorizing Gateway...', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, size: 16, color: Color(0xFFC5A267)),
                          const SizedBox(width: 8),
                          Text(
                            'Pay Rs. $amountPkr Securely',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '🔒 Secured with 3D Secure & State Bank of Pakistan Compliant Gateways',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: colorScheme.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector({
    required PaymentMethodType type,
    required String label,
    Widget? customLogo,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMethod = type;
            _errorMessage = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              customLogo ?? Icon(icon, color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodForm(ColorScheme colorScheme) {
    switch (_selectedMethod) {
      case PaymentMethodType.easypaisa:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Easypaisa Mobile Account Number'),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: _inputDecoration(
                hintText: '',
                prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF00A859)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '💡 You will receive a popup / OTP on your phone to approve the payment.',
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ],
        );

      case PaymentMethodType.jazzcash:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('JazzCash Mobile Account Number'),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: _inputDecoration(
                hintText: '',
                prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFE51937)),
              ),
            ),
            const SizedBox(height: 12),
            _buildFieldLabel('CNIC Last 6 Digits (Optional for Biometric)'),
            TextField(
              controller: _cnicController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: _inputDecoration(
                hintText: '',
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
          ],
        );

      case PaymentMethodType.card:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Cardholder Name'),
            TextField(
              controller: _cardHolderController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                hintText: '',
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            _buildFieldLabel('Debit / Credit Card Number (Visa / Mastercard / PayPak)'),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
              ],
              decoration: _inputDecoration(
                hintText: '',
                prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF1A1F71)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Expiry (MM/YY)'),
                      TextField(
                        controller: _cardExpiryController,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5),
                        ],
                        decoration: _inputDecoration(
                          hintText: '',
                          prefixIcon: const Icon(Icons.date_range, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('CVV Code'),
                      TextField(
                        controller: _cardCvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: _inputDecoration(
                          hintText: '',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText, Widget? prefixIcon}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 13, color: colorScheme.outline),
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF7E3B50), width: 1.8),
      ),
    );
  }
}
