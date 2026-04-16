import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme.dart';
import '../../controllers/build_trigger_controller.dart';

class BranchDropdown extends StatelessWidget {
  const BranchDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BuildTriggerController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_tree_rounded,
                size: 18, color: AppTheme.accent),
            const SizedBox(width: 8),
            Text(
              'Branch',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
            const Spacer(),
            Obx(() => controller.isLoadingBranches.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accent,
                    ),
                  )
                : InkWell(
                    onTap: controller.fetchBranches,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.refresh_rounded,
                          size: 18, color: AppTheme.textMuted),
                    ),
                  )),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final branches = controller.filteredBranches;
          final selected = controller.selectedBranch.value;

          return Container(
            decoration: glassDecoration(opacity: 0.05),
            child: Column(
              children: [
                // Search field
                TextField(
                  onChanged: (v) => controller.branchSearchQuery.value = v,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search branches...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
                // Branch list
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: branches.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No branches found',
                              style: TextStyle(color: AppTheme.textMuted)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: branches.length,
                          itemBuilder: (context, index) {
                            final branch = branches[index];
                            final isSelected = branch.name == selected;

                            return _BranchTile(
                              name: branch.name,
                              isProtected: branch.isProtected,
                              isSelected: isSelected,
                              onTap: () =>
                                  controller.selectBranch(branch.name),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _BranchTile extends StatefulWidget {
  final String name;
  final bool isProtected;
  final bool isSelected;
  final VoidCallback onTap;

  const _BranchTile({
    required this.name,
    required this.isProtected,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BranchTile> createState() => _BranchTileState();
}

class _BranchTileState extends State<_BranchTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primary.withOpacity(0.12)
                : _isHovered
                    ? AppTheme.surfaceLighter.withOpacity(0.5)
                    : Colors.transparent,
            border: widget.isSelected
                ? Border(
                    left:
                        BorderSide(color: AppTheme.primary, width: 3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 16,
                color: widget.isSelected
                    ? AppTheme.primary
                    : AppTheme.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: widget.isSelected
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isProtected)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'protected',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
