import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geocoding/geocoding.dart' as geocoding_package;
import 'package:location/location.dart' as location_package;

/// Translates color <-> string
String colorToString(Color color) {
  //print("el color es: $color");
  if (color == Colors.red) {
    return "Red";
  } else if (color == Colors.purple) {
    return "Purple";
  } else if (color == Colors.indigo) {
    return "Blue";
  } else if (color == Colors.lightBlue) {
    return "LightBlue";
  } else if (color == Colors.green) {
    return "Green";
  } else if (color == Colors.yellow) {
    return "Yellow";
  } else if (color == Colors.amber) {
    return "Gold";
  } else if (color == Colors.orange) {
    return "Orange";
  } else if (color == Colors.brown) {
    return "Brown";
  } else if (color == Colors.white) {
    return "White";
  } else if (color == Colors.grey) {
    return "Grey";
  } else if (color == Color.fromARGB(255, 255, 101, 153)) {
    return "Pink";
  } else if (color == Color.fromARGB(255, 232, 195, 158)) {
    return "Beige";
  } else if (color == Colors.black) {
    return "Black";
  } else {
    return "";
  }
}

/// Translates color <-> string
Color stringToColor(String color) {
  if (color == "Red") {
    return Colors.red;
  } else if (color == "Purple") {
    return Colors.purple;
  } else if (color == "Blue") {
    return Colors.indigo;
  } else if (color == "LightBlue") {
    return Colors.lightBlue;
  } else if (color == "Green") {
    return Colors.green;
  } else if (color == "Yellow") {
    return Colors.yellow;
  } else if (color == "Gold") {
    return Colors.amber;
  } else if (color == "Orange") {
    return Colors.orange;
  } else if (color == "Brown") {
    return Colors.brown;
  } else if (color == "White") {
    return Colors.white;
  } else if (color == "Grey") {
    return Colors.grey;
  } else if (color == "Pink") {
    return Color.fromARGB(255, 255, 101, 153);
  } else if (color == "Beige") {
    return Color.fromARGB(255, 232, 195, 158);
  } else if (color == "Black") {
    return Colors.black;
  } else {
    return Colors.transparent;
  }
}

String countryCodeToEmoji(String countryCode) {
  // 0x41 is Letter A
  // 0x1F1E6 is Regional Indicator Symbol Letter A
  // Example :
  // firstLetter U => 20 + 0x1F1E6
  // secondLetter S => 18 + 0x1F1E6
  // See: https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
  final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
  final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
  return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
}

List<Color> colors = [
  Color.fromARGB(255, 255, 101, 153),
  Colors.red,
  Colors.purple,
  Colors.indigo,
  Colors.lightBlue,
  Colors.green,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.brown,
  Color.fromARGB(255, 232, 195, 158),
  Colors.white,
  Colors.grey,
  Colors.black,
];

const List<String> categoriesListTipos = <String>[
  'Camisetas',
  'Sudaderas',
  'Camisas',
  'Pantalones',
  'Chaquetas',
  'Abrigos',
  'Vestidos',
  'Ropa deportiva',
  'Ropa interior',
  'Ropa de baño',
  'Ropa de casa',
  'Zapatillas'
];

const List<String> sizesListClothes = <String>[
  '',
  'XXS',
  'XS',
  'S',
  'M',
  'L',
  'XL',
  'XXL',
];

const List<String> sizesListShoes = <String>[
  '',
  '36',
  '36.5',
  '37',
  '37.5',
  '38',
  '38.5',
  '39',
  '39.5',
  '40',
  '40.5',
  '41',
  '41.5',
  '42',
  '42.5',
  '43',
  '43.5',
  '44',
  '44.5',
  '45',
  '45.5',
  '46',
  '46.5',
  '47',
  '47.5',
  '48',
  '48.5',
  '49',
  '49.5',
  '50',
  '50.5'
];

const List<String> categoriesListImages = <String>[
  'assets/images/camisetas.png',
  'assets/images/sudaderas.png',
  'assets/images/camisas.png',
  'assets/images/pantalones.png',
  'assets/images/chaquetas.png',
  'assets/images/abrigos.png',
  'assets/images/vestidos.png',
  'assets/images/ropadeportiva.png',
  'assets/images/ropainterior.png',
  'assets/images/ropadebano.png',
  'assets/images/pantalonescortos.png',
  'assets/images/zapatillas.png',
];

/// Constituye un propio mensaje de dialog asi no se tiene que estar escribiendo constantemente
myDialog(
    BuildContext context, String titulo, Widget content, Function() onPressed) {
  showDialog(
    context: context,
    builder: (BuildContext context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      // ignore: prefer_const_constructors
      child: AlertDialog(
        title: Text(titulo),
        shape: LinearBorder(),
        content: content,
        actions: <Widget>[
          TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop()),
          TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                onPressed();
                Navigator.of(context).pop();
              }),
        ],
      ),
    ),
  );
}

myModal(BuildContext context, Widget child) {
  showModalBottomSheet(
      context: context,
      enableDrag: true,
      //isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (ctx) => StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return DraggableScrollableSheet(
                initialChildSize: 0.8,
                maxChildSize: 1,
                minChildSize: 0.28,
                expand: false,
                builder: ((context, scrollController) => Padding(
                    padding: const EdgeInsets.all(10.0), child: child)));
          }));
}

mySnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
    showCloseIcon: true,
    duration: const Duration(seconds: 3),
  ));
}

/// Widget de apoyo para seleccionar colores
Widget pickerLayoutBuilder(
    BuildContext context, List<Color> colors, PickerItem child) {
  //Orientation orientation = MediaQuery.of(context).orientation;

  return SizedBox(
    width: 300,
    //height: orientation == Orientation.portrait ? 360 : 240,
    height: 280,
    child: GridView.count(
      //crossAxisCount: orientation == Orientation.portrait ? 3 : 4,
      crossAxisCount: 4,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      children: [for (Color color in colors) child(color)],
    ),
  );
}

/// Widget de apoyo para seleccionar colores
Widget pickerItemBuilder(
    Color color, bool isCurrentColor, void Function() changeColor) {
  return Container(
    margin: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: color,
      boxShadow: [
        BoxShadow(
            color: color.withOpacity(0.8),
            offset: const Offset(1, 2),
            blurRadius: 5)
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: changeColor,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isCurrentColor ? 1 : 0,
          child: Icon(
            Icons.done,
            size: 24,
            color: useWhiteForeground(color) ? Colors.white : Colors.black,
          ),
        ),
      ),
    ),
  );
}

/// Obtiene la ubicación automáticamente siempre que obtenga los permisos
Future<String> getLocation() async {
  location_package.Location location = location_package.Location();

  bool serviceEnabled;
  location_package.PermissionStatus permissionGranted;
  location_package.LocationData locationData;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return "";
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == location_package.PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != location_package.PermissionStatus.granted) {
      return "";
    }
  }

  locationData = await location.getLocation();

  //print("La latitud es: ${locationData.latitude}");
  double latitud = locationData.latitude ?? 0;
  double longitud = locationData.longitude ?? 0;

  List<geocoding_package.Placemark> placemarks =
      await geocoding_package.placemarkFromCoordinates(latitud, longitud);

  String place = "${placemarks[0].locality}, ${placemarks[0].country}";

  return place;
}

String toEnglishDate(String spanishDate) =>
    "${spanishDate.substring(6, 10)}-${spanishDate.substring(3, 5)}-${spanishDate.substring(0, 2)}";
