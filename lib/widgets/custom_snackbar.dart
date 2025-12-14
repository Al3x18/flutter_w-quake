import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  static void showCustom(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: duration,
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  static void clear(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

class AnimatedSnackBar extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback? onDismissed;

  const AnimatedSnackBar({
    super.key,
    required this.message,
    this.backgroundColor = Colors.white,
    this.duration = const Duration(seconds: 3),
    this.onDismissed,
  });

  @override
  State<AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _exitAnimation();
      }
    });
  }

  void _exitAnimation() async {
    await _animationController.reverse();
    if (mounted) {
      widget.onDismissed?.call();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _exitAnimation,
                  child: const Icon(
                    Icons.close,
                    color: Colors.black54,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedSnackBarHelper {
  static OverlayEntry? _currentEntry;

  static void showSuccess(BuildContext context, String message) {
    _showAnimatedSnackBar(
      context,
      message,
      Colors.white,
      const Duration(seconds: 3),
    );
  }

  static void showError(BuildContext context, String message) {
    _showAnimatedSnackBar(
      context,
      message,
      Colors.white,
      const Duration(seconds: 4),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showAnimatedSnackBar(
      context,
      message,
      Colors.white,
      const Duration(seconds: 3),
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showAnimatedSnackBar(
      context,
      message,
      Colors.white,
      const Duration(seconds: 4),
    );
  }

  static void showCustom(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showAnimatedSnackBar(
      context,
      message,
      Colors.white,
      duration ?? const Duration(seconds: 3),
    );
  }

  static void _showAnimatedSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    Duration duration,
  ) {
    if (!context.mounted) return;

    hide();

    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSnackBar(
                message: message,
                backgroundColor: backgroundColor,
                duration: duration,
                onDismissed: hide,
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_currentEntry!);
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
