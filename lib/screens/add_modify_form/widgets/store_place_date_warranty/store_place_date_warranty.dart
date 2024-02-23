import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/utilities.dart';
import 'package:toggle_switch/toggle_switch.dart';

class StoreDatePlaceWarranty extends StatefulWidget {
  const StoreDatePlaceWarranty({super.key});

  @override
  State<StatefulWidget> createState() => _StoreDatePlaceState();
}

class _StoreDatePlaceState extends State<StoreDatePlaceWarranty> {
  String store = "";
  String date = "";
  String place = "";
  String warranty = "";

  final storeController = TextEditingController();
  final placeController = TextEditingController();
  final dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = context.read<ClothesProvider>().store;
      date = context.read<ClothesProvider>().date.isEmpty
          ? DateFormat('dd-MM-yyyy').format(DateTime.now())
          : context.read<ClothesProvider>().date;
      place = context.read<ClothesProvider>().place;

      storeController.text = store;
      placeController.text = place;
      dateController.text = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: storeController,
                onTapOutside: (event) => context.read<ClothesProvider>().store =
                    storeController.text.trim(),
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                  labelText: 'Tienda',
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: dateController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    labelText: "Fecha"),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(toEnglishDate(date)),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('dd-MM-yyyy').format(pickedDate);
                    setState(() {
                      dateController.text = formattedDate;
                      context.read<ClothesProvider>().date = formattedDate;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 3,
              child: TextField(
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
                      context.read<ClothesProvider>().place =
                          placeController.text;
                    },
                  ),
                  labelText: 'Donde fue adquirida',
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            ToggleSwitch(
              customWidths: [90.0, 50.0],
              cornerRadius: 20.0,
              activeBgColors: [
                [Colors.green],
                [Colors.redAccent]
              ],
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              labels: ['Sí', ''],
              icons: [null, Icons.close],
              initialLabelIndex:
                  context.read<ClothesProvider>().warranty.isEmpty ||
                          DateTime.now().isAfter(DateTime.parse(toEnglishDate(
                              context.read<ClothesProvider>().warranty)))
                      ? 1
                      : 0,
              onToggle: (index) {
                if (index == 0) {
                  TextEditingController myController = TextEditingController();
                  Widget myTextField = TextField(
                    autofocus: true,
                    controller: myController,
                    keyboardType: TextInputType.number,
                  );
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      // ignore: prefer_const_constructors
                      child: AlertDialog(
                        title: Text("¿Cuantos días de garantía?"),
                        shape: LinearBorder(),
                        content: myTextField,
                        actions: <Widget>[
                          TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () => Navigator.of(context).pop()),
                          TextButton(
                              child: const Text('Aceptar'),
                              onPressed: () {
                                if (myController.text.isNotEmpty) {
                                  saveWarrantyDate(
                                      int.parse(myController.text));
                                }
                                Navigator.of(context).pop();
                              }),
                        ],
                      ),
                    ),
                  );
                } else {
                  context.read<ClothesProvider>().warranty = "";
                  setState(() {});
                }
              },
            ),
          ],
        ),
        Offstage(
          offstage: context.read<ClothesProvider>().warranty.isEmpty ||
              DateTime.now().isAfter(DateTime.parse(
                  toEnglishDate(context.read<ClothesProvider>().warranty))),
          child: Text(
              "La garantia será hasta el ${context.read<ClothesProvider>().warranty}"),
        )
      ],
    );
  }

  saveWarrantyDate(int days) {
    var warrantyDate = DateTime.now().add(Duration(days: days));
    var warrantyString = DateFormat('dd-MM-yyyy').format(warrantyDate);
    context.read<ClothesProvider>().warranty = warrantyString;
    setState(() {});
  }

  String toEnglishDate(String spanishDate) =>
      "${spanishDate.substring(6, 10)}-${spanishDate.substring(3, 5)}-${spanishDate.substring(0, 2)}";
}
