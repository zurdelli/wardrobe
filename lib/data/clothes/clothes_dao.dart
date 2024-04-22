import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'clothes_model.dart';

/// clothes DATA ACCESS OBJECT. Aqui se hace el CRUD de la base de datos
class ClothesDAO {
  /// Instancia de la base de datos
  // final DatabaseReference _clothesRef =
  //     FirebaseDatabase.instance.ref().child('clothes');

  DatabaseReference _singleClothesRef(String userid, String category) =>
      FirebaseDatabase.instance.ref().child('clothes/$userid/$category');

  /// Add or update clothes
  String? guardarClothes(
      Clothes clothes, DatabaseReference clothesRef, String key) {
    DatabaseReference myRef =
        key == "null" ? clothesRef.push() : clothesRef.child(key);

    myRef.set(clothes.toJson());
    return myRef.key;
  }

  String? updateWarranty(DatabaseReference clothesRef, String warranty) {
    clothesRef.update({"warranty": warranty});
  }

  deleteClothes(
          {required String category,
          required String userid,
          required String clothesid}) =>
      _singleClothesRef(userid, category).child(clothesid).remove();

  /// Prestar a un amigo
  lentToFromSomeFriend(
      {required String toWhomeID,
      required bool borrowed,
      required String userid,
      required String clothesid,
      required String category,
      required String toWhomeEmail}) {
    // hasbeenLent: true
    FirebaseDatabase.instance
        .ref()
        .child('clothes/$userid/$category/$clothesid')
        .update({"hasBeenLent": borrowed, "holder": toWhomeEmail});

    /// Si el usuario de destino es un usuario de la app, copia esa prenda
    /// al otro usuario
    if (toWhomeID.isNotEmpty) {
      DatabaseReference fromPath = FirebaseDatabase.instance
          .ref()
          .child('clothes/$userid/$category/$clothesid');
      DatabaseReference toPath =
          FirebaseDatabase.instance.ref().child('clothes/$toWhomeID/$category');
      copyRecord(fromPath, toPath);
    }
  }

  //Recupera/devuelve la prenda
  backFromFriend(
      {required bool borrowed,
      required String userid,
      required String clothesid,
      required String category,
      required String toWhomeEmail}) async {
    FirebaseDatabase.instance
        .ref()
        .child('clothes/$userid/$category/$clothesid')
        .update({
      "hasBeenLent": borrowed,
      "holder": FirebaseAuth.instance.currentUser!.email
    });

    // Para eliminarla de la coleccion del amigo
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users');
    final event = await dbRef
        .orderByChild("email")
        .equalTo(toWhomeEmail)
        .once(DatabaseEventType.value);

    if (event.snapshot.exists) {
      final userID = event.snapshot.children.first.child('id').value;

      //Busco la prenda en el destino
      DatabaseReference dbRef =
          FirebaseDatabase.instance.ref().child('clothes/$userID/$category');

      //Debería tener el mismo id? O como localizarla correctamente (?)
    } else {
      print(toWhomeEmail);
    }
  }

  /// Copia un valor de un nodo original a otro
  copyRecord(DatabaseReference fromPath, final DatabaseReference toPath) async {
    final event = await fromPath.once(DatabaseEventType.value);
    final data = event.snapshot.value ?? "";
    if (data.toString().isNotEmpty) {
      DatabaseReference myKey = toPath.push();
      myKey.set(data);
    }
  }

  /// Cuenta el numero de hijos de un nodo, para contar la cantidad de ropa
  Future<int> countChildren(DatabaseReference fromPath) async {
    final event = await fromPath.once(DatabaseEventType.value);
    return event.snapshot.children.length;
  }
}
