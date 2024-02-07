/// Representa al model del mensaje
class Mensaje {
  final String texto;
  final DateTime fecha;

  Mensaje(this.texto, this.fecha);

  /// Recibe un json y lo convierte a fecha y texto
  Mensaje.fromJson(Map<dynamic, dynamic> json)
      : fecha = DateTime.parse(json['fecha'] as String),
        texto = json['texto'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'fecha': fecha.toString(),
        'texto': texto,
      };
}
