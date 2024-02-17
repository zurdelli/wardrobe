class User {
  final String id;
  final String name;
  final String email;
  final String image;

  User(
      {required this.name,
      required this.email,
      required this.id,
      required this.image});

  /// Recibe un json y lo convierte a datos
  User.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'] as String,
        email = json['email'] as String,
        id = json['id'] as String,
        image = json['image'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'name': name,
        'email': email,
        'id': id,
        'image': image,
      };
}
