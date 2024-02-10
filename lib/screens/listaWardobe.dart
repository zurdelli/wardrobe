import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:wardrobe/data/clothes_model.dart';
import 'package:wardrobe/data/mensaje_dao.dart';
import 'package:wardrobe/data/message_model.dart';
import 'package:wardrobe/screens/home/widgets/clothes_widget.dart';
import 'package:wardrobe/screens/home/widgets/mensajewidget.dart';

/// Clase copiada de otro proyecto - Representa la lista de mensajes mostrados
/// en la pantalla principal
class ListaWardrobe extends StatefulWidget {
  ListaWardrobe({Key? key}) : super(key: key);

  //final mensajeDAO = MensajeDAO();

  @override
  ListaWardrobeState createState() => ListaWardrobeState();
}

class ListaWardrobeState extends State<ListaWardrobe> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _mensajeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Ejemplo')),
        body: Column(children: [
          Expanded(
              child: FirebaseAnimatedList(
            controller: _scrollController,
            query: ModalRoute.of(context)!.settings.arguments as Query,
            itemBuilder: (context, snapshot, animation, index) {
              final json = snapshot.value as Map<dynamic, dynamic>;
              final prenda = Clothes.fromJson(json);
              return ClothesWidget(prenda.brand, prenda.date, snapshot.key);
            },
          )),
        ]));
  }
}
