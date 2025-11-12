import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../config/theme_config.dart';
import '../../config/payment_config.dart';
import '../../services/payment_service.dart';
import '../courses/course_detail_screen.dart';

class PaymentScreen extends StatefulWidget {
  final CourseModel course;

  const PaymentScreen({
    super.key,
    required this.course,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  String _selectedPaymentMethod = 'stripe';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConfig.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 40,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.title,
                          style: ThemeConfig.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.course.instructor,
                          style: ThemeConfig.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Method
            Text(
              'Phương thức thanh toán',
              style: ThemeConfig.headingSmall,
            ),
            const SizedBox(height: 16),

            _buildPaymentMethodCard(
              'Stripe',
              'Thanh toán qua thẻ tín dụng/ghi nợ',
              Icons.credit_card,
              'stripe',
            ),

            const SizedBox(height: 12),

            _buildPaymentMethodCard(
              'Razorpay',
              'Thanh toán qua Razorpay',
              Icons.payment,
              'razorpay',
            ),

            const SizedBox(height: 24),

            // Price Summary
            Text(
              'Chi tiết thanh toán',
              style: ThemeConfig.headingSmall,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeConfig.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPriceRow(
                    'Giá khóa học',
                    '${PaymentConfig.currencySymbol}${widget.course.price.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 12),
                  _buildPriceRow('Thuế (0%)', '${PaymentConfig.currencySymbol}0.00'),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildPriceRow(
                    'Tổng cộng',
                    '${PaymentConfig.currencySymbol}${widget.course.price.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Terms
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeConfig.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: ThemeConfig.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bằng việc thanh toán, bạn đồng ý với điều khoản sử dụng và chính sách hoàn tiền của chúng tôi.',
                      style: ThemeConfig.bodySmall.copyWith(
                        color: ThemeConfig.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Thanh toán ${PaymentConfig.currencySymbol}${widget.course.price.toStringAsFixed(2)}',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String title,
    String subtitle,
    IconData icon,
    String method,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ThemeConfig.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? ThemeConfig.primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? ThemeConfig.primaryColor : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ThemeConfig.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: ThemeConfig.bodySmall,
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? ThemeConfig.bodyLarge.copyWith(fontWeight: FontWeight.bold)
              : ThemeConfig.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? ThemeConfig.headingSmall.copyWith(
                  color: ThemeConfig.primaryColor,
                )
              : ThemeConfig.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      // Create payment
      final payment = await _paymentService.createPayment(
        userId: authProvider.currentUser!.id,
        courseId: widget.course.id,
        amount: widget.course.price,
        paymentMethod: _selectedPaymentMethod,
      );

      // Process payment based on method
      bool success = false;
      if (_selectedPaymentMethod == 'stripe') {
        success = await _paymentService.processStripePayment(
          paymentId: payment.id,
          token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else if (_selectedPaymentMethod == 'razorpay') {
        success = await _paymentService.processRazorpayPayment(
          paymentId: payment.id,
          razorpayPaymentId: 'demo_razorpay_${DateTime.now().millisecondsSinceEpoch}',
          razorpaySignature: 'demo_signature',
        );
      }

      if (success) {
        // Complete payment and enroll
        await _paymentService.completePaymentAndEnroll(
          paymentId: payment.id,
          userId: authProvider.currentUser!.id,
          courseId: widget.course.id,
        );

        // Reload enrolled courses
        await courseProvider.loadEnrolledCourses(authProvider.currentUser!.id);

        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeConfig.successColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: ThemeConfig.successColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Thành công!'),
                ],
              ),
              content: const Text(
                'Thanh toán thành công! Bạn đã được đăng ký vào khóa học.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close payment screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => CourseDetailScreen(
                          courseId: widget.course.id,
                        ),
                      ),
                    );
                  },
                  child: const Text('Bắt đầu học'),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception('Payment processing failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thanh toán: $e'),
            backgroundColor: ThemeConfig.errorColor,
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
