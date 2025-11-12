import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../config/theme_config.dart';
import '../../courses/course_detail_screen.dart';
import 'course_card.dart';
import 'category_chip.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (authProvider.currentUser != null) {
              await Future.wait([
                courseProvider.loadPopularCourses(),
                courseProvider.loadRecommendedCourses(authProvider.currentUser!.id),
              ]);
            }
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: ThemeConfig.surfaceColor,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào,',
                      style: ThemeConfig.bodySmall,
                    ),
                    Text(
                      authProvider.currentUser?.name ?? 'Học viên',
                      style: ThemeConfig.headingSmall,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                ],
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm khóa học...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: ThemeConfig.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (query) {
                      // TODO: Navigate to search results
                    },
                  ),
                ),
              ),

              // Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danh mục',
                        style: ThemeConfig.headingSmall,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: const [
                            CategoryChip(label: 'Tất cả', isSelected: true),
                            CategoryChip(label: 'Lập trình'),
                            CategoryChip(label: 'Thiết kế'),
                            CategoryChip(label: 'Marketing'),
                            CategoryChip(label: 'Kinh doanh'),
                            CategoryChip(label: 'Ngoại ngữ'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Popular Courses
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Khóa học phổ biến',
                        style: ThemeConfig.headingSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all popular courses
                        },
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: courseProvider.popularCourses.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: courseProvider.popularCourses.length,
                          itemBuilder: (context, index) {
                            final course = courseProvider.popularCourses[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: CourseCard(
                                course: course,
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
                        ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Recommended Courses
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đề xuất cho bạn',
                        style: ThemeConfig.headingSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all recommended courses
                        },
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: courseProvider.recommendedCourses.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Text('Chưa có khóa học đề xuất'),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final course = courseProvider.recommendedCourses[index];
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
                          childCount: courseProvider.recommendedCourses.length,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
