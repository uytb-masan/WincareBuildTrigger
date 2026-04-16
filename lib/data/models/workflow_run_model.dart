class WorkflowRunModel {
  final int id;
  final String name;
  final String status;
  final String? conclusion;
  final String headBranch;
  final String htmlUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int runNumber;
  final String event;
  final String? actorLogin;
  final String? actorAvatarUrl;

  WorkflowRunModel({
    required this.id,
    required this.name,
    required this.status,
    this.conclusion,
    required this.headBranch,
    required this.htmlUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.runNumber,
    required this.event,
    this.actorLogin,
    this.actorAvatarUrl,
  });

  factory WorkflowRunModel.fromJson(Map<String, dynamic> json) {
    return WorkflowRunModel(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      conclusion: json['conclusion'] as String?,
      headBranch: json['head_branch'] as String,
      htmlUrl: json['html_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      runNumber: json['run_number'] as int,
      event: json['event'] as String,
      actorLogin: (json['actor'] as Map<String, dynamic>?)?['login'] as String?,
      actorAvatarUrl:
          (json['actor'] as Map<String, dynamic>?)?['avatar_url'] as String?,
    );
  }

  bool get isRunning =>
      status == 'queued' || status == 'in_progress' || status == 'waiting';

  bool get isCompleted => status == 'completed';

  bool get isSuccess => conclusion == 'success';

  bool get isFailed =>
      conclusion == 'failure' || conclusion == 'cancelled' || conclusion == 'timed_out';

  String get displayStatus {
    if (isRunning) {
      if (status == 'queued') return 'Queued';
      if (status == 'waiting') return 'Waiting';
      return 'In Progress';
    }
    if (isCompleted) {
      if (isSuccess) return 'Success';
      if (conclusion == 'cancelled') return 'Cancelled';
      if (conclusion == 'timed_out') return 'Timed Out';
      return 'Failed';
    }
    return status;
  }

  Duration get duration => updatedAt.difference(createdAt);

  String get durationFormatted {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    }
    return '${d.inSeconds}s';
  }
}
