class WorkflowModel {
  final int id;
  final String name;
  final String path;
  final String state;
  final String htmlUrl;

  WorkflowModel({
    required this.id,
    required this.name,
    required this.path,
    required this.state,
    required this.htmlUrl,
  });

  factory WorkflowModel.fromJson(Map<String, dynamic> json) {
    return WorkflowModel(
      id: json['id'] as int,
      name: json['name'] as String,
      path: json['path'] as String,
      state: json['state'] as String,
      htmlUrl: json['html_url'] as String,
    );
  }

  /// Extract filename from path (e.g., ".github/workflows/dev-firebase.yml" -> "dev-firebase.yml")
  String get fileName => path.split('/').last;
}
