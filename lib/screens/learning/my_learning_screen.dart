import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/progress_provider.dart';
import '../../config/theme_config.dart';
import '../home/widgets/course_card.dart';
import '../courses/course_detail_screen.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      
      await Future.wait([
        courseProvider.loadEnrolledCourses(authProvider.currentUser!.id),
        progressProvider.loadAllProgress(authProvider.currentUser!.id),
        progressProvider.loadStatistics(authProvider.currentUser!.id),
      ]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final progressProvider = Provider.of<ProgressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Học tập của tôi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Đang học'),
            Tab(text: 'Hoàn thành'),
            Tab(text: 'Thống kê'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // In Progress Tab
          _buildInProgressTab(courseProvider, progressProvider),
          
          // Completed Tab
          _buildCompletedTab(authProvider, courseProvider),
          
          // Statistics Tab
          _buildStatisticsTab(progressProvider),
        ],
      ),
    );
  }

  Widget _buildInProgressTab(CourseProvider courseProvider, ProgressProvider progressProvider) {
    final inProgressCourses = courseProvider.enrolledCourses.where((course) {
      final progress = progressProvider.allProgress.firstWhere(
        (p) => p.courseId == course.id,
        orElse: () => progressProvider.allProgress.first,
      );
      return progress.completedAt == null;
    }).toList();

    if (inProgressCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có khóa học nào',
              style: ThemeConfig.bodyLarge.copyWith(
                color: ThemeConfig.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: inProgressCourses.length,
        itemBuilder: (context, index) {
          final course = inProgressCourses[index];
          final progress = progressProvider.allProgress.firstWhere(
            (p) => p.courseId == course.id,
            orElse: () => progressProvider.allProgress.first,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                CourseCard(
                  course: course,
                  isHorizontal: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailScreen(
                          courseId: course.id,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.overallProgress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    ThemeConfig.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${progress.overallProgress.toStringAsFixed(0)}% hoàn thành',
                    style: ThemeConfig.bodySmall,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletedTab(AuthProvider authProvider, CourseProvider courseProvider) {
    final completedCourses = authProvider.currentUser?.completedCourses ?? [];
    final courses = courseProvider.enrolledCourses
        .where((course) => completedCourses.contains(course.id))
        .toList();

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa hoàn thành khóa học nào',
              style: ThemeConfig.bodyLarge.copyWith(
                color: ThemeConfig.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CourseCard(
            course: course,
            isHorizontal: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(
                    courseId: course.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab(ProgressProvider progressProvider) {
    final stats = progressProvider.statistics;

    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng khóa học',
                  '${stats['totalCourses']}',
                  Icons.school,
                  ThemeConfig.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Hoàn thành',
                  '${stats['completedCourses']}',
                  Icons.check_circle,
                  ThemeConfig.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Điểm tích lũy',
                  '${stats['totalPoints']}',
                  Icons.stars,
                  ThemeConfig.accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Chuỗi ngày học',
                  '${stats['streak']} ngày',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Time Spent
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: ThemeConfig.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng thời gian học',
                      style: ThemeConfig.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${(stats['totalTimeSpent'] / 60).toStringAsFixed(1)} giờ',
                      style: ThemeConfig.headingMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress Overview
          Text(
            'Tiến độ trung bình',
            style: ThemeConfig.headingSmall,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                CircularProgressIndicator(
                  value: stats['averageProgress'] / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    ThemeConfig.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${stats['averageProgress']}%',
                  style: ThemeConfig.headingLarge.copyWith(
                    color: ThemeConfig.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: ThemeConfig.headingMedium.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: ThemeConfig.bodySmall,
          ),
        ],
      ),
    );
  }
}
