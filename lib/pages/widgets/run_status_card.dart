import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../data/models/workflow_run_model.dart';

class RunStatusCard extends StatefulWidget {
  final WorkflowRunModel run;

  const RunStatusCard({super.key, required this.run});

  @override
  State<RunStatusCard> createState() => _RunStatusCardState();
}

class _RunStatusCardState extends State<RunStatusCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.run.isRunning) {
      _spinController.repeat();
    }
  }

  @override
  void didUpdateWidget(RunStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.run.isRunning && !_spinController.isAnimating) {
      _spinController.repeat();
    } else if (!widget.run.isRunning && _spinController.isAnimating) {
      _spinController.stop();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (widget.run.isRunning) return AppTheme.info;
    if (widget.run.isSuccess) return AppTheme.success;
    if (widget.run.conclusion == 'cancelled') return AppTheme.textMuted;
    return AppTheme.error;
  }

  IconData get _statusIcon {
    if (widget.run.isRunning) return Icons.sync_rounded;
    if (widget.run.isSuccess) return Icons.check_circle_rounded;
    if (widget.run.conclusion == 'cancelled') return Icons.cancel_rounded;
    return Icons.error_rounded;
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _openInBrowser(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isHovered ? AppTheme.surfaceLighter : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? _statusColor.withOpacity(0.3)
                  : AppTheme.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Status icon
              widget.run.isRunning
                  ? RotationTransition(
                      turns: _spinController,
                      child: Icon(
                        _statusIcon,
                        color: _statusColor,
                        size: 22,
                      ),
                    )
                  : Icon(
                      _statusIcon,
                      color: _statusColor,
                      size: 22,
                    ),
              const SizedBox(width: 12),
              // Run info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.run.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '#${widget.run.runNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.account_tree_rounded,
                            size: 12, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.run.headBranch,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (widget.run.isCompleted) ...[
                          const Icon(Icons.timer_outlined,
                              size: 12, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            widget.run.durationFormatted,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Status badge + time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.run.displayStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(widget.run.createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              // Open in browser icon
              if (_isHovered) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.run.htmlUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
