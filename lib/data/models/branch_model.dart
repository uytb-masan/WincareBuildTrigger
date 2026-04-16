class BranchModel {
  final String name;
  final String sha;
  final bool isProtected;

  BranchModel({
    required this.name,
    required this.sha,
    this.isProtected = false,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      name: json['name'] as String,
      sha: (json['commit'] as Map<String, dynamic>)['sha'] as String,
      isProtected: json['protected'] as bool? ?? false,
    );
  }
}
