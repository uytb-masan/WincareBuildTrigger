import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _tokenController = TextEditingController();
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    final settings = Get.find<SettingsController>();
    _tokenController.text = settings.token.value;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

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
                const Icon(Icons.settings_rounded,
                    color: AppTheme.primary, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                // Connection status dot
                Obx(() {
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
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GitHub Connection section
                  _SectionHeader(
                    icon: Icons.link_rounded,
                    title: 'GitHub Connection',
                  ),
                  const SizedBox(height: 16),

                  // Connection status card
                  Obx(() => Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: settings.isValid.value
                                ? AppTheme.success.withOpacity(0.3)
                                : AppTheme.cardBorder,
                          ),
                        ),
                        child: settings.isValid.value
                            ? _ConnectedStatus(settings: settings)
                            : _DisconnectedStatus(),
                      )),

                  const SizedBox(height: 24),

                  // Token input
                  const Text(
                    'Personal Access Token',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Required scope: repo (Full control of private repositories)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _tokenController,
                              obscureText: _obscureToken,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                                fontFamily: 'monospace',
                              ),
                              decoration: InputDecoration(
                                hintText: 'ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureToken
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    size: 20,
                                    color: AppTheme.textMuted,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureToken = !_obscureToken),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Obx(() => ElevatedButton.icon(
                                  onPressed: settings.isValidating.value
                                      ? null
                                      : () => settings.saveToken(
                                          _tokenController.text.trim()),
                                  icon: settings.isValidating.value
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save_rounded,
                                          size: 18),
                                  label: Text(settings.isValidating.value
                                      ? 'Validating...'
                                      : 'Save & Test'),
                                )),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tokenController,
                                obscureText: _obscureToken,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureToken
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      size: 20,
                                      color: AppTheme.textMuted,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscureToken = !_obscureToken),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Obx(() => ElevatedButton.icon(
                                  onPressed: settings.isValidating.value
                                      ? null
                                      : () => settings.saveToken(
                                          _tokenController.text.trim()),
                                  icon: settings.isValidating.value
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save_rounded,
                                          size: 18),
                                  label: Text(settings.isValidating.value
                                      ? 'Validating...'
                                      : 'Save & Test'),
                                )),
                          ],
                        ),

                  // Error message
                  Obx(() {
                    if (settings.errorMessage.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 18, color: AppTheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                settings.errorMessage.value,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 40),

                  // About section
                  _SectionHeader(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WincareBuilder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'A desktop app to trigger GitHub Actions workflows for Wincare Android (Firebase) and iOS (TestFlight) builds, and monitor their status in real-time.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectedStatus extends StatelessWidget {
  final SettingsController settings;

  const _ConnectedStatus({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.success,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connected',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Authenticated as ${settings.userName.value}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () => settings.clearToken(),
          icon: const Icon(Icons.logout_rounded,
              size: 16, color: AppTheme.error),
          label: const Text(
            'Disconnect',
            style: TextStyle(color: AppTheme.error),
          ),
        ),
      ],
    );
  }
}

class _DisconnectedStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.link_off_rounded,
            color: AppTheme.warning,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Not Connected',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warning,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Enter your PAT below to connect',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
