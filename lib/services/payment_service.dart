import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../config/payment_config.dart';
import '../config/app_config.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create payment intent
  Future<PaymentModel> createPayment({
    required String userId,
    required String courseId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final payment = PaymentModel(
        id: '',
        userId: userId,
        courseId: courseId,
        amount: amount,
        currency: PaymentConfig.currency,
        paymentMethod: paymentMethod,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(AppConfig.paymentsCollection)
          .add(payment.toFirestore());

      return PaymentModel(
        id: docRef.id,
        userId: userId,
        courseId: courseId,
        amount: amount,
        currency: payment.currency,
        paymentMethod: paymentMethod,
        status: 'pending',
        createdAt: payment.createdAt,
      );
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Process Stripe payment
  Future<bool> processStripePayment({
    required String paymentId,
    required String token,
  }) async {
    try {
      // In production, this would call Stripe API
      // For now, we'll simulate a successful payment
      
      await _firestore
          .collection(AppConfig.paymentsCollection)
          .doc(paymentId)
          .update({
        'status': 'completed',
        'transactionId': 'stripe_$token',
        'completedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      await _firestore
          .collection(AppConfig.paymentsCollection)
          .doc(paymentId)
          .update({
        'status': 'failed',
        'metadata': {'error': e.toString()},
      });
      return false;
    }
  }

  // Process Razorpay payment
  Future<bool> processRazorpayPayment({
    required String paymentId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      // In production, verify signature with Razorpay
      
      await _firestore
          .collection(AppConfig.paymentsCollection)
          .doc(paymentId)
          .update({
        'status': 'completed',
        'transactionId': razorpayPaymentId,
        'completedAt': FieldValue.serverTimestamp(),
        'metadata': {'signature': razorpaySignature},
      });

      return true;
    } catch (e) {
      await _firestore
          .collection(AppConfig.paymentsCollection)
          .doc(paymentId)
          .update({
        'status': 'failed',
        'metadata': {'error': e.toString()},
      });
      return false;
    }
  }

  // Complete payment and enroll user
  Future<void> completePaymentAndEnroll({
    required String paymentId,
    required String userId,
    required String courseId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update payment status
      final paymentRef = _firestore
          .collection(AppConfig.paymentsCollection)
          .doc(paymentId);
      batch.update(paymentRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Enroll user in course
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'enrolledCourses': FieldValue.arrayUnion([courseId]),
      });

      // Update course student count
      final courseRef = _firestore
          .collection(AppConfig.coursesCollection)
          .doc(courseId);
      batch.update(courseRef, {
        'totalStudents': FieldValue.increment(1),
      });

      // Create enrollment record
      final enrollmentRef = _firestore
          .collection(AppConfig.enrollmentsCollection)
          .doc();
      batch.set(enrollmentRef, {
        'userId': userId,
        'courseId': courseId,
        'enrolledAt': FieldValue.serverTimestamp(),
        'paymentId': paymentId,
        'status': 'active',
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to complete payment: $e');
    }
  }

  // Get user payment history
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConfig.paymentsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }

  // Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore
          .collection(AppConfig.paymentsCollection)
          .doc(paymentId)
          .get();

      if (doc.exists) {
        return PaymentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  // Generate invoice
  Future<Invoice> generateInvoice({
    required String paymentId,
    required String userId,
    required String courseTitle,
    required double amount,
    required Map<String, dynamic> billingDetails,
  }) async {
    try {
      final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      
      final invoice = Invoice(
        id: '',
        paymentId: paymentId,
        userId: userId,
        courseTitle: courseTitle,
        amount: amount,
        currency: PaymentConfig.currency,
        issuedAt: DateTime.now(),
        invoiceNumber: invoiceNumber,
        billingDetails: billingDetails,
      );

      final docRef = await _firestore
          .collection('invoices')
          .add(invoice.toFirestore());

      return Invoice(
        id: docRef.id,
        paymentId: paymentId,
        userId: userId,
        courseTitle: courseTitle,
        amount: amount,
        currency: invoice.currency,
        issuedAt: invoice.issuedAt,
        invoiceNumber: invoiceNumber,
        billingDetails: billingDetails,
      );
    } catch (e) {
      throw Exception('Failed to generate invoice: $e');
    }
  }

  // Request refund
  Future<bool> requestRefund(String paymentId) async {
    try {
      await _firestore
          .collection(AppConfig.paymentsCollection)
          .doc(paymentId)
          .update({
        'status': 'refunded',
        'metadata.refundedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to request refund: $e');
    }
  }
}
