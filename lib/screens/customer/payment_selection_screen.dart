// lib/screens/customer/payment_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';
import '../../providers/booking_provider.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String serviceTitle;

  const PaymentSelectionScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.serviceTitle,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String _selectedPaymentMethod = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Debug: Print to see if screen is being initialized
    print('PaymentSelectionScreen initialized: ${widget.bookingId}, ${widget.amount}, ${widget.serviceTitle}');
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'credit_card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'description': 'Visa, Mastercard, American Express',
      'color': AppTheme.primaryPurple,
    },
    {
      'id': 'paypal',
      'name': 'PayPal',
      'icon': Icons.account_balance_wallet,
      'description': 'Fast and secure payment',
      'color': AppTheme.infoBlue,
    },
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'icon': Icons.account_balance,
      'description': 'Direct bank deposit',
      'color': AppTheme.greenStatus,
    },
    {
      'id': 'cash_on_arrival',
      'name': 'Cash on Arrival',
      'icon': Icons.money,
      'description': 'Pay when service is completed',
      'color': AppTheme.goldAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.watch<ThemeProvider>().primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary
            _buildBookingSummary(),
            const SizedBox(height: 24),
            
            // Payment Methods
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._paymentMethods.map((method) => _buildPaymentMethod(method)),
            
            const SizedBox(height: 24),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod.isEmpty ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Processing...'),
                        ],
                      )
                    : const Text(
                        'Confirm Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Security Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: AppTheme.primaryPurple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your payment information is secure and encrypted',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.work, color: AppTheme.primaryPurple, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.serviceTitle,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.confirmation_number, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Booking ID: ${widget.bookingId}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                Text(
                  'R${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? method['color'].withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? method['color'] : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method['id'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: method['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  method['icon'],
                  color: method['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? method['color'] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: method['id'],
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                activeColor: method['color'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment() async {
    print('Processing payment with method: $_selectedPaymentMethod');
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing with steps
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        // Show processing dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Processing payment...'),
                const SizedBox(height: 8),
                Text(
                  'Payment Method: ${_getPaymentMethodName()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
        
        // Continue processing
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          Navigator.of(context).pop(); // Close processing dialog
          setState(() {
            _isProcessing = false;
          });
          
          print('Payment successful! Navigating to home...');
          
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.greenStatus),
                  const SizedBox(width: 8),
                  Text('Payment Successful!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Your booking has been confirmed.'),
                  const SizedBox(height: 8),
                  Text(
                    'Payment Method: ${_getPaymentMethodName()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Amount: R${widget.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close success dialog
                    context.go(AppRoutes.customerHome); // Navigate to home
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        print('Payment failed: $e');
        
        Navigator.of(context).pop(); // Close processing dialog if open
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: AppTheme.redStatus,
          ),
        );
      }
    }
  }

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 'credit_card':
        return 'Credit/Debit Card';
      case 'paypal':
        return 'PayPal';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cash_on_arrival':
        return 'Cash on Arrival';
      default:
        return 'Unknown';
    }
  }
}

class PaymentDetailsScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String paymentMethod;
  final String serviceTitle;

  const PaymentDetailsScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.serviceTitle,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _saveCardInfo = false;

  // Form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.paymentMethod.toUpperCase()} Payment'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.watch<ThemeProvider>().primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Header
              _buildPaymentMethodHeader(),
              const SizedBox(height: 24),
              
              // Payment Form
              _buildPaymentForm(),
              const SizedBox(height: 24),
              
              // Save Card Option (for credit card)
              if (widget.paymentMethod == 'credit_card') ...[
                CheckboxListTile(
                  value: _saveCardInfo,
                  onChanged: (value) {
                    setState(() {
                      _saveCardInfo = value!;
                    });
                  },
                  title: const Text('Save card information for future payments'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
              ],
              
              // Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processing Payment...'),
                          ],
                        )
                      : Text(
                          'Pay R${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodHeader() {
    final method = _getPaymentMethodInfo();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: method['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              method['icon'],
              color: method['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.serviceTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'R${widget.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: method['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    switch (widget.paymentMethod) {
      case 'credit_card':
        return _buildCreditCardForm();
      case 'paypal':
        return _buildPayPalForm();
      case 'bank_transfer':
        return _buildBankTransferForm();
      case 'cash_on_arrival':
        return _buildCashOnArrivalForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCreditCardForm() {
    return Column(
      children: [
        // Card Number
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            if (value.length < 16) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Card Name and Expiry in row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cardNameController,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expiry date';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // CVV
        TextFormField(
          controller: _cvvController,
          decoration: InputDecoration(
            labelText: 'CVV',
            hintText: '123',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.security),
          ),
          keyboardType: TextInputType.number,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter CVV';
            }
            if (value.length < 3) {
              return 'Please enter a valid CVV';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Contact Information
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'john@example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPayPalForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.infoBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.infoBlue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet, color: AppTheme.infoBlue, size: 48),
              const SizedBox(height: 8),
              Text(
                'You will be redirected to PayPal to complete your payment',
                style: TextStyle(
                  color: AppTheme.infoBlue,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'PayPal Email',
            hintText: 'your@email.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter PayPal email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankTransferForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.greenStatus.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.greenStatus.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bank Transfer Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greenStatus,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bank: NCL Cleaning Services\nAccount: 1234567890\nBranch: Main Branch\nReference: ${widget.bookingId}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email for Receipt',
            hintText: 'your@email.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email for receipt';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCashOnArrivalForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.goldAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.money, color: AppTheme.goldAccent, size: 48),
          const SizedBox(height: 8),
          Text(
            'Pay when service is completed',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.goldAccent,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please have the exact amount ready when our staff arrives.',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Contact Number',
              hintText: '+27 12 345 6789',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getPaymentMethodInfo() {
    switch (widget.paymentMethod) {
      case 'credit_card':
        return {
          'name': 'Credit/Debit Card',
          'icon': Icons.credit_card,
          'color': AppTheme.primaryPurple,
        };
      case 'paypal':
        return {
          'name': 'PayPal',
          'icon': Icons.account_balance_wallet,
          'color': AppTheme.infoBlue,
        };
      case 'bank_transfer':
        return {
          'name': 'Bank Transfer',
          'icon': Icons.account_balance,
          'color': AppTheme.greenStatus,
        };
      case 'cash_on_arrival':
        return {
          'name': 'Cash on Arrival',
          'icon': Icons.money,
          'color': AppTheme.goldAccent,
        };
      default:
        return {
          'name': 'Unknown',
          'icon': Icons.help,
          'color': Colors.grey,
        };
    }
  }

  void _submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        // Show payment success
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentConfirmationScreen(
              bookingId: widget.bookingId,
              amount: widget.amount,
              paymentMethod: widget.paymentMethod,
              serviceTitle: widget.serviceTitle,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: AppTheme.redStatus,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

class PaymentConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final double amount;
  final String paymentMethod;
  final String serviceTitle;

  const PaymentConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.serviceTitle,
  });

  @override
  Widget build(BuildContext context) {
    final method = _getPaymentMethodInfo();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment Complete'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: TextStyle(
                color: context.watch<ThemeProvider>().primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.greenStatus.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.greenStatus,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              
              // Success Message
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greenStatus,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Your booking has been confirmed',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              
              // Payment Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.work, color: AppTheme.primaryPurple, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            serviceTitle,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.confirmation_number, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Booking ID: $bookingId',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(method['icon'], color: method['color'], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          method['name'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.greenStatus.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount Paid',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.greenStatus,
                            ),
                          ),
                          Text(
                            'R$amount.toStringAsFixed(2)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.greenStatus,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/customer/home',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Generate receipt PDF
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt downloaded successfully'),
                        backgroundColor: AppTheme.greenStatus,
                      ),
                    );
                  },
                  child: const Text('Download Receipt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getPaymentMethodInfo() {
    switch (paymentMethod) {
      case 'credit_card':
        return {
          'name': 'Credit/Debit Card',
          'icon': Icons.credit_card,
          'color': AppTheme.primaryPurple,
        };
      case 'paypal':
        return {
          'name': 'PayPal',
          'icon': Icons.account_balance_wallet,
          'color': AppTheme.infoBlue,
        };
      case 'bank_transfer':
        return {
          'name': 'Bank Transfer',
          'icon': Icons.account_balance,
          'color': AppTheme.greenStatus,
        };
      case 'cash_on_arrival':
        return {
          'name': 'Cash on Arrival',
          'icon': Icons.money,
          'color': AppTheme.goldAccent,
        };
      default:
        return {
          'name': 'Unknown',
          'icon': Icons.help,
          'color': Colors.grey,
        };
    }
  }
}
