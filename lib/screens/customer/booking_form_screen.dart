// lib/screens/customer/booking_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../models/booking_model.dart';

import '../../providers/booking_provider.dart';
import '../../providers/theme_provider.dart';

import '../../theme/app_theme.dart';

class BookingFormScreen extends StatefulWidget {
  final String serviceId;
  final Booking? existingBooking;

  const BookingFormScreen({
    super.key, 
    required this.serviceId,
    this.existingBooking,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _instructionsController = TextEditingController();
  final _addressController = TextEditingController();
  final _scrollController = ScrollController();

  late DateTime _selectedDate;
  late TimeOfDayPreference _timePreference;
  late PropertySize _propertySize;
  late BookingFrequency _frequency;
  bool _isLoading = false;
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingBooking != null;
    
    if (_isEditMode) {
      final booking = widget.existingBooking!;
      _selectedDate = booking.bookingDate;
      _timePreference = booking.timePreference;
      _propertySize = booking.propertySize;
      _frequency = booking.frequency;
      _instructionsController.text = booking.specialInstructions ?? '';
      _addressController.text = booking.address;
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 30)); // Start from one month advance
      _timePreference = TimeOfDayPreference.morning;
      _propertySize = PropertySize.medium;
      _frequency = BookingFrequency.oneTime;
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _addressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 30)), // Start from one month advance
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final bookingProvider = context.read<BookingProvider>();
      
      final booking = Booking(
        id: _isEditMode ? widget.existingBooking!.id : DateTime.now().toString(),
        customerId: 'current_user_id', // Replace with actual user ID
        serviceId: widget.serviceId,
        serviceName: 'Cleaning Service', // Get from service details
        bookingDate: _selectedDate,
        timePreference: _timePreference,
        address: _addressController.text,
        status: BookingStatus.pending,
        basePrice: 100.0, // Get from service details
        propertySize: _propertySize,
        frequency: _frequency,
        specialInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text
            : null,
        createdAt: DateTime.now(),
        startTime: _selectedDate,
        endTime: _selectedDate.add(const Duration(hours: 2)),
        assignedStaffId: _isEditMode ? widget.existingBooking!.assignedStaffId : null,
        assignedStaffName: _isEditMode ? widget.existingBooking!.assignedStaffName : null,
      );

      if (_isEditMode) {
        // Update existing booking
        bookingProvider.updateBooking(booking);
        if (mounted) {
          Navigator.of(context).pop(true); // Return success
        }
      } else {
        // Create new booking
        print('Creating booking with serviceId: ${widget.serviceId}');
        print('Selected date: $_selectedDate');
        print('Address: ${_addressController.text}');
        print('Property size: ${_propertySize.name}');
        print('Frequency: ${_frequency.name}');
        print('Time preference: $_timePreference');
        
        final success = await bookingProvider.createBooking(
          serviceId: widget.serviceId,
          bookingDate: _selectedDate,
          address: _addressController.text,
          propertySize: _propertySize.name,
          frequency: _frequency.name,
          timePreference: _timePreference,
          notes: _instructionsController.text.trim().isNotEmpty
              ? _instructionsController.text
              : null,
        );
        
        print('Booking creation success: $success');
        
        if (success && mounted) {
          // Get the first booking (most recently created)
          final bookings = bookingProvider.bookings;
          print('Total bookings: ${bookings.length}');
          
          if (bookings.isNotEmpty) {
            final currentBooking = bookings.first;
            print('Booking ID: ${currentBooking.id}');
            print('Booking amount: ${currentBooking.basePrice}');
            print('Booking service: ${currentBooking.serviceName}');
            
            // Navigate to payment screen
            print('Navigating to payment: /customer/payment/${currentBooking.id}?amount=${currentBooking.basePrice}&service=${currentBooking.serviceName}');
            context.push('/customer/payment/${currentBooking.id}?amount=${currentBooking.basePrice}&service=${currentBooking.serviceName}');
          } else {
            print('Error: No bookings found after successful creation');
          }
        } else {
          print('Booking creation failed or widget not mounted');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isEditMode ? 'update' : 'create'} booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEditMode ? 'Update Booking' : 'New Booking'),
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
      body: Form(
        key: _formKey,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('When', Icons.calendar_today),
                    _buildDateField(theme),
                    const SizedBox(height: 16),
                    _buildTimePreferenceField(theme),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('Property Details', Icons.home),
                    _buildAddressField(theme),
                    const SizedBox(height: 16),
                    _buildPropertySizeField(theme),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('Service Options', Icons.settings),
                    _buildFrequencyField(theme),
                    const SizedBox(height: 16),
                    _buildSpecialInstructionsField(theme),
                    
                    const SizedBox(height: 32),
                    _buildSubmitButton(theme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildDateField(ThemeData theme) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Select Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, y').format(_selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePreferenceField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TimeOfDayPreference.values.map((time) {
            final isSelected = _timePreference == time;
            return ChoiceChip(
              label: Text(
                '${time.displayName} (${time.timeRange})',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.primaryColor,
              backgroundColor: Colors.grey[200],
              onSelected: (selected) {
                if (selected) {
                  setState(() => _timePreference = time);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddressField(ThemeData theme) {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Address',
        hintText: 'Enter your full address',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.location_on),
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your address';
        }
        
        // Check if address contains both numbers and letters (road name)
        final hasNumbers = RegExp(r'\d').hasMatch(value);
        final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(value);
        
        if (!hasNumbers) {
          return 'Please include street number in your address';
        }
        
        if (!hasLetters) {
          return 'Please include street name in your address';
        }
        
        if (value.trim().length < 5) {
          return 'Please enter a complete address';
        }
        
        return null;
      },
    );
  }

  Widget _buildPropertySizeField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Size',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PropertySize.values.map((size) {
            final isSelected = _propertySize == size;
            return ChoiceChip(
              label: Text(
                size.displayName, // TODO: Add sqMeters to PropertySize enum
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.primaryColor,
              backgroundColor: Colors.grey[200],
              onSelected: (selected) {
                if (selected) {
                  setState(() => _propertySize = size);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

 Widget _buildFrequencyField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cleaning Frequency',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BookingFrequency.values.map((freq) {
            final isSelected = _frequency == freq;
            return ChoiceChip(
              label: Text(
                '${freq.displayName} ${freq != BookingFrequency.oneTime ? '(${freq.discountMultiplier * 100}% off)' : ''}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.primaryColor,
              backgroundColor: Colors.grey[200],
              onSelected: (selected) {
                if (selected) {
                  setState(() => _frequency = freq);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpecialInstructionsField(ThemeData theme) {
    return TextFormField(
      controller: _instructionsController,
      decoration: InputDecoration(
        labelText: 'Special Instructions (Optional)',
        hintText: 'Any special requests or instructions for the cleaner?',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.note_add),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isEditMode ? 'UPDATE BOOKING' : 'BOOK NOW',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
      value: _timePreference.name,
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
        if (value != null) setState(() => _timePreference = TimeOfDayPreference.values.firstWhere((e) => e.name == value));
      },
    );
  }

  Widget _buildPropertySizeDropdown() {
    return DropdownButtonFormField<PropertySize>(
      value: _propertySize,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: PropertySize.values.map((size) {
        return DropdownMenuItem(
          value: size,
          child: Text(size.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _propertySize = value);
      },
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<BookingFrequency>(
      value: _frequency,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: BookingFrequency.values.map((freq) {
        return DropdownMenuItem(
          value: freq,
          child: Text(freq.displayName),
        );
      }).toList(),
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

    setState(() => _isLoading = true);

    final provider = Provider.of<BookingProvider>(context, listen: false);

    try {
      final success = await provider.createBooking(
        serviceId: widget.serviceId,
        bookingDate: _selectedDate!,
        address: _addressController.text.trim(),
        propertySize: _propertySize.name,
        frequency: _frequency.name,
        timePreference: _timePreference,
        notes: _instructionsController.text.trim(),
      );

      if (success && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Booking Confirmed!'),
            content: const Text('Your booking has been successfully created.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/customer/bookings');
                },
                child: const Text('View Bookings'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/customer/home');
                },
                child: const Text('Home'),
              ),
            ],
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
        setState(() => _isLoading = false);
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
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
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
  }}
