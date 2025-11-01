class Person {
  final int id;
  final int order;
  final String name;
  final String profilePath;
  final String? character; //only actors will have this
  final String? job; //only for the non-actors (other crew involved)

  Person({
    required this.id,
    required this.order,
    required this.name,
    required this.profilePath,
    this.character,
    this.job,
  });

  static Person fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      order: json['order']?? -1,
      name: json['name']?? '',
      profilePath: json['profile_path']?? '',
      character: json['character'],
      job: json['job'],
    );
  }
}