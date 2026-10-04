import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TripSpeedDialFab extends StatefulWidget {
  final VoidCallback onScanCamera;
  final VoidCallback onAddExpense;

  const TripSpeedDialFab({
    super.key,
    required this.onScanCamera,
    required this.onAddExpense,
  });

  @override
  State<TripSpeedDialFab> createState() => _TripSpeedDialFabState();
}

class _TripSpeedDialFabState extends State<TripSpeedDialFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;
  bool _isOpen = false;

  static const double _fabSize = 56.0;
  static const double _itemSize = 46.0;
  static const double _fabRight = 18.0;
  static const double _fabBottom = 16.0; // Snug right above the bottom nav bar

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _controller.reverse();
      });
    }
  }

  Widget _buildDialItem({
    required IconData icon,
    required String label,
    required Color color,
    required double verticalOffset,
    required double progress,
    required VoidCallback onTap,
  }) {
    const fabCenterRight = _fabRight + (_fabSize / 2);
    final currentBottom = _fabBottom + verticalOffset * progress;
    const currentRight = fabCenterRight - (_itemSize / 2);

    return Positioned(
      right: currentRight,
      bottom: currentBottom,
      child: Opacity(
        opacity: progress.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: progress.clamp(0.0, 1.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pill Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Circular Action Button
              Container(
                width: _itemSize,
                height: _itemSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: color,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    splashColor: Colors.white24,
                    onTap: () {
                      _close();
                      onTap();
                    },
                    child: Center(
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, _) {
        final progress = _expandAnimation.value;
        final isVisible = _isOpen || _controller.isAnimating;

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            // Backdrop dismissal scrim
            if (isVisible && progress > 0.01)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                  child: Container(
                    color: Colors.black.withOpacity(0.35 * progress.clamp(0.0, 1.0)),
                  ),
                ),
              ),

            // Item 1: Manual Expense (Opens 60px upward)
            if (isVisible)
              _buildDialItem(
                icon: Icons.edit_note_rounded,
                label: 'Add manually',
                color: AppColors.coral,
                verticalOffset: 62.0,
                progress: progress,
                onTap: widget.onAddExpense,
              ),

            // Item 2: Scan Camera (Opens 122px upward)
            if (isVisible)
              _buildDialItem(
                icon: Icons.camera_alt_rounded,
                label: 'Scan receipt',
                color: const Color(0xFF00C48C),
                verticalOffset: 122.0,
                progress: progress,
                onTap: widget.onScanCamera,
              ),

            // Main Primary FAB Button
            Positioned(
              right: _fabRight,
              bottom: _fabBottom,
              width: _fabSize,
              height: _fabSize,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isOpen ? AppColors.ink : AppColors.coral).withOpacity(0.42),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: _isOpen ? AppColors.ink : AppColors.coral,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _toggle,
                    child: Center(
                      child: RotationTransition(
                        turns: _rotationAnimation,
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
