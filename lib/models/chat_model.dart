import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String userId;
  final String message;
  final String sender; // user or bot
  final DateTime timestamp;
  final String? courseContext; // optional course context
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.sender,
    required this.timestamp,
    this.courseContext,
    this.metadata,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      sender: data['sender'] ?? 'user',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      courseContext: data['courseContext'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'message': message,
      'sender': sender,
      'timestamp': Timestamp.fromDate(timestamp),
      'courseContext': courseContext,
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? userId,
    String? message,
    String? sender,
    DateTime? timestamp,
    String? courseContext,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      courseContext: courseContext ?? this.courseContext,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ChatSession {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final List<ChatMessage> messages;
  final String? courseContext;

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    this.lastMessageAt,
    this.messages = const [],
    this.courseContext,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessageAt: data['lastMessageAt'] != null 
          ? (data['lastMessageAt'] as Timestamp).toDate() 
          : null,
      messages: (data['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessage.fromFirestore(
              FirebaseFirestore.instance.doc('temp').snapshots() as DocumentSnapshot))
          .toList() ?? [],
      courseContext: data['courseContext'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'courseContext': courseContext,
    };
  }
}
