import 'user.dart';

class Poll {
  final int id;
  final String name;
  final String description;
  final String? imageName;
  final DateTime eventDate;
  final User user;

  Poll({
    required this.id,
    required this.name,
    required this.description,
    this.imageName,
    required this.eventDate,
    required this.user,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageName: json['imageName'],
      eventDate: DateTime.parse(json['eventDate']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageName': imageName,
      'eventDate': eventDate.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
