/// Representa al model del Clothes
class Clothes {
  final String date;
  //final String category;
  final String subcategory;
  final String status;
  final String color;
  final String brand;
  final String size;
  final String place;
  final String store;
  final int warranty;
  final String image;

  Clothes(
      {required this.subcategory,
      required this.brand,
      required this.color,
      required this.status,
      required this.size,
      required this.place,
      required this.date,
      required this.store,
      required this.warranty,
      required this.image});

  /// Recibe un json y lo convierte a datos de las prendas
  Clothes.fromJson(Map<dynamic, dynamic> json)
      : subcategory = json['subcategory'] as String,
        brand = json['brand'] as String,
        color = json['color'] as String,
        status = json['status'] as String,
        size = json['size'] as String,
        place = json['place'] as String,
        date = json['date'] as String,
        store = json['store'] as String,
        warranty = json['warranty'] as int,
        image = json['image'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'subcategory': subcategory,
        'brand': brand,
        'color': color,
        'status': status,
        'size': size,
        'place': place,
        'date': date,
        'store': store,
        'warranty': warranty,
        'image': image,
      };
}
