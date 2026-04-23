import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'models/branch_model.dart';
import 'models/workflow_model.dart';
import 'models/workflow_run_model.dart';

class GitHubApiService {
  late Dio _dio;
  String? _token;

  static final GitHubApiService _instance = GitHubApiService._internal();
  factory GitHubApiService() => _instance;
  GitHubApiService._internal();

  void configure(String token) {
    _token = token;
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'Authorization': 'Bearer $token',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  bool get isConfigured => _token != null && _token!.isNotEmpty;

  /// Validate the PAT by fetching the authenticated user
  Future<Map<String, dynamic>> validateToken() async {
    final response = await _dio.get('/user');
    return response.data as Map<String, dynamic>;
  }

  /// List all branches for the repository
  Future<List<BranchModel>> listBranches({
    required String repoOwner,
    required String repoName,
    int perPage = 100,
  }) async {
    final List<BranchModel> allBranches = [];
    int page = 1;

    while (true) {
      final response = await _dio.get(
        '/repos/$repoOwner/$repoName/branches',
        queryParameters: {'per_page': perPage, 'page': page},
      );

      final List<dynamic> data = response.data as List<dynamic>;
      if (data.isEmpty) break;

      allBranches.addAll(
        data.map((json) => BranchModel.fromJson(json as Map<String, dynamic>)),
      );

      if (data.length < perPage) break;
      page++;
    }

    return allBranches;
  }

  /// List all workflows for the repository
  Future<List<WorkflowModel>> listWorkflows({
    required String repoOwner,
    required String repoName,
  }) async {
    final response = await _dio.get(
      '/repos/$repoOwner/$repoName/actions/workflows',
    );

    final List<dynamic> workflows =
        (response.data as Map<String, dynamic>)['workflows'] as List<dynamic>;

    return workflows
        .map((json) => WorkflowModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Trigger a workflow dispatch event
  Future<bool> triggerWorkflow({
    required String repoOwner,
    required String repoName,
    required String workflowFile,
    required String ref,
    Map<String, String> inputs = const {},
  }) async {
    try {
      await _dio.post(
        '/repos/$repoOwner/$repoName/actions/workflows/$workflowFile/dispatches',
        data: {
          'ref': ref,
          'inputs': inputs,
        },
      );
      return true; // 204 No Content = success
    } on DioException catch (e) {
      if (e.response?.statusCode == 204) return true;
      rethrow;
    }
  }

  /// List recent workflow runs, optionally filtered by workflow ID
  Future<List<WorkflowRunModel>> listWorkflowRuns({
    required String repoOwner,
    required String repoName,
    int? workflowId,
    String? branch,
    String? status,
    int perPage = 15,
  }) async {
    final String path;
    if (workflowId != null) {
      path =
          '/repos/$repoOwner/$repoName/actions/workflows/$workflowId/runs';
    } else {
      path =
          '/repos/$repoOwner/$repoName/actions/runs';
    }

    final queryParams = <String, dynamic>{'per_page': perPage};
    if (branch != null) queryParams['branch'] = branch;
    if (status != null) queryParams['status'] = status;

    final response = await _dio.get(path, queryParameters: queryParams);

    final List<dynamic> runs =
        (response.data as Map<String, dynamic>)['workflow_runs']
            as List<dynamic>;

    return runs
        .map(
            (json) => WorkflowRunModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific workflow run
  Future<WorkflowRunModel> getWorkflowRun({
    required String repoOwner,
    required String repoName,
    required int runId,
  }) async {
    final response = await _dio.get(
      '/repos/$repoOwner/$repoName/actions/runs/$runId',
    );

    return WorkflowRunModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// List artifacts for a workflow run
  Future<List<Map<String, dynamic>>> listRunArtifacts({
    required String repoOwner,
    required String repoName,
    required int runId,
  }) async {
    final response = await _dio.get(
      '/repos/$repoOwner/$repoName/actions/runs/$runId/artifacts',
    );

    return ((response.data as Map<String, dynamic>)['artifacts'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Get download URL for an artifact
  Future<String> getArtifactDownloadUrl({
    required String repoOwner,
    required String repoName,
    required int artifactId,
  }) async {
    final response = await _dio.get(
      '/repos/$repoOwner/$repoName/actions/artifacts/$artifactId/zip',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status == 302,
      ),
    );

    return response.headers.value('location') ?? '';
  }

  /// Get workflow run logs URL
  Future<String> getRunLogsUrl({
    required String repoOwner,
    required String repoName,
    required int runId,
  }) async {
    final response = await _dio.get(
      '/repos/$repoOwner/$repoName/actions/runs/$runId/logs',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status == 302,
      ),
    );

    return response.headers.value('location') ?? '';
  }
}
