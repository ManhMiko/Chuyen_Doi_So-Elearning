import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/course_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme_config.dart';
import '../../models/course_model.dart';
import '../payment/payment_screen.dart';
import '../learning/lesson_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await courseProvider.selectCourse(widget.courseId);

    if (authProvider.currentUser != null) {
      _isEnrolled = await courseProvider.isUserEnrolled(
        userId: authProvider.currentUser!.id,
        courseId: widget.courseId,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final course = courseProvider.selectedCourse;

    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: course.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: course.thumbnailUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: ThemeConfig.primaryColor.withOpacity(0.2),
                      child: const Icon(
                        Icons.school,
                        size: 80,
                        color: ThemeConfig.primaryColor,
                      ),
                    ),
            ),
          ),

          // Course Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course.category,
                      style: ThemeConfig.bodyMedium.copyWith(
                        color: ThemeConfig.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    course.title,
                    style: ThemeConfig.headingMedium,
                  ),

                  const SizedBox(height: 8),

                  // Instructor
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.person, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        course.instructor,
                        style: ThemeConfig.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    children: [
                      _buildStat(Icons.star, course.rating.toStringAsFixed(1)),
                      const SizedBox(width: 24),
                      _buildStat(Icons.people, '${course.totalStudents} học viên'),
                      const SizedBox(width: 24),
                      _buildStat(Icons.access_time, '${course.durationMinutes ~/ 60}h'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Mô tả',
                    style: ThemeConfig.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: ThemeConfig.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // What you'll learn
                  if (course.whatYouWillLearn.isNotEmpty) ...[
                    Text(
                      'Bạn sẽ học được gì',
                      style: ThemeConfig.headingSmall,
                    ),
                    const SizedBox(height: 12),
                    ...course.whatYouWillLearn.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: ThemeConfig.successColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: ThemeConfig.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Requirements
                  if (course.requirements.isNotEmpty) ...[
                    Text(
                      'Yêu cầu',
                      style: ThemeConfig.headingSmall,
                    ),
                    const SizedBox(height: 12),
                    ...course.requirements.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.fiber_manual_record,
                                size: 8,
                                color: ThemeConfig.textSecondaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: ThemeConfig.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Curriculum
                  Text(
                    'Nội dung khóa học',
                    style: ThemeConfig.headingSmall,
                  ),
                  const SizedBox(height: 12),
                  ...course.lessons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final lesson = entry.value;
                    return _buildLessonItem(lesson, index + 1);
                  }),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, course, authProvider),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ThemeConfig.textSecondaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: ThemeConfig.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLessonItem(Lesson lesson, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ThemeConfig.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
          child: Text(
            '$index',
            style: ThemeConfig.bodyMedium.copyWith(
              color: ThemeConfig.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          lesson.title,
          style: ThemeConfig.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Icon(
              lesson.type == 'video' ? Icons.play_circle_outline : Icons.quiz_outlined,
              size: 16,
              color: ThemeConfig.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Text('${lesson.durationMinutes} phút'),
            if (lesson.isFree) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeConfig.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Miễn phí',
                  style: ThemeConfig.bodySmall.copyWith(
                    color: ThemeConfig.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: lesson.isFree || _isEnrolled
            ? const Icon(Icons.play_arrow)
            : const Icon(Icons.lock_outline),
        onTap: (lesson.isFree || _isEnrolled)
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonScreen(
                      courseId: widget.courseId,
                      lesson: lesson,
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CourseModel course, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giá',
                style: ThemeConfig.bodySmall,
              ),
              Text(
                course.price > 0 ? '\$${course.price.toStringAsFixed(2)}' : 'Miễn phí',
                style: ThemeConfig.headingMedium.copyWith(
                  color: ThemeConfig.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: _isEnrolled
                  ? () {
                      if (course.lessons.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonScreen(
                              courseId: course.id,
                              lesson: course.lessons.first,
                            ),
                          ),
                        );
                      }
                    }
                  : () {
                      if (course.price > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              course: course,
                            ),
                          ),
                        );
                      } else {
                        // Free course, enroll directly
                        _enrollInCourse(context, authProvider);
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isEnrolled ? 'Tiếp tục học' : 'Đăng ký ngay'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enrollInCourse(BuildContext context, AuthProvider authProvider) async {
    if (authProvider.currentUser == null) return;

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final success = await courseProvider.enrollCourse(
      userId: authProvider.currentUser!.id,
      courseId: widget.courseId,
    );

    if (success) {
      setState(() {
        _isEnrolled = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký khóa học thành công!'),
            backgroundColor: ThemeConfig.successColor,
          ),
        );
      }
    }
  }
}
