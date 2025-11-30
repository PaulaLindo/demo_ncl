// lib/widgets/pricing_calculator_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/pricing_provider.dart';
import '../models/pricing_model.dart';
import '../theme/app_theme.dart';
import '../utils/color_utils.dart';

class PricingCalculatorWidget extends StatefulWidget {
  final bool showSummary;
  final bool allowBooking;
  final VoidCallback? onPriceCalculated;
  final VoidCallback? onBookRequested;

  const PricingCalculatorWidget({
    super.key,
    this.showSummary = true,
    this.allowBooking = true,
    this.onPriceCalculated,
    this.onBookRequested,
  });

  @override
  State<PricingCalculatorWidget> createState() => _PricingCalculatorWidgetState();
}

class _PricingCalculatorWidgetState extends State<PricingCalculatorWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PricingProvider>().calculatePrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PricingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Type Selection
              _buildSectionHeader('Service Type'),
              const SizedBox(height: 12),
              _buildServiceTypeSelector(provider),
              
              const SizedBox(height: 24),
              
              // Property Size Selection
              _buildSectionHeader('Property Size'),
              const SizedBox(height: 12),
              _buildPropertySizeSelector(provider),
              
              const SizedBox(height: 24),
              
              // Frequency Selection
              _buildSectionHeader('Booking Frequency'),
              const SizedBox(height: 12),
              _buildFrequencySelector(provider),
              
              const SizedBox(height: 24),
              
              // Add-ons Selection
              _buildSectionHeader('Additional Services'),
              const SizedBox(height: 12),
              _buildAddOnsSelector(provider),
              
              if (widget.showSummary && provider.currentQuote != null) ...[
                const SizedBox(height: 32),
                _buildPricingSummary(provider),
              ],
              
              if (widget.allowBooking && provider.currentQuote != null) ...[
                const SizedBox(height: 24),
                _buildBookingButton(provider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildServiceTypeSelector(PricingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: ServiceType.values.map((service) {
          final isSelected = provider.selectedService == service;
          return _buildServiceOption(service, isSelected, provider);
        }).toList(),
      ),
    );
  }

  Widget _buildServiceOption(ServiceType service, bool isSelected, PricingProvider provider) {
    return InkWell(
      onTap: () => provider.updateServiceType(service),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple.withCustomOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryPurple : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.getServiceDescription(service),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${service.basePrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryPurple : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertySizeSelector(PricingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: PropertySize.values.map((size) {
          final isSelected = provider.selectedPropertySize == size;
          return _buildPropertySizeOption(size, isSelected, provider);
        }).toList(),
      ),
    );
  }

  Widget _buildPropertySizeOption(PropertySize size, bool isSelected, PricingProvider provider) {
    return InkWell(
      onTap: () => provider.updatePropertySize(size),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple.withCustomOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryPurple : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    size.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.getPropertySizeDescription(size),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(size.multiplier * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryPurple : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(PricingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: BookingFrequency.values.map((frequency) {
          final isSelected = provider.selectedFrequency == frequency;
          return _buildFrequencyOption(frequency, isSelected, provider);
        }).toList(),
      ),
    );
  }

  Widget _buildFrequencyOption(BookingFrequency frequency, bool isSelected, PricingProvider provider) {
    final discount = (1 - frequency.discountMultiplier) * 100;
    
    return InkWell(
      onTap: () => provider.updateFrequency(frequency),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple.withCustomOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryPurple : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    frequency.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.getFrequencyDescription(frequency),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (discount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.greenStatus.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '-${discount.toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.greenStatus,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOnsSelector(PricingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: AddOnService.values.map((addOn) {
          final isSelected = provider.isAddOnSelected(addOn);
          return _buildAddOnOption(addOn, isSelected, provider);
        }).toList(),
      ),
    );
  }

  Widget _buildAddOnOption(AddOnService addOn, bool isSelected, PricingProvider provider) {
    return InkWell(
      onTap: () => provider.toggleAddOn(addOn),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple.withCustomOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryPurple : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addOn.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.getAddOnDescription(addOn),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+\$${addOn.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryPurple : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummary(PricingProvider provider) {
    final quote = provider.currentQuote!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple,
            AppTheme.primaryPurple.withCustomOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withCustomOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Summary',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSummaryRow('Base Price', quote.formattedBasePrice),
          if (quote.sizeMultiplier > 1.0)
            _buildSummaryRow('Size Multiplier', '${(quote.sizeMultiplier * 100).toInt()}%'),
          if (quote.addOnsTotal > 0)
            _buildSummaryRow('Add-ons', quote.formattedAddOnsTotal),
          _buildSummaryRow('Subtotal', quote.formattedSubtotal),
          if (quote.discountAmount > 0)
            _buildSummaryRow('Discount', quote.formattedDiscount, isDiscount: true),
          _buildSummaryRow('Tax (8.5%)', quote.formattedTaxAmount),
          const Divider(color: Colors.white54),
          _buildSummaryRow('Total', quote.formattedTotalPrice, isTotal: true),
          
          const SizedBox(height: 16),
          Text(
            'Estimated duration: ${quote.estimatedHours.toStringAsFixed(1)} hours',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isDiscount ? Colors.greenAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(PricingProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          final validationError = provider.validateSelections();
          if (validationError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(validationError),
                backgroundColor: AppTheme.redStatus,
              ),
            );
            return;
          }
          
          widget.onBookRequested?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldAccent,
          foregroundColor: Colors.black,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Text(
              'Book Service - ${provider.currentQuote!.formattedTotalPrice}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
