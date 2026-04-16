class AppConfig {
  static const String repoOwner = 'tcx-wcm';
  static const String repoName = 'Wincare.Android';
  static const String apiBaseUrl = 'https://api.github.com';

  static const Map<String, FlavorConfig> flavors = {
    'dev': FlavorConfig(
      name: 'DEV',
      workflowFile: 'dev-firebase.yml',
      description: 'Development build → Firebase Distribution',
      colorHex: 0xFF4CAF50,
      icon: '🟢',
    ),
    'uat': FlavorConfig(
      name: 'UAT',
      workflowFile: 'uat-firebase.yml',
      description: 'UAT build → Firebase Distribution',
      colorHex: 0xFFFFC107,
      icon: '🟡',
    ),
    'production': FlavorConfig(
      name: 'PRODUCTION',
      workflowFile: 'dev-build.yml',
      description: 'Production build → Confluence',
      colorHex: 0xFFF44336,
      icon: '🔴',
      supportsInputs: false,
    ),
  };

  static const int pollingIntervalSeconds = 10;
  static const int maxRecentRuns = 15;
}

class FlavorConfig {
  final String name;
  final String workflowFile;
  final String description;
  final int colorHex;
  final String icon;
  final bool supportsInputs;

  const FlavorConfig({
    required this.name,
    required this.workflowFile,
    required this.description,
    required this.colorHex,
    required this.icon,
    this.supportsInputs = true,
  });
}
