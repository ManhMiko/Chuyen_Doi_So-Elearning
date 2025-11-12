import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../../models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../config/theme_config.dart';
import '../quiz/quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;
  final Lesson lesson;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.lesson,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.type == 'video' && widget.lesson.videoUrl != null) {
      _initializeVideoPlayer();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(
        widget.lesson.videoUrl!,
      );

      await _videoPlayerController!.initialize();

      // Get saved position
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      final savedPosition = progressProvider.getVideoPosition(widget.lesson.id);

      if (savedPosition > 0) {
        await _videoPlayerController!.seekTo(Duration(seconds: savedPosition));
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: ThemeConfig.primaryColor,
          handleColor: ThemeConfig.primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey[300]!,
        ),
      );

      // Listen to video progress
      _videoPlayerController!.addListener(_onVideoProgress);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải video: $e'),
            backgroundColor: ThemeConfig.errorColor,
          ),
        );
      }
    }
  }

  void _onVideoProgress() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
      return;
    }

    final position = _videoPlayerController!.value.position.inSeconds;
    final duration = _videoPlayerController!.value.duration.inSeconds;

    if (duration > 0) {
      final progress = (position / duration * 100).clamp(0.0, 100.0);
      
      // Save progress every 5 seconds
      if (position % 5 == 0) {
        _saveProgress(progress, position);
      }

      // Mark as completed if watched 90%
      if (progress >= 90 && !_isCompleted) {
        _markAsCompleted();
      }
    }
  }

  bool _isCompleted = false;

  Future<void> _saveProgress(double progress, int videoPosition) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await progressProvider.updateLessonProgress(
        userId: authProvider.currentUser!.id,
        courseId: widget.courseId,
        lessonId: widget.lesson.id,
        progress: progress,
        videoPosition: videoPosition,
      );
    }
  }

  Future<void> _markAsCompleted() async {
    _isCompleted = true;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await progressProvider.updateLessonProgress(
        userId: authProvider.currentUser!.id,
        courseId: widget.courseId,
        lessonId: widget.lesson.id,
        progress: 100,
        isCompleted: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bài học đã hoàn thành! 🎉'),
            backgroundColor: ThemeConfig.successColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_onVideoProgress);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Player or Content
                  if (widget.lesson.type == 'video' && _chewieController != null)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Chewie(controller: _chewieController!),
                    )
                  else if (widget.lesson.type == 'reading')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      color: ThemeConfig.backgroundColor,
                      child: const Icon(
                        Icons.article,
                        size: 80,
                        color: ThemeConfig.primaryColor,
                      ),
                    ),

                  // Lesson Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lesson.title,
                          style: ThemeConfig.headingMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              widget.lesson.type == 'video'
                                  ? Icons.play_circle_outline
                                  : Icons.article_outlined,
                              size: 20,
                              color: ThemeConfig.textSecondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.lesson.durationMinutes} phút',
                              style: ThemeConfig.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Mô tả',
                          style: ThemeConfig.headingSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.lesson.description,
                          style: ThemeConfig.bodyMedium,
                        ),
                        const SizedBox(height: 24),

                        // Content for reading type
                        if (widget.lesson.type == 'reading' && widget.lesson.content != null) ...[
                          Text(
                            'Nội dung',
                            style: ThemeConfig.headingSmall,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ThemeConfig.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.lesson.content!,
                              style: ThemeConfig.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Quiz button if lesson type is quiz
                        if (widget.lesson.type == 'quiz')
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    lessonId: widget.lesson.id,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.quiz),
                            label: const Text('Bắt đầu làm bài'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),

                        // Mark as complete button
                        if (widget.lesson.type != 'quiz' && !_isCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _markAsCompleted,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Đánh dấu hoàn thành'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
