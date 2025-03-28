class Vote {
  final int pollId;
  final int userId;
  final bool status;
  final DateTime created;

  Vote({
    required this.pollId,
    required this.userId,
    required this.status,
    required this.created,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      pollId: json['pollId'],
      userId: json['userId'],
      status: json['status'],
      created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pollId': pollId,
      'userId': userId,
      'status': status,
      'created': created.toIso8601String(),
    };
  }
}
