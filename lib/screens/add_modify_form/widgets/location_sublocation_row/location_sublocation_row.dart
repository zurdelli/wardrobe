import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/utilities.dart';

class SublocationRow extends StatefulWidget {
  const SublocationRow({Key? key}) : super(key: key);

  @override
  _SublocationRowState createState() => _SublocationRowState();
}

class _SublocationRowState extends State<SublocationRow> {
  String location = "";
  String sublocation = "";
  var user;
  final locController = TextEditingController();
  final sublocController = TextEditingController();
  late Query ubicacionesQuery;
  late Query subUbicacionesQuery;
  String ubicacionKey = "";

  @override
  void initState() {
    super.initState();
    user = context.read<UserProvider>().currentUser;
    locController.text = location = context.read<ClothesProvider>().place;
    sublocController.text =
        sublocation = context.read<ClothesProvider>().sublocation;

    ubicacionesQuery =
        FirebaseDatabase.instance.ref().child('clothes/$user/Ubicaciones');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            readOnly: true,
            onTap: () => myModal(context,
                gimmeLocations(query: ubicacionesQuery, isUbicacion: true)),
            onTapOutside: (event) => context.read<ClothesProvider>().place =
                locController.text.trim(),
            controller: locController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Ubicación'),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 3,
          child: TextFormField(
            readOnly: true,
            onTap: () {
              locController.text.isEmpty
                  ? mySnackBar(
                      context, "Debe seleccionar primero una ubicación")
                  : myModal(
                      context,
                      gimmeLocations(
                          query: subUbicacionesQuery, isUbicacion: false));
            },
            onTapOutside: (event) => context
                .read<ClothesProvider>()
                .sublocation = sublocController.text.trim(),
            controller: sublocController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Sub-ubicación'),
          ),
        ),
      ],
    );
  }

  Widget gimmeLocations({required Query query, required bool isUbicacion}) {
    Offset _tapPosition = Offset.zero;
    void _getTapPosition(TapDownDetails tapPosition) {
      final RenderBox referenceBox = context.findRenderObject() as RenderBox;
      setState(() => _tapPosition =
          referenceBox.globalToLocal(tapPosition.globalPosition));
    }

    void _showContextMenu(
        BuildContext context, String location, String key) async {
      final RenderObject? overlay =
          Overlay.of(context).context.findRenderObject();

      final result = await showMenu(
          context: context,
          position: RelativeRect.fromRect(
              Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 100, 100),
              Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                  overlay.paintBounds.size.height)),
          items: [
            const PopupMenuItem(
              value: "editar",
              child: Text('Editar'),
            ),
            const PopupMenuItem(
              value: "borrar",
              child: Text('Borrar'),
            )
          ]);
      switch (result) {
        case 'editar': // SI QUIERE EDITAR LA UBICACION
          addOrEditLocation(
              location, key, isUbicacion, isUbicacion ? "" : ubicacionKey);
          break;
        case 'borrar':
          print('borrar');
          Navigator.pop(context);
          break;
      }
    }

    return Column(
      children: [
        FirebaseAnimatedList(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          query: query,
          itemBuilder: (context, snapshot, animation, index) {
            final json = snapshot.value as Map<dynamic, dynamic>;
            final ubicacion = json['ubicacion'] as String;
            final key = snapshot.key;
            return GestureDetector(
              onTapDown: (position) => {_getTapPosition(position)},
              onTap: () {
                if (isUbicacion) {
                  locController.text = ubicacion;
                  Navigator.of(context).pop();
                  subUbicacionesQuery = FirebaseDatabase.instance
                      .ref()
                      .child('clothes/$user/Ubicaciones/$key/Sububicaciones');
                  ubicacionKey = key!;
                } else {
                  sublocController.text = ubicacion;
                }
              },
              onLongPress: () => {_showContextMenu(context, ubicacion, key!)},
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  ubicacion,
                  style: TextStyle(fontSize: 18, color: Colors.amber[700]),
                ),
              )),
            );
          },
        ),
        Divider(),
        TextButton(
            onPressed: () => addOrEditLocation(
                "", "", isUbicacion, isUbicacion ? "" : ubicacionKey),
            child: const Text(
              "Añadir",
              textScaleFactor: 1.1,
            ))
      ],
    );
  }

  addOrEditLocation(
      String location, String key, bool isUbicacion, String ubicacionKey) {
    TextEditingController locationController = TextEditingController();
    locationController.text = location;
    showDialog(
        context: context,
        builder: (BuildContext context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              // ignore: prefer_const_constructors
              child: AlertDialog(
                title: const Text("Añadir ubicación favorita"),
                shape: LinearBorder(),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Ubicación'),
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Aceptar'),
                    onPressed: () {
                      DatabaseReference myRef;
                      if (location.isEmpty) {
                        myRef = isUbicacion
                            ? FirebaseDatabase.instance
                                .ref()
                                .child('clothes/$user/Ubicaciones')
                                .push()
                            : FirebaseDatabase.instance
                                .ref()
                                .child(
                                    'clothes/$user/Ubicaciones/$ubicacionKey/Sububicaciones')
                                .push();
                      } else {
                        myRef = isUbicacion
                            ? FirebaseDatabase.instance
                                .ref()
                                .child('clothes/$user/Ubicaciones/$key')
                            : FirebaseDatabase.instance.ref().child(
                                'clothes/$user/Ubicaciones/$ubicacionKey/Sububicaciones/$key');
                      }
                      myRef.set(<String, String>{
                        'ubicacion': locationController.text
                      });
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ));
  }

  String getKeyFromLocation(String location) {
    var myRef = FirebaseDatabase.instance
        .ref()
        .child('clothes/$user/Ubicaciones')
        .orderByChild('ubicacion')
        .equalTo(location)
        .get();
    return "hh";
  }

  @override
  void dispose() {
    super.dispose();
    locController.dispose();
    sublocController.dispose();
  }
}
