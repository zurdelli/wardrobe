import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wardrobe/data/clothes_dao.dart';
import 'package:wardrobe/data/clothes_model.dart';

/// Representa al widget mostrado en la home donde se visualiza cada prenda por
/// separado
class ClothesWidget extends StatelessWidget {
  final Clothes clothes;
  //final String? nodeKey;
  //final String marca, fecha, imagen;

  //String? messagekey;

  const ClothesWidget({super.key, required this.clothes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.grey[350]!,
            blurRadius: 2.0,
            offset: const Offset(0, 1.0))
      ], borderRadius: BorderRadius.circular(5.0), color: Colors.white),
      child: MaterialButton(
        disabledTextColor: Colors.black87,
        padding: const EdgeInsets.all(10),
        onPressed: () {
          //todo abrir un dialog con más información
          openDialogMoreInfo(context);
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundImage: MemoryImage(base64Decode(clothes.image)),
                  radius: 30.0,
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(clothes.brand)),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text("Estado: Muy bueno")),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          clothes.date.substring(0, 10),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  openDialogMoreInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
                child: Image.memory(
                  base64Decode(clothes.image),
                  //radius: 250,
                ),
              ),
              Row(
                children: [
                  Text.rich(TextSpan(text: "${clothes.brand} ", children: [
                    TextSpan(text: clothes.date),
                  ]))
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pushNamed(
                            context, "/formclothes",
                            arguments: clothes)
                        // Necesario para el reload de la listview
                        .then((_) {}),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.swap_horizontal_circle_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.abc),
                  ),
                ],
              )
            ],
          )),
        ),
      ),
    );
  }

  modifyClothes(BuildContext context) {
    Navigator.pushNamed(context, "/formclothes", arguments: clothes)
        // Necesario para el reload de la listview
        .then((_) {});
  }
}
