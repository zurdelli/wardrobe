import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:wardrobe/data/mensaje_dao.dart';
import 'package:wardrobe/data/message.dart';
import 'package:wardrobe/widgets/mensajewidget.dart';

class MyWardrobe extends StatefulWidget {
  MyWardrobe({Key? key}) : super(key: key);

  final mensajeDAO = MensajeDAO();

  @override
  MyWardrobeState createState() => MyWardrobeState();
}

class MyWardrobeState extends State<MyWardrobe> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _mensajeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
        appBar: AppBar(title: const Text('Ejemplo Chat')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              _getMyWardrobe(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                            keyboardType: TextInputType.text,
                            controller: _mensajeController,
                            onChanged: (text) => setState(() {}),
                            onSubmitted: (input) {
                              _enviarMensaje();
                            },
                            decoration: const InputDecoration(
                                hintText: 'Escribe un mensaje')))),
                IconButton(
                    icon: Icon(_puedoEnviarMensaje()
                        ? CupertinoIcons.arrow_right_circle_fill
                        : CupertinoIcons.arrow_right_circle),
                    onPressed: () {
                      _enviarMensaje();
                    })
              ]),
            ])));
  }


  Widget _getMyWardrobe() {
    return Expanded(
        child: FirebaseAnimatedList(
      controller: _scrollController,
      query: widget.mensajeDAO.getMensajes(),
      itemBuilder: (context, snapshot, animation, index) {
        final json = snapshot.value as Map<dynamic, dynamic>;
        final mensaje = Mensaje.fromJson(json);
        return MensajeWidget(mensaje.texto, mensaje.fecha, snapshot.key);
      },
    ));
  }

}
