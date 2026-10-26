class Category {
  final String id;
  final String name;
  final String? description;

  const Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}

class Country {
  final String code;
  final String name;
  final List<String> languages;
  final String flag;

  const Country({
    required this.code,
    required this.name,
    this.languages = const [],
    this.flag = '',
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        languages: (json['languages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        flag: json['flag']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'languages': languages,
        'flag': flag,
      };
}

class Language {
  final String code;
  final String name;

  const Language({
    required this.code,
    required this.name,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
      };
}
