import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String instructorId;
  final String? thumbnailUrl;
  final double price;
  final String category;
  final List<String> tags;
  final List<Lesson> lessons;
  final double rating;
  final int totalStudents;
  final int totalReviews;
  final String level; // beginner, intermediate, advanced
  final String language;
  final int durationMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublished;
  final List<String> requirements;
  final List<String> whatYouWillLearn;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.instructorId,
    this.thumbnailUrl,
    required this.price,
    required this.category,
    this.tags = const [],
    this.lessons = const [],
    this.rating = 0.0,
    this.totalStudents = 0,
    this.totalReviews = 0,
    required this.level,
    required this.language,
    required this.durationMinutes,
    required this.createdAt,
    this.updatedAt,
    this.isPublished = false,
    this.requirements = const [],
    this.whatYouWillLearn = const [],
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructor: data['instructor'] ?? '',
      instructorId: data['instructorId'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      lessons: (data['lessons'] as List<dynamic>?)
          ?.map((e) => Lesson.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      rating: (data['rating'] ?? 0).toDouble(),
      totalStudents: data['totalStudents'] ?? 0,
      totalReviews: data['totalReviews'] ?? 0,
      level: data['level'] ?? 'beginner',
      language: data['language'] ?? 'en',
      durationMinutes: data['durationMinutes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      isPublished: data['isPublished'] ?? false,
      requirements: List<String>.from(data['requirements'] ?? []),
      whatYouWillLearn: List<String>.from(data['whatYouWillLearn'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'instructor': instructor,
      'instructorId': instructorId,
      'thumbnailUrl': thumbnailUrl,
      'price': price,
      'category': category,
      'tags': tags,
      'lessons': lessons.map((e) => e.toMap()).toList(),
      'rating': rating,
      'totalStudents': totalStudents,
      'totalReviews': totalReviews,
      'level': level,
      'language': language,
      'durationMinutes': durationMinutes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isPublished': isPublished,
      'requirements': requirements,
      'whatYouWillLearn': whatYouWillLearn,
    };
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String type; // video, quiz, reading
  final String? videoUrl;
  final String? content;
  final int durationMinutes;
  final int order;
  final bool isFree;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.videoUrl,
    this.content,
    required this.durationMinutes,
    required this.order,
    this.isFree = false,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'video',
      videoUrl: map['videoUrl'],
      content: map['content'],
      durationMinutes: map['durationMinutes'] ?? 0,
      order: map['order'] ?? 0,
      isFree: map['isFree'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'videoUrl': videoUrl,
      'content': content,
      'durationMinutes': durationMinutes,
      'order': order,
      'isFree': isFree,
    };
  }
}
