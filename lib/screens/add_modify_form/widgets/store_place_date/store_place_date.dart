import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding_package;
import 'package:intl/intl.dart';
import 'package:location/location.dart' as location_package;
import 'package:provider/provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/utilities.dart';

class StoreDatePlace extends StatefulWidget {
  const StoreDatePlace({super.key});

  @override
  State<StatefulWidget> createState() => _StoreDatePlaceState();
}

class _StoreDatePlaceState extends State<StoreDatePlace> {
  String store = "";
  String date = "";
  String place = "";

  final storeController = TextEditingController();
  final placeController = TextEditingController();
  final dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = context.read<ClothesProvider>().store;
      date = context.read<ClothesProvider>().date;
      place = context.read<ClothesProvider>().place;

      storeController.text = store;
      placeController.text = place;
      dateController.text = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // store & date row
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    labelText: "Date"),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.parse(context.read<ClothesProvider>().date),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      dateController.text = formattedDate;
                      Provider.of<ClothesProvider>(context, listen: false)
                          .date = formattedDate;
                    });
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: placeController,
                onTapOutside: (event) =>
                    Provider.of<ClothesProvider>(context, listen: false).place =
                        placeController.text.trim(),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.near_me),
                  suffixIcon: IconButton(
                    color: Colors.blue,
                    //alignment: Alignment.centerRight,
                    icon: Icon(Icons.gps_fixed),
                    onPressed: () async {
                      placeController.text = await getLocation();
                      Provider.of<ClothesProvider>(context, listen: false)
                          .place = placeController.text;
                    },
                  ),
                  labelText: 'Place',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

  /// Obtiene el lugar actual donde se encuentra el usuario a través del paquete
  /// location.
//   Future getLocation() async {
//     location_package.Location location = location_package.Location();

//     bool serviceEnabled;
//     location_package.PermissionStatus permissionGranted;
//     location_package.LocationData locationData;

//     serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         return;
//       }
//     }

//     permissionGranted = await location.hasPermission();
//     if (permissionGranted == location_package.PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != location_package.PermissionStatus.granted) {
//         return;
//       }
//     }

//     locationData = await location.getLocation();

//     //print("La latitud es: ${locationData.latitude}");
//     double latitud = locationData.latitude ?? 0;
//     double longitud = locationData.longitude ?? 0;

//     List<geocoding_package.Placemark> placemarks =
//         await geocoding_package.placemarkFromCoordinates(latitud, longitud);

//     String place = "${placemarks[0].locality}, ${placemarks[0].country}";

//     placeController.text = place;
//     Provider.of<ClothesProvider>(context, listen: false).place = place;
//     //return place;
//   }
// }
