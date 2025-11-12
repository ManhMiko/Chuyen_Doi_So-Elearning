import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String userId;
  final String courseId;
  final double amount;
  final String currency;
  final String paymentMethod; // stripe, razorpay
  final String status; // pending, completed, failed, refunded
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? 'pending',
      transactionId: data['transactionId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseId': courseId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'metadata': metadata,
    };
  }
}

class Invoice {
  final String id;
  final String paymentId;
  final String userId;
  final String courseTitle;
  final double amount;
  final String currency;
  final DateTime issuedAt;
  final String invoiceNumber;
  final Map<String, dynamic> billingDetails;

  Invoice({
    required this.id,
    required this.paymentId,
    required this.userId,
    required this.courseTitle,
    required this.amount,
    required this.currency,
    required this.issuedAt,
    required this.invoiceNumber,
    required this.billingDetails,
  });

  factory Invoice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      paymentId: data['paymentId'] ?? '',
      userId: data['userId'] ?? '',
      courseTitle: data['courseTitle'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      issuedAt: (data['issuedAt'] as Timestamp).toDate(),
      invoiceNumber: data['invoiceNumber'] ?? '',
      billingDetails: Map<String, dynamic>.from(data['billingDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'courseTitle': courseTitle,
      'amount': amount,
      'currency': currency,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'invoiceNumber': invoiceNumber,
      'billingDetails': billingDetails,
    };
  }
}
