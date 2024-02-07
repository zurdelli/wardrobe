import 'package:firebase_database/firebase_database.dart';
import 'message_model.dart';

/// Mensaje DATA ACCESS OBJECT. Aqui se hace el CRUD de la base de datos
class MensajeDAO {
  /// Instancia de la base de datos
  final DatabaseReference _mensajesRef =
      FirebaseDatabase.instance.ref().child('mensajes');

  DatabaseReference _mensajeRef(String id) =>
      FirebaseDatabase.instance.ref().child('mensajes/$id');

  /// Save mensaje
  String? guardarMensaje(Mensaje mensaje) {
    DatabaseReference myRef = _mensajesRef.push();
    myRef.set(mensaje.toJson());
    return myRef.key;
  }

  /// Read mensajes
  Query getMensajes() => _mensajesRef;

  /// Delete mensajes
  deleteMensaje(String id) => _mensajeRef(id).remove();

  /// Update mensaje
}
