import '../../interface/sample_interface.dart';

class JsonSerializableModelSample extends Sample {
  JsonSerializableModelSample({String path = 'lib/app/models/app_user.dart'})
      : super(path, overwrite: true);

  @override
  String get content =>
      '''import 'package:json_annotation/json_annotation.dart';

part 'app_user.g.dart';

@JsonSerializable()
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _\$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _\$AppUserToJson(this);
}
''';
}
