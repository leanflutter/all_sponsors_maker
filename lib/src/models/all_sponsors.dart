import 'entity.dart';

class AllSponsors {
  final String name;
  final String description;
  final List<Entity> entities;

  AllSponsors({
    required this.name,
    required this.description,
    required this.entities,
  });

  factory AllSponsors.fromJson(Map<String, dynamic> json) {
    List<Entity> entities = (json['entities'] as List)
        .map((item) => Entity.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return AllSponsors(
      name: json['name'],
      description: json['description'],
      entities: entities,
    );
  }

  factory AllSponsors.fromYaml(dynamic yaml) {
    return AllSponsors.fromJson(Map<String, dynamic>.from(yaml));
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'entities': entities.map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}
