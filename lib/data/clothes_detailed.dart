/// Representa al model del Clothes
class Clothes {
  final DateTime fecha;
  final String category;
  final String status;
  final String color;
  final String brand;
  final String season;
  final String size;
  final String style;
  final String image;

  Clothes(this.fecha, this.category, this.status, this.color, this.brand,
      this.season, this.size, this.style, this.image);

  /// Recibe un json y lo convierte a fecha y texto
  Clothes.fromJson(Map<dynamic, dynamic> json)
      : fecha = DateTime.parse(json['fecha'] as String),
        category = json['category'] as String,
        status = json['status'] as String,
        color = json['color'] as String,
        brand = json['brand'] as String,
        season = json['season'] as String,
        size = json['size'] as String,
        style = json['style'] as String,
        image = json['image'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'fecha': fecha.toString(),
        'category': category,
        'status': status,
        'color': color,
        'brand': brand,
        'season': season,
        'size': size,
        'style': style,
        'image': image,
      };
}
