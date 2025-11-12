import 'package:intl/intl.dart';

class Helpers {
  // Format date
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }
  
  // Format time
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  // Format date time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  // Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
  
  // Format duration (e.g., "1h 30m")
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (mins == 0) {
      return '${hours}h';
    }
    
    return '${hours}h ${mins}m';
  }
  
  // Format price
  static String formatPrice(double price, {String currency = '\$'}) {
    if (price == 0) {
      return 'Miễn phí';
    }
    
    return '$currency${price.toStringAsFixed(2)}';
  }
  
  // Format number with separator
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    
    return '${text.substring(0, maxLength)}...';
  }
  
  // Get initials from name
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    
    if (parts.isEmpty) {
      return '';
    }
    
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
  
  // Calculate percentage
  static double calculatePercentage(int value, int total) {
    if (total == 0) {
      return 0;
    }
    
    return (value / total * 100).clamp(0, 100);
  }
  
  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour < 18) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
  
  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }
  
  // Validate video URL
  static bool isValidVideoUrl(String url) {
    return url.contains('youtube.com') ||
           url.contains('youtu.be') ||
           url.contains('vimeo.com') ||
           url.endsWith('.mp4') ||
           url.endsWith('.m3u8');
  }
  
  // Extract YouTube video ID
  static String? extractYouTubeId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
  
  // Generate random color
  static int generateColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = hash & 0x0000FF;
    
    return 0xFF000000 | (r << 16) | (g << 8) | b;
  }
}
