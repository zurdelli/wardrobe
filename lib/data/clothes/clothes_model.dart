/// Representa al model del Clothes
class Clothes {
  final String brand;
  final String color;
  final String date;
  final bool hasBeenLent;
  final String holder;
  final String image;
  final String owner;
  final String place;
  final String size;
  //final String status;
  final String store;
  final String sublocation;
  final String warranty;
  final String website;

  Clothes(
      {required this.sublocation,
      required this.brand,
      required this.color,
      //required this.status,
      required this.size,
      required this.place,
      required this.date,
      required this.store,
      required this.warranty,
      required this.image,
      required this.hasBeenLent,
      required this.owner,
      required this.holder,
      required this.website});

  /// Recibe un json y lo convierte a datos de las prendas
  Clothes.fromJson(Map<dynamic, dynamic> json)
      : sublocation = json['sublocation'] as String,
        brand = json['brand'] as String,
        color = json['color'] as String,
        //status = json['status'] as String,
        size = json['size'] as String,
        place = json['place'] as String,
        date = json['date'] as String,
        store = json['store'] as String,
        warranty = json['warranty'] as String,
        image = json['image'] as String,
        hasBeenLent = json['hasBeenLent'] as bool,
        owner = json['owner'] as String,
        holder = json['holder'] as String,
        website = json['website'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'sublocation': sublocation,
        'brand': brand,
        'color': color,
        //'status': status,
        'size': size,
        'place': place,
        'date': date,
        'store': store,
        'warranty': warranty,
        'image': image,
        'hasBeenLent': hasBeenLent,
        'owner': owner,
        'holder': holder,
        'website': website,
      };
}
