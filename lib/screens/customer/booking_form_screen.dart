// lib/screens/customer/booking_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import 'booking_confirmation_screen.dart';
import '../../theme/app_theme.dart';

class BookingFormScreen extends StatefulWidget {
  final String serviceId;

  const BookingFormScreen({super.key, required this.serviceId});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _instructionsController = TextEditingController();

  DateTime? _selectedDate;
  String _preferredTime = 'morning';
  String _propertySize = 'medium';
  String _frequency = 'one-time';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final service = provider.getServiceById(widget.serviceId);

    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Service not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.primaryPurple,
        ),
        title: const Text(
          'Book Service',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryPurple,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Service summary card
            _buildServiceSummary(service),

            // Booking form
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Selection
                    _buildFormSection(
                      'Select Date',
                      _buildDatePicker(),
                      'Choose your preferred service date',
                    ),

                    const SizedBox(height: 20),

                    // Time Selection
                    _buildFormSection(
                      'Preferred Time',
                      _buildTimeDropdown(),
                      'When would you prefer the service?',
                    ),

                    const SizedBox(height: 20),

                    // Property Size
                    _buildFormSection(
                      'Property Size',
                      _buildPropertySizeDropdown(),
                      'This helps us estimate duration and pricing',
                    ),

                    const SizedBox(height: 20),

                    // Frequency
                    _buildFormSection(
                      'Booking Frequency',
                      _buildFrequencyDropdown(),
                      'Save with regular bookings',
                    ),

                    const SizedBox(height: 20),

                    // Special Instructions
                    _buildFormSection(
                      'Special Instructions (Optional)',
                      TextField(
                        controller: _instructionsController,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          hintText:
                              'Any specific requirements, access instructions, or areas of focus...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      'Let us know about any special requirements',
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded),
                      label:
                          Text(_isSubmitting ? 'Processing...' : 'Confirm Booking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 54),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(String label, Widget child, String helpText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          child,
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppTheme.subtleText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  helpText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.subtleText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppTheme.primaryPurple,
                  onPrimary: Colors.white,
                  surface: AppTheme.cardBackground,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.cardBackground,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null
                  ? DateFormat('EEEE, MMMM d, y').format(_selectedDate!)
                  : 'Select a date',
              style: TextStyle(
                fontSize: 16,
                color:
                    _selectedDate != null ? AppTheme.textColor : AppTheme.subtleText,
              ),
            ),
            const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDropdown() {
    return DropdownButtonFormField<String>(
      value: _preferredTime,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: const [
        DropdownMenuItem(value: 'morning', child: Text('Morning (8:00 - 12:00)')),
        DropdownMenuItem(value: 'afternoon', child: Text('Afternoon (12:00 - 16:00)')),
        DropdownMenuItem(value: 'flexible', child: Text('Flexible')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _preferredTime = value);
      },
    );
  }

  Widget _buildPropertySizeDropdown() {
    return DropdownButtonFormField<String>(
      value: _propertySize,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: const [
        DropdownMenuItem(value: 'small', child: Text('Small (1-2 Bedrooms)')),
        DropdownMenuItem(value: 'medium', child: Text('Medium (3-4 Bedrooms)')),
        DropdownMenuItem(value: 'large', child: Text('Large (5+ Bedrooms)')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _propertySize = value);
      },
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _frequency,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: const [
        DropdownMenuItem(value: 'one-time', child: Text('One-time service')),
        DropdownMenuItem(value: 'weekly', child: Text('Weekly (10% discount)')),
        DropdownMenuItem(value: 'bi-weekly', child: Text('Bi-weekly (5% discount)')),
        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _frequency = value);
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select a date'),
            ],
          ),
          backgroundColor: AppTheme.redStatus,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = Provider.of<BookingProvider>(context, listen: false);

    try {
      final success = await provider.createBooking(
        serviceId: widget.serviceId,
        bookingDate: _selectedDate!,
        preferredTime: _preferredTime,
        propertySize: _propertySize,
        specialInstructions: _instructionsController.text.trim(),
        frequency: _frequency,
      );

      if (success && mounted) {
        // Get the created booking
        final createdBooking = provider.bookings.last;
        
        // Navigate to confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              booking: createdBooking,
            ),
          ),
        );
      } else if (mounted) {
        _showError('Failed to create booking. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.redStatus,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildServiceSummary(dynamic service) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cleaning_services_rounded,
                  color: AppTheme.primaryPurple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.duration,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.subtleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.borderColor),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated price:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.subtleText,
                ),
              ),
              Text(
                service.priceDisplay,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'for $_propertySize property',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.subtleText,
            ),
          ),
        ],
      ),
    );
  }
}