import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../config/app_config.dart';

class PlatformToggle extends StatefulWidget {
  final BuildPlatform selected;
  final ValueChanged<BuildPlatform> onChanged;

  const PlatformToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<PlatformToggle> createState() => _PlatformToggleState();
}

class _PlatformToggleState extends State<PlatformToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    if (widget.selected == BuildPlatform.ios) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PlatformToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected == BuildPlatform.ios) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfWidth = constraints.maxWidth / 2;

          return Stack(
            children: [
              // Animated sliding indicator
              AnimatedBuilder(
                animation: _slideAnim,
                builder: (context, child) {
                  final isIos = _slideAnim.value > 0.5;
                  final indicatorColor = isIos
                      ? const Color(0xFF007AFF) // iOS blue
                      : const Color(0xFF3DDC84); // Android green

                  return Positioned(
                    left: _slideAnim.value * halfWidth + 3,
                    top: 3,
                    bottom: 3,
                    width: halfWidth - 6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            indicatorColor.withOpacity(0.25),
                            indicatorColor.withOpacity(0.12),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: indicatorColor.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: indicatorColor.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Platform buttons
              Row(
                children: [
                  Expanded(
                    child: _PlatformButton(
                      platform: BuildPlatform.android,
                      isSelected: widget.selected == BuildPlatform.android,
                      onTap: () => widget.onChanged(BuildPlatform.android),
                    ),
                  ),
                  Expanded(
                    child: _PlatformButton(
                      platform: BuildPlatform.ios,
                      isSelected: widget.selected == BuildPlatform.ios,
                      onTap: () => widget.onChanged(BuildPlatform.ios),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlatformButton extends StatefulWidget {
  final BuildPlatform platform;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlatformButton({
    required this.platform,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PlatformButton> createState() => _PlatformButtonState();
}

class _PlatformButtonState extends State<_PlatformButton> {
  bool _isHovered = false;

  IconData get _icon => widget.platform == BuildPlatform.android
      ? Icons.android_rounded
      : Icons.apple_rounded;

  Color get _activeColor => widget.platform == BuildPlatform.android
      ? const Color(0xFF3DDC84) // Android green
      : const Color(0xFF007AFF); // iOS blue

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icon,
                size: 20,
                color: widget.isSelected
                    ? _activeColor
                    : _isHovered
                        ? AppTheme.textPrimary
                        : AppTheme.textMuted,
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isSelected
                      ? _activeColor
                      : _isHovered
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                  letterSpacing: widget.isSelected ? 0.3 : 0,
                ),
                child: Text(widget.platform.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
