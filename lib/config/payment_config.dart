class PaymentConfig {
  // Stripe Configuration
  static const String stripePublishableKey = 'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY';
  static const String stripeSecretKey = 'sk_test_YOUR_STRIPE_SECRET_KEY';
  static const String stripeMerchantId = 'merchant.com.elearning';
  
  // Razorpay Configuration
  static const String razorpayKeyId = 'rzp_test_YOUR_RAZORPAY_KEY_ID';
  static const String razorpayKeySecret = 'YOUR_RAZORPAY_KEY_SECRET';
  
  // Currency
  static const String currency = 'USD';
  static const String currencySymbol = '\$';
  
  // Payment Methods
  static const List<String> supportedPaymentMethods = [
    'stripe',
    'razorpay',
  ];
}
