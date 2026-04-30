import 'package:json_annotation/json_annotation.dart';

part 'runner.g.dart';

@JsonSerializable()
class Runner {
  final String id;
  final String userId;
  final bool isOnline;
  final double? latitude;
  final double? longitude;

  const Runner({
    required this.id,
    required this.userId,
    required this.isOnline,
    this.latitude,
    this.longitude,
  });

  factory Runner.fromJson(Map<String, dynamic> json) =>
      _$RunnerFromJson(json);

  Map<String, dynamic> toJson() => _$RunnerToJson(this);
}
