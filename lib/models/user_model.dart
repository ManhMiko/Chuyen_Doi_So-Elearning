import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> enrolledCourses;
  final List<String> completedCourses;
  final int totalPoints;
  final int streak;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    required this.createdAt,
    this.updatedAt,
    this.enrolledCourses = const [],
    this.completedCourses = const [],
    this.totalPoints = 0,
    this.streak = 0,
    this.preferences,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      enrolledCourses: List<String>.from(data['enrolledCourses'] ?? []),
      completedCourses: List<String>.from(data['completedCourses'] ?? []),
      totalPoints: data['totalPoints'] ?? 0,
      streak: data['streak'] ?? 0,
      preferences: data['preferences'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'enrolledCourses': enrolledCourses,
      'completedCourses': completedCourses,
      'totalPoints': totalPoints,
      'streak': streak,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? enrolledCourses,
    List<String>? completedCourses,
    int? totalPoints,
    int? streak,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      completedCourses: completedCourses ?? this.completedCourses,
      totalPoints: totalPoints ?? this.totalPoints,
      streak: streak ?? this.streak,
      preferences: preferences ?? this.preferences,
    );
  }
}
