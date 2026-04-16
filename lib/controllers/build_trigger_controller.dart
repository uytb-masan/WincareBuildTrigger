import 'package:get/get.dart';
import '../config/app_config.dart';
import '../data/github_api_service.dart';
import '../data/models/branch_model.dart';

class BuildTriggerController extends GetxController {
  final _apiService = GitHubApiService();

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

  @override
  void onInit() {
    super.onInit();
    fetchBranches();

    // React to search query changes
    ever(branchSearchQuery, (_) => _filterBranches());
  }

  Future<void> fetchBranches() async {
    isLoadingBranches.value = true;
    try {
      final result = await _apiService.listBranches();
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
    final flavorConfig = AppConfig.flavors[flavor];

    if (flavorConfig == null) {
      triggerError.value = 'Unknown flavor: $flavor';
      return;
    }

    isTriggeringBuild.value = true;
    triggerSuccess.value = false;
    triggerError.value = '';

    try {
      final inputs = <String, String>{};
      if (flavorConfig.supportsInputs && releaseNotes.value.isNotEmpty) {
        inputs['release_notes'] = releaseNotes.value;
      }

      await _apiService.triggerWorkflow(
        workflowFile: flavorConfig.workflowFile,
        ref: branch,
        inputs: flavorConfig.supportsInputs ? inputs : const {},
      );

      triggerSuccess.value = true;
      Get.snackbar(
        '🚀 Build Triggered!',
        '${flavorConfig.name} build on $branch',
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
