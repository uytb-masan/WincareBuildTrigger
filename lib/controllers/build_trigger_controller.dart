import 'package:get/get.dart';
import '../config/app_config.dart';
import '../data/github_api_service.dart';
import '../data/models/branch_model.dart';

class BuildTriggerController extends GetxController {
  final _apiService = GitHubApiService();

  final selectedPlatform = BuildPlatform.android.obs;
  final branches = <BranchModel>[].obs;
  final filteredBranches = <BranchModel>[].obs;
  final selectedBranch = Rxn<String>();
  final selectedFlavor = Rxn<String>();
  final releaseNotes = ''.obs;
  final branchSearchQuery = ''.obs;

  final isLoadingBranches = false.obs;
  final isTriggeringBuild = false.obs;
  final triggerSuccess = false.obs;
  final triggerError = ''.obs;

  /// Returns the flavor configs for the currently selected platform
  Map<String, FlavorConfig> get currentFlavors =>
      AppConfig.flavorsFor(selectedPlatform.value);

  /// Returns the repo owner for the currently selected platform
  String get currentRepoOwner => selectedPlatform.value.repoOwner;

  /// Returns the repo name for the currently selected platform
  String get currentRepoName => selectedPlatform.value.repoName;

  @override
  void onInit() {
    super.onInit();
    fetchBranches();

    // React to search query changes
    ever(branchSearchQuery, (_) => _filterBranches());
  }

  /// Switch platform (Android / iOS) and reload branches + reset selection
  void switchPlatform(BuildPlatform platform) {
    if (selectedPlatform.value == platform) return;

    selectedPlatform.value = platform;
    selectedBranch.value = null;
    selectedFlavor.value = null;
    releaseNotes.value = '';
    branchSearchQuery.value = '';
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    isLoadingBranches.value = true;
    try {
      final result = await _apiService.listBranches(
        repoOwner: currentRepoOwner,
        repoName: currentRepoName,
      );
      branches.value = result;
      _filterBranches();

      // Auto-select 'dev' branch if available
      if (selectedBranch.value == null) {
        final devBranch = result.where((b) => b.name == 'dev');
        if (devBranch.isNotEmpty) {
          selectedBranch.value = devBranch.first.name;
        } else if (result.isNotEmpty) {
          selectedBranch.value = result.first.name;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch branches: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingBranches.value = false;
    }
  }

  void _filterBranches() {
    if (branchSearchQuery.value.isEmpty) {
      filteredBranches.value = branches;
    } else {
      filteredBranches.value = branches
          .where((b) => b.name
              .toLowerCase()
              .contains(branchSearchQuery.value.toLowerCase()))
          .toList();
    }
  }

  void selectBranch(String branch) {
    selectedBranch.value = branch;
  }

  void selectFlavor(String flavor) {
    if (selectedFlavor.value == flavor) {
      selectedFlavor.value = null; // Toggle off
    } else {
      selectedFlavor.value = flavor;
    }
  }

  bool get canTrigger =>
      selectedBranch.value != null &&
      selectedFlavor.value != null &&
      !isTriggeringBuild.value;

  Future<void> triggerBuild() async {
    if (!canTrigger) return;

    final flavor = selectedFlavor.value!;
    final branch = selectedBranch.value!;
    final flavorConfig = currentFlavors[flavor];

    if (flavorConfig == null) {
      triggerError.value = 'Unknown flavor: $flavor';
      return;
    }

    isTriggeringBuild.value = true;
    triggerSuccess.value = false;
    triggerError.value = '';

    try {
      final inputs = <String, String>{};
      if (flavorConfig.supportsInputs) {
        if (releaseNotes.value.isNotEmpty) {
          inputs['release_notes'] = releaseNotes.value;
        }
        if (flavorConfig.testerGroups != null) {
          inputs['tester_groups'] = flavorConfig.testerGroups!;
        }
      }

      await _apiService.triggerWorkflow(
        repoOwner: currentRepoOwner,
        repoName: currentRepoName,
        workflowFile: flavorConfig.workflowFile,
        ref: branch,
        inputs: flavorConfig.supportsInputs ? inputs : const {},
      );

      triggerSuccess.value = true;
      final platformLabel = selectedPlatform.value.label;
      Get.snackbar(
        '🚀 Build Triggered!',
        '$platformLabel ${flavorConfig.name} build on $branch',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      triggerError.value = e.toString();
      Get.snackbar(
        '❌ Trigger Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isTriggeringBuild.value = false;
    }
  }
}
