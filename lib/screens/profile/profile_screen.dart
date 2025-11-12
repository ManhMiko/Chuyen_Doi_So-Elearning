import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../config/theme_config.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await progressProvider.loadStatistics(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final progressProvider = Provider.of<ProgressProvider>(context);
    final user = authProvider.currentUser;
    final stats = progressProvider.statistics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: ThemeConfig.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.white,
                                  backgroundImage: user.photoUrl != null
                                      ? NetworkImage(user.photoUrl!)
                                      : null,
                                  child: user.photoUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: ThemeConfig.primaryColor,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: ThemeConfig.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Name
                          Text(
                            user.name,
                            style: ThemeConfig.headingMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Email
                          Text(
                            user.email,
                            style: ThemeConfig.bodyMedium.copyWith(
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Edit Profile Button
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              'Chỉnh sửa hồ sơ',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats Cards
                    if (stats != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Khóa học',
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
                              'Điểm',
                              '${stats['totalPoints']}',
                              Icons.stars,
                              ThemeConfig.accentColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Streak',
                              '${stats['streak']} ngày',
                              Icons.local_fire_department,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Menu Items
                    _buildMenuItem(
                      'Khóa học của tôi',
                      Icons.school_outlined,
                      () {
                        // Navigate to my courses
                      },
                    ),
                    _buildMenuItem(
                      'Lịch sử thanh toán',
                      Icons.payment,
                      () {
                        // Navigate to payment history
                      },
                    ),
                    _buildMenuItem(
                      'Chứng chỉ',
                      Icons.workspace_premium,
                      () {
                        // Navigate to certificates
                      },
                    ),
                    _buildMenuItem(
                      'Thông báo',
                      Icons.notifications_outlined,
                      () {
                        // Navigate to notifications
                      },
                    ),
                    _buildMenuItem(
                      'Trợ giúp & Hỗ trợ',
                      Icons.help_outline,
                      () {
                        // Navigate to help
                      },
                    ),
                    _buildMenuItem(
                      'Giới thiệu',
                      Icons.info_outline,
                      () {
                        // Navigate to about
                      },
                    ),

                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout, color: ThemeConfig.errorColor),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(color: ThemeConfig.errorColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: ThemeConfig.errorColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: ThemeConfig.headingSmall.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: ThemeConfig.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: ThemeConfig.primaryColor),
        title: Text(
          title,
          style: ThemeConfig.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: ThemeConfig.errorColor),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
