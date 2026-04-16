import 'package:flutter/material.dart';
import '../../app/theme.dart';

class TriggerButton extends StatefulWidget {
  final bool canTrigger;
  final bool isLoading;
  final VoidCallback onPressed;

  const TriggerButton({
    super.key,
    required this.canTrigger,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<TriggerButton> createState() => _TriggerButtonState();
}

class _TriggerButtonState extends State<TriggerButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.canTrigger && !widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TriggerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.canTrigger && !widget.isLoading) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.canTrigger && !widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ScaleTransition(
        scale: _pulseAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: _isHovered
                        ? [
                            AppTheme.primary,
                            AppTheme.accent,
                          ]
                        : [
                            AppTheme.primary,
                            AppTheme.primaryDark,
                          ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isEnabled ? null : AppTheme.surfaceLighter,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(_isHovered ? 0.4 : 0.25),
                      blurRadius: _isHovered ? 24 : 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: widget.isLoading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Triggering Build...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.rocket_launch_rounded,
                            size: 22,
                            color: isEnabled
                                ? Colors.white
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Trigger Build',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isEnabled
                                  ? Colors.white
                                  : AppTheme.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
