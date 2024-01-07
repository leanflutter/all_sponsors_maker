class Entity {
  String name;
  String? homepage;
  String? description;
  String? github_id;
  String? image_url;

  Entity({
    required this.name,
    this.homepage,
    this.description,
    this.github_id,
    this.image_url,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      name: json['name'] ?? json['github_id'],
      homepage: json['homepage'],
      description: json['description'],
      github_id: json['github_id'],
      image_url: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'homepage': homepage,
      'description': description,
      'github_id': github_id,
      'image_url': image_url,
    }..removeWhere((key, value) => value == null);
  }
}
