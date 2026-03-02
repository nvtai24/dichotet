import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget dùng chung cho Image.network với loading + error state.
/// Truyền [url] vào, để trống hoặc null để hiển thị placeholder.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = (url == null || url!.isEmpty)
        ? _Placeholder(width: width, height: height)
        : Image.network(
            url!,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _LoadingShimmer(width: width, height: height);
            },
            errorBuilder: (context, error, stackTrace) {
              return _Placeholder(width: width, height: height);
            },
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

class _LoadingShimmer extends StatefulWidget {
  final double? width;
  final double? height;

  const _LoadingShimmer({this.width, this.height});

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.divider.withValues(alpha: _animation.value),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double? width;
  final double? height;

  const _Placeholder({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFFCE4EC),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 32, color: AppColors.textHint),
          SizedBox(height: 6),
          Text(
            'Chưa có ảnh',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
