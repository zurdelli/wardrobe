import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wardrobe/data/clothes_dao.dart';

/// Representa al widget mostrado en la home donde se visualiza cada prenda por
/// separado
class ClothesWidget extends StatelessWidget {
  final String marca, fecha;

  String? messagekey;

  ClothesWidget(this.marca, this.fecha, this.messagekey, {super.key});

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
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.amber,
                  radius: 30.0,
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    children: [
                      Align(alignment: Alignment.topLeft, child: Text(marca)),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text("Estado: Muy bueno")),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          fecha.substring(0, 10),
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
}
