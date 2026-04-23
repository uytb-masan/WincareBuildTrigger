import 'dart:async';
import 'package:get/get.dart';
import '../config/app_config.dart';
import '../data/github_api_service.dart';
import '../data/models/workflow_run_model.dart';
import 'build_trigger_controller.dart';

class RunHistoryController extends GetxController {
  final _apiService = GitHubApiService();

  final runs = <WorkflowRunModel>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs; // 'all', 'dev', 'uat', 'production'

  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchRuns();
    _startPolling();

    // Listen for platform changes from BuildTriggerController
    if (Get.isRegistered<BuildTriggerController>()) {
      final buildController = Get.find<BuildTriggerController>();
      ever(buildController.selectedPlatform, (_) {
        selectedFilter.value = 'all';
        fetchRuns();
      });
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(
      Duration(seconds: AppConfig.pollingIntervalSeconds),
      (_) => fetchRuns(),
    );
  }

  /// Get the current platform from BuildTriggerController
  BuildPlatform get _currentPlatform {
    if (Get.isRegistered<BuildTriggerController>()) {
      return Get.find<BuildTriggerController>().selectedPlatform.value;
    }
    return BuildPlatform.android;
  }

  Future<void> fetchRuns() async {
    if (!_apiService.isConfigured) return;

    final platform = _currentPlatform;

    try {
      final result = await _apiService.listWorkflowRuns(
        repoOwner: platform.repoOwner,
        repoName: platform.repoName,
        perPage: AppConfig.maxRecentRuns,
      );
      runs.value = result;
    } catch (e) {
      // Silently fail on polling errors
    }
  }

  /// Returns the flavor configs for the current platform
  Map<String, FlavorConfig> get _currentFlavors =>
      AppConfig.flavorsFor(_currentPlatform);

  List<WorkflowRunModel> get filteredRuns {
    if (selectedFilter.value == 'all') return runs;

    final flavorConfig = _currentFlavors[selectedFilter.value];
    if (flavorConfig == null) return runs;

    // Match by workflow name
    return runs
        .where((r) =>
            r.name.toLowerCase().contains(selectedFilter.value.toLowerCase()))
        .toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  bool get hasRunningBuilds => runs.any((r) => r.isRunning);

  int get runningCount => runs.where((r) => r.isRunning).length;
}
