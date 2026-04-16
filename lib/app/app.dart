import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme.dart';
import '../controllers/settings_controller.dart';
import '../controllers/build_trigger_controller.dart';
import '../controllers/run_history_controller.dart';
import '../pages/home_page.dart';
import '../pages/settings_page.dart';

class WincareBuildApp extends StatelessWidget {
  const WincareBuildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wincare Build Trigger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialBinding: AppBindings(),
      home: const AppShell(),
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(SettingsController(), permanent: true);
    Get.lazyPut(() => BuildTriggerController());
    Get.lazyPut(() => RunHistoryController());
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final _pages = const [
    HomePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side navigation rail
          Container(
            width: 72,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                right: BorderSide(
                  color: AppTheme.cardBorder,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // App icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 32),
                // Nav items
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Build',
                  isSelected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                const SizedBox(height: 8),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                const Spacer(),
                // Connection status
                Obx(() {
                  final settings = Get.find<SettingsController>();
                  return Tooltip(
                    message: settings.isValid.value
                        ? 'Connected as ${settings.userName.value}'
                        : 'Not connected',
                    child: Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(bottom: 20),
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
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppTheme.primary.withOpacity(0.15)
                  : _isHovered
                      ? AppTheme.surfaceLighter
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: widget.isSelected
                  ? Border.all(color: AppTheme.primary.withOpacity(0.3))
                  : null,
            ),
            child: Icon(
              widget.icon,
              size: 22,
              color: widget.isSelected
                  ? AppTheme.primary
                  : _isHovered
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
