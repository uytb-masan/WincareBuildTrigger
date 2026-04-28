enum BuildPlatform {
  android(
    label: 'Android',
    icon: '🤖',
    repoOwner: 'tcx-wcm',
    repoName: 'Wincare.Android',
  ),
  ios(
    label: 'iOS',
    icon: '🍎',
    repoOwner: 'tcx-wcm',
    repoName: 'Wincare.iOS',
  );

  final String label;
  final String icon;
  final String repoOwner;
  final String repoName;

  const BuildPlatform({
    required this.label,
    required this.icon,
    required this.repoOwner,
    required this.repoName,
  });
}

class AppConfig {
  static const String apiBaseUrl = 'https://api.github.com';

  /// Android flavors — Firebase Distribution
  static const Map<String, FlavorConfig> androidFlavors = {
    'dev': FlavorConfig(
      name: 'DEV',
      workflowFile: 'dev-firebase.yml',
      description: 'Development build → Firebase Distribution',
      colorHex: 0xFF4CAF50,
      icon: '🟢',
      testerGroups: 'tcx-internal',
    ),
    'uat': FlavorConfig(
      name: 'UAT',
      workflowFile: 'uat-firebase.yml',
      description: 'UAT build → Firebase Distribution',
      colorHex: 0xFFFFC107,
      icon: '🟡',
      testerGroups: 'tcx-internal',
    ),
    'production': FlavorConfig(
      name: 'PRODUCTION',
      workflowFile: 'prd-firebase.yml',
      description: 'Production build → Firebase Distribution',
      colorHex: 0xFFF44336,
      icon: '🔴',
      testerGroups: 'tcx-internal',
    ),
  };

  /// iOS flavors — TestFlight Distribution
  static const Map<String, FlavorConfig> iosFlavors = {
    'dev': FlavorConfig(
      name: 'DEV',
      workflowFile: 'ios-dev-testflight.yml',
      description: 'Development build → TestFlight',
      colorHex: 0xFF4CAF50,
      icon: '🟢',
    ),
    'uat': FlavorConfig(
      name: 'UAT',
      workflowFile: 'ios-uat-testflight.yml',
      description: 'UAT build → TestFlight',
      colorHex: 0xFFFFC107,
      icon: '🟡',
    ),
    'production': FlavorConfig(
      name: 'PRODUCTION',
      workflowFile: 'ios-prod-testflight.yml',
      description: 'Production build → TestFlight',
      colorHex: 0xFFF44336,
      icon: '🔴',
      supportsInputs: false,
    ),
  };

  /// Legacy accessor — returns Android flavors for backward compat
  static const Map<String, FlavorConfig> flavors = androidFlavors;

  /// Get flavors for a given platform
  static Map<String, FlavorConfig> flavorsFor(BuildPlatform platform) {
    switch (platform) {
      case BuildPlatform.android:
        return androidFlavors;
      case BuildPlatform.ios:
        return iosFlavors;
    }
  }

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
  final String? testerGroups;

  const FlavorConfig({
    required this.name,
    required this.workflowFile,
    required this.description,
    required this.colorHex,
    required this.icon,
    this.supportsInputs = true,
    this.testerGroups,
  });
}
