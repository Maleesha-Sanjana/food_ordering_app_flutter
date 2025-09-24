import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/payment.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();

  String _selectedCardType = 'Visa';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with dummy data
    _cardNumberController.text = '1111 1111 1111 1111';
    _expiryDateController.text = '02/25';
    _cvvController.text = '123';
    _cardHolderNameController.text = 'Maleesha Sanjana';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  void _formatCardNumber(String value) {
    // Remove all non-digits
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Add spaces every 4 digits
    final formatted = digitsOnly
        .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
        .trim();

    _cardNumberController.value = _cardNumberController.value.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    // Update card type based on first digit
    if (digitsOnly.isNotEmpty) {
      setState(() {
        _selectedCardType = PaymentMethod.getCardType(digitsOnly);
      });
    }
  }

  void _formatExpiryDate(String value) {
    // Remove all non-digits
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    String formatted = digitsOnly;
    if (digitsOnly.length >= 2) {
      formatted = '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
    }

    _expiryDateController.value = _expiryDateController.value.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final paymentMethod = PaymentMethod(
      cardNumber: _cardNumberController.text,
      expiryDate: _expiryDateController.text,
      cvv: _cvvController.text,
      cardHolderName: _cardHolderNameController.text,
      cardType: _selectedCardType,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      // Store payment method in cart
      context.read<CartProvider>().setPaymentMethod(paymentMethod);

      // Create and process the order
      final auth = context.read<AuthProvider>();
      final cart = context.read<CartProvider>();
      final ordersProvider = context.read<OrdersProvider>();

      final user = auth.currentUser;
      if (user != null && cart.lines.isNotEmpty) {
        final sellerId = cart.lines.first.item.sellerId;
        final order = OrderModel(
          id: 0,
          customerId: user.id,
          sellerId: sellerId,
          items: cart.toOrderItems(),
          subtotal: cart.subtotal,
          discount: cart.discount,
          grandTotal: cart.grandTotal,
          paymentStatus: 'Paid',
          orderStatus: 'Pending',
        );

        await ordersProvider.createOrder(order);

        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Payment Successful!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card: ${paymentMethod.maskedCardNumber}'),
                  Text('Amount: \$${cart.grandTotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const Text('Your order has been placed successfully!'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    cart.clear(); // Clear cart after successful order
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(
                      context,
                    ).pop(); // Go back to customer dashboard
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Items (${cart.lines.length})'),
                              Text('\$${cart.subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          if (cart.discount > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Discount',
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                Text(
                                  '-\$${cart.discount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${cart.grandTotal.toStringAsFixed(2)}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Details',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Card Number
                          TextFormField(
                            controller: _cardNumberController,
                            onChanged: _formatCardNumber,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(19),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Card Number',
                              hintText: '1234 5678 9012 3456',
                              prefixIcon: Icon(_getCardIcon(_selectedCardType)),
                              suffixIcon: Icon(
                                Icons.credit_card,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter card number';
                              }
                              final payment = PaymentMethod(
                                cardNumber: value,
                                expiryDate: _expiryDateController.text,
                                cvv: _cvvController.text,
                                cardHolderName: _cardHolderNameController.text,
                                cardType: _selectedCardType,
                              );
                              if (!payment.isValidCardNumber) {
                                return 'Invalid card number';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Expiry Date and CVV
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _expiryDateController,
                                  onChanged: _formatExpiryDate,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Expiry Date',
                                    hintText: 'MM/YY',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    final payment = PaymentMethod(
                                      cardNumber: _cardNumberController.text,
                                      expiryDate: value,
                                      cvv: _cvvController.text,
                                      cardHolderName:
                                          _cardHolderNameController.text,
                                      cardType: _selectedCardType,
                                    );
                                    if (!payment.isValidExpiryDate) {
                                      return 'Invalid date';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _cvvController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'CVV',
                                    hintText: '123',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    final payment = PaymentMethod(
                                      cardNumber: _cardNumberController.text,
                                      expiryDate: _expiryDateController.text,
                                      cvv: value,
                                      cardHolderName:
                                          _cardHolderNameController.text,
                                      cardType: _selectedCardType,
                                    );
                                    if (!payment.isValidCvv) {
                                      return 'Invalid CVV';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Card Holder Name
                          TextFormField(
                            controller: _cardHolderNameController,
                            decoration: const InputDecoration(
                              labelText: 'Card Holder Name',
                              hintText: 'John Doe',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter card holder name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isProcessing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Processing...'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.payment),
                                const SizedBox(width: 8),
                                Text(
                                  'Pay \$${cart.grandTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'american express':
        return Icons.credit_card;
      case 'discover':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}
