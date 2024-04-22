import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/utilities.dart';
import 'package:toggle_switch/toggle_switch.dart';

class PlaceDateWarranty extends StatefulWidget {
  const PlaceDateWarranty({super.key});

  @override
  State<StatefulWidget> createState() => PlaceDateWarrantyState();
}

class PlaceDateWarrantyState extends State<PlaceDateWarranty> {
  String date = "";
  String storePlace = "";

  final storePlaceController = TextEditingController();
  final dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      date = context.read<ClothesProvider>().date.isEmpty
          ? DateFormat('dd-MM-yyyy').format(DateTime.now())
          : context.read<ClothesProvider>().date;
      storePlace = context.read<ClothesProvider>().storePlace;

      storePlaceController.text = storePlace;
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
              flex: 1,
              child: TextField(
                controller: storePlaceController,
                onTapOutside: (event) =>
                    Provider.of<ClothesProvider>(context, listen: false)
                        .storePlace = storePlaceController.text.trim(),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.near_me),
                  suffixIcon: IconButton(
                    color: Colors.blue,
                    //alignment: Alignment.centerRight,
                    icon: Icon(Icons.gps_fixed),
                    onPressed: () async {
                      storePlaceController.text = await getLocation();
                      context.read<ClothesProvider>().storePlace =
                          storePlaceController.text;
                    },
                  ),
                  labelText: 'Donde fue adquirida',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Garantía"),
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "La garantia será hasta el ${context.read<ClothesProvider>().warranty}"),
          ),
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dateController.dispose();
  }
}
