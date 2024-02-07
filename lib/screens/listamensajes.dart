import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:wardrobe/data/mensaje_dao.dart';
import 'package:wardrobe/data/message_model.dart';
import 'package:wardrobe/widgets/mensajewidget.dart';

/// Clase copiada de otro proyecto - Representa la lista de mensajes mostrados
/// en la pantalla principal
class ListaMensajes extends StatefulWidget {
  ListaMensajes({Key? key}) : super(key: key);
  final mensajeDAO = MensajeDAO();

  @override
  ListaMensajesState createState() => ListaMensajesState();
}

class ListaMensajesState extends State<ListaMensajes> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _mensajeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollHaciaAbajo());

    return Scaffold(
        appBar: AppBar(title: const Text('Ejemplo Chat')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              _getListaMensajes(),
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

  void _enviarMensaje() {
    if (_puedoEnviarMensaje()) {
      final mensaje = Mensaje(_mensajeController.text, DateTime.now());
      print(widget.mensajeDAO.guardarMensaje(mensaje));
      _mensajeController.clear();
      setState(() {});
    }
  }

  bool _puedoEnviarMensaje() => _mensajeController.text.isNotEmpty;

  Widget _getListaMensajes() {
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

  /// Scroll hasta el fondo de los mensajes
  _scrollHaciaAbajo() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
