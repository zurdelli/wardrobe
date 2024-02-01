import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wardrobe/data/mensaje_dao.dart';
import 'package:wardrobe/data/message.dart';

class MensajeWidget extends StatelessWidget {
  final String texto;
  final DateTime fecha;
  String? messagekey;

  MensajeWidget(this.texto, this.fecha, this.messagekey, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.grey[350]!,
                blurRadius: 2.0,
                offset: const Offset(0, 1.0))
          ], borderRadius: BorderRadius.circular(50.0), color: Colors.white),
          child: MaterialButton(
              disabledTextColor: Colors.black87,
              padding: const EdgeInsets.only(left: 18),
              onPressed: () => MensajeDAO().deleteMensaje(messagekey ?? "nada"),
              child: Row(
                children: [
                  Text(texto),
                ],
              ))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Align(
              alignment: Alignment.topRight,
              child: Text(
                  DateFormat('kk:mm, dd-MM-yyyy').format(fecha).toString(),
                  style: const TextStyle(color: Colors.grey))))
    ]);
  }
}
