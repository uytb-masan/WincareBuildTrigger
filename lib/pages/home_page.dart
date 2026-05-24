import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme.dart';
import '../controllers/build_trigger_controller.dart';
import '../controllers/run_history_controller.dart';
import '../controllers/settings_controller.dart';
import 'widgets/branch_dropdown.dart';
import 'widgets/flavor_card.dart';
import 'widgets/platform_toggle.dart';
import 'widgets/trigger_button.dart';
import 'widgets/run_status_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized
    if (!Get.isRegistered<BuildTriggerController>()) {
      Get.put(BuildTriggerController());
    }
    if (!Get.isRegistered<RunHistoryController>()) {
      Get.put(RunHistoryController());
    }

    final settings = Get.find<SettingsController>();

    return Obx(() {
      if (!settings.isValid.value) {
        return _NotConnectedView();
      }
      return const _DashboardView();
    });
  }
}

class _NotConnectedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.vpn_key_rounded,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connect to GitHub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your GitHub Personal Access Token\nin Settings to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Settings',
                  'Click the ⚙️ icon in the left sidebar to configure your PAT.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    if (isMobile) {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: AppTheme.surface,
              child: const TabBar(
                indicatorColor: AppTheme.primary,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(
                    icon: Icon(Icons.build_circle_rounded, size: 20),
                    text: 'Build Trigger',
                  ),
                  Tab(
                    icon: Icon(Icons.history_rounded, size: 20),
                    text: 'Recent Runs',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BuildTriggerPanel(),
                  _RunHistoryPanel(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Left panel - Build Trigger
        Expanded(
          flex: 5,
          child: _BuildTriggerPanel(),
        ),
        // Divider
        Container(
          width: 1,
          color: AppTheme.cardBorder,
        ),
        // Right panel - Run History
        Expanded(
          flex: 4,
          child: _RunHistoryPanel(),
        ),
      ],
    );
  }
}

class _BuildTriggerPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BuildTriggerController>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      color: AppTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                bottom: BorderSide(color: AppTheme.cardBorder),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.build_circle_rounded,
                    color: AppTheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trigger Build',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Obx(() => Text(
                            '${controller.currentRepoOwner}/${controller.currentRepoName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Connection status dot
                Obx(() {
                  final settings = Get.find<SettingsController>();
                  return Tooltip(
                    message: settings.isValid.value
                        ? 'Connected as ${settings.userName.value}'
                        : 'Not connected',
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: settings.isValid.value
                            ? AppTheme.success
                            : AppTheme.error,
                        boxShadow: [
                          BoxShadow(
                            color: (settings.isValid.value
                                    ? AppTheme.success
                                    : AppTheme.error)
                                .withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform toggle
                  Row(
                    children: [
                      const Icon(Icons.devices_rounded,
                          size: 18, color: AppTheme.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Platform',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() => PlatformToggle(
                        selected: controller.selectedPlatform.value,
                        onChanged: controller.switchPlatform,
                      )),

                  SizedBox(height: isMobile ? 18 : 28),

                  // Branch selector
                  const BranchDropdown(),

                  SizedBox(height: isMobile ? 18 : 28),

                  // Flavor selector
                  Row(
                    children: [
                      const Icon(Icons.layers_rounded,
                          size: 18, color: AppTheme.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Flavor',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            controller.currentFlavors.entries.map((entry) {
                          return SizedBox(
                            width: isMobile ? double.infinity : 225,
                            child: FlavorCard(
                              flavorKey: entry.key,
                              config: entry.value,
                              isSelected:
                                  controller.selectedFlavor.value == entry.key,
                              onTap: () =>
                                  controller.selectFlavor(entry.key),
                            ),
                          );
                        }).toList(),
                      )),

                  SizedBox(height: isMobile ? 18 : 28),

                  // Release notes
                  Row(
                    children: [
                      const Icon(Icons.notes_rounded,
                          size: 18, color: AppTheme.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Release Notes (optional)',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (v) => controller.releaseNotes.value = v,
                    maxLines: 3,
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Enter release notes for testers...',
                    ),
                  ),

                  SizedBox(height: isMobile ? 22 : 32),

                  // Trigger button
                  Obx(() => TriggerButton(
                        canTrigger: controller.canTrigger,
                        isLoading: controller.isTriggeringBuild.value,
                        onPressed: controller.triggerBuild,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunHistoryPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RunHistoryController>();
    final buildController = Get.find<BuildTriggerController>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      color: AppTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                bottom: BorderSide(color: AppTheme.cardBorder),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.history_rounded,
                    color: AppTheme.accent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Runs',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Obx(() => Text(
                            '${buildController.selectedPlatform.value.icon} ${buildController.selectedPlatform.value.label}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          )),
                    ],
                  ),
                ),
                // Running builds indicator
                Obx(() {
                  final running = controller.runningCount;
                  if (running == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.info.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.info,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$running running',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(width: 8),
                // Connection status dot
                Obx(() {
                  final settings = Get.find<SettingsController>();
                  return Tooltip(
                    message: settings.isValid.value
                        ? 'Connected as ${settings.userName.value}'
                        : 'Not connected',
                    child: Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: settings.isValid.value
                            ? AppTheme.success
                            : AppTheme.error,
                        boxShadow: [
                          BoxShadow(
                            color: (settings.isValid.value
                                    ? AppTheme.success
                                    : AppTheme.error)
                                .withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                // Refresh button
                IconButton(
                  onPressed: controller.fetchRuns,
                  icon: const Icon(Icons.refresh_rounded,
                      size: 20, color: AppTheme.textMuted),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // Filter chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
            child: Obx(() {
              final currentFlavors = buildController.currentFlavors;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: controller.selectedFilter.value == 'all',
                    onTap: () => controller.setFilter('all'),
                  ),
                  ...currentFlavors.entries.map((entry) => _FilterChip(
                        label: entry.value.name,
                        color: Color(entry.value.colorHex),
                        isSelected:
                            controller.selectedFilter.value == entry.key,
                        onTap: () => controller.setFilter(entry.key),
                      )),
                ],
              );
            }),
          ),

          // Runs list
          Expanded(
            child: Obx(() {
              final runs = controller.filteredRuns;

              if (runs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 48, color: AppTheme.textMuted.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'No workflow runs yet',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                itemCount: runs.length,
                itemBuilder: (context, index) {
                  return RunStatusCard(run: runs[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final chipColor = widget.color ?? AppTheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? chipColor.withOpacity(0.15)
                : _isHovered
                    ? AppTheme.surfaceLighter
                    : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? chipColor.withOpacity(0.5)
                  : AppTheme.cardBorder,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.isSelected ? chipColor : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
