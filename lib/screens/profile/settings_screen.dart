import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _autoPlayVideos = true;
  String _videoQuality = 'auto';
  bool _downloadOverWifiOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader('Thông báo'),
          SwitchListTile(
            title: const Text('Bật thông báo'),
            subtitle: const Text('Nhận thông báo từ ứng dụng'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Email thông báo'),
            subtitle: const Text('Nhận thông báo qua email'),
            value: _emailNotifications,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text('Nhận thông báo đẩy'),
            value: _pushNotifications,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  }
                : null,
          ),

          const Divider(),

          // Video Settings
          _buildSectionHeader('Video'),
          SwitchListTile(
            title: const Text('Tự động phát video'),
            subtitle: const Text('Tự động phát video khi mở bài học'),
            value: _autoPlayVideos,
            onChanged: (value) {
              setState(() {
                _autoPlayVideos = value;
              });
            },
          ),
          ListTile(
            title: const Text('Chất lượng video'),
            subtitle: Text(_getVideoQualityLabel(_videoQuality)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showVideoQualityDialog(),
          ),

          const Divider(),

          // Download Settings
          _buildSectionHeader('Tải xuống'),
          SwitchListTile(
            title: const Text('Chỉ tải qua WiFi'),
            subtitle: const Text('Chỉ tải video khi kết nối WiFi'),
            value: _downloadOverWifiOnly,
            onChanged: (value) {
              setState(() {
                _downloadOverWifiOnly = value;
              });
            },
          ),
          ListTile(
            title: const Text('Quản lý tải xuống'),
            subtitle: const Text('Xem và quản lý các video đã tải'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to downloads
            },
          ),

          const Divider(),

          // Privacy & Security
          _buildSectionHeader('Quyền riêng tư & Bảo mật'),
          ListTile(
            title: const Text('Đổi mật khẩu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to change password
            },
          ),
          ListTile(
            title: const Text('Quyền riêng tư'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy settings
            },
          ),

          const Divider(),

          // About
          _buildSectionHeader('Về ứng dụng'),
          ListTile(
            title: const Text('Điều khoản sử dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show terms
            },
          ),
          ListTile(
            title: const Text('Chính sách bảo mật'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show privacy policy
            },
          ),
          ListTile(
            title: const Text('Phiên bản'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.info_outline),
          ),

          const SizedBox(height: 24),

          // Clear Cache Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                _showClearCacheDialog();
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Xóa bộ nhớ cache'),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: ThemeConfig.bodyLarge.copyWith(
          color: ThemeConfig.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getVideoQualityLabel(String quality) {
    switch (quality) {
      case 'auto':
        return 'Tự động';
      case '720p':
        return '720p (HD)';
      case '480p':
        return '480p';
      case '360p':
        return '360p';
      default:
        return 'Tự động';
    }
  }

  void _showVideoQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chất lượng video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tự động'),
              value: 'auto',
              groupValue: _videoQuality,
              onChanged: (value) {
                setState(() {
                  _videoQuality = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('720p (HD)'),
              value: '720p',
              groupValue: _videoQuality,
              onChanged: (value) {
                setState(() {
                  _videoQuality = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('480p'),
              value: '480p',
              groupValue: _videoQuality,
              onChanged: (value) {
                setState(() {
                  _videoQuality = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('360p'),
              value: '360p',
              groupValue: _videoQuality,
              onChanged: (value) {
                setState(() {
                  _videoQuality = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bộ nhớ cache'),
        content: const Text('Bạn có chắc chắn muốn xóa bộ nhớ cache? Điều này sẽ xóa tất cả dữ liệu tạm thời.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa bộ nhớ cache'),
                  backgroundColor: ThemeConfig.successColor,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
